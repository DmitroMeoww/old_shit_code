local TextChatService = game:GetService("TextChatService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local akademPlaceId = 86573843636941

local command = Instance.new("TextChatCommand")
command.Name = "toakadem"
command.PrimaryAlias = "/toakadem"
command.Parent = TextChatService

local function onCommandTriggered(textSource)
	local player = Players:GetPlayerByUserId(textSource.UserId)
	if player then
		TeleportService:Teleport(akademPlaceId, player)
	end
end

command.Triggered:Connect(onCommandTriggered)