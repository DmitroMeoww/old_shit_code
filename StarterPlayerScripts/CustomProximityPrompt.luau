-- Custom ProximityPrompt Style
-- Відповідає дизайн-системі з документації UI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Кольорова палітра теми
local Theme = {
	Background = Color3.fromRGB(26, 28, 32),
	PrimaryUI = Color3.fromRGB(40, 42, 54),
	PrimaryUI_Light = Color3.fromRGB(56, 58, 74),
	TextPrimary = Color3.fromRGB(248, 248, 242),
	TextSecondary = Color3.fromRGB(180, 180, 190),
	Accent = Color3.fromRGB(77, 141, 255),
	Success = Color3.fromRGB(80, 250, 123),
	Warning = Color3.fromRGB(241, 250, 140),
	Error = Color3.fromRGB(255, 85, 85),
	Disabled = Color3.fromRGB(100, 100, 100)
}

-- Шрифти
local Fonts = {
	GothamBold = Enum.Font.GothamBold,
	Gotham = Enum.Font.Gotham
}

-- Маппінги для клавіш
local GamepadButtonImage = {
	[Enum.KeyCode.ButtonX] = "rbxasset://textures/ui/Controls/xboxX.png",
	[Enum.KeyCode.ButtonY] = "rbxasset://textures/ui/Controls/xboxY.png",
	[Enum.KeyCode.ButtonA] = "rbxasset://textures/ui/Controls/xboxA.png",
	[Enum.KeyCode.ButtonB] = "rbxasset://textures/ui/Controls/xboxB.png",
	[Enum.KeyCode.DPadLeft] = "rbxasset://textures/ui/Controls/dpadLeft.png",
	[Enum.KeyCode.DPadRight] = "rbxasset://textures/ui/Controls/dpadRight.png",
	[Enum.KeyCode.DPadUp] = "rbxasset://textures/ui/Controls/dpadUp.png",
	[Enum.KeyCode.DPadDown] = "rbxasset://textures/ui/Controls/dpadDown.png",
	[Enum.KeyCode.ButtonSelect] = "rbxasset://textures/ui/Controls/xboxmenu.png",
	[Enum.KeyCode.ButtonL1] = "rbxasset://textures/ui/Controls/xboxLS.png",
	[Enum.KeyCode.ButtonR1] = "rbxasset://textures/ui/Controls/xboxRS.png",
}

local KeyboardButtonImage = {
	[Enum.KeyCode.Backspace] = "rbxasset://textures/ui/Controls/backspace.png",
	[Enum.KeyCode.Return] = "rbxasset://textures/ui/Controls/return.png",
	[Enum.KeyCode.LeftShift] = "rbxasset://textures/ui/Controls/shift.png",
	[Enum.KeyCode.RightShift] = "rbxasset://textures/ui/Controls/shift.png",
	[Enum.KeyCode.Tab] = "rbxasset://textures/ui/Controls/tab.png"
}

local KeyboardButtonIconMapping = {
	["'"] = "rbxasset://textures/ui/Controls/apostrophe.png",
	[","] = "rbxasset://textures/ui/Controls/comma.png",
	["`"] = "rbxasset://textures/ui/Controls/graveaccent.png",
	["."] = "rbxasset://textures/ui/Controls/period.png",
	[" "] = "rbxasset://textures/ui/Controls/spacebar.png"
}

local KeyCodeToTextMapping = {
	[Enum.KeyCode.LeftControl] = "Ctrl",
	[Enum.KeyCode.RightControl] = "Ctrl",
	[Enum.KeyCode.LeftAlt] = "Alt",
	[Enum.KeyCode.RightAlt] = "Alt",
	[Enum.KeyCode.F1] = "F1",
	[Enum.KeyCode.F2] = "F2",
	[Enum.KeyCode.F3] = "F3",
	[Enum.KeyCode.F4] = "F4",
	[Enum.KeyCode.F5] = "F5",
	[Enum.KeyCode.F6] = "F6",
	[Enum.KeyCode.F7] = "F7",
	[Enum.KeyCode.F8] = "F8",
	[Enum.KeyCode.F9] = "F9",
	[Enum.KeyCode.F10] = "F10",
	[Enum.KeyCode.F11] = "F11",
	[Enum.KeyCode.F12] = "F12"
}

-- Отримання ScreenGui
local function getScreenGui()
	local screenGui = PlayerGui:FindFirstChild("ProximityPrompts")
	if screenGui == nil then
		screenGui = Instance.new("ScreenGui")
		screenGui.Name = "ProximityPrompts"
		screenGui.ResetOnSpawn = false
		screenGui.Parent = PlayerGui
	end
	return screenGui
end

-- Створення кругового індикатора прогресу
local function createCircularProgressBar()
	local container = Instance.new("Frame")
	container.Name = "ProgressContainer"
	container.Size = UDim2.fromOffset(40, 40)
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.Position = UDim2.fromScale(0.5, 0.5)
	container.BackgroundTransparency = 1

	-- Фонове коло (залишається)
	local background = Instance.new("Frame")
	background.Size = UDim2.fromScale(1, 1)
	background.BackgroundColor3 = Theme.Background
	background.BorderSizePixel = 0
	background.Parent = container

	local bgCorner = Instance.new("UICorner")
	bgCorner.CornerRadius = UDim.new(0, 6)
	bgCorner.Parent = background

	local bgStroke = Instance.new("UIStroke")
	bgStroke.Color = Theme.PrimaryUI_Light
	bgStroke.Thickness = 1.5
	bgStroke.Parent = background

	-- Заповнення прогресу
	local fillFrame = Instance.new("Frame")
	fillFrame.Name = "FillFrame"
	fillFrame.Size = UDim2.fromScale(0, 1)
	fillFrame.Position = UDim2.fromScale(0, 0)
	fillFrame.BackgroundColor3 = Theme.Accent
	fillFrame.BorderSizePixel = 0
	fillFrame.ClipsDescendants = true
	fillFrame.Parent = background

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 6)
	fillCorner.Parent = fillFrame

	-- Значення прогресу
	local progress = Instance.new("NumberValue")
	progress.Name = "Progress"
	progress.Value = 0
	progress.Parent = container

	-- Оновлення прогресу
	progress.Changed:Connect(function(value)
		local clampedValue = math.clamp(value, 0, 1)
		fillFrame.Size = UDim2.fromScale(clampedValue, 1)
	end)

	return container
end

-- Створення кастомного промпту
local function createCustomPrompt(prompt, inputType, gui)
	local tweensForButtonHoldBegin = {}
	local tweensForButtonHoldEnd = {}
	local tweensForFadeOut = {}
	local tweensForFadeIn = {}

	-- Налаштування анімацій
	local tweenInfoHold = TweenInfo.new(prompt.HoldDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tweenInfoQuint = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local tweenInfoQuad = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tweenInfoFast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	-- Основний GUI
	local promptUI = Instance.new("BillboardGui")
	promptUI.Name = "CustomProximityPrompt"
	promptUI.Size = UDim2.fromOffset(200, 60)
	promptUI.StudsOffset = Vector3.new(0, 0, 0)
	promptUI.AlwaysOnTop = true
	promptUI.Adornee = prompt.Parent
	promptUI.Parent = gui

	-- Головний контейнер
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.fromScale(1, 1)
	mainFrame.BackgroundColor3 = Theme.PrimaryUI
	mainFrame.BackgroundTransparency = 0.1
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = promptUI

	-- Заокруглення
	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 8)
	mainCorner.Parent = mainFrame

	-- Обводка
	local mainStroke = Instance.new("UIStroke")
	mainStroke.Color = Theme.PrimaryUI_Light
	mainStroke.Thickness = 1.5
	mainStroke.Parent = mainFrame

	-- Контейнер для клавіші (зліва)
	local keyContainer = Instance.new("Frame")
	keyContainer.Name = "KeyContainer"
	keyContainer.Size = UDim2.fromOffset(40, 40)
	keyContainer.Position = UDim2.new(0, 10, 0.5, -20)
	keyContainer.BackgroundColor3 = Theme.Background
	keyContainer.BorderSizePixel = 0
	keyContainer.Parent = mainFrame

	-- Заокруглення контейнера клавіші
	local keyCorner = Instance.new("UICorner")
	keyCorner.CornerRadius = UDim.new(0, 6)
	keyCorner.Parent = keyContainer

	-- Контейнер для тексту (справа)
	local textContainer = Instance.new("Frame")
	textContainer.Name = "TextContainer"
	textContainer.Size = UDim2.new(1, -60, 1, 0)
	textContainer.Position = UDim2.new(0, 60, 0, 0)
	textContainer.BackgroundTransparency = 1
	textContainer.Parent = mainFrame

	-- Текст дії (назва дії)
	local actionText = Instance.new("TextLabel")
	actionText.Name = "ActionText"
	actionText.Size = UDim2.new(1, -10, 0.55, 0)
	actionText.Position = UDim2.new(0, 5, 0, 5)
	actionText.BackgroundTransparency = 1
	actionText.Font = Fonts.GothamBold
	actionText.TextSize = 14
	actionText.TextColor3 = Theme.TextPrimary
	actionText.TextXAlignment = Enum.TextXAlignment.Left
	actionText.TextYAlignment = Enum.TextYAlignment.Center
	actionText.Text = prompt.ActionText or ""
	actionText.Parent = textContainer

	-- Текст об'єкта (назва об'єкта)
	local objectText = Instance.new("TextLabel")
	objectText.Name = "ObjectText"
	objectText.Size = UDim2.new(1, -10, 0.45, 0)
	objectText.Position = UDim2.new(0, 5, 0.55, -5)
	objectText.BackgroundTransparency = 1
	objectText.Font = Fonts.Gotham
	objectText.TextSize = 11
	objectText.TextColor3 = Theme.TextSecondary
	objectText.TextXAlignment = Enum.TextXAlignment.Left
	objectText.TextYAlignment = Enum.TextYAlignment.Center
	objectText.Text = prompt.ObjectText or ""
	objectText.Parent = textContainer

	-- Створення контенту клавіші залежно від типу вводу
	local keyContent

	if inputType == Enum.ProximityPromptInputType.Gamepad then
		if GamepadButtonImage[prompt.GamepadKeyCode] then
			keyContent = Instance.new("ImageLabel")
			keyContent.Size = UDim2.fromOffset(24, 24)
			keyContent.Position = UDim2.fromScale(0.5, 0.5)
			keyContent.AnchorPoint = Vector2.new(0.5, 0.5)
			keyContent.BackgroundTransparency = 1
			keyContent.Image = GamepadButtonImage[prompt.GamepadKeyCode]
			keyContent.Parent = keyContainer
		end
	elseif inputType == Enum.ProximityPromptInputType.Touch then
		keyContent = Instance.new("ImageLabel")
		keyContent.Size = UDim2.fromOffset(20, 25)
		keyContent.Position = UDim2.fromScale(0.5, 0.5)
		keyContent.AnchorPoint = Vector2.new(0.5, 0.5)
		keyContent.BackgroundTransparency = 1
		keyContent.Image = "rbxasset://textures/ui/Controls/TouchTapIcon.png"
		keyContent.ImageColor3 = Theme.TextPrimary
		keyContent.Parent = keyContainer
	else
		-- Клавіатура
		local buttonTextString = UserInputService:GetStringForKeyCode(prompt.KeyboardKeyCode)
		local buttonTextImage = KeyboardButtonImage[prompt.KeyboardKeyCode]

		if buttonTextImage == nil then
			buttonTextImage = KeyboardButtonIconMapping[buttonTextString]
		end

		if buttonTextImage == nil then
			local keyCodeMappedText = KeyCodeToTextMapping[prompt.KeyboardKeyCode]
			if keyCodeMappedText then
				buttonTextString = keyCodeMappedText
			end
		end

		if buttonTextImage then
			keyContent = Instance.new("ImageLabel")
			keyContent.Size = UDim2.fromOffset(24, 24)
			keyContent.Position = UDim2.fromScale(0.5, 0.5)
			keyContent.AnchorPoint = Vector2.new(0.5, 0.5)
			keyContent.BackgroundTransparency = 1
			keyContent.Image = buttonTextImage
			keyContent.ImageColor3 = Theme.TextPrimary
			keyContent.Parent = keyContainer
		elseif buttonTextString ~= nil and buttonTextString ~= '' then
			keyContent = Instance.new("TextLabel")
			keyContent.Size = UDim2.fromScale(1, 1)
			keyContent.Position = UDim2.fromScale(0.5, 0.5)
			keyContent.AnchorPoint = Vector2.new(0.5, 0.5)
			keyContent.BackgroundTransparency = 1
			keyContent.Font = Fonts.GothamBold
			keyContent.TextSize = string.len(buttonTextString) > 2 and 10 or 12
			keyContent.TextColor3 = Theme.TextPrimary
			keyContent.TextXAlignment = Enum.TextXAlignment.Center
			keyContent.TextYAlignment = Enum.TextYAlignment.Center
			keyContent.Text = buttonTextString
			keyContent.Parent = keyContainer
		end
	end

	-- Круговий прогрес для hold-дій
	local progressBar
	if prompt.HoldDuration > 0 then
		progressBar = createCircularProgressBar()
		progressBar.Parent = keyContainer
		progressBar.Visible = false
	end

	-- Налаштування анімацій
	table.insert(tweensForFadeIn, TweenService:Create(mainFrame, tweenInfoQuad, { BackgroundTransparency = 0.1 }))
	table.insert(tweensForFadeOut, TweenService:Create(mainFrame, tweenInfoQuad, { BackgroundTransparency = 1 }))

	table.insert(tweensForFadeIn, TweenService:Create(mainStroke, tweenInfoQuad, { Transparency = 0 }))
	table.insert(tweensForFadeOut, TweenService:Create(mainStroke, tweenInfoQuad, { Transparency = 1 }))

	table.insert(tweensForFadeIn, TweenService:Create(keyContainer, tweenInfoQuad, { BackgroundTransparency = 0 }))
	table.insert(tweensForFadeOut, TweenService:Create(keyContainer, tweenInfoQuad, { BackgroundTransparency = 1 }))

	if keyContent then
		if keyContent:IsA("ImageLabel") then
			table.insert(tweensForFadeIn, TweenService:Create(keyContent, tweenInfoQuad, { ImageTransparency = 0 }))
			table.insert(tweensForFadeOut, TweenService:Create(keyContent, tweenInfoQuad, { ImageTransparency = 1 }))
		else
			table.insert(tweensForFadeIn, TweenService:Create(keyContent, tweenInfoQuad, { TextTransparency = 0 }))
			table.insert(tweensForFadeOut, TweenService:Create(keyContent, tweenInfoQuad, { TextTransparency = 1 }))
		end
	end

	table.insert(tweensForFadeIn, TweenService:Create(actionText, tweenInfoQuad, { TextTransparency = 0 }))
	table.insert(tweensForFadeOut, TweenService:Create(actionText, tweenInfoQuad, { TextTransparency = 1 }))

	table.insert(tweensForFadeIn, TweenService:Create(objectText, tweenInfoQuad, { TextTransparency = 0 }))
	table.insert(tweensForFadeOut, TweenService:Create(objectText, tweenInfoQuad, { TextTransparency = 1 }))

	-- Анімації для hold
	if progressBar then
		table.insert(tweensForButtonHoldBegin, TweenService:Create(progressBar.Progress, tweenInfoHold, { Value = 1 }))
		table.insert(tweensForButtonHoldEnd, TweenService:Create(progressBar.Progress, tweenInfoFast, { Value = 0 }))

		-- Анімація зміни кольору контенту клавіші
		if keyContent then
			if keyContent:IsA("ImageLabel") then
				table.insert(tweensForButtonHoldBegin, TweenService:Create(keyContent, tweenInfoHold, { ImageColor3 = Theme.Background }))
				table.insert(tweensForButtonHoldEnd, TweenService:Create(keyContent, tweenInfoFast, { ImageColor3 = Theme.TextPrimary }))
			else
				table.insert(tweensForButtonHoldBegin, TweenService:Create(keyContent, tweenInfoHold, { TextColor3 = Theme.Background }))
				table.insert(tweensForButtonHoldEnd, TweenService:Create(keyContent, tweenInfoFast, { TextColor3 = Theme.TextPrimary }))
			end
		end
	end

	-- Підключення до подій промпту
	local connections = {}

	if prompt.HoldDuration > 0 then
		connections.holdBegan = prompt.PromptButtonHoldBegan:Connect(function()
			if progressBar then
				progressBar.Visible = true
				if keyContent then
					keyContent.Visible = false
				end
			end
			for _, tween in ipairs(tweensForButtonHoldBegin) do
				tween:Play()
			end
		end)

		connections.holdEnded = prompt.PromptButtonHoldEnded:Connect(function()
			if progressBar then
				progressBar.Visible = false
				if keyContent then
					keyContent.Visible = true
				end
			end
			for _, tween in ipairs(tweensForButtonHoldEnd) do
				tween:Play()
			end
		end)
	end

	connections.triggered = prompt.Triggered:Connect(function()
		for _, tween in ipairs(tweensForFadeOut) do
			tween:Play()
		end
	end)

	connections.triggerEnded = prompt.TriggerEnded:Connect(function()
		for _, tween in ipairs(tweensForFadeIn) do
			tween:Play()
		end
	end)

	-- Оновлення UI при зміні параметрів промпту
	local function updateUI()
		actionText.Text = prompt.ActionText or ""
		objectText.Text = prompt.ObjectText or ""
		actionText.AutoLocalize = prompt.AutoLocalize
		actionText.RootLocalizationTable = prompt.RootLocalizationTable
		objectText.AutoLocalize = prompt.AutoLocalize
		objectText.RootLocalizationTable = prompt.RootLocalizationTable

		-- Обчислення розміру
		local actionTextSize = TextService:GetTextSize(actionText.Text, 16, Fonts.GothamBold, Vector2.new(1000, 1000))
		local objectTextSize = TextService:GetTextSize(objectText.Text, 12, Fonts.Gotham, Vector2.new(1000, 1000))
		local maxTextWidth = math.max(actionTextSize.X, objectTextSize.X)

		local promptWidth = math.max(200, maxTextWidth + 80)
		promptUI.Size = UDim2.fromOffset(promptWidth, 60)
	end

	connections.changed = prompt.Changed:Connect(updateUI)
	updateUI()

	-- Початкове відображення
	for _, tween in ipairs(tweensForFadeIn) do
		tween:Play()
	end

	-- Touch підтримка
	if inputType == Enum.ProximityPromptInputType.Touch or prompt.ClickablePrompt then
		local button = Instance.new("TextButton")
		button.BackgroundTransparency = 1
		button.TextTransparency = 1
		button.Size = UDim2.fromScale(1, 1)
		button.Parent = promptUI

		local buttonDown = false

		button.InputBegan:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and
				input.UserInputState ~= Enum.UserInputState.Change then
				prompt:InputHoldBegin()
				buttonDown = true
			end
		end)

		button.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				if buttonDown then
					buttonDown = false
					prompt:InputHoldEnd()
				end
			end
		end)

		promptUI.Active = true
	end

	-- Функція очищення
	local function cleanup()
		for _, connection in pairs(connections) do
			connection:Disconnect()
		end

		for _, tween in ipairs(tweensForFadeOut) do
			tween:Play()
		end

		wait(0.2)
		promptUI:Destroy()
	end

	return cleanup
end

-- Ініціалізація
local function initialize()
	ProximityPromptService.PromptShown:Connect(function(prompt, inputType)
		if prompt.Style ~= Enum.ProximityPromptStyle.Custom then
			return
		end

		local gui = getScreenGui()
		local cleanupFunction = createCustomPrompt(prompt, inputType, gui)

		prompt.PromptHidden:Wait()
		cleanupFunction()
	end)
end

-- Запуск
initialize()