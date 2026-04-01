-- Сервіси
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local DataStoreService = game:GetService("DataStoreService")
local AnalyticsService = game:GetService("AnalyticsService")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")

-- DataStore
local expDataStore = DataStoreService:GetDataStore("PlayerEXPv3")

-- Константи
local EXP_BOOST_GAME_PASS_ID = 1314829438
local EXP_AWARD_DISTANCE = 1000 -- Відстань для нарахування EXP
local MAX_RETRIES = 3 -- Кількість спроб завантаження DataStore
local DEFAULT_EXP = 0 -- Значення EXP, якщо завантаження повністю невдале
local MAX_SPEED = 82 -- Обмеження швидкості для захисту від експлойтів
local ADMIN_WAIT_TIME = 3 -- Час очікування для адмін-систем

-- Вайтліст для адмін-команд
local WHITELISTED_USERS = {
	[1385423455] = true
}

-- Перевірка чи це приватний сервер
local isPrivateServer = game.PrivateServerId ~= "" and game.PrivateServerOwnerId ~= 0
local privateServerWarningsShown = {} -- Таблиця для відстеження показаних попереджень

-- Кеш для збереження EXP значень (захист від втрати даних)
local playerExpCache = {}

--- Функції для роботи з даними гравця

-- Завантаження досвіду гравця з повторними спробами
local function loadPlayerEXP(player)
	-- Спочатку перевіряємо кеш
	if playerExpCache[player.UserId] then
		print("[EXP] Завантажено з кешу для " .. player.Name .. ": " .. playerExpCache[player.UserId])
		return playerExpCache[player.UserId]
	end

	-- Логіка завантаження з DataStore
	for i = 1, MAX_RETRIES do
		local success, result = pcall(function()
			return expDataStore:GetAsync(player.UserId)
		end)

		if success then
			local loadedExp = result or DEFAULT_EXP

			-- Зберігаємо в кеш
			playerExpCache[player.UserId] = loadedExp

			if isPrivateServer then
				print(string.format("[EXP] Приватний сервер: EXP завантажено (%d), але не буде зберігатися.", loadedExp))
			end

			return loadedExp 
		else
			warn("Failed to load EXP for player " .. player.Name .. ": " .. tostring(result) .. " (Attempt " .. i .. "/" .. MAX_RETRIES .. ")")
			if i < MAX_RETRIES then
				task.wait(2)
			end
		end
	end

	-- Якщо всі спроби невдалі
	warn("Fatal: All DataStore load attempts failed for " .. player.Name .. ". Defaulting to " .. DEFAULT_EXP)
	playerExpCache[player.UserId] = DEFAULT_EXP
	return DEFAULT_EXP
end

-- Збереження досвіду гравця
local function savePlayerEXP(player)
	-- Не зберігати дані на приватних серверах
	if isPrivateServer then
		print("[EXP] Приватний сервер: DataStore Save заблоковано.")
		return
	end

	-- Спробувати отримати EXP з leaderstats або з кешу
	local expValue = nil

	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local expInstance = leaderstats:FindFirstChild("EXP")
		if expInstance then
			expValue = expInstance.Value
		end
	end

	-- Якщо не знайдено в leaderstats, використовуємо кеш
	if expValue == nil then
		expValue = playerExpCache[player.UserId]
		if expValue then
			print("[EXP] Використовуємо кешоване значення для збереження: " .. expValue)
		end
	end

	if expValue == nil then
		warn("No EXP data found for player " .. player.Name .. " during save attempt (neither leaderstats nor cache).")
		return
	end

	local success, err = pcall(function()
		expDataStore:SetAsync(player.UserId, expValue)
	end)

	if not success then
		warn("Failed to save EXP for player " .. player.Name .. ": " .. tostring(err))
	else
		print("Successfully saved EXP for " .. player.Name .. ": " .. expValue)
	end
end

-- Показати попередження про приватний сервер
local function showPrivateServerWarning(player)
	if privateServerWarningsShown[player.UserId] then
		return
	end

	task.delay(15, function()
		if not player.Parent then return end
		if privateServerWarningsShown[player.UserId] then return end
		privateServerWarningsShown[player.UserId] = true

		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "PrivateServerWarning"
		screenGui.ResetOnSpawn = false

		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(0, 400, 0, 150)
		frame.Position = UDim2.new(0.5, -200, 0.5, -75)
		frame.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
		frame.BorderSizePixel = 2
		frame.BorderColor3 = Color3.fromRGB(200, 0, 0)
		frame.Parent = screenGui

		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, -20, 1, -60)
		textLabel.Position = UDim2.new(0, 10, 0, 10)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = "⚠️ УВАГА ⚠️\n\nЦе приватний сервер!\nДосвід тут не зараховується та не зберігається."
		textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		textLabel.TextScaled = true
		textLabel.Font = Enum.Font.SourceSansBold
		textLabel.Parent = frame

		local closeButton = Instance.new("TextButton")
		closeButton.Size = UDim2.new(0, 100, 0, 30)
		closeButton.Position = UDim2.new(0.5, -50, 1, -40)
		closeButton.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
		closeButton.Text = "Зрозуміло"
		closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		closeButton.Font = Enum.Font.SourceSans
		closeButton.TextScaled = true
		closeButton.Parent = frame

		closeButton.MouseButton1Click:Connect(function()
			screenGui:Destroy()
		end)

		task.spawn(function()
			task.wait(10)
			if screenGui.Parent then
				screenGui:Destroy()
			end
		end)

		local playerGui = player:FindFirstChild("PlayerGui")
		if playerGui then
			screenGui.Parent = playerGui
		end
	end)
end

-- Перевірка чи гравець сидить у VehicleSeat
local function isPlayerInVehicleSeat(player)
	local character = player.Character
	if not character then return false end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return false end
	local seat = humanoid.SeatPart
	return seat and seat:IsA("VehicleSeat")
end

-- Функція для пошуку гравця за ім'ям або ID
local function findPlayerByNameOrId(identifier)
	local userId = tonumber(identifier)
	if userId then
		for _, player in pairs(Players:GetPlayers()) do
			if player.UserId == userId then
				return player, userId
			end
		end
		return nil, userId
	else
		local targetPlayer = Players:FindFirstChild(identifier)
		if targetPlayer then
			return targetPlayer, targetPlayer.UserId
		end

		local success, foundUserId = pcall(function()
			return Players:GetUserIdFromNameAsync(identifier)
		end)

		if success and foundUserId then
			return nil, foundUserId
		end
	end
	return nil, nil
end

-- Обробка команд адміна
local function handleExpCommand(commandName, flowType, originTextSource, args, isRemoveCommand)
	local adminPlayer = Players:GetPlayerByUserId(originTextSource.UserId)
	if not adminPlayer or not WHITELISTED_USERS[adminPlayer.UserId] then 
		print("Access denied for user:", originTextSource.UserId)
		return 
	end

	if #args < 3 then 
		print("Not enough arguments. Usage: /" .. commandName:lower() .. " <player_name_or_id> <amount>")
		return 
	end

	local targetIdentifier = args[2]
	local amount = tonumber(args[3])

	if not targetIdentifier or not amount or amount <= 0 then 
		print("Invalid arguments. Amount must be a positive number.")
		return 
	end

	local targetPlayer, targetUserId = findPlayerByNameOrId(targetIdentifier)

	if not targetUserId then
		print("Player not found: " .. targetIdentifier)
		return
	end

	if targetPlayer then
		local leaderstats = targetPlayer:FindFirstChild("leaderstats")
		if not leaderstats or not leaderstats:FindFirstChild("EXP") then 
			print("No EXP data found for online player: " .. targetPlayer.Name)
			return 
		end

		local expInstance = leaderstats.EXP
		local oldValue = expInstance.Value
		local newValue = oldValue + (isRemoveCommand and -amount or amount)
		expInstance.Value = math.max(0, newValue)

		-- Оновлюємо кеш
		playerExpCache[targetPlayer.UserId] = expInstance.Value

		print(string.format("%s %d EXP for %s (online). Old: %d, New: %d", 
			isRemoveCommand and "Removed" or "Gave", 
			amount, 
			targetPlayer.Name, 
			oldValue, 
			expInstance.Value))

		if not RunService:IsStudio() then
			pcall(function()
				AnalyticsService:LogEconomyEvent(adminPlayer, flowType, "EXP", amount, expInstance.Value, "Admin" .. commandName, "TargetPlayer:" .. targetPlayer.Name)
			end)
		end
	else
		if isPrivateServer then
			print("Cannot modify offline player data on private servers.")
			return
		end

		local getSuccess, currentExp = pcall(function()
			return expDataStore:GetAsync(targetUserId)
		end)

		if getSuccess then
			local currentExpValue = currentExp or 0
			local newExp = isRemoveCommand and math.max(0, currentExpValue - amount) or (currentExpValue + amount)

			local saveSuccess, saveErr = pcall(function()
				expDataStore:SetAsync(targetUserId, newExp)
			end)

			if saveSuccess then
				print(string.format("%s %d EXP for UserID %d (offline). Old: %d, New: %d", 
					isRemoveCommand and "Removed" or "Gave", 
					amount, 
					targetUserId, 
					currentExpValue, 
					newExp))

				if not RunService:IsStudio() then
					pcall(function()
						AnalyticsService:LogEconomyEvent(adminPlayer, flowType, "EXP", amount, newExp, "Admin" .. commandName .. "Offline", "TargetUserId:" .. targetUserId)
					end)
				end
			else
				warn("Failed to save offline EXP for UserID " .. targetUserId .. ": " .. tostring(saveErr))
			end
		else
			warn("Failed to get offline EXP for UserID " .. targetUserId .. ": " .. tostring(currentExp))
		end
	end
end

-- Створення команд
local giveExpCommand = Instance.new("TextChatCommand")
giveExpCommand.Parent = TextChatService
giveExpCommand.Name = "giveexp"
giveExpCommand.PrimaryAlias = "/giveexp"
giveExpCommand.SecondaryAlias = "/gexp"
giveExpCommand.Triggered:Connect(function(originTextSource, unfilteredText)
	local args = unfilteredText:split(" ")
	handleExpCommand("GiveExp", Enum.AnalyticsEconomyFlowType.Source, originTextSource, args, false)
end)

local removeExpCommand = Instance.new("TextChatCommand")
removeExpCommand.Parent = TextChatService
removeExpCommand.Name = "removeexp"
removeExpCommand.PrimaryAlias = "/removeexp"
removeExpCommand.SecondaryAlias = "/rexp"
removeExpCommand.Triggered:Connect(function(originTextSource, unfilteredText)
	local args = unfilteredText:split(" ")
	handleExpCommand("RemoveExp", Enum.AnalyticsEconomyFlowType.Sink, originTextSource, args, true)
end)

--- Функції захисту від конфліктів з адмін-системами

-- Створення або отримання leaderstats з захистом
local function setupLeaderstats(player)
	-- Чекаємо, поки адмін-система створить свої дані
	task.wait(ADMIN_WAIT_TIME)

	-- Перевіряємо чи гравець все ще на сервері
	if not player.Parent then return nil, nil end

	-- Перевіряємо чи leaderstats вже існує
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
		print("[EXP] Створено нову папку leaderstats для " .. player.Name)
	else
		print("[EXP] Використовуємо існуючу папку leaderstats для " .. player.Name)
	end

	-- Перевіряємо чи EXP вже існує
	local exp = leaderstats:FindFirstChild("EXP")
	if not exp then
		exp = Instance.new("IntValue")
		exp.Name = "EXP"
		exp.Value = loadPlayerEXP(player)
		exp.Parent = leaderstats
		print("[EXP] Створено EXP для " .. player.Name .. " зі значенням: " .. exp.Value)
	else
		-- Якщо EXP існує але має значення 0, а в кеші є інше значення
		local cachedExp = playerExpCache[player.UserId]
		if exp.Value == 0 and cachedExp and cachedExp > 0 then
			exp.Value = cachedExp
			print("[EXP] Відновлено EXP з кешу для " .. player.Name .. ": " .. cachedExp)
		end
	end

	return leaderstats, exp
end

-- Захист EXP від видалення
local function protectEXP(player, leaderstats, exp)
	if not leaderstats or not exp then return end

	-- Оновлюємо кеш при зміні EXP
	exp.Changed:Connect(function(newValue)
		playerExpCache[player.UserId] = newValue
	end)

	-- Захист від видалення EXP
	leaderstats.ChildRemoved:Connect(function(child)
		if child.Name == "EXP" then
			warn("[EXP] EXP було видалено для " .. player.Name .. "! Відновлюємо...")
			task.wait(0.1)

			-- Перевіряємо чи гравець все ще на сервері
			if not player.Parent then return end

			-- Перевіряємо чи leaderstats все ще існує
			local currentLeaderstats = player:FindFirstChild("leaderstats")
			if not currentLeaderstats then
				currentLeaderstats = Instance.new("Folder")
				currentLeaderstats.Name = "leaderstats"
				currentLeaderstats.Parent = player
			end

			-- Перевіряємо чи EXP не було створено заново
			if not currentLeaderstats:FindFirstChild("EXP") then
				local newExp = Instance.new("IntValue")
				newExp.Name = "EXP"
				newExp.Value = playerExpCache[player.UserId] or loadPlayerEXP(player)
				newExp.Parent = currentLeaderstats
				print("[EXP] EXP відновлено для " .. player.Name .. " зі значенням: " .. newExp.Value)

				-- Підключаємо захист до нового EXP
				protectEXP(player, currentLeaderstats, newExp)
			end
		end
	end)

	-- Захист від видалення leaderstats
	leaderstats.AncestryChanged:Connect(function(_, parent)
		if parent == nil then
			warn("[EXP] leaderstats було видалено для " .. player.Name .. "! Відновлюємо...")
			task.wait(0.1)

			-- Перевіряємо чи гравець все ще на сервері
			if not player.Parent then return end

			-- Перевіряємо чи leaderstats не було створено заново
			local currentLeaderstats = player:FindFirstChild("leaderstats")
			if not currentLeaderstats then
				currentLeaderstats = Instance.new("Folder")
				currentLeaderstats.Name = "leaderstats"
				currentLeaderstats.Parent = player
				print("[EXP] leaderstats відновлено для " .. player.Name)
			end

			-- Створюємо EXP якщо його немає
			if not currentLeaderstats:FindFirstChild("EXP") then
				local newExp = Instance.new("IntValue")
				newExp.Name = "EXP"
				newExp.Value = playerExpCache[player.UserId] or loadPlayerEXP(player)
				newExp.Parent = currentLeaderstats
				print("[EXP] EXP відновлено після видалення leaderstats для " .. player.Name .. " зі значенням: " .. newExp.Value)

				-- Підключаємо захист до нового EXP
				protectEXP(player, currentLeaderstats, newExp)
			end
		end
	end)
end

-- Періодична перевірка цілісності даних
local function startIntegrityCheck(player)
	task.spawn(function()
		while player.Parent do
			task.wait(5) -- Перевіряємо кожні 5 секунд

			if not player.Parent then break end

			local leaderstats = player:FindFirstChild("leaderstats")
			local exp = leaderstats and leaderstats:FindFirstChild("EXP")

			if not leaderstats or not exp then
				warn("[EXP] Integrity check failed for " .. player.Name .. "! Відновлюємо дані...")

				local newLeaderstats, newExp = setupLeaderstats(player)
				if newLeaderstats and newExp then
					protectEXP(player, newLeaderstats, newExp)
				end
			end
		end
	end)
end

--- Основна логіка гри

-- Обробка входу гравця
Players.PlayerAdded:Connect(function(player)
	print("[EXP] Гравець приєднався: " .. player.Name)

	-- Показати попередження про приватний сервер
	if isPrivateServer then
		player.CharacterAdded:Connect(function()
			task.wait(2)
			showPrivateServerWarning(player)
		end)
		if player.Character then
			task.wait(2)
			showPrivateServerWarning(player)
		end
	end

	-- Передзавантажуємо EXP в кеш
	loadPlayerEXP(player)

	-- Створення leaderstats з захистом від конфліктів
	local leaderstats, exp = setupLeaderstats(player)

	if not leaderstats or not exp then
		warn("[EXP] Не вдалося створити leaderstats для " .. player.Name)
		return
	end

	-- Підключаємо захист
	protectEXP(player, leaderstats, exp)

	-- Запускаємо періодичну перевірку цілісності
	startIntegrityCheck(player)

	-- Перевірка наявності геймпасу
	local success, hasPass = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, EXP_BOOST_GAME_PASS_ID)
	end)

	if success and hasPass then
		player:SetAttribute("HasExpBoost", true)
		print(player.Name .. " has the 2x EXP game pass.")
	else
		player:SetAttribute("HasExpBoost", false)
		if not success then
			warn("Failed to check game pass for " .. player.Name .. ". Error: " .. tostring(hasPass))
		end
	end

	-- Логіка нарахування досвіду за відстань
	local lastPos = nil
	local distanceTraveled = 0
	local connection

	connection = RunService.Heartbeat:Connect(function(deltaTime)
		if not player:IsDescendantOf(Players) then
			connection:Disconnect()
			return
		end

		-- Не нараховувати досвід на приватних серверах
		if isPrivateServer then
			return
		end

		local char = player.Character
		if not char then return end
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then return end
		local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
		if not humanoidRootPart then return end

		if not isPlayerInVehicleSeat(player) then
			lastPos = nil
			distanceTraveled = 0
			return
		end

		-- Отримуємо актуальний EXP (з захистом від nil)
		local currentLeaderstats = player:FindFirstChild("leaderstats")
		local currentExp = currentLeaderstats and currentLeaderstats:FindFirstChild("EXP")

		if not currentExp then
			return -- Пропускаємо якщо EXP тимчасово недоступний
		end

		local currentPos = humanoidRootPart.Position
		if lastPos then
			local distanceMoved = (currentPos - lastPos).Magnitude
			local speed = deltaTime > 0 and distanceMoved / deltaTime or 0

			if speed <= MAX_SPEED then
				distanceTraveled += distanceMoved

				if distanceTraveled >= EXP_AWARD_DISTANCE then
					local expGain = 1
					if player:GetAttribute("HasExpBoost") then
						expGain = 2
					end

					currentExp.Value += expGain

					-- Оновлюємо кеш
					playerExpCache[player.UserId] = currentExp.Value

					if not RunService:IsStudio() then
						pcall(function()
							AnalyticsService:LogEconomyEvent(player, Enum.AnalyticsEconomyFlowType.Source, "EXP", expGain, currentExp.Value, "Gameplay", "DistanceTraveled")
						end)
					end

					distanceTraveled -= EXP_AWARD_DISTANCE
				end
			end
		end
		lastPos = currentPos
	end)
end)

-- Обробка виходу гравця
Players.PlayerRemoving:Connect(function(player)
	savePlayerEXP(player)

	-- Очищаємо кеш через деякий час (на випадок якщо збереження не встигло)
	task.delay(10, function()
		playerExpCache[player.UserId] = nil
	end)
end)

-- Збереження даних при закритті сервера
game:BindToClose(function()
	if RunService:IsStudio() then return end

	for _, player in ipairs(Players:GetPlayers()) do
		savePlayerEXP(player)
	end

	task.wait(2)
end)

print("[EXP System] Скрипт завантажено з захистом від конфліктів адмін-систем")