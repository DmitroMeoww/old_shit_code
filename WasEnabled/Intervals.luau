-- ================================================= --
--         АВТОНОМНИЙ МЕНЕДЖЕР ІНТЕРВАЛІВ             --
-- ================================================= --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

--// Налаштування
local TRAIN_MODEL_NAME = "Nomernoi_TISU_TEST" -- Точна назва моделі поїзда
local POEZDA_FOLDER_NAME = "Poezda"
local UPDATE_FREQUENCY = 3 -- Як часто перераховувати (секунди)

--// Ініціалізація змінних
local poezdaFolder = Workspace:WaitForChild(POEZDA_FOLDER_NAME)

-- Створення або пошук глобального значення (для автопілотів поїздів)
local globalIntervalValue = ReplicatedStorage:FindFirstChild("GlobalTrainInterval")
if not globalIntervalValue then
	globalIntervalValue = Instance.new("NumberValue")
	globalIntervalValue.Name = "GlobalTrainInterval"
	globalIntervalValue.Parent = ReplicatedStorage
end

-- Створення події для оновлення GUI у гравців
local updateIntervalEvent = ReplicatedStorage:FindFirstChild("UpdateIntervalEvent")
if not updateIntervalEvent then
	updateIntervalEvent = Instance.new("RemoteEvent")
	updateIntervalEvent.Name = "UpdateIntervalEvent"
	updateIntervalEvent.Parent = ReplicatedStorage
end

local currentInterval = -1

--// Логіка розрахунку (Ваші вимоги)
local function getIntervalByCount(count)
	if count <= 1 then
		return 0       -- 1 поїзд: їде як хоче
	elseif count == 2 then
		return 180     -- 2 поїзда: 3.00
	elseif count == 3 then
		return 150     -- 3 поїзда: 2.30
	elseif count == 4 then
		return 135     -- 4 поїзда: 2.15 (135 секунд)
	elseif count == 5 then
		return 110     -- 5 поїздів: 1.50 (110 секунд)
	else
		return 60      -- 6+ поїздів: 1.00
	end
end

--// Функція підрахунку (використовує GetDescendants)
local function countTrains()
	local count = 0
	-- Шукаємо глибоко у всіх папках всередині Poezda
	for _, object in pairs(poezdaFolder:GetDescendants()) do
		if object:IsA("Model") and object.Name == TRAIN_MODEL_NAME then
			count += 1
		end
	end
	return count
end

--// Головний цикл
task.spawn(function()
	while true do
		local trainCount = countTrains()
		local newInterval = getIntervalByCount(trainCount)

		-- Оновлюємо тільки якщо значення змінилося
		if newInterval ~= currentInterval then
			currentInterval = newInterval

			-- 1. Оновлюємо фізичне значення для скриптів поїздів
			globalIntervalValue.Value = currentInterval

			-- 2. Відправляємо всім гравцям для GUI
			updateIntervalEvent:FireAllClients(currentInterval)

			print(string.format("[AUTO] Поїздів: %d | Новий інтервал: %d с.", trainCount, currentInterval))
		end

		task.wait(UPDATE_FREQUENCY)
	end
end)

--// Відправка актуального значення новому гравцю
game:GetService("Players").PlayerAdded:Connect(function(player)
	task.wait(1)
	updateIntervalEvent:FireClient(player, currentInterval)
end)