-- MetroChatTheme.lua
-- Помісти цей LocalScript у StarterPlayerScripts

local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")

-- Тема з твого меню
local Theme = {
	Background = Color3.fromRGB(6, 12, 23),
	PrimaryUI = Color3.fromRGB(14, 24, 49),
	PrimaryUI_Light = Color3.fromRGB(30, 48, 91),
	Accent = Color3.fromRGB(68, 214, 196),
	TextPrimary = Color3.fromRGB(225, 236, 255),
	TextSecondary = Color3.fromRGB(148, 168, 210),
	Success = Color3.fromRGB(88, 255, 197),
	Warning = Color3.fromRGB(255, 201, 92),
	Error = Color3.fromRGB(255, 105, 105),
	OutlineSoft = Color3.fromRGB(38, 62, 104)
}

-- Кольори для різних команд/ролей
local TeamColors = {
	["Administrator"] = Color3.fromRGB(144, 0, 0),
	["Machinist"] = Color3.fromRGB(74, 101, 255),
	["Neutral"] = Color3.fromRGB(180, 180, 180),
	["Passanger"] = Color3.fromRGB(88, 255, 197),
	["Диспетчер"] = Color3.fromRGB(255, 170, 50),
	["Модератор"] = Color3.fromRGB(255, 215, 0),
	["Поліція"] = Color3.fromRGB(68, 122, 255),
	["ЧПС"] = Color3.fromRGB(249, 249, 249),
	["Default"] = Theme.Accent
}

-- Бейджі для кожної ролі
local TeamBadges = {
	["Administrator"] = "🎫",
	["Machinist"] = "🚇",
	["Neutral"] = "👤",
	["Passanger"] = "🎫",
	["Диспетчер"] = "📡",
	["Модератор"] = "🛡️",
	["Поліція"] = "🚔",
	["ЧПС"] = "📋",
}

-- Функція для отримання кольору команди
local function GetTeamColor(player)
	if player and player.Team then
		return TeamColors[player.Team.Name] or TeamColors["Default"]
	end
	return TeamColors["Default"]
end

-- Функція для створення hex кольору
local function ColorToHex(color)
	return string.format("#%02X%02X%02X", 
		math.floor(color.R * 255), 
		math.floor(color.G * 255), 
		math.floor(color.B * 255)
	)
end

-- Кастомізація повідомлень
local function OnIncomingMessage(message)
	local properties = Instance.new("TextChatMessageProperties")

	-- Перевіряємо чи є відправник (пропускаємо системні повідомлення)
	if not message.TextSource then
		return properties
	end

	local player = Players:GetPlayerByUserId(message.TextSource.UserId)

	-- Перевіряємо чи знайдено гравця
	if not player then
		return properties
	end

	local teamColor = GetTeamColor(player)
	local teamHex = ColorToHex(teamColor)
	local textHex = ColorToHex(Theme.TextPrimary)

	-- Визначаємо роль для бейджу
	local roleBadge = ""
	if player.Team then
		local teamName = player.Team.Name
		local badge = TeamBadges[teamName]
		local color = TeamColors[teamName]

		if badge and color then
			roleBadge = string.format('<font color="%s">[%s]</font> ', ColorToHex(color), badge)
		end
	end

	-- Форматуємо префікс (ім'я гравця з бейджем)
	properties.PrefixText = string.format(
		'%s<font color="%s"><b>%s</b></font><font color="#94A8D2">:</font>',
		roleBadge,
		teamHex,
		player.DisplayName
	)

	-- Форматуємо текст повідомлення тільки якщо статус успішний
	-- Це запобігає поломці системних повідомлень та помилок команд
	if message.Status == Enum.TextChatMessageStatus.Success then
		properties.Text = string.format(
			'<font color="%s">%s</font>',
			textHex,
			message.Text
		)
	end

	return properties
end

-- Підключаємо обробник
TextChatService.OnIncomingMessage = OnIncomingMessage

-- Налаштування шрифту
local FONT_SIZE = 16
local FONT_FACE = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium)

-- Кастомізація ChatWindowConfiguration
local chatWindow = TextChatService:FindFirstChildOfClass("ChatWindowConfiguration")
if chatWindow then
	chatWindow.BackgroundColor3 = Theme.PrimaryUI
	chatWindow.BackgroundTransparency = 0.15
	chatWindow.TextColor3 = Theme.TextPrimary
	chatWindow.TextSize = FONT_SIZE
	chatWindow.FontFace = FONT_FACE
	chatWindow.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	chatWindow.TextStrokeTransparency = 0.7
end

-- Кастомізація ChatInputBarConfiguration
local chatInput = TextChatService:FindFirstChildOfClass("ChatInputBarConfiguration")
if chatInput then
	chatInput.BackgroundColor3 = Theme.PrimaryUI_Light
	chatInput.BackgroundTransparency = 0.1
	chatInput.TextColor3 = Theme.TextPrimary
	chatInput.PlaceholderColor3 = Theme.TextSecondary
	chatInput.TextSize = FONT_SIZE
	chatInput.FontFace = FONT_FACE
	chatInput.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	chatInput.TextStrokeTransparency = 0.7
end

-- Кастомізація BubbleChatConfiguration (повідомлення над головою)
local bubbleChat = TextChatService:FindFirstChildOfClass("BubbleChatConfiguration")
if bubbleChat then
	bubbleChat.BackgroundColor3 = Theme.PrimaryUI
	bubbleChat.BackgroundTransparency = 0.1
	bubbleChat.TextColor3 = Theme.TextPrimary
	bubbleChat.TextSize = 16
	bubbleChat.FontFace = FONT_FACE
	bubbleChat.TailVisible = true
	bubbleChat.BubblesSpacing = 8
	bubbleChat.BubbleDuration = 15
	bubbleChat.MaxBubbles = 3
	bubbleChat.MaxDistance = 50
	bubbleChat.MinimizeDistance = 40
	bubbleChat.VerticalStudsOffset = 0
end