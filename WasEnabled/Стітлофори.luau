--[=[
	Головний серверний скрипт для керування системою залізничних світлофорів.
	
	ВЕРСІЯ 5.2 - ОСТАТОЧНА:
	- Видалено всі діагностичні повідомлення.
	- Додано обробку раптового видалення поїзда з гри.
	- Гарантоване створення та ініціалізація атрибутів SignalCode та IsManualOverride.
	- Коректне початкове відображення стану світлофорів.
	- Логіка пріоритету - дотик потяга завжди переважає ручне керування,
	  скидаючи ManualOverride.
	- OnServerEvent обробляється у кожному ControlPanelScript (як в оригіналі).
]=]

local CollectionService = game:GetService("CollectionService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage") 

local TrafficLightClass = require(ServerScriptService.Sevak.Classes.TrainTrafficLightClass)
local AUTONOMOUS_RESET_TIME = 15 -- Час в секундах для скидання автономного світлофора

local occupiedTrains = {} 
local validSignalCodes = {["Red"] = true, ["Yellow"] = true, ["Blue"] = true} 

local changeSignalEvent = ReplicatedStorage:FindFirstChild("ChangeSignalEvent")
if not changeSignalEvent then
	changeSignalEvent = Instance.new("RemoteEvent")
	changeSignalEvent.Name = "ChangeSignalEvent"
	changeSignalEvent.Parent = ReplicatedStorage
end

-- ================================================
--          ОСНОВНИЙ ЦИКЛ ІНІЦІАЛІЗАЦІЯ СВІТЛОФОРІВ
-- ================================================
for _, signalModel in CollectionService:GetTagged("TrainTrafficSignal") do

	-- Гарантуємо, що атрибут SignalCode існує і має дійсне значення
	local currentSignalCode = signalModel:GetAttribute("SignalCode")
	if not currentSignalCode or not validSignalCodes[currentSignalCode] then
		signalModel:SetAttribute("SignalCode", "Blue") 
	end
	-- Атрибут для ручного керування. Скидається при дотику потяга.
	if not signalModel:GetAttribute("IsManualOverride") then
		signalModel:SetAttribute("IsManualOverride", false) 
	end

	local signalClass = TrafficLightClass.new(signalModel)
	if not signalClass then 
		continue -- Якщо клас не вдалося створити, просто ігноруємо цю модель
	end

	local nextSignalModel = signalClass.NextSignal
	local nextKorobkaModel = signalClass.NextKorobka

	-- Функція для скидання світлофора в його "вільний" стан
	local function resetSignalToBlue(currentSignalModel)
		local train = nil
		for t, s in pairs(occupiedTrains) do
			if s == currentSignalModel then
				train = t
				break
			end
		end
		if train then
			occupiedTrains[train] = nil 
		end
		currentSignalModel:SetAttribute("SignalCode", "Blue")
		currentSignalModel:SetAttribute("IsManualOverride", false) 
	end

	-- Логіка спрацьовування світлофора при дотику поїзда (завжди пріоритетна)
	signalClass.SignalPassDetector.Touched:Connect(function(otherPart)
		local trainModel = otherPart:FindFirstAncestorOfClass("Model")
		if trainModel and trainModel:FindFirstChild("SignalContactor") then
			if occupiedTrains[trainModel] and occupiedTrains[trainModel] ~= signalModel then 
				return 
			end

			occupiedTrains[trainModel] = signalModel
			signalModel:SetAttribute("SignalCode", "Red")
			signalModel:SetAttribute("IsManualOverride", false) 

			trainModel.AncestryChanged:Once(function()
				if occupiedTrains[trainModel] == signalModel then 
					resetSignalToBlue(signalModel) 
				end
			end)
		end
	end)

	-- ===================================================================
	-- Сценарій 1: Повноцінна чотириаспектна логіка
	-- ===================================================================
	if nextKorobkaModel and nextSignalModel then
		local korobkaDetector = nextKorobkaModel:FindFirstChild("Detector") 
			or nextKorobkaModel:FindFirstChild("KorobkaDetector")
			or nextKorobkaModel:FindFirstChild("PassDetector")

		local nextSignalDetector = nextSignalModel:FindFirstChild("SignalPassDetector")
			or nextSignalModel:FindFirstChild("Detector")
			or nextSignalModel:FindFirstChild("PassDetector")

		if korobkaDetector and nextSignalDetector then
			korobkaDetector.Touched:Connect(function(otherPart)
				local trainModel = otherPart:FindFirstAncestorOfClass("Model")
				if trainModel and occupiedTrains[trainModel] == signalModel then
					if signalModel:GetAttribute("SignalCode") ~= "Yellow" and signalModel:GetAttribute("SignalCode") ~= "Blue" 
						and not signalModel:GetAttribute("IsManualOverride") then 
						signalModel:SetAttribute("SignalCode", "Yellow")
					end
				end
			end)

			nextSignalDetector.Touched:Connect(function(otherPart)
				local trainModel = otherPart:FindFirstAncestorOfClass("Model")
				if trainModel and occupiedTrains[trainModel] == signalModel then
					resetSignalToBlue(signalModel) 
				end
			end)
		end -- Немає warn, якщо детектори не знайдені
		-- ===================================================================
		-- Сценарій 2: Проста трьохаспектна логіка
		-- ===================================================================
	elseif nextSignalModel then
		nextSignalModel:GetAttributeChangedSignal("SignalCode"):Connect(function()
			if not signalModel:GetAttribute("IsManualOverride") and signalModel:GetAttribute("SignalCode") ~= "Red" then
				local nextSignalCode = nextSignalModel:GetAttribute("SignalCode")

				if nextSignalCode == "Red" and signalModel:GetAttribute("SignalCode") == "Blue" then
					signalModel:SetAttribute("SignalCode", "Yellow")
				elseif nextSignalCode ~= "Red" and (nextSignalModel:GetAttribute("SignalCode") ~= "Red" or occupiedTrains[nextSignalModel] == nil) then
					resetSignalToBlue(signalModel) 
				end
			end
		end)

		local nextSignalDetector = nextSignalModel:FindFirstChild("SignalPassDetector")
			or nextSignalModel:FindFirstChild("Detector")
			or nextSignalModel:FindFirstChild("PassDetector")

		if nextSignalDetector then
			nextSignalDetector.Touched:Connect(function(otherPart)
				local trainModel = otherPart:FindFirstAncestorOfClass("Model")
				if trainModel and occupiedTrains[trainModel] == signalModel then
					resetSignalToBlue(signalModel)
				end
			end)
		end -- Немає warn, якщо детектор не знайдений
		-- ===================================================================
		-- Сценарій 3: Автономний режим
		-- ===================================================================
	else
		-- Логіка автономного світлофора вже в SignalPassDetector.Touched
	end

	-- Ініціалізація візуального стану світлофора при запуску
	if signalClass and signalClass.Model then
		signalClass:updateVisuals()
		signalModel:GetAttributeChangedSignal("SignalCode"):Connect(function()
			if signalClass and signalClass.Model then
				pcall(function() signalClass:updateVisuals() end) 
			end
		end)
	end
end