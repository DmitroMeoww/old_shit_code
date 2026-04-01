-- ================================================= --
--            ІНТЕРВАЛ GUI (ТІЛЬКИ ПЕРЕГЛЯД)          --
-- ================================================= --

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--// Тема
local Theme = {
	Background = Color3.fromRGB(26, 28, 32),
	Text = Color3.fromRGB(248, 248, 242),
	Accent = Color3.fromRGB(77, 141, 255),
	Border = Color3.fromRGB(56, 58, 74)
}

--// Змінні
local player = Players.LocalPlayer
local updateIntervalEvent = ReplicatedStorage:WaitForChild("UpdateIntervalEvent")

--// Створення GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "IntervalDisplayGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Рамка зверху
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 160, 0, 32)
frame.Position = UDim2.new(0.5, 0, 0, -50) -- Початкова позиція за екраном
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.BackgroundColor3 = Theme.Background
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0

-- Закруглення
local uiCorner = Instance.new("UICorner", frame)
uiCorner.CornerRadius = UDim.new(0, 6)

-- Обводка
local uiStroke = Instance.new("UIStroke", frame)
uiStroke.Color = Theme.Border
uiStroke.Thickness = 1.5

-- Текст
local label = Instance.new("TextLabel", frame)
label.Size = UDim2.fromScale(1, 1)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamBold
label.TextColor3 = Theme.Text
label.TextSize = 16
label.Text = "Очікування..."

--// Функція форматування часу (секунди -> M:SS)
local function formatTime(seconds)
	if seconds <= 0 then return "Без інтервалу" end
	local m = math.floor(seconds / 60)
	local s = seconds % 60
	return string.format("Інтервал: %d:%02d", m, s)
end

--// Анімація появи (один раз)
task.wait(1)
TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
	Position = UDim2.new(0.5, 0, 0, 10)
}):Play()

--// Оновлення тексту при отриманні сигналу від сервера
updateIntervalEvent.OnClientEvent:Connect(function(seconds)
	-- Анімація зникнення тексту
	local fadeOut = TweenService:Create(label, TweenInfo.new(0.2), {TextTransparency = 1})
	fadeOut:Play()

	fadeOut.Completed:Connect(function()
		label.Text = formatTime(seconds)

		-- Якщо поїздів мало (0 сек), робимо текст сірим, інакше білим
		label.TextColor3 = (seconds == 0) and Color3.fromRGB(150,150,150) or Theme.Text

		-- Анімація появи
		TweenService:Create(label, TweenInfo.new(0.2), {TextTransparency = 0}):Play()

		-- Легкий пульс рамки, щоб привернути увагу
		uiStroke.Color = Theme.Accent
		TweenService:Create(uiStroke, TweenInfo.new(0.5), {Color = Theme.Border}):Play()
	end)
end)