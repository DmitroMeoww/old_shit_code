--[ FILE: LocalScript | LOCATION: StarterPlayer > StarterPlayerScripts ]--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local isMobile = UserInputService.TouchEnabled

local EventsFolder = ReplicatedStorage:WaitForChild("BillboardConfig")
local showPurchaseGUIEvent = EventsFolder:WaitForChild("ShowPurchaseGUI")
local requestPurchaseEvent = EventsFolder:WaitForChild("RequestPurchase")
local purchaseResultEvent = EventsFolder:WaitForChild("PurchaseResult")

-- ОНОВЛЕНА КОНФІГУРАЦІЯ
local Config = {
	Tariffs = {
		[1] = { Robux = 60,   EXP = 1250, DevProductId = 3338541996 },
		[2] = { Robux = 100,  EXP = 1500, DevProductId = 3338541995 },
		[3] = { Robux = nil,  EXP = 1650, DevProductId = nil }, -- TODO: Вставити ціну в Robux та ID продукта
		[4] = { Robux = nil,  EXP = 1750, DevProductId = nil }, -- TODO: Вставити ціну в Robux та ID продукта
		[5] = { Robux = nil,  EXP = 1850, DevProductId = nil }, -- TODO: Вставити ціну в Robux та ID продукта
		[6] = { Robux = nil,  EXP = 1950, DevProductId = nil }, -- TODO: Вставити ціну в Robux та ID продукта
		[7] = { Robux = nil,  EXP = 2880, DevProductId = nil }, -- TODO: Вставити ціну в Robux та ID продукта
	},
	MaxDays = 7
}

local currentBillboardModel = nil
local currentBillboardNumber = nil
local selectedDays = 1
local isDraggingSlider = false
local validatedImageId = nil
local isGuiVisible = false

-- НАЛАШТУВАННЯ ТЕМИ ТА АНІМАЦІЙ
local Theme = {
	Background = Color3.fromRGB(26, 28, 32), PrimaryUI = Color3.fromRGB(40, 42, 54),
	PrimaryUI_Light = Color3.fromRGB(56, 58, 74), Accent = Color3.fromRGB(77, 141, 255),
	Accent_Hover = Color3.fromRGB(128, 174, 255), TextPrimary = Color3.fromRGB(248, 248, 242),
	TextSecondary = Color3.fromRGB(180, 180, 190), Success = Color3.fromRGB(80, 250, 123),
	Warning = Color3.fromRGB(241, 250, 140), Error = Color3.fromRGB(255, 85, 85),
	Disabled = Color3.fromRGB(100, 100, 100)
}
local windowOpenAnimInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local tweenInfoEnter = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfoFade = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfoSlider = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local cameraReturnAnimInfo = TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

--[[------------------------------------------------------------------------------------------
	CREATION & SETUP
------------------------------------------------------------------------------------------]]

local function applyHoverEffect(button, baseColor, hoverColor)
	button.MouseEnter:Connect(function() if button.Selectable then TweenService:Create(button, tweenInfoEnter, { BackgroundColor3 = hoverColor }):Play() end end)
	button.MouseLeave:Connect(function() if button.Selectable then TweenService:Create(button, tweenInfoEnter, { BackgroundColor3 = baseColor }):Play() end end)
end

local function createWindow(name, titleText, width, height)
	local windowFrame = Instance.new("Frame")
	windowFrame.Name = name
	windowFrame.Size = UDim2.new(0, width, 0, height)
	windowFrame.Position = UDim2.new(0, 25, 0.5, 0)
	windowFrame.AnchorPoint = Vector2.new(0, 0.5)
	windowFrame.BackgroundColor3 = Theme.PrimaryUI
	windowFrame.BorderSizePixel = 0
	windowFrame.Visible = false
	windowFrame.ClipsDescendants = true

	Instance.new("UICorner", windowFrame).CornerRadius = UDim.new(0, 12)
	local border = Instance.new("UIStroke", windowFrame)
	border.Thickness = 1.5
	border.Color = Theme.PrimaryUI_Light
	border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	local padding = Instance.new("UIPadding", windowFrame)
	padding.PaddingTop = UDim.new(0,10)
	padding.PaddingBottom = UDim.new(0,20)
	padding.PaddingLeft = UDim.new(0,20)
	padding.PaddingRight = UDim.new(0,20)

	local titleBar = Instance.new("Frame", windowFrame)
	titleBar.Name = "TitleBar"
	titleBar.Size = UDim2.new(1, 0, 0, 45)
	titleBar.BackgroundTransparency = 1
	titleBar.ZIndex = 2

	local titleLabel = Instance.new("TextLabel", titleBar)
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.fromScale(1, 1)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Text = titleText
	titleLabel.TextSize = 22
	titleLabel.TextColor3 = Theme.TextPrimary
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left

	local titleSeparator = Instance.new("Frame", titleBar)
	titleSeparator.Name = "TitleSeparator"
	titleSeparator.Size = UDim2.new(1, 0, 0, 1.5)
	titleSeparator.Position = UDim2.new(0.5, 0, 1, 0)
	titleSeparator.AnchorPoint = Vector2.new(0.5, 1)
	titleSeparator.BackgroundColor3 = Theme.PrimaryUI_Light

	local closeButton = Instance.new("TextButton", titleBar)
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 30, 0, 30)
	closeButton.Position = UDim2.new(1, 15, 0.5, 0)
	closeButton.AnchorPoint = Vector2.new(1, 0.5)
	closeButton.BackgroundTransparency = 1
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Text = "X"
	closeButton.TextSize = 20
	closeButton.TextColor3 = Theme.TextSecondary

	closeButton.MouseEnter:Connect(function() TweenService:Create(closeButton, tweenInfoEnter, {TextColor3 = Theme.Error}):Play() end)
	closeButton.MouseLeave:Connect(function() TweenService:Create(closeButton, tweenInfoEnter, {TextColor3 = Theme.TextSecondary}):Play() end)

	local contentFrame = Instance.new("Frame", windowFrame)
	contentFrame.Name = "ContentFrame"
	contentFrame.Size = UDim2.new(1, 0, 1, -45)
	contentFrame.Position = UDim2.new(0,0,0,45)
	contentFrame.BackgroundTransparency = 1
	contentFrame.ClipsDescendants = true

	return windowFrame, contentFrame, closeButton
end

local screenGui = Instance.new("ScreenGui", playerGui)
screenGui.Name = "BillboardPurchaseScreen"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

-- Main Purchase Window
local mainFrame, mainContentFrame, mainCloseButton = createWindow("BillboardPurchaseWindow", "ОРЕНДА БІЛБОРДА", 400, 620)
mainFrame.Parent = screenGui

-- Help Instruction Window
local helpFrame, helpContentFrame, helpCloseButton = createWindow("HelpWindow", "ІНСТРУКЦІЯ", 420, 480)
helpFrame.Position = UDim2.new(0, 445, 0.5, 0)
helpFrame.Parent = screenGui
if isMobile then
	-- Mobile adjustments
end

local contentCanvas = Instance.new("CanvasGroup", mainContentFrame)
contentCanvas.Name = "ContentCanvas"
contentCanvas.BackgroundTransparency = 1
contentCanvas.Size = UDim2.fromScale(1,1)
contentCanvas.GroupTransparency = 1
local contentListLayout = Instance.new("UIListLayout", contentCanvas)
contentListLayout.Padding = UDim.new(0, 18)
contentListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
contentListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Purchase Window Elements
local purchaseElementsContainer = Instance.new("Frame", contentCanvas)
purchaseElementsContainer.Name = "PurchaseContainer"
purchaseElementsContainer.LayoutOrder = 1
purchaseElementsContainer.BackgroundTransparency = 1
purchaseElementsContainer.Size = UDim2.new(1, 0, 0, 520)
local purchaseLayout = Instance.new("UIListLayout", purchaseElementsContainer)
purchaseLayout.Padding = UDim.new(0, 15)
purchaseLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
purchaseLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Info Container (for occupied billboards)
local infoContainer = Instance.new("Frame", mainContentFrame)
infoContainer.Name = "InfoContainer"
infoContainer.BackgroundTransparency = 1
infoContainer.Size = UDim2.fromScale(1, 1)
infoContainer.Visible = false
local infoLayout = Instance.new("UIListLayout", infoContainer)
infoLayout.Padding = UDim.new(0, 10)
local function createInfoLabel(name, labelText, isTitle)
	local label = Instance.new("TextLabel", infoContainer)
	label.Name = name
	label.Size = UDim2.new(1, 0, 0, isTitle and 30 or 25)
	label.BackgroundTransparency = 1
	label.Font = isTitle and Enum.Font.GothamBold or Enum.Font.Gotham
	label.Text = labelText
	label.TextColor3 = isTitle and Theme.TextPrimary or Theme.TextSecondary
	label.TextSize = isTitle and 18 or 16
	label.TextXAlignment = Enum.TextXAlignment.Left
	return label
end
createInfoLabel("OwnerLabel_Title", "Власник:", true)
local ownerLabel = createInfoLabel("OwnerLabel", "...", false)
createInfoLabel("ImageIdLabel_Title", "ID Зображення:", true)
local imageIdLabel = createInfoLabel("ImageIdLabel", "...", false)
createInfoLabel("StartTimeLabel_Title", "Початок оренди:", true)
local startTimeLabel = createInfoLabel("StartTimeLabel", "...", false)
createInfoLabel("EndTimeLabel_Title", "Кінець оренди:", true)
local endTimeLabel = createInfoLabel("EndTimeLabel", "...", false)


-- Preview, Input, Slider etc. setup
local previewContainer = Instance.new("Frame", purchaseElementsContainer)
previewContainer.Name = "PreviewContainer"
previewContainer.LayoutOrder = 1
previewContainer.Size = UDim2.new(1, 0, 0, 180)
previewContainer.BackgroundColor3 = Theme.Background
Instance.new("UICorner", previewContainer).CornerRadius = UDim.new(0, 8)
local previewImage = Instance.new("ImageLabel", previewContainer)
previewImage.Name = "PreviewImage"
previewImage.Size = UDim2.fromScale(1, 1)
previewImage.BackgroundTransparency = 1
previewImage.ScaleType = Enum.ScaleType.Fit
local previewPlaceholder = Instance.new("TextLabel", previewImage)
previewPlaceholder.Name = "PreviewPlaceholder"
previewPlaceholder.Size = UDim2.fromScale(1,1)
previewPlaceholder.BackgroundTransparency = 1
previewPlaceholder.Font = Enum.Font.Gotham
previewPlaceholder.TextColor3 = Theme.TextSecondary
previewPlaceholder.TextSize = 16
previewPlaceholder.Text = "Попередній перегляд"

local imageIdInput = Instance.new("TextBox", purchaseElementsContainer)
imageIdInput.Name = "ImageIdInput"
imageIdInput.LayoutOrder = 2
imageIdInput.Size = UDim2.new(1, 0, 0, 45)
imageIdInput.BackgroundColor3 = Theme.PrimaryUI_Light
imageIdInput.Font = Enum.Font.Gotham
imageIdInput.PlaceholderText = "Вставте ID зображення..."
imageIdInput.PlaceholderColor3 = Theme.Disabled
imageIdInput.TextColor3 = Theme.TextPrimary
imageIdInput.TextSize = 16
imageIdInput.ClearTextOnFocus = false
Instance.new("UICorner", imageIdInput).CornerRadius = UDim.new(0, 8)
Instance.new("UIPadding", imageIdInput).PaddingLeft = UDim.new(0, 12)
Instance.new("UIPadding", imageIdInput).PaddingRight = UDim.new(0, 12)

-- SLIDER FOR DAY SELECTION
local sliderContainer = Instance.new("Frame", purchaseElementsContainer)
sliderContainer.Name = "DaysSliderContainer"
sliderContainer.LayoutOrder = 3
sliderContainer.Size = UDim2.new(1, 0, 0, 50)
sliderContainer.BackgroundTransparency = 1

local sliderLabel = Instance.new("TextLabel", sliderContainer)
sliderLabel.Name = "SliderLabel"
sliderLabel.Size = UDim2.new(1,0,0,20)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Font = Enum.Font.GothamBold
sliderLabel.Text = "Термін оренди: 1 день"
sliderLabel.TextColor3 = Theme.TextPrimary
sliderLabel.TextSize = 16
sliderLabel.TextXAlignment = Enum.TextXAlignment.Left

local sliderTrack = Instance.new("Frame", sliderContainer)
sliderTrack.Name = "Track"
sliderTrack.Size = UDim2.new(1, 0, 0, 8)
sliderTrack.Position = UDim2.new(0.5, 0, 1, 0)
sliderTrack.AnchorPoint = Vector2.new(0.5, 1)
sliderTrack.BackgroundColor3 = Theme.Background
sliderTrack.BorderSizePixel = 0
Instance.new("UICorner", sliderTrack).CornerRadius = UDim.new(1, 0)

local sliderFill = Instance.new("Frame", sliderTrack)
sliderFill.Name = "Fill"
sliderFill.Size = UDim2.new(0, 0, 1, 0)
sliderFill.BackgroundColor3 = Theme.Accent
sliderFill.BorderSizePixel = 0
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(1, 0)

local sliderHandle = Instance.new("TextButton", sliderTrack)
sliderHandle.Name = "Handle"
sliderHandle.Size = UDim2.new(0, 24, 0, 24)
sliderHandle.AnchorPoint = Vector2.new(0.5, 0.5)
sliderHandle.Position = UDim2.new(0, 0, 0.5, 0)
sliderHandle.BackgroundColor3 = Theme.TextPrimary
sliderHandle.Text = ""
sliderHandle.ZIndex = 2
Instance.new("UICorner", sliderHandle).CornerRadius = UDim.new(1, 0)
local handleStroke = Instance.new("UIStroke", sliderHandle)
handleStroke.Color = Theme.Accent
handleStroke.Thickness = 3

-- Purchase Buttons
local purchaseButtonsFrame = Instance.new("Frame", purchaseElementsContainer)
purchaseButtonsFrame.Name = "PurchaseButtons"
purchaseButtonsFrame.LayoutOrder = 4
purchaseButtonsFrame.Size = UDim2.new(1, 0, 0, 55)
purchaseButtonsFrame.BackgroundTransparency = 1
local buttonsLayout = Instance.new("UIListLayout", purchaseButtonsFrame)
buttonsLayout.FillDirection = Enum.FillDirection.Horizontal
buttonsLayout.Padding = UDim.new(0, 10)
buttonsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
buttonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local payWithRobuxButton = Instance.new("TextButton", purchaseButtonsFrame)
payWithRobuxButton.Name = "PayWithRobux"
payWithRobuxButton.Size = UDim2.new(0.5, -5, 1, 0)
payWithRobuxButton.BackgroundColor3 = Theme.Accent
payWithRobuxButton.TextColor3 = Theme.TextPrimary
payWithRobuxButton.Font = Enum.Font.GothamBold
payWithRobuxButton.TextSize = 16
Instance.new("UICorner", payWithRobuxButton).CornerRadius = UDim.new(0, 8)
local payWithExpButton = Instance.new("TextButton", purchaseButtonsFrame)
payWithExpButton.Name = "PayWithEXP"
payWithExpButton.Size = UDim2.new(0.5, -5, 1, 0)
payWithExpButton.BackgroundColor3 = Theme.Success
payWithExpButton.TextColor3 = Theme.Background
payWithExpButton.Font = Enum.Font.GothamBold
payWithExpButton.TextSize = 16
Instance.new("UICorner", payWithExpButton).CornerRadius = UDim.new(0, 8)
applyHoverEffect(payWithRobuxButton, Theme.Accent, Theme.Accent_Hover)
applyHoverEffect(payWithExpButton, Theme.Success, Color3.fromRGB(120, 255, 160))

local warningLabel = Instance.new("TextLabel", purchaseElementsContainer)
warningLabel.Name = "WarningLabel"
warningLabel.LayoutOrder = 5
warningLabel.Size = UDim2.new(1, 0, 0, 60)
warningLabel.BackgroundTransparency = 1
warningLabel.Font = Enum.Font.Gotham
warningLabel.TextColor3 = Theme.TextSecondary
warningLabel.TextSize = 13
warningLabel.TextWrapped = true
warningLabel.TextYAlignment = Enum.TextYAlignment.Top
warningLabel.Text = "Увага: Заборонено розміщувати політичний, NSFW, чи образливий контент. Порушення призведе до видалення зображення без повернення коштів."

local statusContainer = Instance.new("Frame", purchaseElementsContainer)
statusContainer.Name = "StatusContainer"
statusContainer.LayoutOrder = 6
statusContainer.BackgroundTransparency = 1
statusContainer.Size = UDim2.new(1, 0, 0, 50)
local statusLabel = Instance.new("TextLabel", statusContainer)
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, -110, 1, 0)
statusLabel.Position = UDim2.fromScale(0, 0.5)
statusLabel.AnchorPoint = Vector2.new(0, 0.5)
statusLabel.BackgroundTransparency = 1
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextColor3 = Theme.TextSecondary
statusLabel.TextSize = 15
statusLabel.TextWrapped = true
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Visible = false
local helpButton = Instance.new("TextButton", statusContainer)
helpButton.Name = "HelpButton"
helpButton.Size = UDim2.new(0, 100, 0, 30)
helpButton.AnchorPoint = Vector2.new(0.5, 0.5)
helpButton.Position = UDim2.fromScale(0.5, 0.5)
helpButton.BackgroundColor3 = Theme.Accent
helpButton.TextColor3 = Theme.TextPrimary
helpButton.Font = Enum.Font.GothamBold
helpButton.Text = "Допомога"
helpButton.TextSize = 14
helpButton.Visible = false
Instance.new("UICorner", helpButton).CornerRadius = UDim.new(0, 6)
applyHoverEffect(helpButton, Theme.Accent, Theme.Accent_Hover)


-- Help Window Content Setup
local helpLayout = Instance.new("UIListLayout", helpContentFrame)
helpLayout.Padding = UDim.new(0,15)
helpLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local helpText = Instance.new("TextLabel", helpContentFrame)
helpText.Name = "HelpText"
helpText.Size = UDim2.new(1,0,0,100)
helpText.BackgroundTransparency = 1
helpText.TextColor3 = Theme.TextPrimary
helpText.Font = Enum.Font.Gotham
helpText.TextSize = 16
helpText.TextWrapped = true
helpText.TextYAlignment = Enum.TextYAlignment.Top
local helpImage = Instance.new("ImageLabel", helpContentFrame)
helpImage.Name = "HelpImage"
helpImage.Size = UDim2.new(1, 0, 0, 200)
helpImage.BackgroundTransparency = 1
helpImage.ScaleType = Enum.ScaleType.Fit
helpImage.Visible = false
local helpNavFrame = Instance.new("Frame", helpContentFrame)
helpNavFrame.Name = "HelpNav"
helpNavFrame.Size = UDim2.new(1,0,0,40)
helpNavFrame.BackgroundTransparency = 1
local helpPrevButton = Instance.new("TextButton", helpNavFrame)
helpPrevButton.Size = UDim2.new(0.5, -5, 1, 0)
helpPrevButton.Position = UDim2.fromScale(0,0)
helpPrevButton.BackgroundColor3 = Theme.PrimaryUI_Light
helpPrevButton.Text = "<"
helpPrevButton.Font=Enum.Font.GothamBold
helpPrevButton.TextColor3 = Theme.TextPrimary
helpPrevButton.TextSize = 24
Instance.new("UICorner", helpPrevButton).CornerRadius = UDim.new(0,6)
local helpNextButton = Instance.new("TextButton", helpNavFrame)
helpNextButton.Size = UDim2.new(0.5, -5, 1, 0)
helpNextButton.Position = UDim2.new(0.5, 5, 0, 0)
helpNextButton.AnchorPoint = Vector2.new(0,0)
helpNextButton.BackgroundColor3 = Theme.PrimaryUI_Light
helpNextButton.Text = ">"
helpNextButton.Font=Enum.Font.GothamBold
helpNextButton.TextColor3 = Theme.TextPrimary
helpNextButton.TextSize = 24
Instance.new("UICorner", helpNextButton).CornerRadius = UDim.new(0,6)

--[[------------------------------------------------------------------------------------------
	HELP INSTRUCTION LOGIC
------------------------------------------------------------------------------------------]]
local currentHelpStep = 1
local helpSteps = {
	{Text = "Щоб орендувати білборд, потрібно отримати ID картинки. Перейдіть у розділ 'Create' на сайті Roblox."},
	{Text = "У меню зліва оберіть 'Marketplace Items' -> 'Images' та завантажте свою картинку або знайдіть існуючу.", ImageID = "rbxassetid://96139936829763"}, -- Replace with actual screenshot ID
	{Text = "Натисніть на картинку. У адресному рядку браузера ви побачите посилання. Скопіюйте тільки набір цифр з нього.", ImageID = "rbxassetid://6297394200"}, -- Replace with actual screenshot ID
	{Text = "Вставте скопійований ID у поле для вводу в грі. Все готово! Тепер можете обирати термін та спосіб оплати."},
}

local function displayHelpStep(stepNum)
	currentHelpStep = stepNum
	local stepData = helpSteps[stepNum]

	helpText.Text = stepData.Text
	helpImage.Visible = stepData.ImageID ~= nil
	if stepData.ImageID then
		helpImage.Image = stepData.ImageID
	end

	helpPrevButton.Visible = stepNum > 1
	helpNextButton.Visible = stepNum < #helpSteps
end

helpButton.MouseButton1Click:Connect(function() helpFrame.Visible = true; displayHelpStep(1) end)
helpCloseButton.MouseButton1Click:Connect(function() helpFrame.Visible = false end)
helpNextButton.MouseButton1Click:Connect(function() if currentHelpStep < #helpSteps then displayHelpStep(currentHelpStep + 1) end end)
helpPrevButton.MouseButton1Click:Connect(function() if currentHelpStep > 1 then displayHelpStep(currentHelpStep - 1) end end)

--[[------------------------------------------------------------------------------------------
	CORE UI LOGIC
------------------------------------------------------------------------------------------]]
function showStatus(message, color, showHelp)
	statusLabel.Visible = true
	helpButton.Visible = false

	if showHelp then
		statusLabel.Text = message
		statusLabel.TextColor3 = color
		helpButton.Visible = true
		helpButton.Position = UDim2.new(1, 0, 0.5, 0)
		helpButton.AnchorPoint = Vector2.new(1, 0.5)
	else
		statusLabel.Text = message
		statusLabel.TextColor3 = color
		statusLabel.Position = UDim2.fromScale(0, 0.5)
		statusLabel.AnchorPoint = Vector2.new(0, 0.5)
	end
end

function updatePurchaseInfo(days)
	selectedDays = math.clamp(math.floor(days + 0.5), 1, Config.MaxDays)
	local tariffInfo = Config.Tariffs[selectedDays]

	if not tariffInfo then return end

	local dayText = "днів"
	if selectedDays == 1 then dayText = "день"
	elseif selectedDays >= 2 and selectedDays <= 4 then dayText = "дні" end
	sliderLabel.Text = string.format("Термін оренди: %d %s", selectedDays, dayText)

	payWithExpButton.Text = string.format("ЗА %d EXP", tariffInfo.EXP)

	if tariffInfo.Robux and tariffInfo.DevProductId then
		payWithRobuxButton.Text = string.format("ЗА R$ %d", tariffInfo.Robux)
		payWithRobuxButton.Selectable = true
		TweenService:Create(payWithRobuxButton, tweenInfoEnter, {BackgroundColor3 = Theme.Accent}):Play()
	else
		payWithRobuxButton.Text = "НЕДОСТУПНО"
		payWithRobuxButton.Selectable = false
		TweenService:Create(payWithRobuxButton, tweenInfoEnter, {BackgroundColor3 = Theme.Disabled}):Play()
	end

	-- Update slider visual position to snap to the correct day
	local progress = (selectedDays - 1) / (Config.MaxDays - 1)
	TweenService:Create(sliderFill, tweenInfoSlider, { Size = UDim2.new(progress, 0, 1, 0) }):Play()
	TweenService:Create(sliderHandle, tweenInfoSlider, { Position = UDim2.new(progress, 0, 0.5, 0) }):Play()
end

-- Slider Logic
local function handleSliderInput(input)
	if isDraggingSlider then
		local relativePos = input.Position.X - sliderTrack.AbsolutePosition.X
		local width = sliderTrack.AbsoluteSize.X
		local progress = math.clamp(relativePos / width, 0, 1)
		local newDays = 1 + progress * (Config.MaxDays - 1)
		updatePurchaseInfo(newDays)
	end
end

sliderHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isDraggingSlider = true
	end
end)
sliderHandle.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isDraggingSlider = false
		updatePurchaseInfo(selectedDays)
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		handleSliderInput(input)
	end
end)

function showGui(billmodel, isOccupied, data)
	if isGuiVisible then return end
	isGuiVisible = true
	currentBillboardModel = billmodel
	currentBillboardNumber = tonumber(billmodel.Bill.Nomer.SurfaceGui.SIGN.Text)
	local titleLabel = mainFrame.TitleBar.TitleLabel

	mainFrame.Visible = true
	local openPosition = UDim2.new(0, 25, 0.5, 0)
	mainFrame.Position = UDim2.new(0, -mainFrame.AbsoluteSize.X - 25, 0.5, 0)
	local windowTween = TweenService:Create(mainFrame, windowOpenAnimInfo, { Position = openPosition })
	windowTween:Play()
	windowTween.Completed:Once(function()
		TweenService:Create(contentCanvas, tweenInfoFade, { GroupTransparency = 0 }):Play()
	end)

	camera.CameraType = Enum.CameraType.Scriptable
	local targetPart = billmodel.Bill
	local offset = (targetPart.CFrame.RightVector * 8) + (targetPart.CFrame.LookVector * -12) + Vector3.new(0, 3, 0)
	TweenService:Create(camera, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {CFrame = CFrame.lookAt(targetPart.Position + offset, targetPart.Position)}):Play()

	if isOccupied then
		titleLabel.Text = "ІНФОРМАЦІЯ"
		contentCanvas.Visible = false
		infoContainer.Visible = true
		local dateFormat = "%d.%m.%Y o %H:%M"
		ownerLabel.Text = data.OwnerName
		imageIdLabel.Text = data.ImageId
		startTimeLabel.Text = os.date(dateFormat, data.PurchaseTime)
		endTimeLabel.Text = os.date(dateFormat, data.ExpirationTime)
	else
		titleLabel.Text = "ОРЕНДА БІЛБОРДА"
		infoContainer.Visible = false
		contentCanvas.Visible = true
		imageIdInput.Text = ""
		previewImage.Image = ""
		previewPlaceholder.Visible = true
		validatedImageId = nil
		showStatus("Введіть ID зображення та оберіть тариф", Theme.TextSecondary, false)
		updatePurchaseInfo(1)
	end
end

function closeGui()
	if not isGuiVisible then return end
	isGuiVisible = false

	TweenService:Create(contentCanvas, tweenInfoFade, { GroupTransparency = 1 }):Play()
	task.wait(tweenInfoFade.Time)

	local closedPosition = UDim2.new(0, -mainFrame.AbsoluteSize.X - 25, 0.5, 0)
	local closeTween = TweenService:Create(mainFrame, windowOpenAnimInfo, { Position = closedPosition })
	closeTween:Play()
	closeTween.Completed:Once(function()
		mainFrame.Visible = false
		helpFrame.Visible = false
	end)

	local character = player.Character
	if character and character:FindFirstChild("Head") then
		local head = character.Head
		local cameraTargetCFrame = CFrame.lookAt(head.Position + Vector3.new(0, 2, 0) + (head.CFrame.LookVector * 10), head.Position)
		TweenService:Create(camera, cameraReturnAnimInfo, { CFrame = cameraTargetCFrame }):Play()
		task.wait(cameraReturnAnimInfo.Time)
		camera.CameraType = Enum.CameraType.Custom
	else
		camera.CameraType = Enum.CameraType.Custom
	end

	currentBillboardModel = nil
end

imageIdInput:GetPropertyChangedSignal("Text"):Connect(function()
	validatedImageId = nil
	previewImage.Image = ""
	previewPlaceholder.Visible = true
	local text = imageIdInput.Text:match("%d+")

	if not text or text == "" then
		if imageIdInput.Text == "" then
			showStatus("Введіть ID зображення...", Theme.TextSecondary, false)
		end
		return
	end

	local id = tonumber(text)
	showStatus("Перевірка ID...", Theme.TextSecondary, false)

	task.spawn(function()
		local success, productInfo = pcall(function() return MarketplaceService:GetProductInfo(id, Enum.InfoType.Asset) end)
		if imageIdInput.Text:match("%d+") ~= text then return end 

		if not success or not productInfo then
			showStatus("Помилка. Асет не знайдено.", Theme.Error, true)
			return
		end

		local assetTypeId = productInfo.AssetTypeId
		if assetTypeId == Enum.AssetType.Image.Value or assetTypeId == Enum.AssetType.Decal.Value then
			validatedImageId = "rbxassetid://"..tostring(id)
			previewImage.Image = validatedImageId
			previewPlaceholder.Visible = false
			showStatus("Зображення завантажено!", Theme.Success, false)
		else
			showStatus("Це не зображення. Прочитайте інструкцію.", Theme.Error, true)
		end
	end)
end)

function attemptPurchase(purchaseType)
	if not validatedImageId then
		showStatus("Спочатку введіть дійсний ID зображення.", Theme.Error, false)
		return
	end
	if not currentBillboardNumber then return end

	local tariffInfo = Config.Tariffs[selectedDays]
	if purchaseType == "Robux" and (not tariffInfo.Robux or not tariffInfo.DevProductId) then
		showStatus("Покупка на цей термін недоступна.", Theme.Warning, false)
		return
	end

	local idNumberOnly = tonumber(validatedImageId:match("%d+"))
	if not idNumberOnly then
		showStatus("Внутрішня помилка. Не вдалося обробити ID.", Theme.Error, false)
		return
	end

	local statusMessage = (purchaseType == "Robux") and "Запуск покупки..." or "Обробка запиту..."
	showStatus(statusMessage, Theme.TextSecondary, false)
	requestPurchaseEvent:FireServer(currentBillboardNumber, idNumberOnly, selectedDays, purchaseType)
end

-- EVENT CONNECTIONS
purchaseResultEvent.OnClientEvent:Connect(function(isSuccess, message)
	showStatus(message, isSuccess and Theme.Success or Theme.Error)
	if isSuccess then
		task.wait(2.5)
		closeGui()
	end
end)
showPurchaseGUIEvent.OnClientEvent:Connect(showGui)
mainCloseButton.MouseButton1Click:Connect(closeGui)
payWithExpButton.MouseButton1Click:Connect(function() attemptPurchase("EXP") end)
payWithRobuxButton.MouseButton1Click:Connect(function() 
	if payWithRobuxButton.Selectable then
		attemptPurchase("Robux") 
	end
end)

-- INITIAL CALL
updatePurchaseInfo(1)