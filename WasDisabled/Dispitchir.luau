--[[
    Dispatcher Server Script v15 (Physics-Safe / Load Balanced)
    Розміщення: ServerScriptService
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- === REMOTE EVENTS ===
local DispatcherFolder = ReplicatedStorage:FindFirstChild("DispatcherEvents") or Instance.new("Folder")
DispatcherFolder.Name = "DispatcherEvents"
DispatcherFolder.Parent = ReplicatedStorage

local function getRemote(name)
	local r = DispatcherFolder:FindFirstChild(name)
	if not r then
		r = Instance.new("RemoteEvent")
		r.Name = name
		r.Parent = DispatcherFolder
	end
	return r
end

local OpenGUI = getRemote("OpenDispatcherGUI")
local CloseGUI = getRemote("CloseDispatcherGUI")
local UpdateDetectors = getRemote("UpdateDetectors")

-- === НАЛАШТУВАННЯ ===
local DecFolder = workspace:WaitForChild("Dec")
local Put1 = DecFolder:WaitForChild("Put1")
local Put2 = DecFolder:WaitForChild("Put2")

local DETECTOR_COUNT = 274

-- Налаштування продуктивності
local TARGET_FPS = 15 -- Скільки разів на секунду оновлювати дані (15 цілком достатньо для очей)
local UPDATE_DELAY = 1 / TARGET_FPS 

-- === КЕШУВАННЯ ===
local detectorStates = { Put1 = table.create(DETECTOR_COUNT, false), Put2 = table.create(DETECTOR_COUNT, false) }
local lastSentStates = { Put1 = {}, Put2 = {} }

-- Підготовка детекторів
-- Ми не зберігаємо їх як Parts, бо нам важливіше просто знати їх існування для клієнта
-- Але переконайся, що детектори мають CanQuery = true (або CanCollide/CanTouch, якщо Raycast)
for i = 0, DETECTOR_COUNT - 1 do
	local d1 = Put1:FindFirstChild("L1_" .. i)
	local d2 = Put2:FindFirstChild("L1_" .. i)
	-- Налаштування самих деталей, щоб вони не заважали фізиці
	if d1 then 
		d1.CanCollide = false 
		d1.CanTouch = false -- Вимикаємо Touch, бо ми юзаємо запити
		d1.CanQuery = true 
	end
	if d2 then 
		d2.CanCollide = false 
		d2.CanTouch = false 
		d2.CanQuery = true 
	end
end

-- === ТРЕКІНГ ПОЇЗДІВ ===
local mainParts = {}    -- Список частин для перевірки {part = trainModel}
local partsList = {}    -- Індексований список для циклічного оновлення

local trainSeats = {}   -- Кеш сидінь
local partToTrainCache = {}

local activeDispatchers = {}

local function getTrainModel(part)
	if partToTrainCache[part] then return partToTrainCache[part] end
	local current = part.Parent
	while current and current ~= workspace do
		if current.Name:match("Nomernoi") or current.Name:match("TISU") or current:GetAttribute("IsTrain") then
			partToTrainCache[part] = current
			return current
		end
		current = current.Parent
	end
	return nil
end

local function cacheTrainSeats(trainModel)
	if trainSeats[trainModel] then return end
	local seats = {}
	local sHodovki = trainModel:FindFirstChild("S_Hodovki") or trainModel
	for _, desc in ipairs(sHodovki:GetDescendants()) do
		if desc:IsA("VehicleSeat") then
			table.insert(seats, desc)
		end
	end
	trainSeats[trainModel] = seats
end

local function addMainPart(part)
	if part:IsA("BasePart") and part.Name:match("^Main%d+$") then
		local train = getTrainModel(part)
		if train then
			mainParts[part] = train
			table.insert(partsList, part)
			cacheTrainSeats(train)
		end
	end
end

local function removeMainPart(part)
	mainParts[part] = nil
	partToTrainCache[part] = nil
	-- Видаляємо зі списку partsList (трохи повільно, але рідко відбувається)
	local idx = table.find(partsList, part)
	if idx then table.remove(partsList, idx) end
end

-- Сканування карти
for _, obj in ipairs(workspace:GetDescendants()) do
	addMainPart(obj)
end
workspace.DescendantAdded:Connect(function(obj) task.defer(addMainPart, obj) end)
workspace.DescendantRemoving:Connect(removeMainPart)

-- === ОТРИМАННЯ ВОДІЯ ===
local function getTrainDriver(trainModel)
	local seats = trainSeats[trainModel]
	if not seats then return nil end
	for _, seat in ipairs(seats) do
		local occupant = seat.Occupant
		if occupant and occupant.Parent then
			local player = Players:GetPlayerFromCharacter(occupant.Parent)
			if player then return player.DisplayName or player.Name end
		end
	end
	return nil
end

-- === ПАРАМЕТРИ ПЕРЕВІРКИ ===
local overlapParams = OverlapParams.new()
overlapParams.FilterType = Enum.RaycastFilterType.Include
overlapParams.FilterDescendantsInstances = {Put1, Put2}
overlapParams.MaxParts = 5 -- ОПТИМІЗАЦІЯ: Нам не треба знати про 100 детекторів, достатньо 1-2, щоб зрозуміти де поїзд

-- Буфери
local trainDetectorsBuffer = {} 
local trainInfoBuffer = { Put1 = {}, Put2 = {} }

-- === РОЗПОДІЛ НАВАНТАЖЕННЯ (LOAD BALANCER) ===
-- Замість перевірки всіх поїздів за один кадр, ми робимо це поступово.
-- Але так як ми хочемо актуальність, ми оновлюємо дані, але відправляємо їх пакетами.

local lastUpdate = 0

RunService.Heartbeat:Connect(function(dt)
	-- Якщо немає диспетчерів, не навантажуємо сервер взагалі
	if next(activeDispatchers) == nil then return end

	-- Контроль частоти оновлення (Throttle)
	lastUpdate += dt
	if lastUpdate < UPDATE_DELAY then return end
	lastUpdate = 0

	-- 1. Очищення старих даних перед новим циклом розрахунку
	for i = 0, DETECTOR_COUNT - 1 do
		detectorStates.Put1[i] = false
		detectorStates.Put2[i] = false
	end
	table.clear(trainDetectorsBuffer)
	table.clear(trainInfoBuffer.Put1)
	table.clear(trainInfoBuffer.Put2)

	-- 2. "Розумна" перевірка. 
	-- Ми проходимо по всім частинам. Якщо частин ДУЖЕ багато (>50), це може бути важко.
	-- Але GetPartsInPart - це найважче місце.

	for _, mainPart in ipairs(partsList) do
		if mainPart.Parent then 
			-- ВАЖЛИВО: Використовуємо MainPart як Hitbox. 
			-- Якщо MainPart - це MeshPart зі складною колізією - це буде лагати.
			-- Бажано, щоб MainPart був звичайним Part (Box).

			local touching = workspace:GetPartsInPart(mainPart, overlapParams)

			if #touching > 0 then
				local trainModel = mainParts[mainPart]
				if not trainDetectorsBuffer[trainModel] then
					trainDetectorsBuffer[trainModel] = { Put1 = {}, Put2 = {} }
				end

				local tBuffer = trainDetectorsBuffer[trainModel]

				for _, det in ipairs(touching) do
					local indexStr = det.Name:match("L1_(%d+)")
					if indexStr then
						local idx = tonumber(indexStr)
						local putName = (det.Parent == Put1) and "Put1" or "Put2"
						detectorStates[putName][idx] = true
						tBuffer[putName][idx] = true
					end
				end
			end
		end
	end

	-- 3. Обробка даних поїздів (це дуже швидко, тут лагів не буває)
	for trainModel, puts in pairs(trainDetectorsBuffer) do
		local driverName = getTrainDriver(trainModel)

		for putName, indices in pairs(puts) do
			local minIdx, maxIdx = 999999, -1
			local hasData = false
			for idx in pairs(indices) do
				if idx < minIdx then minIdx = idx end
				if idx > maxIdx then maxIdx = idx end
				hasData = true
			end

			if hasData then
				local headIdx = (putName == "Put1") and minIdx or maxIdx
				local tailIdx = (putName == "Put1") and maxIdx or minIdx

				table.insert(trainInfoBuffer[putName], {
					head = headIdx,
					tail = tailIdx,
					driver = driverName
				})
			end
		end
	end

	-- 4. Відправка клієнтам (тільки якщо є зміни або є активні поїзди)
	-- Перевіряємо, чи змінилися стани, щоб не спамити мережу (мережевий лаг теж може виглядати як фізичний)
	local hasChanges = false
	for i = 0, DETECTOR_COUNT - 1 do
		if detectorStates.Put1[i] ~= lastSentStates.Put1[i] then hasChanges = true break end
		if detectorStates.Put2[i] ~= lastSentStates.Put2[i] then hasChanges = true break end
	end

	-- Якщо поїздів немає, але детектори світяться - це баг, треба почистити
	if next(trainDetectorsBuffer) == nil and hasChanges then
		hasChanges = true -- Дозволяємо відправку для очищення
	end

	local hasActiveTrains = (#trainInfoBuffer.Put1 > 0) or (#trainInfoBuffer.Put2 > 0)

	if hasChanges or hasActiveTrains then
		-- Оновлюємо кеш відправленого
		if hasChanges then
			for i = 0, DETECTOR_COUNT - 1 do
				lastSentStates.Put1[i] = detectorStates.Put1[i]
				lastSentStates.Put2[i] = detectorStates.Put2[i]
			end
		end

		for player in pairs(activeDispatchers) do
			if player.Parent then
				UpdateDetectors:FireClient(player, detectorStates, trainInfoBuffer)
			end
		end
	end
end)

-- === СІДІХА (Без змін, працює добре) ===
local function setupSeat(seat)
	seat:GetPropertyChangedSignal("Occupant"):Connect(function()
		local humanoid = seat.Occupant
		if humanoid then
			local p = Players:GetPlayerFromCharacter(humanoid.Parent)
			if p then
				activeDispatchers[p] = seat
				OpenGUI:FireClient(p, detectorStates, trainInfoBuffer)
			end
		else
			for p, s in pairs(activeDispatchers) do
				if s == seat then
					activeDispatchers[p] = nil
					CloseGUI:FireClient(p)
					break
				end
			end
		end
	end)
end

local function checkObj(obj)
	if (obj:IsA("Seat") or obj:IsA("VehicleSeat")) then
		if obj.Name == "DispatcherSeat" or obj:GetAttribute("IsDispatcher") then
			setupSeat(obj)
		end
	end
end

for _, obj in ipairs(workspace:GetDescendants()) do checkObj(obj) end
workspace.DescendantAdded:Connect(checkObj)
Players.PlayerRemoving:Connect(function(p) activeDispatchers[p] = nil end)

print("[Dispatcher] Server v15 (Physics Lag Fix Applied)")