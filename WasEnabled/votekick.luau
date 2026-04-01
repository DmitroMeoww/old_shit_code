--[[
	VOTEKICK SYSTEM - Server Script
	ServerScriptService
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local DataStoreService = game:GetService("DataStoreService")
local TextChatService = game:GetService("TextChatService")

local BanDataStore = DataStoreService:GetDataStore("VotekickBans")

local WEBHOOK_URL = "https://discordapp.com/api/webhooks/1457799890083250343/ugaErydhJ4GhiMgRM5M0V4aQBVZTz-cNLFyxpdlKu8t9hajMIEqU00obi8BRSkmq7w7L"
local OWNER_ID = 1385423455

local VOTE_DURATION = 90
local BAN_DURATION = 3600
local REMINDER_INTERVAL = 120
local VOTEKICK_COOLDOWN = 300

local VotekickFolder = Instance.new("Folder")
VotekickFolder.Name = "VotekickSystem"
VotekickFolder.Parent = ReplicatedStorage

local StartVotekickEvent = Instance.new("RemoteEvent")
StartVotekickEvent.Name = "StartVotekick"
StartVotekickEvent.Parent = VotekickFolder

local CastVoteEvent = Instance.new("RemoteEvent")
CastVoteEvent.Name = "CastVote"
CastVoteEvent.Parent = VotekickFolder

local ShowVotingUIEvent = Instance.new("RemoteEvent")
ShowVotingUIEvent.Name = "ShowVotingUI"
ShowVotingUIEvent.Parent = VotekickFolder

local UpdateVotesEvent = Instance.new("RemoteEvent")
UpdateVotesEvent.Name = "UpdateVotes"
UpdateVotesEvent.Parent = VotekickFolder

local EndVotingEvent = Instance.new("RemoteEvent")
EndVotingEvent.Name = "EndVoting"
EndVotingEvent.Parent = VotekickFolder

local OpenVotekickMenuEvent = Instance.new("RemoteEvent")
OpenVotekickMenuEvent.Name = "OpenVotekickMenu"
OpenVotekickMenuEvent.Parent = VotekickFolder

local ChatReminderEvent = Instance.new("RemoteEvent")
ChatReminderEvent.Name = "ChatReminder"
ChatReminderEvent.Parent = VotekickFolder

local NotifyEvent = Instance.new("RemoteEvent")
NotifyEvent.Name = "Notify"
NotifyEvent.Parent = VotekickFolder

local currentVote = nil
local votedPlayers = {}
local votesFor = 0
local votesAgainst = 0
local lastVotekickTime = 0

local function sendWebhook(title, description, color)
	local data = {
		embeds = {{
			title = title,
			description = description,
			color = color or 16776960,
			timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
			footer = {
				text = "Votekick System | Server: " .. game.JobId
			}
		}}
	}

	pcall(function()
		HttpService:PostAsync(WEBHOOK_URL, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
	end)
end

local function isPlayerBanned(userId)
	local success, banData = pcall(function()
		return BanDataStore:GetAsync("Ban_" .. tostring(userId) .. "_" .. game.JobId)
	end)

	if success and banData then
		local banEndTime = banData.banEndTime
		if os.time() < banEndTime then
			return true, banData
		else
			pcall(function()
				BanDataStore:RemoveAsync("Ban_" .. tostring(userId) .. "_" .. game.JobId)
			end)
		end
	end

	return false, nil
end

local function unbanPlayer(playerName)
	local success, result = pcall(function()
		local pages = BanDataStore:ListKeysAsync()
		while true do
			local items = pages:GetCurrentPage()
			for _, item in ipairs(items) do
				local key = item.KeyName
				if string.find(key, game.JobId) then
					local banData = BanDataStore:GetAsync(key)
					if banData and banData.playerName and string.lower(banData.playerName) == string.lower(playerName) then
						BanDataStore:RemoveAsync(key)
						return banData
					end
				end
			end
			if pages.IsFinished then break end
			pages:AdvanceToNextPageAsync()
		end
		return nil
	end)
	return success, result
end

local function banPlayer(userId, playerName, reason, initiator)
	local banEndTime = os.time() + (BAN_DURATION * 60)

	local banData = {
		bannedAt = os.time(),
		banEndTime = banEndTime,
		reason = reason,
		initiator = initiator,
		playerName = playerName
	}

	pcall(function()
		BanDataStore:SetAsync("Ban_" .. tostring(userId) .. "_" .. game.JobId, banData)
	end)

	sendWebhook(
		"🔨 ГРАВЕЦЬ ЗАБАНЕНИЙ",
		string.format(
			"**Гравець:** %s (ID: %s)\n**Причина:** %s\n**Ініціатор:** %s\n**Тривалість:** %d хвилин",
			playerName, tostring(userId), reason, initiator, BAN_DURATION
		),
		16711680
	)
end

local function getEligibleVoters()
	local count = 0
	for _, p in pairs(Players:GetPlayers()) do
		if not currentVote or p.UserId ~= currentVote.targetId then
			count = count + 1
		end
	end
	return count
end

local function getRequiredVotes()
	local eligible = getEligibleVoters()
	return math.max(eligible - 2, 1)
end

local function endVoting(forced)
	if not currentVote then return end

	local eligibleVoters = getEligibleVoters()
	local requiredVotes = getRequiredVotes()
	local voteSuccess = votesFor >= requiredVotes

	for _, player in pairs(Players:GetPlayers()) do
		EndVotingEvent:FireClient(player, voteSuccess, currentVote.targetName, votesFor, votesAgainst, requiredVotes)
	end

	if voteSuccess then
		local targetPlayer = nil
		for _, p in pairs(Players:GetPlayers()) do
			if p.UserId == currentVote.targetId then
				targetPlayer = p
				break
			end
		end

		banPlayer(currentVote.targetId, currentVote.targetName, currentVote.reason, currentVote.initiator)

		if targetPlayer then
			targetPlayer:Kick(string.format(
				"⛔ Вас вигнали через votekick!\n\nПричина: %s\nВи забанені на %d хвилин на цьому сервері.\n\n⚠️ Зловживання системою votekick є КАРАНИМ!",
				currentVote.reason,
				BAN_DURATION
				))
		end

		sendWebhook(
			"✅ ГОЛОСУВАННЯ УСПІШНЕ",
			string.format(
				"**Ціль:** %s була вигнана!\n**Голоси ЗА:** %d / %d\n**Голоси ПРОТИ:** %d\n**Голосуючих:** %d%s",
				currentVote.targetName, votesFor, requiredVotes, votesAgainst, eligibleVoters,
				forced and "\n**Достроково:** Так" or ""
			),
			65280
		)
	else
		sendWebhook(
			"❌ ГОЛОСУВАННЯ НЕВДАЛЕ",
			string.format(
				"**Ціль:** %s залишається!\n**Голоси ЗА:** %d / %d\n**Голоси ПРОТИ:** %d",
				currentVote.targetName, votesFor, requiredVotes, votesAgainst
			),
			8421504
		)
	end

	lastVotekickTime = os.time()
	currentVote = nil
	votedPlayers = {}
	votesFor = 0
	votesAgainst = 0
end

local function checkVoteThreshold()
	if not currentVote then return false end

	local eligibleVoters = getEligibleVoters()
	local requiredVotes = getRequiredVotes()

	if votesFor >= requiredVotes then
		endVoting(true)
		return true
	end

	local maxPossibleVotes = votesFor + (eligibleVoters - votesFor - votesAgainst)
	if maxPossibleVotes < requiredVotes then
		endVoting(true)
		return true
	end

	return false
end

local function updateAllClients()
	if not currentVote then return end
	local eligibleVoters = getEligibleVoters()
	local requiredVotes = getRequiredVotes()
	for _, p in pairs(Players:GetPlayers()) do
		UpdateVotesEvent:FireClient(p, votesFor, votesAgainst, eligibleVoters, -1, requiredVotes)
	end
end

local function createCommands()
	local textChatCommands = TextChatService:WaitForChild("TextChatCommands", 10)
	if not textChatCommands then return end

	if not textChatCommands:FindFirstChild("VotekickCommand") then
		local votekickCommand = Instance.new("TextChatCommand")
		votekickCommand.Name = "VotekickCommand"
		votekickCommand.PrimaryAlias = "/votekick"
		votekickCommand.SecondaryAlias = "/vk"
		votekickCommand.Enabled = true
		votekickCommand.Parent = textChatCommands

		votekickCommand.Triggered:Connect(function(textSource, message)
			local player = Players:GetPlayerByUserId(textSource.UserId)
			if player then
				if currentVote then
					NotifyEvent:FireClient(player, "Голосування вже йде!", "warning")
					return
				end

				local timeSinceLast = os.time() - lastVotekickTime
				if timeSinceLast < VOTEKICK_COOLDOWN then
					local remaining = VOTEKICK_COOLDOWN - timeSinceLast
					NotifyEvent:FireClient(player, "Кулдаун! Зачекайте " .. remaining .. " сек", "warning")
					return
				end

				OpenVotekickMenuEvent:FireClient(player)

				sendWebhook(
					"📋 МЕНЮ VOTEKICK ВІДКРИТО",
					string.format("**Гравець:** %s відкрив меню votekick", player.Name),
					3447003
				)
			end
		end)
	end

	if not textChatCommands:FindFirstChild("VkUnbanCommand") then
		local unbanCommand = Instance.new("TextChatCommand")
		unbanCommand.Name = "VkUnbanCommand"
		unbanCommand.PrimaryAlias = "/vkunban"
		unbanCommand.Enabled = true
		unbanCommand.Parent = textChatCommands

		unbanCommand.Triggered:Connect(function(textSource, message)
			local player = Players:GetPlayerByUserId(textSource.UserId)
			if not player then return end

			if player.UserId ~= OWNER_ID then
				NotifyEvent:FireClient(player, "Тільки овнер може розбанювати!", "error")
				return
			end

			local args = string.split(message, " ")
			if #args < 2 then
				NotifyEvent:FireClient(player, "Використання: /vkunban [username]", "warning")
				return
			end

			local targetName = args[2]
			local success, result = unbanPlayer(targetName)

			if success and result then
				NotifyEvent:FireClient(player, "Гравець " .. targetName .. " розбанений!", "success")
				sendWebhook(
					"🔓 ГРАВЕЦЬ РОЗБАНЕНИЙ",
					string.format("**Гравець:** %s\n**Розбанив:** %s", targetName, player.Name),
					65280
				)
			else
				NotifyEvent:FireClient(player, "Гравця не знайдено в бан-листі", "error")
			end
		end)
	end
end

Players.PlayerAdded:Connect(function(player)
	local isBanned, banData = isPlayerBanned(player.UserId)

	if isBanned then
		local remainingTime = math.ceil((banData.banEndTime - os.time()) / 60)
		player:Kick(string.format(
			"⛔ Ви забанені на цьому сервері через votekick!\n\nПричина: %s\nЗалишилось: %d хвилин\n\n⚠️ Абьюз системи votekick є КАРАНИМ!",
			banData.reason or "Не вказано",
			remainingTime
			))

		sendWebhook(
			"🚫 ЗАБЛОКОВАНИЙ ВХІД",
			string.format(
				"**Гравець:** %s намагався зайти на сервер\n**Бан закінчується через:** %d хвилин",
				player.Name, remainingTime
			),
			16744448
		)
		return
	end

	if currentVote and player.UserId ~= currentVote.targetId then
		local eligibleVoters = getEligibleVoters()
		local requiredVotes = getRequiredVotes()
		local timeLeft = VOTE_DURATION - (os.time() - currentVote.startTime)
		if timeLeft > 0 then
			ShowVotingUIEvent:FireClient(player, currentVote.targetName, currentVote.reason, currentVote.initiator, timeLeft, false, false, eligibleVoters, requiredVotes)
		end
		updateAllClients()
	end
end)

StartVotekickEvent.OnServerEvent:Connect(function(initiator, targetUserId, reason)
	if currentVote then return end

	local timeSinceLast = os.time() - lastVotekickTime
	if timeSinceLast < VOTEKICK_COOLDOWN then
		local remaining = VOTEKICK_COOLDOWN - timeSinceLast
		NotifyEvent:FireClient(initiator, "Кулдаун! Зачекайте " .. remaining .. " сек", "warning")
		return
	end

	if targetUserId == OWNER_ID then
		NotifyEvent:FireClient(initiator, "Неможливо кікнути овнера гри!", "error")
		return
	end

	local targetPlayer = nil
	for _, p in pairs(Players:GetPlayers()) do
		if p.UserId == targetUserId then
			targetPlayer = p
			break
		end
	end

	if not targetPlayer then return end
	if targetPlayer == initiator then return end

	currentVote = {
		target = targetPlayer,
		targetId = targetUserId,
		targetName = targetPlayer.Name,
		reason = reason or "Не вказано",
		initiator = initiator.Name,
		initiatorId = initiator.UserId,
		startTime = os.time()
	}

	votedPlayers = {}
	votesFor = 0
	votesAgainst = 0

	votedPlayers[initiator.UserId] = true
	votedPlayers[targetUserId] = true
	votesFor = 1

	local eligibleVoters = getEligibleVoters()
	local requiredVotes = getRequiredVotes()

	for _, player in pairs(Players:GetPlayers()) do
		local isInitiator = player.UserId == initiator.UserId
		local isTarget = player.UserId == targetUserId
		ShowVotingUIEvent:FireClient(player, currentVote.targetName, currentVote.reason, currentVote.initiator, VOTE_DURATION, isInitiator, isTarget, eligibleVoters, requiredVotes)
	end

	sendWebhook(
		"🗳️ ГОЛОСУВАННЯ РОЗПОЧАТО",
		string.format(
			"**Ініціатор:** %s (автоматично ЗА)\n**Ціль:** %s (не може голосувати)\n**Причина:** %s\n**Потрібно голосів:** %d / %d",
			initiator.Name, targetPlayer.Name, reason, requiredVotes, eligibleVoters
		),
		16776960
	)

	if checkVoteThreshold() then return end

	task.spawn(function()
		local timeLeft = VOTE_DURATION

		while timeLeft > 0 and currentVote do
			task.wait(1)
			timeLeft = timeLeft - 1

			if timeLeft % 5 == 0 and currentVote then
				updateAllClients()
			end
		end

		if currentVote then
			endVoting(false)
		end
	end)
end)

CastVoteEvent.OnServerEvent:Connect(function(player, voteFor)
	if not currentVote then return end
	if votedPlayers[player.UserId] then return end
	if player.UserId == currentVote.targetId then return end

	votedPlayers[player.UserId] = true

	if voteFor then
		votesFor = votesFor + 1
	else
		votesAgainst = votesAgainst + 1
	end

	updateAllClients()

	sendWebhook(
		"🗳️ НОВИЙ ГОЛОС",
		string.format(
			"**Гравець:** %s проголосував %s\n**Поточний рахунок:** ЗА: %d / %d | ПРОТИ: %d",
			player.Name, voteFor and "ЗА" or "ПРОТИ", votesFor, getRequiredVotes(), votesAgainst
		),
		voteFor and 65280 or 16711680
	)

	checkVoteThreshold()
end)

Players.PlayerRemoving:Connect(function(player)
	if currentVote then
		task.wait(0.1)
		updateAllClients()
		checkVoteThreshold()
	end
end)

task.spawn(function()
	while true do
		task.wait(REMINDER_INTERVAL)
		if not currentVote then
			local timeSinceLast = os.time() - lastVotekickTime
			if timeSinceLast >= VOTEKICK_COOLDOWN then
				for _, player in pairs(Players:GetPlayers()) do
					ChatReminderEvent:FireClient(player)
				end
			end
		end
	end
end)

task.spawn(createCommands)