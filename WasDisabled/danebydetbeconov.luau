local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local TextChatService = game:GetService("TextChatService")
local DataStoreService = game:GetService("DataStoreService")

local LITE_VERSION_PLACE_ID = 81755063055861

local ASSET_IDS_TO_CHECK = {
	[63690008] = true, [86498048] = true, [144076760] = true,
	[144076358] = true, [62724852] = true, [144076436] = true,
}
local ASSET_WEARING_THRESHOLD = 3 

local ADMIN_USER_IDS = {[game.CreatorId] = true}

if game.PlaceId == LITE_VERSION_PLACE_ID then
	script:Destroy()
	return
end

local whitelistDataStore = DataStoreService:GetDataStore("PlayerWhitelistV2")
local whitelistCache = {}

local function saveWhitelist()
	local success, err = pcall(function()
		whitelistDataStore:SetAsync("mainWhitelist", whitelistCache)
	end)
	if not success then
		warn("НЕ вдалося зберегти вайтлист! Помилка: ", err)
	end
end

local function loadWhitelist()
	local success, data = pcall(function()
		return whitelistDataStore:GetAsync("mainWhitelist")
	end)

	if success and type(data) == "table" then
		whitelistCache = data
	else
		warn("Не вдалося завантажити вайтлист або він порожній. Створено новий. Помилка: ", data)
		whitelistCache = {}
	end
end

local function addDefaultUserToWhitelist()
	local targetUsername = "salad6562636"
	local success, userId = pcall(Players.GetUserIdFromNameAsync, Players, targetUsername)

	if success and userId then
		local userIdStr = tostring(userId)
		if not whitelistCache[userIdStr] then
			whitelistCache[userIdStr] = true
			saveWhitelist()
		end
	end
end

local function checkPlayerAssetsAndTeleport(player)
	if whitelistCache[tostring(player.UserId)] then
		return
	end

	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	if not humanoid then return end

	local wornAssetsCount = 0
	local success, appliedDesc = pcall(function()
		return humanoid:GetAppliedDescription()
	end)

	if success and appliedDesc then
		local allWornIds = {}
		for _, item in ipairs(appliedDesc:GetChildren()) do
			if item:IsA("AccessoryDescription") or item:IsA("BodyPartDescription") then
				if item.AssetId > 0 then
					table.insert(allWornIds, item.AssetId)
				end
			end
		end

		if appliedDesc.Shirt > 0 then table.insert(allWornIds, appliedDesc.Shirt) end
		if appliedDesc.Pants > 0 then table.insert(allWornIds, appliedDesc.Pants) end
		if appliedDesc.GraphicTShirt > 0 then table.insert(allWornIds, appliedDesc.GraphicTShirt) end

		local alreadyChecked = {}
		for _, assetId in ipairs(allWornIds) do
			if not alreadyChecked[assetId] and ASSET_IDS_TO_CHECK[assetId] then
				wornAssetsCount += 1
				alreadyChecked[assetId] = true
			end
		end
	else
		warn("Не вдалося отримати опис аватара для " .. player.Name .. ". Помилка: " .. tostring(appliedDesc))
	end

	if wornAssetsCount >= ASSET_WEARING_THRESHOLD then
		TeleportService:TeleportAsync(LITE_VERSION_PLACE_ID, {player})
	end
end

local function setupChatCommands()
	local function processWhitelistCommand(source, message, isAdding)
		if not ADMIN_USER_IDS[source.UserId] then return end

		local parts = string.split(message, " ")
		local targetUsername = parts[2]
		if not targetUsername then return end

		local success, userId = pcall(Players.GetUserIdFromNameAsync, Players, targetUsername)
		if not success or not userId then return end

		local userIdStr = tostring(userId)
		whitelistCache[userIdStr] = if isAdding then true else nil
		saveWhitelist()
	end

	local whitelistCommand = Instance.new("TextChatCommand")
	whitelistCommand.Name = "whitelist"
	whitelistCommand.PrimaryAlias = "/whitelist"
	whitelistCommand.Triggered:Connect(function(source, message)
		processWhitelistCommand(source, message, true)
	end)
	whitelistCommand.Parent = TextChatService

	local notWhitelistCommand = Instance.new("TextChatCommand")
	notWhitelistCommand.Name = "notwhitelist"
	notWhitelistCommand.PrimaryAlias = "/notwhitelist"
	notWhitelistCommand.Triggered:Connect(function(source, message)
		processWhitelistCommand(source, message, false)
	end)
	notWhitelistCommand.Parent = TextChatService
end

loadWhitelist()
task.spawn(addDefaultUserToWhitelist)
setupChatCommands()

Players.PlayerAdded:Connect(checkPlayerAssetsAndTeleport)

game:BindToClose(function()
	if #Players:GetPlayers() > 0 then
		task.wait(3)
	end
	saveWhitelist()
end)