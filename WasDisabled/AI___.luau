-- NPCTrainSystem_v2.lua
-- Розмістити в ServerScriptService
-- З підтримкою дверей та приварювання NPC

local PathfindingService = game:GetService("PathfindingService")
local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

--============================================
-- НАЛАШТУВАННЯ
--============================================
local CONFIG = {
	NPC_FOLDER_PATH = "NPC",
	PLATFORMS_FOLDER = "Platforms",
	SPAWNS_FOLDER = "Spawns",

	SPAWN_PART_NAME = "Spawn",
	DETECTOR_PART_NAME = "Detector",
	PLATFORM_PART_NAME = "Platform",
	EXIT_PART_NAME = "Exit",
	SEAT_NAME = "NPC_SEAT",
	FIRST_WAGON_PART = "Main1",

	-- Налаштування дверей
	DOORS_FOLDER_NAME = "S_Dveri",
	DOOR_PARTS_NAMES = {"Dor1", "Dor2"}, -- Моделі дверей
	DOOR_OPEN_THRESHOLD = 2, -- Наскільки двері мають відсунутись щоб вважатись відкритими
	DOOR_CHECK_INTERVAL = 0.2,

	DETECTION_INTERVAL = 0.3,
	NPC_TEMPLATE_NAME = "DummyNPC",
	NPC_COUNT = 5,

	TRAIN_STOP_SPEED = 0.5,
	TRAIN_MOVING_SPEED = 3, -- Швидкість при якій вважаємо що поїзд рушив
	EXIT_DELAY = 10,

	MIN_NPC_DISTANCE = 3,
	PLATFORM_MARGIN = 0.6,

	MAX_SEAT_SEARCH_DISTANCE = 50,
	MAX_DOOR_SEARCH_DISTANCE = 30,

	WAYPOINT_TIMEOUT = 2,
	DIRECT_MOVE_THRESHOLD = 8,
	STUCK_CHECK_INTERVAL = 0.3,
	STUCK_DISTANCE_THRESHOLD = 0.5,
	MAX_STUCK_TIME = 1.5,

	ACTIVE_STATIONS = {"Lisova"},
}

-- Анімації
local ANIMATIONS = {
	WALK = "rbxassetid://180426354",
	IDLE = "rbxassetid://180435571", 
	SIT = "rbxassetid://178130996",
}

--============================================
-- ЗМІННІ
--============================================
local NPCFolder = Workspace:WaitForChild(CONFIG.NPC_FOLDER_PATH)
local PlatformsFolder = NPCFolder:WaitForChild(CONFIG.PLATFORMS_FOLDER)
local SpawnsFolder = NPCFolder:WaitForChild(CONFIG.SPAWNS_FOLDER)

local Stations = {}
local ActiveNPCs = {}
local WaitingNPCs = {}
local ReservedSeats = {}
local OccupiedPlatformPoints = {}
local WeldedNPCs = {} -- NPC які приварені до поїзда

--============================================
-- ДОПОМІЖНІ ФУНКЦІЇ
--============================================

local function IsPointFree(stationName, point)
	local occupied = OccupiedPlatformPoints[stationName]
	if not occupied then return true end

	for _, occupiedPoint in ipairs(occupied) do
		if (occupiedPoint - point).Magnitude < CONFIG.MIN_NPC_DISTANCE then
			return false
		end
	end
	return true
end

local function ReservePoint(stationName, point)
	if not OccupiedPlatformPoints[stationName] then
		OccupiedPlatformPoints[stationName] = {}
	end
	table.insert(OccupiedPlatformPoints[stationName], point)
end

local function ReleasePoint(stationName, point)
	local occupied = OccupiedPlatformPoints[stationName]
	if not occupied then return end

	for i, occupiedPoint in ipairs(occupied) do
		if (occupiedPoint - point).Magnitude < 1 then
			table.remove(occupied, i)
			return
		end
	end
end

local function GetRandomPointOnPlatform(platformPart, stationName)
	if not platformPart then return nil end

	local size = platformPart.Size
	local cframe = platformPart.CFrame
	local margin = CONFIG.PLATFORM_MARGIN

	for _ = 1, 30 do
		local randomX = math.random(-size.X/2 * margin * 100, size.X/2 * margin * 100) / 100
		local randomZ = math.random(-size.Z/2 * margin * 100, size.Z/2 * margin * 100) / 100

		local worldPosition = cframe:PointToWorldSpace(Vector3.new(randomX, size.Y/2 + 2, randomZ))

		if IsPointFree(stationName, worldPosition) then
			return worldPosition
		end
	end

	local gridSize = 4
	for x = -gridSize, gridSize do
		for z = -gridSize, gridSize do
			local offsetX = (x / gridSize) * (size.X/2 * margin)
			local offsetZ = (z / gridSize) * (size.Z/2 * margin)
			local worldPosition = cframe:PointToWorldSpace(Vector3.new(offsetX, size.Y/2 + 2, offsetZ))

			if IsPointFree(stationName, worldPosition) then
				return worldPosition
			end
		end
	end

	return cframe:PointToWorldSpace(Vector3.new(0, size.Y/2 + 2, 0))
end

local function FindPlatformForStation(stationName)
	for _, platformFolder in ipairs(PlatformsFolder:GetChildren()) do
		if string.find(platformFolder.Name, stationName) then
			return platformFolder:FindFirstChild(CONFIG.PLATFORM_PART_NAME)
		end
	end
	return nil
end

local function FindExitsForStation(stationName)
	local exits = {}
	for _, platformFolder in ipairs(PlatformsFolder:GetChildren()) do
		if string.find(platformFolder.Name, stationName) then
			for _, child in ipairs(platformFolder:GetChildren()) do
				if child.Name == CONFIG.EXIT_PART_NAME then
					table.insert(exits, child)
				end
			end
			break
		end
	end
	return exits
end

local function InitializeStations()
	for _, spawnFolder in ipairs(SpawnsFolder:GetChildren()) do
		local stationName = spawnFolder.Name

		Stations[stationName] = {
			Name = stationName,
			SpawnPoint = spawnFolder:FindFirstChild(CONFIG.SPAWN_PART_NAME),
			Detector = spawnFolder:FindFirstChild(CONFIG.DETECTOR_PART_NAME),
			Platform = FindPlatformForStation(stationName),
			Exits = FindExitsForStation(stationName),
			CurrentTrain = nil,
		}

		WaitingNPCs[stationName] = {}
		OccupiedPlatformPoints[stationName] = {}
	end
end

local function GetTrainModel(part)
	local current = part.Parent
	while current and current.Parent ~= Workspace do
		current = current.Parent
	end
	return current
end

local function GetTrainSpeed(trainModel)
	local mainPart = trainModel:FindFirstChild(CONFIG.FIRST_WAGON_PART, true)
	if mainPart then
		return mainPart.AssemblyLinearVelocity.Magnitude
	end
	return 999
end

local function IsTrainStopped(trainModel)
	return GetTrainSpeed(trainModel) < CONFIG.TRAIN_STOP_SPEED
end

local function IsTrainMoving(trainModel)
	return GetTrainSpeed(trainModel) > CONFIG.TRAIN_MOVING_SPEED
end

local function IsSeatAvailable(seat)
	if seat.Occupant then return false end
	if ReservedSeats[seat] then return false end
	return true
end

local function ReserveSeat(seat, npcData)
	ReservedSeats[seat] = npcData
end

local function ReleaseSeatReservation(seat)
	ReservedSeats[seat] = nil
end

--============================================
-- СИСТЕМА ДВЕРЕЙ
--============================================

-- Отримуємо всі парти дверей з моделі
local function GetDoorParts(doorModel)
	local parts = {}
	for _, child in ipairs(doorModel:GetDescendants()) do
		if child:IsA("BasePart") then
			table.insert(parts, child)
		end
	end
	return parts
end

-- Знаходимо найближчий парт дверей до позиції
local function GetNearestDoorPart(doorModel, position)
	local nearestPart = nil
	local nearestDist = math.huge

	for _, part in ipairs(GetDoorParts(doorModel)) do
		local dist = (part.Position - position).Magnitude
		if dist < nearestDist then
			nearestDist = dist
			nearestPart = part
		end
	end

	return nearestPart, nearestDist
end

-- Знаходимо всі двері на поїзді
local function GetTrainDoors(trainModel)
	local doors = {}

	local doorsFolder = trainModel:FindFirstChild(CONFIG.DOORS_FOLDER_NAME, true)
	if not doorsFolder then return doors end

	-- Шукаємо Dveri_L і Dveri_R
	for _, dveriSide in ipairs(doorsFolder:GetChildren()) do
		if dveriSide.Name == "Dveri_L" or dveriSide.Name == "Dveri_R" then
			-- Шукаємо вагони (1_L, 2_L, etc.)
			for _, wagonDoors in ipairs(dveriSide:GetChildren()) do
				-- Шукаємо Dor1, Dor2
				for _, doorName in ipairs(CONFIG.DOOR_PARTS_NAMES) do
					local doorModel = wagonDoors:FindFirstChild(doorName)
					if doorModel then
						table.insert(doors, {
							Model = doorModel,
							Side = dveriSide.Name,
							Wagon = wagonDoors.Name,
							InitialPositions = {}, -- Зберігаємо початкові позиції для перевірки відкриття
						})

						-- Зберігаємо початкові позиції партів
						for _, part in ipairs(GetDoorParts(doorModel)) do
							doors[#doors].InitialPositions[part] = part.Position
						end
					end
				end
			end
		end
	end

	return doors
end

-- Перевіряємо чи двері відкриті (порівнюємо з початковою позицією)
local function AreDoorOpen(doorData)
	for part, initialPos in pairs(doorData.InitialPositions) do
		if part and part.Parent then
			local currentPos = part.Position
			local moved = (currentPos - initialPos).Magnitude
			if moved > CONFIG.DOOR_OPEN_THRESHOLD then
				return true
			end
		end
	end
	return false
end

-- Знаходимо найближчі відкриті двері до NPC
local function FindNearestOpenDoor(trainModel, fromPosition, preferredSide)
	local doors = GetTrainDoors(trainModel)
	local nearestDoor = nil
	local nearestPart = nil
	local nearestDist = math.huge

	for _, doorData in ipairs(doors) do
		-- Перевіряємо сторону (якщо вказано)
		if preferredSide and doorData.Side ~= preferredSide then
			continue
		end

		if AreDoorOpen(doorData) then
			local part, dist = GetNearestDoorPart(doorData.Model, fromPosition)
			if dist < nearestDist and dist < CONFIG.MAX_DOOR_SEARCH_DISTANCE then
				nearestDist = dist
				nearestDoor = doorData
				nearestPart = part
			end
		end
	end

	return nearestDoor, nearestPart, nearestDist
end

-- Знаходимо найближчі двері (навіть закриті) для очікування
local function FindNearestDoor(trainModel, fromPosition, preferredSide)
	local doors = GetTrainDoors(trainModel)
	local nearestDoor = nil
	local nearestPart = nil
	local nearestDist = math.huge

	for _, doorData in ipairs(doors) do
		if preferredSide and doorData.Side ~= preferredSide then
			continue
		end

		local part, dist = GetNearestDoorPart(doorData.Model, fromPosition)
		if dist < nearestDist and dist < CONFIG.MAX_DOOR_SEARCH_DISTANCE then
			nearestDist = dist
			nearestDoor = doorData
			nearestPart = part
		end
	end

	return nearestDoor, nearestPart, nearestDist
end

-- Визначаємо сторону платформи (L чи R)
local function GetPlatformSide(station, trainModel)
	if not station.Platform or not trainModel then return nil end

	local mainPart = trainModel:FindFirstChild(CONFIG.FIRST_WAGON_PART, true)
	if not mainPart then return nil end

	local platformPos = station.Platform.Position
	local trainPos = mainPart.Position
	local trainCFrame = mainPart.CFrame

	-- Визначаємо з якого боку платформа відносно поїзда
	local toplatform = (platformPos - trainPos)
	local rightVector = trainCFrame.RightVector
	local dot = toplatform:Dot(rightVector)

	if dot > 0 then
		return "Dveri_R"
	else
		return "Dveri_L"
	end
end

--============================================
-- СИСТЕМА ПРИВАРЮВАННЯ
--============================================

local function WeldNPCToTrain(npcData, trainModel)
	if not npcData.Model or not npcData.RootPart then return end
	if WeldedNPCs[npcData] then return end -- Вже приварений

	local mainPart = trainModel:FindFirstChild(CONFIG.FIRST_WAGON_PART, true)
	if not mainPart then return end

	-- Створюємо WeldConstraint
	local weld = Instance.new("WeldConstraint")
	weld.Name = "NPCWeld"
	weld.Part0 = npcData.RootPart
	weld.Part1 = mainPart
	weld.Parent = npcData.RootPart

	-- Вимикаємо фізику NPC
	for _, part in ipairs(npcData.Model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = false
			part.CanCollide = false
		end
	end

	WeldedNPCs[npcData] = {
		Weld = weld,
		Train = trainModel,
	}

	npcData.State = "WELDED"
	print("[NPC] Welded NPC to train: " .. npcData.Model.Name)
end

local function UnweldNPC(npcData)
	local weldData = WeldedNPCs[npcData]
	if not weldData then return end

	if weldData.Weld and weldData.Weld.Parent then
		weldData.Weld:Destroy()
	end

	-- Повертаємо колізії
	if npcData.Model then
		for _, part in ipairs(npcData.Model:GetDescendants()) do
			if part:IsA("BasePart") then
				if part.Name == "HumanoidRootPart" or part.Name == "Head" then
					part.CanCollide = true
				end
			end
		end
	end

	WeldedNPCs[npcData] = nil
end

--============================================
-- ПОШУК СИДІННЯ
--============================================

local function FindNearestAvailableSeat(trainModel, fromPosition)
	local nearestSeat = nil
	local nearestDistance = math.huge

	for _, descendant in ipairs(trainModel:GetDescendants()) do
		if descendant:IsA("Seat") and descendant.Name == CONFIG.SEAT_NAME then
			if IsSeatAvailable(descendant) then
				local distance = (descendant.Position - fromPosition).Magnitude

				if distance < nearestDistance and distance < CONFIG.MAX_SEAT_SEARCH_DISTANCE then
					nearestDistance = distance
					nearestSeat = descendant
				end
			end
		end
	end

	return nearestSeat
end

local function FindNearestExit(exits, fromPosition)
	local nearestExit = nil
	local nearestDistance = math.huge

	for _, exit in ipairs(exits) do
		local distance = (exit.Position - fromPosition).Magnitude
		if distance < nearestDistance then
			nearestDistance = distance
			nearestExit = exit
		end
	end

	return nearestExit
end

--============================================
-- СИСТЕМА АНІМАЦІЙ
--============================================

local function GetOrCreateAnimator(humanoid)
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end
	return animator
end

local function StopAllAnimations(npcData)
	if npcData.WalkTrack then
		npcData.WalkTrack:Stop(0.2)
	end
	if npcData.IdleTrack then
		npcData.IdleTrack:Stop(0.2)
	end
end

local function PlayWalkAnimation(npcData)
	if not npcData.Humanoid then return end

	local animator = GetOrCreateAnimator(npcData.Humanoid)

	if npcData.IdleTrack and npcData.IdleTrack.IsPlaying then
		npcData.IdleTrack:Stop(0.2)
	end

	if not npcData.WalkTrack then
		local walkAnim = Instance.new("Animation")
		walkAnim.AnimationId = ANIMATIONS.WALK
		npcData.WalkTrack = animator:LoadAnimation(walkAnim)
		npcData.WalkTrack.Priority = Enum.AnimationPriority.Movement
		npcData.WalkTrack.Looped = true
	end

	if not npcData.WalkTrack.IsPlaying then
		npcData.WalkTrack:Play(0.2)
	end
end

local function PlayIdleAnimation(npcData)
	if not npcData.Humanoid then return end

	local animator = GetOrCreateAnimator(npcData.Humanoid)

	if npcData.WalkTrack and npcData.WalkTrack.IsPlaying then
		npcData.WalkTrack:Stop(0.2)
	end

	if not npcData.IdleTrack then
		local idleAnim = Instance.new("Animation")
		idleAnim.AnimationId = ANIMATIONS.IDLE
		npcData.IdleTrack = animator:LoadAnimation(idleAnim)
		npcData.IdleTrack.Priority = Enum.AnimationPriority.Idle
		npcData.IdleTrack.Looped = true
	end

	if not npcData.IdleTrack.IsPlaying then
		npcData.IdleTrack:Play(0.2)
	end
end

local function PlaySitAnimation(npcData)
	if not npcData.Humanoid then return end

	local animator = GetOrCreateAnimator(npcData.Humanoid)

	StopAllAnimations(npcData)

	for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
		track:Stop(0)
	end

	local sitAnim = Instance.new("Animation")
	sitAnim.AnimationId = ANIMATIONS.SIT
	npcData.SitTrack = animator:LoadAnimation(sitAnim)
	npcData.SitTrack.Priority = Enum.AnimationPriority.Core
	npcData.SitTrack.Looped = true
	npcData.SitTrack:Play(0)
end

--============================================
-- ОПТИМІЗОВАНИЙ РУХ NPC
--============================================

local function DirectMoveTo(npcData, targetPosition, timeout)
	if not npcData.Humanoid or not npcData.RootPart then return false end

	PlayWalkAnimation(npcData)
	npcData.Humanoid:MoveTo(targetPosition)

	local startTime = tick()
	local lastPos = npcData.RootPart.Position
	local stuckTime = 0

	while (tick() - startTime) < timeout do
		if not npcData.RootPart or not npcData.Model.Parent then 
			return false 
		end

		if npcData.State == "SEATED" or npcData.State == "WELDED" then
			return false
		end

		local currentPos = npcData.RootPart.Position
		local distanceToTarget = (Vector3.new(currentPos.X, 0, currentPos.Z) - Vector3.new(targetPosition.X, 0, targetPosition.Z)).Magnitude

		if distanceToTarget < 2 then
			return true
		end

		local moved = (currentPos - lastPos).Magnitude
		if moved < CONFIG.STUCK_DISTANCE_THRESHOLD then
			stuckTime = stuckTime + CONFIG.STUCK_CHECK_INTERVAL
			if stuckTime > CONFIG.MAX_STUCK_TIME then
				npcData.Humanoid.Jump = true
				stuckTime = 0
			end
		else
			stuckTime = 0
		end

		lastPos = currentPos
		task.wait(CONFIG.STUCK_CHECK_INTERVAL)
	end

	return false
end

local function WalkNPCTo(npcData, targetPosition, callback)
	if not npcData.Humanoid or not npcData.RootPart then return end
	if npcData.State == "SEATED" or npcData.State == "WELDED" then return end
	if npcData.IsMoving then return end

	npcData.IsMoving = true
	npcData.State = "WALKING"
	npcData.CurrentTarget = targetPosition

	local startPos = npcData.RootPart.Position
	local directDistance = (Vector3.new(startPos.X, 0, startPos.Z) - Vector3.new(targetPosition.X, 0, targetPosition.Z)).Magnitude

	if directDistance < CONFIG.DIRECT_MOVE_THRESHOLD then
		local success = DirectMoveTo(npcData, targetPosition, 5)
		npcData.IsMoving = false

		if npcData.State ~= "SEATED" and npcData.State ~= "WELDED" then
			PlayIdleAnimation(npcData)
		end

		if callback and npcData.CurrentTarget == targetPosition then
			callback()
		end
		return
	end

	local pathParams = {
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		AgentCanClimb = false,
		WaypointSpacing = 4,
	}

	local path = PathfindingService:CreatePath(pathParams)

	local success, errorMsg = pcall(function()
		path:ComputeAsync(npcData.RootPart.Position, targetPosition)
	end)

	if success and path.Status == Enum.PathStatus.Success then
		local waypoints = path:GetWaypoints()

		PlayWalkAnimation(npcData)

		for i, waypoint in ipairs(waypoints) do
			if npcData.CurrentTarget ~= targetPosition then break end
			if npcData.State == "SEATED" or npcData.State == "BOARDING" or npcData.State == "WELDED" then break end
			if not npcData.RootPart or not npcData.Model.Parent then break end

			npcData.Humanoid:MoveTo(waypoint.Position)

			if waypoint.Action == Enum.PathWaypointAction.Jump then
				npcData.Humanoid.Jump = true
			end

			local waypointStartTime = tick()
			local lastPos = npcData.RootPart.Position
			local stuckTime = 0

			while true do
				if not npcData.RootPart or not npcData.Model.Parent then break end
				if npcData.CurrentTarget ~= targetPosition then break end
				if npcData.State == "SEATED" or npcData.State == "WELDED" then break end

				local currentPos = npcData.RootPart.Position
				local dist = (Vector3.new(currentPos.X, 0, currentPos.Z) - Vector3.new(waypoint.Position.X, 0, waypoint.Position.Z)).Magnitude

				if dist < 2.5 then
					break
				end

				if (tick() - waypointStartTime) > CONFIG.WAYPOINT_TIMEOUT then
					break
				end

				local moved = (currentPos - lastPos).Magnitude
				if moved < CONFIG.STUCK_DISTANCE_THRESHOLD then
					stuckTime = stuckTime + 0.1
					if stuckTime > CONFIG.MAX_STUCK_TIME then
						npcData.Humanoid.Jump = true
						stuckTime = 0
					end
				else
					stuckTime = 0
				end

				lastPos = currentPos
				task.wait(0.1)
			end
		end
	else
		DirectMoveTo(npcData, targetPosition, 8)
	end

	npcData.IsMoving = false

	if npcData.State ~= "SEATED" and npcData.State ~= "BOARDING" and npcData.State ~= "WELDED" then
		PlayIdleAnimation(npcData)
	end

	if callback and npcData.State ~= "SEATED" and npcData.State ~= "WELDED" and npcData.CurrentTarget == targetPosition then
		callback()
	end
end

--============================================
-- NPC ДІЇ
--============================================

local function NPCExitTrain(npcData, station)
	if npcData.State ~= "SEATED" and npcData.State ~= "WELDED" then return end

	-- Знімаємо weld якщо був
	UnweldNPC(npcData)

	if npcData.SitTrack then
		npcData.SitTrack:Stop(0.2)
		npcData.SitTrack = nil
	end

	if npcData.Seat and npcData.Humanoid then
		npcData.Humanoid.Sit = false
	end

	task.wait(0.3)

	local exits = station.Exits
	if #exits == 0 then
		if npcData.Model then
			npcData.Model:Destroy()
		end
		return
	end

	local nearestExit = FindNearestExit(exits, npcData.RootPart.Position)

	npcData.State = "EXITING"
	npcData.Seat = nil
	npcData.IsMoving = false

	WalkNPCTo(npcData, nearestExit.Position, function()
		if npcData.Model then
			npcData.Model:Destroy()
		end

		for i, npc in ipairs(ActiveNPCs) do
			if npc == npcData then
				table.remove(ActiveNPCs, i)
				break
			end
		end
	end)
end


local function WalkNPCToSeatAndSit(npcData, seat, station)
	if not seat or not npcData.Humanoid or not npcData.RootPart then return false end

	if seat.Occupant then 
		ReleaseSeatReservation(seat)
		return false 
	end

	if npcData.WaitingPoint then
		ReleasePoint(npcData.Station, npcData.WaitingPoint)
		npcData.WaitingPoint = nil
	end

	npcData.State = "BOARDING"
	npcData.TargetSeat = seat
	npcData.IsMoving = false

	local seatPosition = seat.Position
	local platformY = npcData.RootPart.Position.Y
	local targetPoint = Vector3.new(seatPosition.X, platformY, seatPosition.Z)

	WalkNPCTo(npcData, targetPoint, function()
		if not seat or not seat.Parent then
			ReleaseSeatReservation(seat)
			npcData.State = "WAITING"
			return
		end

		if seat.Occupant then
			ReleaseSeatReservation(seat)
			npcData.State = "WAITING"
			return
		end

		StopAllAnimations(npcData)

		npcData.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
		seat:Sit(npcData.Humanoid)

		task.wait(0.15)

		PlaySitAnimation(npcData)

		npcData.State = "SEATED"
		npcData.Seat = seat
		ReleaseSeatReservation(seat)

		local trainModel = GetTrainModel(seat)

		-- Відстежуємо чи поїзд рушив (для приварювання)
		task.spawn(function()
			-- Чекаємо поки поїзд рушить або час вийде
			local checkStartTime = tick()

			while npcData.State == "SEATED" do
				if not npcData.Model or not npcData.Model.Parent then return end
				if not trainModel or not trainModel.Parent then return end

				-- Якщо поїзд рушив - приварюємо NPC
				if IsTrainMoving(trainModel) then
					WeldNPCToTrain(npcData, trainModel)
					break
				end

				task.wait(0.3)
			end
		end)

		-- Вихід з поїзда через затримку
		task.spawn(function()
			task.wait(CONFIG.EXIT_DELAY)

			if npcData.State == "SEATED" or npcData.State == "WELDED" then
				if trainModel and IsTrainStopped(trainModel) then
					NPCExitTrain(npcData, station)
				else
					-- Чекаємо поки поїзд зупиниться
					local waitStart = tick()
					repeat
						task.wait(0.3)
					until not trainModel or IsTrainStopped(trainModel) or (npcData.State ~= "SEATED" and npcData.State ~= "WELDED") or (tick() - waitStart) > 60

					if npcData.State == "SEATED" or npcData.State == "WELDED" then
						NPCExitTrain(npcData, station)
					end
				end
			end
		end)
	end)

	return true
end

-- NPC йде до дверей і чекає їх відкриття
local function NPCWaitAtDoor(npcData, trainModel, station)
	if not npcData.RootPart then return end

	local platformSide = GetPlatformSide(station, trainModel)
	local doorData, doorPart, dist = FindNearestDoor(trainModel, npcData.RootPart.Position, platformSide)

	if not doorPart then
		-- Немає дверей - пробуємо просто знайти сидіння
		local seat = FindNearestAvailableSeat(trainModel, npcData.RootPart.Position)
		if seat then
			ReserveSeat(seat, npcData)
			WalkNPCToSeatAndSit(npcData, seat, station)
		end
		return
	end

	-- Визначаємо точку очікування біля дверей (трохи відступаємо від дверей)
	local doorPos = doorPart.Position
	local platformPos = station.Platform.Position
	local directionToplatform = (platformPos - doorPos).Unit
	local waitPoint = doorPos + directionToplatform * 3 -- 3 studs від дверей
	waitPoint = Vector3.new(waitPoint.X, npcData.RootPart.Position.Y, waitPoint.Z)

	npcData.State = "GOING_TO_DOOR"
	npcData.TargetDoor = doorData
	npcData.IsMoving = false

	-- Йдемо до точки біля дверей
	WalkNPCTo(npcData, waitPoint, function()
		npcData.State = "WAITING_AT_DOOR"

		-- Чекаємо відкриття дверей
		task.spawn(function()
			local waitStartTime = tick()
			local maxWaitTime = 30

			while npcData.State == "WAITING_AT_DOOR" do
				if not npcData.Model or not npcData.Model.Parent then return end

				-- Перевіряємо чи поїзд поїхав
				if IsTrainMoving(trainModel) then
					-- Поїзд рушив - NPC залишається на платформі
					npcData.State = "WAITING"
					npcData.TargetDoor = nil
					table.insert(WaitingNPCs[station.Name], npcData)
					return
				end

				-- Перевіряємо чи двері відкрились
				if AreDoorOpen(doorData) then
					-- Двері відкрились - шукаємо сидіння і заходимо
					local seat = FindNearestAvailableSeat(trainModel, npcData.RootPart.Position)
					if seat then
						ReserveSeat(seat, npcData)
						npcData.TargetDoor = nil
						WalkNPCToSeatAndSit(npcData, seat, station)
						return
					end
				end

				-- Таймаут
				if (tick() - waitStartTime) > maxWaitTime then
					npcData.State = "WAITING"
					npcData.TargetDoor = nil
					table.insert(WaitingNPCs[station.Name], npcData)
					return
				end

				task.wait(CONFIG.DOOR_CHECK_INTERVAL)
			end
		end)
	end)
end


local function SpawnNPC(stationName)
	local station = Stations[stationName]
	if not station or not station.SpawnPoint then return nil end

	local template = ServerStorage:FindFirstChild(CONFIG.NPC_TEMPLATE_NAME)
	if not template then 
		warn("NPC template not found: " .. CONFIG.NPC_TEMPLATE_NAME)
		return nil 
	end

	if not station.Platform then
		warn("No platform for station: " .. stationName)
		return nil
	end

	local waitingPoint = GetRandomPointOnPlatform(station.Platform, stationName)
	if not waitingPoint then
		warn("Could not find free point on platform")
		return nil
	end

	ReservePoint(stationName, waitingPoint)

	local npcModel = template:Clone()
	npcModel.Name = "NPC_" .. tostring(math.random(10000, 99999))

	local spawnPos = station.SpawnPoint.CFrame.Position + Vector3.new(
		math.random(-2, 2),
		3,
		math.random(-2, 2)
	)

	local rootPart = npcModel:FindFirstChild("HumanoidRootPart")
	if npcModel.PrimaryPart then
		npcModel:SetPrimaryPartCFrame(CFrame.new(spawnPos))
	elseif rootPart then
		rootPart.CFrame = CFrame.new(spawnPos)
	end

	local humanoid = npcModel:FindFirstChildOfClass("Humanoid")

	for _, part in ipairs(npcModel:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Massless = true
			part.CanCollide = part.Name == "HumanoidRootPart" or part.Name == "Head"
		end
	end

	if humanoid then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
		humanoid.WalkSpeed = 12
	end

	npcModel.Parent = Workspace

	local npcData = {
		Model = npcModel,
		Humanoid = humanoid,
		RootPart = rootPart,
		Station = stationName,
		State = "IDLE",
		Seat = nil,
		TargetSeat = nil,
		TargetDoor = nil,
		SitTrack = nil,
		WalkTrack = nil,
		IdleTrack = nil,
		WaitingPoint = waitingPoint,
		IsMoving = false,
		CurrentTarget = nil,
	}

	table.insert(ActiveNPCs, npcData)

	task.spawn(function()
		task.wait(0.1)

		WalkNPCTo(npcData, waitingPoint, function()
			npcData.State = "WAITING"
			table.insert(WaitingNPCs[stationName], npcData)

			-- Перевіряємо чи є поїзд
			if station.CurrentTrain and IsTrainStopped(station.CurrentTrain) then
				-- Видаляємо з waiting list
				for i, npc in ipairs(WaitingNPCs[stationName]) do
					if npc == npcData then
						table.remove(WaitingNPCs[stationName], i)
						break
					end
				end

				-- Йдемо до дверей
				NPCWaitAtDoor(npcData, station.CurrentTrain, station)
			end
		end)
	end)

	return npcData
end

--============================================
-- ДЕТЕКЦІЯ ПОЇЗДА
--============================================

local function CheckTrainAtStation(station)
	if not station.Detector then return end

	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Exclude
	overlapParams.FilterDescendantsInstances = {NPCFolder}

	local parts = Workspace:GetPartBoundsInBox(
		station.Detector.CFrame,
		station.Detector.Size,
		overlapParams
	)

	local foundTrain = nil

	for _, part in ipairs(parts) do
		if part.Name == CONFIG.FIRST_WAGON_PART then
			foundTrain = GetTrainModel(part)
			break
		end
	end

	if foundTrain then
		local wasNewTrain = station.CurrentTrain ~= foundTrain
		station.CurrentTrain = foundTrain

		if IsTrainStopped(foundTrain) then
			local waitingList = WaitingNPCs[station.Name]
			local toRemove = {}

			for i, npcData in ipairs(waitingList) do
				if npcData.State == "WAITING" and npcData.RootPart and not npcData.IsMoving then
					table.insert(toRemove, i)

					task.spawn(function()
						NPCWaitAtDoor(npcData, foundTrain, station)
					end)
				end
			end

			for i = #toRemove, 1, -1 do
				table.remove(waitingList, toRemove[i])
			end
		end

	elseif station.CurrentTrain then
		station.CurrentTrain = nil
	end
end

local function StartDetectionLoop()
	task.spawn(function()
		while true do
			for _, station in pairs(Stations) do
				CheckTrainAtStation(station)
			end
			task.wait(CONFIG.DETECTION_INTERVAL)
		end
	end)
end

--============================================
-- ОЧИСТКА
--============================================

local function StartCleanupLoop()
	task.spawn(function()
		while true do
			task.wait(3)

			for i = #ActiveNPCs, 1, -1 do
				local npcData = ActiveNPCs[i]

				if not npcData.Model or not npcData.Model.Parent then
					if npcData.WaitingPoint and npcData.Station then
						ReleasePoint(npcData.Station, npcData.WaitingPoint)
					end
					UnweldNPC(npcData)
					table.remove(ActiveNPCs, i)
				end
			end

			for seat, npcData in pairs(ReservedSeats) do
				if not seat or not seat.Parent then
					ReservedSeats[seat] = nil
				elseif npcData.State == "SEATED" or npcData.State == "WELDED" or not npcData.Model or not npcData.Model.Parent then
					ReservedSeats[seat] = nil
				end
			end

			for stationName, points in pairs(OccupiedPlatformPoints) do
				for i = #points, 1, -1 do
					local pointUsed = false
					for _, npc in ipairs(ActiveNPCs) do
						if npc.WaitingPoint and (npc.WaitingPoint - points[i]).Magnitude < 1 then
							pointUsed = true
							break
						end
					end
					if not pointUsed then
						table.remove(points, i)
					end
				end
			end

			for stationName, waitingList in pairs(WaitingNPCs) do
				for i = #waitingList, 1, -1 do
					local npcData = waitingList[i]
					if not npcData.Model or not npcData.Model.Parent or npcData.State ~= "WAITING" then
						table.remove(waitingList, i)
					end
				end
			end
		end
	end)
end

--============================================
-- ЗАПУСК
--============================================

print("[NPCTrainSystem v2] Initializing...")

InitializeStations()
StartDetectionLoop()
StartCleanupLoop()

print("[NPCTrainSystem v2] Stations initialized: " .. #CONFIG.ACTIVE_STATIONS)

task.wait(1)

for i = 1, CONFIG.NPC_COUNT do
	local stationName = CONFIG.ACTIVE_STATIONS[math.random(1, #CONFIG.ACTIVE_STATIONS)]
	local npc = SpawnNPC(stationName)
	if npc then
		print("[NPCTrainSystem v2] Spawned NPC #" .. i .. " at " .. stationName)
	end
	task.wait(2)
end

print("[NPCTrainSystem v2] System ready!")