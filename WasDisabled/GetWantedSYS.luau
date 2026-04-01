-- =========================================================================
-- JAIL, WANTED - SERVER SCRIPT (Версія з новою системою звільнення)
-- =========================================================================

local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local WANTED_PART_NAME = "GetWanted"
local JAIL_ZONE_NAME = "JailZone"
local POLICE_TEAM_NAME = "Поліція"

local JAIL_TIMES = {300, 600, 1800, 3000, 5400, 7200}
local FINE_AMOUNTS = {1000, 1500, 1750, 2000, 3000, 4500}
local RAGE_QUIT_TIME_MULTIPLIER = 1.4
local RAGE_QUIT_FINE_MULTIPLIER = 2.0
local RAGE_QUIT_CUFFED_MULTIPLIER = 2.0
local INITIAL_BOUNTY = 1000
local MINIMUM_BOUNTY = 100
local BOUNTY_DECAY_INTERVAL = 5
local BOUNTY_DECAY_AMOUNT = 10

local JailDataStore = DataStoreService:GetDataStore("JailStatusData_V5")

local GameRemotes = ReplicatedStorage:WaitForChild("GameRemotes")
local JailEvent = GameRemotes:WaitForChild("JailEvent")
local PoliceLocatorEvent = GameRemotes:WaitForChild("PoliceLocatorEvent")
local CuffEvent = GameRemotes:WaitForChild("CuffEvent")
local RequestReleaseEvent = GameRemotes:WaitForChild("RequestReleaseEvent")
local ReleasePlayerEvent = GameRemotes:WaitForChild("ReleasePlayerEvent") -- <-- Нова подія

local playerData = {}
local jailZonePart = nil
local jailSpawnPosition = nil
local processedArrests = {}
local isPrivateServer = game.PrivateServerId ~= "" and game.PrivateServerOwnerId ~= 0

-- НОВА ФУНКЦІЯ для зняття кайданів та розшуку
local function uncuffAndReleasePlayer(targetPlayer)
	local data = playerData[targetPlayer]
	if not data then return end

	data.isWanted = false
	if targetPlayer.Character then
		CuffEvent:FireAllClients("ClearAttributes", targetPlayer.Character)
		task.wait(0.1)
		targetPlayer.Character:SetAttribute("isWanted", false)
		targetPlayer.Character:SetAttribute("isCuffed", false)
		targetPlayer.Character:SetAttribute("ArrestingOfficer", nil)
		if targetPlayer.Character:FindFirstChildOfClass("Humanoid") then
			targetPlayer.Character.Humanoid.WalkSpeed = 16
		end
	end

	JailEvent:FireClient(targetPlayer, "SetWantedStatus", false)
	JailEvent:FireClient(targetPlayer, "ShowReward", "Ви щаслива людина! Вас відпустив поліцейський. Не робіть так більше")
end


local function notifyPolice(criminalName)
	local message = "🚨 НОВИЙ ЗЛОЧИНЕЦЬ!\n" .. criminalName .. " тепер у розшуку!"
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Team and player.Team.Name == POLICE_TEAM_NAME then
			JailEvent:FireClient(player, "ShowNotification", message)
		end
	end
end

local function setWantedStatus(player, reason)
	local data = playerData[player]
	if not data or (player.Team and player.Team.Name == POLICE_TEAM_NAME) or data.isWanted or data.jailTimer > 0 or data.isSettingWanted then return end

	data.isSettingWanted = true
	data.isWanted = true
	data.bounty = INITIAL_BOUNTY
	data.bountyDecayCooldown = BOUNTY_DECAY_INTERVAL

	if player.Character then
		player.Character:SetAttribute("isWanted", true)
	end

	if reason then
		JailEvent:FireClient(player, "ShowNotification", reason)
	end

	JailEvent:FireClient(player, "SetWantedStatus", true)
	notifyPolice(player.Name)

	task.delay(1, function() data.isSettingWanted = false end)
end

local function releasePlayerFromJail(player, reason)
	local data = playerData[player]
	if not data then return end

	if player.Character then
		player.Character:SetAttribute("isWanted", false)
		player.Character:SetAttribute("isCuffed", false)
		player.Character:SetAttribute("ArrestingOfficer", nil)
		player.Character:SetAttribute("InJail", false)
	end
	data.isWanted = false
	data.jailTimer = 0
	data.jailFine = 0
	data.bounty = 0
	data.arrestingOfficerId = nil

	pcall(function() JailDataStore:RemoveAsync(tostring(player.UserId)) end)
	JailEvent:FireClient(player, "HideJailUI", reason or "Ви вільні!")
	player:LoadCharacter()
end

local function jailPlayer(player, loadedData, arrestingOfficer)
	local data = playerData[player]
	if not data or not player.Character then return end

	local arrestKey = player.UserId
	if processedArrests[arrestKey] and tick() - processedArrests[arrestKey] < 3 then return end
	processedArrests[arrestKey] = tick()

	local rewardAmount = 0
	local officerUserId = nil

	if loadedData then
		data.jailTimer = loadedData.jailTimer
		data.jailFine = loadedData.jailFine
		data.arrestingOfficerId = loadedData.arrestingOfficerId
		data.offenses = loadedData.offenses or data.offenses
	else
		data.offenses = (data.offenses or 0) + 1
		local offenseLevel = math.min(data.offenses, #JAIL_TIMES)

		if offenseLevel >= 7 then
			player:Kick("❌ Ви заблоковані на 1 день за численні порушення!")
			pcall(function()
				JailDataStore:SetAsync(tostring(player.UserId), {
					banned = true,
					banUntil = os.time() + 86400,
					offenses = data.offenses
				})
			end)
			playerData[player] = nil
			return
		end

		data.jailTimer = JAIL_TIMES[offenseLevel]
		data.jailFine = FINE_AMOUNTS[offenseLevel]

		if arrestingOfficer and arrestingOfficer.Parent and arrestingOfficer.Team and arrestingOfficer.Team.Name == POLICE_TEAM_NAME then
			local baseBounty = math.max(data.bounty or INITIAL_BOUNTY)
			rewardAmount = math.floor(baseBounty * 0.5)
			officerUserId = arrestingOfficer.UserId
			data.arrestingOfficerId = officerUserId

			local officerLeaderstats = arrestingOfficer:FindFirstChild("leaderstats")
			local officerExp = officerLeaderstats and officerLeaderstats:FindFirstChild("EXP")
			if officerExp then
				officerExp.Value = officerExp.Value + rewardAmount
			end
		end
	end

	if data.jailTimer <= 0 then
		data.jailTimer = 10
	end

	data.isWanted = false
	data.bounty = 0

	local character = player.Character
	character:SetAttribute("InJail", true)
	CuffEvent:FireAllClients("ClearAttributes", character)
	task.wait(0.1)

	character:SetAttribute("isWanted", false)
	character:SetAttribute("isCuffed", false)
	character:SetAttribute("ArrestingOfficer", nil)

	if character.Head and character.Head:FindFirstChild("WantedGui") then
		character.Head.WantedGui:Destroy()
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = 16
		humanoid.JumpPower = 0
		humanoid.JumpHeight = 0
	end

	if jailSpawnPosition then
		task.wait(0.2)
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = CFrame.new(jailSpawnPosition)
			hrp.Anchored = false
		else
			character:MoveTo(jailSpawnPosition)
		end
	end

	task.wait(0.3)
	JailEvent:FireClient(player, "ShowJailUI", data.jailTimer, data.jailFine)

	if officerUserId then
		if arrestingOfficer and arrestingOfficer.Parent then
			JailEvent:FireClient(arrestingOfficer, "ShowReward", "Ви отримали " .. rewardAmount .. " за арешт!")
		end
	end
end

local function handleCuffedDisconnect(player, character)
	local data = playerData[player]
	if not data then return end

	data.offenses = (data.offenses or 0) + 1
	local offenseLevel = math.min(data.offenses, #JAIL_TIMES)

	local saveData = {
		jailTimer = JAIL_TIMES[offenseLevel] * RAGE_QUIT_CUFFED_MULTIPLIER,
		jailFine = FINE_AMOUNTS[offenseLevel] * RAGE_QUIT_CUFFED_MULTIPLIER,
		arrestingOfficerId = character:GetAttribute("ArrestingOfficer"),
		offenses = data.offenses
	}
	pcall(function() JailDataStore:SetAsync(tostring(player.UserId), saveData) end)
end

Players.PlayerAdded:Connect(function(player)
	local success, savedData = pcall(function() return JailDataStore:GetAsync(tostring(player.UserId)) end)
	if success and savedData and savedData.banned then
		if os.time() < (savedData.banUntil or 0) then
			local timeLeft = savedData.banUntil - os.time()
			local hoursLeft = math.floor(timeLeft / 3600)
			local minutesLeft = math.floor((timeLeft % 3600) / 60)
			player:Kick(string.format("❌ Ви заблоковані!\nЧас до розблокування: %d год %d хв", hoursLeft, minutesLeft))
			return
		else
			pcall(function() JailDataStore:RemoveAsync(tostring(player.UserId)) end)
			savedData = nil
		end
	end

	playerData[player] = {
		isWanted = false, offenses = 0, jailTimer = 0, jailFine = 0, bounty = 0,
		policeCooldown = 0, isBeingTeleported = false, bountyDecayCooldown = 0,
		arrestingOfficerId = nil,
		isSettingWanted = false,
		lastUIUpdate = 0
	}

	if success and savedData and not savedData.banned then
		savedData.jailTimer = (savedData.jailTimer or 0) * RAGE_QUIT_TIME_MULTIPLIER
		savedData.jailFine = (savedData.jailFine or 0) * RAGE_QUIT_FINE_MULTIPLIER
	end

	player.CharacterAdded:Connect(function(character)
		task.wait(1.5)
		local data = playerData[player]
		if not data then return end

		character:SetAttribute("isWanted", data.isWanted)
		character:SetAttribute("isCuffed", false)

		if data.jailTimer > 0 then
			jailPlayer(player, { jailTimer = data.jailTimer, jailFine = data.jailFine, arrestingOfficerId = data.arrestingOfficerId, offenses = data.offenses })
			return
		end

		if success and savedData and not savedData.banned and jailSpawnPosition then
			task.wait(0.5)
			jailPlayer(player, savedData)
			savedData = nil
		end

		character.Destroying:Connect(function()
			if character:GetAttribute("isCuffed") then
				handleCuffedDisconnect(player, character)
			end
		end)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	local data = playerData[player]
	local character = player.Character

	if data and character and character:GetAttribute("isCuffed") then
		handleCuffedDisconnect(player, character)
	elseif data and data.jailTimer > 0 and not isPrivateServer then
		local saveData = {
			jailTimer = data.jailTimer,
			jailFine = data.jailFine,
			arrestingOfficerId = data.arrestingOfficerId,
			offenses = data.offenses
		}
		pcall(function() JailDataStore:SetAsync(tostring(player.UserId), saveData) end)
	end

	processedArrests[player.UserId] = nil
	playerData[player] = nil
end)

JailEvent.OnServerEvent:Connect(function(player, action)
	local data = playerData[player]
	if not data or data.jailTimer <= 0 then
		return
	end

	if action == "PayFine" then
		if data.jailFine <= 0 then
			JailEvent:FireClient(player, "ShowWarning", "Сплата штрафу неможлива! (0 EXP)")
			return
		end

		local leaderstats = player:FindFirstChild("leaderstats")
		local exp = leaderstats and leaderstats:FindFirstChild("EXP")

		if not exp then
			JailEvent:FireClient(player, "ShowWarning", "Помилка: EXP не знайдено!")
			return
		end

		if exp.Value >= data.jailFine then
			exp.Value = exp.Value - data.jailFine
			releasePlayerFromJail(player, "Ви сплатили штраф!")
		else
			JailEvent:FireClient(player, "ShowWarning", string.format("Недостатньо EXP! (Потрібно: %d, є: %d)", data.jailFine, exp.Value))
		end
	end
end)

PoliceLocatorEvent.OnServerEvent:Connect(function(player, action)
	if action == "FindCriminals" then
		local data = playerData[player]
		if not data or (player.Team and player.Team.Name ~= POLICE_TEAM_NAME) then return end

		if data.policeCooldown > 0 then
			PoliceLocatorEvent:FireClient(player, "CooldownActive", data.policeCooldown)
			return
		end

		data.policeCooldown = 60
		local wantedPositions = {}

		for otherPlayer, otherData in pairs(playerData) do
			if otherData.isWanted and otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
				table.insert(wantedPositions, otherPlayer.Character.HumanoidRootPart.Position)
			end
		end
		PoliceLocatorEvent:FireClient(player, "ShowCriminals", wantedPositions)
	end
end)

RequestReleaseEvent.OnServerEvent:Connect(function(player)
	local data = playerData[player]
	local character = player.Character
	if not data or not character or not character:GetAttribute("isCuffed") then return end

	local leaderstats = player:FindFirstChild("leaderstats")
	local exp = leaderstats and leaderstats:FindFirstChild("EXP")
	if not exp or exp.Value >= 2000 then return end

	local arrestingOfficerId = character:GetAttribute("ArrestingOfficer")
	if not arrestingOfficerId then return end

	local officerPlayer = Players:GetPlayerByUserId(arrestingOfficerId)
	if officerPlayer then
		-- Змінено: тепер показуємо офіцеру кнопку для звільнення
		JailEvent:FireClient(officerPlayer, "ShowReleasePrompt", player)
	end
end)

-- ========== НОВИЙ ОБРОБНИК ПОДІЇ ДЛЯ ЗВІЛЬНЕННЯ ==========
ReleasePlayerEvent.OnServerEvent:Connect(function(officerPlayer, targetPlayer)
	if not officerPlayer or not targetPlayer then return end

	-- Перевірка: чи офіцер - поліцейський, і чи він дійсно заарештував цього гравця
	if officerPlayer.Team and officerPlayer.Team.Name == POLICE_TEAM_NAME then
		local targetCharacter = targetPlayer.Character
		if targetCharacter and targetCharacter:GetAttribute("isCuffed") and targetCharacter:GetAttribute("ArrestingOfficer") == officerPlayer.UserId then
			uncuffAndReleasePlayer(targetPlayer)
		end
	end
end)
-- ==========================================================

RunService.Heartbeat:Connect(function(deltaTime)
	for player, data in pairs(playerData) do
		if data.policeCooldown > 0 then data.policeCooldown -= deltaTime end

		local character = player.Character
		local isCuffed = character and character:GetAttribute("isCuffed")

		if data.isWanted and not isCuffed and data.bounty > MINIMUM_BOUNTY then
			data.bountyDecayCooldown -= deltaTime
			if data.bountyDecayCooldown <= 0 then
				data.bounty = math.max(MINIMUM_BOUNTY, data.bounty - BOUNTY_DECAY_AMOUNT)
				data.bountyDecayCooldown = BOUNTY_DECAY_INTERVAL
			end
		end

		if data.jailTimer > 0 and character then
			data.jailTimer -= deltaTime

			if not data.lastUIUpdate or (tick() - data.lastUIUpdate) >= 0.5 then
				data.lastUIUpdate = tick()
				JailEvent:FireClient(player, "UpdateJailTimer", data.jailTimer)
			end

			if data.jailTimer <= 0 then
				releasePlayerFromJail(player, "Термін ув'язнення закінчився!")
				continue
			end

			if jailZonePart and character:FindFirstChild("HumanoidRootPart") and not data.isBeingTeleported then
				local hrp = character.HumanoidRootPart
				local distance = (hrp.Position - jailZonePart.Position).Magnitude
				local maxDistance = (math.max(jailZonePart.Size.X, jailZonePart.Size.Z) / 2 + 5)

				if distance > maxDistance then
					data.isBeingTeleported = true
					hrp.CFrame = CFrame.new(jailSpawnPosition)
					hrp.Velocity = Vector3.new(0, 0, 0)
					hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
					data.jailTimer += 30
					JailEvent:FireClient(player, "UpdateJailTime", data.jailTimer, "Покарання за спробу втечі!")
					task.wait(1.5)
					data.isBeingTeleported = false
				end
			end
		end
	end
end)

task.wait(1)

for _, part in ipairs(workspace:GetDescendants()) do
	if part:IsA("BasePart") and part.Name == WANTED_PART_NAME then
		part.CanTouch = true
		part.Touched:Connect(function(otherPart)
			local player = Players:GetPlayerFromCharacter(otherPart.Parent)
			if not player then return end
			local data = playerData[player]

			if not data or data.jailTimer > 0 or data.isWanted or data.isSettingWanted then return end

			setWantedStatus(player, "Вам видано розшук за те що ви ходите по діючим коліям метрополітену!")
		end)
	end
end

jailZonePart = workspace:FindFirstChild(JAIL_ZONE_NAME)
if jailZonePart then
	jailSpawnPosition = jailZonePart.Position + Vector3.new(0, 3, 0)
	jailZonePart.CanTouch = true
	jailZonePart.CanCollide = false
	jailZonePart.Transparency = 0.8

	jailZonePart.Touched:Connect(function(hit)
		local character = hit.Parent
		if not character then return end
		local criminalPlayer = Players:GetPlayerFromCharacter(character)
		if not criminalPlayer or not playerData[criminalPlayer] then return end

		local data = playerData[criminalPlayer]
		local isCuffed = character:GetAttribute("isCuffed")
		local arrestingOfficerId = character:GetAttribute("ArrestingOfficer")

		if isCuffed and arrestingOfficerId then
			local arrestingOfficer = Players:GetPlayerByUserId(arrestingOfficerId)
			jailPlayer(criminalPlayer, nil, arrestingOfficer)
		elseif data.isWanted then
			jailPlayer(criminalPlayer, nil, nil)
		end
	end)
end