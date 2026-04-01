local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local alertStatus = workspace.isAlertDeclared.Value
local warningEvent = ReplicatedStorage:WaitForChild("AirRaidWarningEvent")

local warnedPlayers = {} -- { [Player] = { WarnStartTime = tick(), PenaltyPending = true } }
local MIN_SPEED_THRESHOLD = 5
local WARNING_DURATION = 30 -- секунд
local EXP_PENALTY = 50
local CHECK_INTERVAL = 1 -- Як часто перевіряти (в секундах)

-- --- Функції ---

-- Перевірка, чи гравець порушує правила
local function isPlayerViolating(player)
	if not alertStatus.Value then return false end -- Немає тривоги

	local character = player.Character
	if not character then return false end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return false end -- Гравець не живий

	local seat = humanoid.SeatPart
	-- Перевіряємо, що це саме VehicleSeat
	if not (seat and seat:IsA("VehicleSeat")) then return false end

	-- Перевіряємо швидкість через HumanoidRootPart (надійніше для транспорту)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	local velocity = hrp.AssemblyLinearVelocity
	-- Можна перевіряти тільки горизонтальну швидкість, якщо потрібно
	local horizontalVelocity = Vector3.new(velocity.X, 0, velocity.Z)

	-- Якщо швидкість більша за поріг - порушує
	if horizontalVelocity.Magnitude > MIN_SPEED_THRESHOLD then
		return true
	else
		return false
	end
end

-- Застосування штрафу
local function applyPenalty(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		warn("Не знайдено leaderstats для гравця:", player.Name)
		return
	end

	local exp = leaderstats:FindFirstChild("EXP")
	if not exp or not exp:IsA("IntValue") and not exp:IsA("NumberValue") then -- Перевірка типу
		warn("Не знайдено EXP або невірний тип для гравця:", player.Name)
		return
	end

	exp.Value = exp.Value - EXP_PENALTY
	print(string.format("Гравець %s отримав штраф -%d EXP за їзду під час тривоги.", player.Name, EXP_PENALTY))
end

-- Очищення стану попередження для гравця
local function clearWarningState(player)
	if warnedPlayers[player] then
		warnedPlayers[player] = nil
		warningEvent:FireClient(player, false) -- Сказати клієнту приховати GUI
		print(player.Name .. " припинив порушення або тривога закінчилась. Попередження знято.")
	end
end

-- --- Головний цикл перевірки ---
RunService.Heartbeat:Connect(function(deltaTime)
	-- Цей цикл виконується дуже часто, можна додати затримку, якщо не потрібна така точність
	-- Наприклад, додати змінну timeSinceLastCheck і перевіряти кожні CHECK_INTERVAL секунд

	for _, player in ipairs(Players:GetPlayers()) do
		if isPlayerViolating(player) then
			-- Гравець порушує
			if not warnedPlayers[player] then
				-- Якщо гравця ще не попереджали, почати відлік
				warnedPlayers[player] = { WarnStartTime = tick(), PenaltyPending = true }
				warningEvent:FireClient(player, true) -- Сказати клієнту показати GUI
				print("Попереджено гравця:", player.Name)
			else
				-- Якщо гравець вже попереджений, перевірити час
				local data = warnedPlayers[player]
				if data.PenaltyPending and (tick() - data.WarnStartTime >= WARNING_DURATION) then
					-- Час вийшов і штраф ще не застосовано
					applyPenalty(player)
					data.PenaltyPending = false -- Позначити, що штраф застосовано (щоб не штрафувати постійно)
					-- Попередження залишається активним, поки гравець не зупиниться
				end
			end
		else
			-- Гравець НЕ порушує (або тривога закінчилась)
			if warnedPlayers[player] then
				-- Якщо було попередження, зняти його
				clearWarningState(player)
			end
		end
	end
end)

-- --- Обробка виходу гравця ---
Players.PlayerRemoving:Connect(function(player)
	if warnedPlayers[player] then
		warnedPlayers[player] = nil -- Очистити дані при виході
	end
end)

-- --- Обробка зміни статусу тривоги ---
alertStatus.Changed:Connect(function(newValue)
	if not newValue then -- Якщо тривога закінчилась
		print("Тривога закінчилась. Зняття всіх активних попереджень.")
		-- Пройтись по всіх попереджених гравцях і зняти попередження
		for player, _ in pairs(warnedPlayers) do
			clearWarningState(player)
		end
		warnedPlayers = {} -- Очистити таблицю повністю (про всяк випадок)
	end
end)

print("AirRaidPenaltyHandler запущено.")