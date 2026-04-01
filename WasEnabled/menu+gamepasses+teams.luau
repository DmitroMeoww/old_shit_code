local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local TARGET_PLACE_ID_UNDERGROUND = 71310371117948

local changeTeamEvent = ReplicatedStorage:WaitForChild("ChangeTeamG")
local attemptEnterUndergroundEvent = ReplicatedStorage:WaitForChild("AttemptEnterUndergroundEvent")
local undergroundAccessResultEvent = ReplicatedStorage:WaitForChild("UndergroundAccessResultEvent")

-- --- НОВЕ: Список станцій, доступних для ЧПС ---
local DSP_STATIONS = {
	Lisova = "Lisova_OccupiedBy"
}

-- --- НОВЕ: Функція для очищення слоту ЧПС для гравця ---
local function clearPlayerDspStation(player)
	local dspTeam = Teams:FindFirstChild("ЧПС")
	if not dspTeam then return end

	for stationName, attributeName in pairs(DSP_STATIONS) do
		if dspTeam:GetAttribute(attributeName) == player.UserId then
			dspTeam:SetAttribute(attributeName, 0) -- 0 означає "вільно"
			print("DSP station cleared for player:", player.Name, "at", stationName)
			break -- Гравець може займати лише одну станцію
		end
	end
end


-- --- ЗМІНЕНО: Обробник тепер приймає назву станції ---
local function onChangeTeamRequested(player, requestedTeamName, requestedStationName)
	local teamInstance = Teams:FindFirstChild(requestedTeamName)
	if not teamInstance or not teamInstance:IsA("Team") then return end

	-- --- НОВЕ: Спеціальна логіка для ролі ЧПС ---
	if requestedTeamName == "ЧПС" then
		local dspTeam = teamInstance
		local attributeName = DSP_STATIONS[requestedStationName]

		-- Перевірка, чи це валідна станція для ЧПС і чи вона вільна
		if attributeName and dspTeam:GetAttribute(attributeName) == 0 then
			-- Перед тим, як зайняти новий слот, звільняємо старий (якщо був)
			clearPlayerDspStation(player)

			-- Займаємо новий слот
			dspTeam:SetAttribute(attributeName, player.UserId)
			print("DSP station assigned to player:", player.Name, "at", requestedStationName)

		elseif attributeName and dspTeam:GetAttribute(attributeName) ~= 0 then
			-- Станція зайнята, нічого не робимо. Клієнт не мав би цього відправити.
			warn("Player", player.Name, "attempted to take an occupied DSP station:", requestedStationName)
			return
		else 
			-- Невалідна станція для ЧПС або інша помилка
			warn("Player", player.Name, "requested invalid DSP station:", requestedStationName)
			return
		end
	else
		-- Якщо гравець переходить з ЧПС на іншу роль, звільняємо його станцію
		if player.Team and player.Team.Name == "ЧПС" then
			clearPlayerDspStation(player)
		end
	end

	-- Загальна логіка зміни команди
	player.Team = teamInstance
	player:LoadCharacter()
end

changeTeamEvent.OnServerEvent:Connect(onChangeTeamRequested)


-- --- НОВЕ: Ініціалізація атрибутів при старті сервера ---
local function initializeDspTeam()
	local dspTeam = Teams:FindFirstChild("ЧПС")
	if dspTeam then
		for _, attributeName in pairs(DSP_STATIONS) do
			-- Встановлюємо атрибут, лише якщо його ще немає
			if dspTeam:GetAttribute(attributeName) == nil then
				dspTeam:SetAttribute(attributeName, 0) -- 0 = вільно
			end
		end
		print("DSP Team attributes initialized.")
	else
		warn("DSP Team not found during initialization!")
	end
end

-- Спробуємо ініціалізувати одразу, і якщо команди ще немає, то при її появі
initializeDspTeam()
Teams.ChildAdded:Connect(function(child)
	if child.Name == "ЧПС" and child:IsA("Team") then
		initializeDspTeam()
	end
end)

-- --- НОВЕ: Обробник виходу гравця для очищення слоту ЧПС ---
Players.PlayerRemoving:Connect(function(player)
	clearPlayerDspStation(player)
end)


-- Логіка телепорту (без змін)
local function onAttemptEnterUnderground(player)
	local hasAccess = true 
	local message = "Підземна частина знаходиться в розробці. Ви будете телепортовані. Будьте обережні!"
	local isTeleporting = true

	undergroundAccessResultEvent:FireClient(player, true, message, isTeleporting)

	local playersToTeleport = {player}
	local teleportOptions = Instance.new("TeleportOptions")
	teleportOptions.ShouldReserveServer = false 

	local successTeleport, teleportError = pcall(function()
		TeleportService:TeleportAsync(TARGET_PLACE_ID_UNDERGROUND, playersToTeleport, teleportOptions)
	end)

	if not successTeleport then
		local failMessage = "Помилка телепортації: " .. tostring(teleportError) .. ". Доступ підтверджено, але ви залишаєтесь тут."
		undergroundAccessResultEvent:FireClient(player, true, failMessage, false) 
	end
end

attemptEnterUndergroundEvent.OnServerEvent:Connect(onAttemptEnterUnderground)