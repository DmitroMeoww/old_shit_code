local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
-- Перевірка RemoteFunction
local getHolidayStatus = ReplicatedStorage:WaitForChild("GetHolidayStatus", 5)
local blockedProductID = {3495365604}

-- =============================================================================
-- [1] ДИЗАЙН І ТЕМИ
-- =============================================================================

local function getKyivTime()
	local utcTime = os.time()
	local kyivOffset = 3 * 60 * 60
	return os.date("*t", utcTime + kyivOffset)
end

local HalloweenTheme = {
	PrimaryUI = Color3.fromRGB(42, 35, 58),
	PrimaryUI_Light = Color3.fromRGB(65, 55, 90),
	Accent = Color3.fromRGB(255, 118, 0),
	Accent_Hover = Color3.fromRGB(255, 150, 50),
	TextPrimary = Color3.fromRGB(248, 248, 242),
	TextSecondary = Color3.fromRGB(200, 190, 220),
	Success = Color3.fromRGB(80, 250, 123),
	Error = Color3.fromRGB(255, 85, 85),
	Error_Hover = Color3.fromRGB(255, 120, 120),
	HolidayYellow = Color3.fromRGB(255, 160, 50),
	Gold_Light = Color3.fromRGB(255, 200, 100),
	Gold_Dark = Color3.fromRGB(200, 100, 0),
}

local NewYearTheme = {
	PrimaryUI = Color3.fromRGB(35, 45, 70),
	PrimaryUI_Light = Color3.fromRGB(56, 68, 94),
	Accent = Color3.fromRGB(100, 200, 255),
	Accent_Hover = Color3.fromRGB(150, 220, 255),
	TextPrimary = Color3.fromRGB(240, 240, 255),
	TextSecondary = Color3.fromRGB(180, 190, 210),
	Success = Color3.fromRGB(70, 230, 150),
	Error = Color3.fromRGB(255, 100, 100),
	Error_Hover = Color3.fromRGB(255, 140, 140),
	HolidayYellow = Color3.fromRGB(100, 220, 255),
	Gold_Light = Color3.fromRGB(200, 240, 255),
	Gold_Dark = Color3.fromRGB(50, 150, 255),
}

local DefaultTheme = {
	PrimaryUI = Color3.fromRGB(14, 24, 49),
	PrimaryUI_Light = Color3.fromRGB(30, 48, 91),
	Accent = Color3.fromRGB(68, 214, 196),
	Accent_Hover = Color3.fromRGB(112, 230, 214),
	TextPrimary = Color3.fromRGB(225, 236, 255),
	TextSecondary = Color3.fromRGB(148, 168, 210),
	Success = Color3.fromRGB(88, 255, 197),
	Error = Color3.fromRGB(255, 105, 105),
	Error_Hover = Color3.fromRGB(255, 140, 140),
	HolidayYellow = Color3.fromRGB(253, 224, 71),
	Gold_Light = Color3.fromRGB(255, 230, 120),
	Gold_Dark = Color3.fromRGB(255, 190, 40),
}

local Theme = DefaultTheme
local currentTime = getKyivTime()
local day = currentTime.day
local month = currentTime.month

if (month == 10 and day >= 27 and day <= 31) or (month == 11 and day == 3) then
	Theme = HalloweenTheme
elseif (month == 12 and day >= 20) or (month == 1 and day <= 10) then
	Theme = NewYearTheme
end

-- =============================================================================
-- [2] ДАНІ ПРО ТОВАРИ
-- =============================================================================

local productsDataConfig = {
	{ Type = "DeveloperProduct", Id = 2686236007, OriginalPrice = 30,    Name = "+100 EXP" },
	{ Type = "DeveloperProduct", Id = 2686236556, OriginalPrice = 50,    Name = "+300 EXP" },
	{ Type = "DeveloperProduct", Id = 2686236557, OriginalPrice = 100,   Name = "+425 EXP" },
	{ Type = "DeveloperProduct", Id = 2686236554, OriginalPrice = 200,   Name = "+650 EXP" },
	{ Type = "DeveloperProduct", Id = 2686236555, OriginalPrice = 350,   Name = "+750 EXP" },
	{ Type = "DeveloperProduct", Id = 3330925357, OriginalPrice = 1000,  Name = "+2500 EXP" },
	{ Type = "DeveloperProduct", Id = 3330926313, OriginalPrice = 2000,  Name = "+7500 EXP" },
	{ Type = "DeveloperProduct", Id = 3330927094, OriginalPrice = 3500,  Name = "+11111 EXP" },
	{ Type = "GamePass", Id = 1314829438, OriginalPrice = 99, Name = "x2 EXP" },
	{ Type = "GamePass", Id = 1419827962, OriginalPrice = 25, Name = "ОЕВРЗ (5м доповнення)" },
	{ Type = "GamePass", Id = 1413744978, OriginalPrice = 40, Name = "ЕМА-502 [ДЕВ]" },
	{ Type = "GamePass", Id = 1095539343, OriginalPrice = 3, Name = "Нічого" },
	{ Type = "GamePass", Id = 1091213694, OriginalPrice = 65, Name = "81-717.5М" },
	{ Type = "GamePass", Id = 1056233817, OriginalPrice = 45, Name = "Ретро Поїзда" },
}

-- Цей масив буде заповнений тільки валідними товарами
local productsData = {}

local purchaseNotifications = {
	Success = { Text = "Покупка успішна! Дякуємо!", Sound = 18844391063 },
	Cancelled = { Text = "Ви скасували покупку. Дякуємо, що граєте!", Sound = 9066167010 },
	Error = { Text = "Сталася помилка під час покупки.", Sound = 9066167010 }
}

local tweenInfoEnter = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfoLeave = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local windowOpenAnimInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local windowCloseAnimInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local leaderstats = player:WaitForChild("leaderstats")
local expValueObject = leaderstats:WaitForChild("EXP")

-- =============================================================================
-- [3] GUI
-- =============================================================================

local expInfoGui = Instance.new("ScreenGui")
expInfoGui.Name = "ExpInfoGui"
expInfoGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
expInfoGui.DisplayOrder = 10
expInfoGui.Parent = playerGui

local mainDisplayContainer = Instance.new("Frame")
mainDisplayContainer.Name = "MainDisplayContainer"
mainDisplayContainer.BackgroundTransparency = 1
mainDisplayContainer.Position = UDim2.new(0, 20, 0, 20)
mainDisplayContainer.Size = UDim2.new(0, 300, 0, 0)
mainDisplayContainer.AutomaticSize = Enum.AutomaticSize.Y
mainDisplayContainer.Parent = expInfoGui

local containerLayout = Instance.new("UIListLayout", mainDisplayContainer)
containerLayout.FillDirection = Enum.FillDirection.Vertical
containerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
containerLayout.Padding = UDim.new(0, 10)

-- === ПЛАШКА EXP ===
local expDisplayFrame = Instance.new("Frame")
expDisplayFrame.Name = "ExpDisplayFrame"
expDisplayFrame.LayoutOrder = 1
expDisplayFrame.Size = UDim2.new(0, 0, 0, 45)
expDisplayFrame.AutomaticSize = Enum.AutomaticSize.X
expDisplayFrame.BackgroundColor3 = Theme.PrimaryUI
expDisplayFrame.Parent = mainDisplayContainer

Instance.new("UICorner", expDisplayFrame).CornerRadius = UDim.new(0, 12)

local expStroke = Instance.new("UIStroke", expDisplayFrame)
expStroke.Thickness = 1.5
expStroke.Color = Theme.PrimaryUI_Light
expStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local expLayout = Instance.new("UIListLayout", expDisplayFrame)
expLayout.FillDirection = Enum.FillDirection.Horizontal
expLayout.VerticalAlignment = Enum.VerticalAlignment.Center
expLayout.SortOrder = Enum.SortOrder.LayoutOrder
expLayout.Padding = UDim.new(0, 8)

local expPadding = Instance.new("UIPadding", expDisplayFrame)
expPadding.PaddingLeft = UDim.new(0, 12)
expPadding.PaddingRight = UDim.new(0, 12)

-- КАРТИНКА EXP (ЗЛІВА)
local expIcon = Instance.new("ImageLabel", expDisplayFrame)
expIcon.Name = "ExpIcon"
expIcon.LayoutOrder = 0
expIcon.Size = UDim2.new(0, 30, 0, 30)
expIcon.BackgroundTransparency = 1
expIcon.Image = "rbxassetid://103973116782117"

local expLabel = Instance.new("TextLabel", expDisplayFrame)
expLabel.Name = "EXPLabel"
expLabel.LayoutOrder = 1
expLabel.Size = UDim2.new(0, 0, 1, 0)
expLabel.AutomaticSize = Enum.AutomaticSize.X
expLabel.BackgroundTransparency = 1
expLabel.Font = Enum.Font.GothamBold
expLabel.TextSize = 18
expLabel.TextColor3 = Theme.TextPrimary
expLabel.TextXAlignment = Enum.TextXAlignment.Left
expLabel.Text = "Загрузка"
expLabel.RichText = true

local storeButton = Instance.new("TextButton", expDisplayFrame)
storeButton.Name = "StoreButton"
storeButton.LayoutOrder = 2
storeButton.Size = UDim2.new(0, 40, 0, 28)
storeButton.BackgroundColor3 = Theme.Accent
storeButton.Font = Enum.Font.GothamBold
storeButton.Text = "SHOP"
storeButton.TextSize = 12
storeButton.TextColor3 = Theme.PrimaryUI
Instance.new("UICorner", storeButton).CornerRadius = UDim.new(0, 8)

-- === ВІКНО МАГАЗИНУ ===
local storeWindowFrame = Instance.new("Frame", expInfoGui)
storeWindowFrame.Name = "StoreWindow"
storeWindowFrame.Size = UDim2.new(0, 550, 0, 450)
storeWindowFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
storeWindowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
storeWindowFrame.BackgroundColor3 = Theme.PrimaryUI
storeWindowFrame.Visible = false
storeWindowFrame.ClipsDescendants = true
storeWindowFrame.ZIndex = 100

Instance.new("UICorner", storeWindowFrame).CornerRadius = UDim.new(0, 16)

local storeStroke = Instance.new("UIStroke", storeWindowFrame)
storeStroke.Thickness = 1.5
storeStroke.Color = Theme.PrimaryUI_Light
storeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local storePadding = Instance.new("UIPadding", storeWindowFrame)
storePadding.PaddingTop = UDim.new(0, 10)
storePadding.PaddingLeft = UDim.new(0, 10)
storePadding.PaddingRight = UDim.new(0, 10)
storePadding.PaddingBottom = UDim.new(0, 10)

local titleLabel = Instance.new("TextLabel", storeWindowFrame)
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 45)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.Text = "МАГАЗИН"
titleLabel.TextSize = 24
titleLabel.TextColor3 = Theme.TextPrimary

local closeButton = Instance.new("TextButton", storeWindowFrame)
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -15, 0, 22.5)
closeButton.AnchorPoint = Vector2.new(1, 0.5)
closeButton.BackgroundTransparency = 1
closeButton.BorderSizePixel = 0
closeButton.Font = Enum.Font.GothamBold
closeButton.Text = "X"
closeButton.TextSize = 20
closeButton.TextColor3 = Theme.Error
closeButton.ZIndex = titleLabel.ZIndex + 1
closeButton.AutoButtonColor = false

local scrollingFrame = Instance.new("ScrollingFrame", storeWindowFrame)
scrollingFrame.Size = UDim2.new(1, 0, 1, -45)
scrollingFrame.Position = UDim2.new(0, 0, 0, 45)
scrollingFrame.AnchorPoint = Vector2.new(0, 0)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarThickness = 6
scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local scrollPadding = Instance.new("UIPadding", scrollingFrame)
scrollPadding.PaddingBottom = UDim.new(0, 15)

local gridLayout = Instance.new("UIGridLayout", scrollingFrame)
gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
gridLayout.CellSize = UDim2.new(0, 160, 0, 200)
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local notificationContainer = Instance.new("Frame", expInfoGui)
notificationContainer.Name = "NotificationContainer"
notificationContainer.Size = UDim2.fromScale(1, 1)
notificationContainer.BackgroundTransparency = 1
notificationContainer.ZIndex = 200
notificationContainer.Visible = false

local notificationLabel = Instance.new("TextLabel", notificationContainer)
notificationLabel.Name = "NotificationLabel"
notificationLabel.Size = UDim2.new(0, 400, 0, 60)
notificationLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
notificationLabel.AnchorPoint = Vector2.new(0.5, 0.5)
notificationLabel.BackgroundColor3 = Theme.PrimaryUI
notificationLabel.BackgroundTransparency = 0.1
notificationLabel.Font = Enum.Font.GothamBold
notificationLabel.TextSize = 18
notificationLabel.TextColor3 = Theme.TextPrimary
notificationLabel.TextWrapped = true

Instance.new("UICorner", notificationLabel).CornerRadius = UDim.new(0, 12)

local notificationStroke = Instance.new("UIStroke", notificationLabel)
notificationStroke.Thickness = 1.5
notificationStroke.Color = Theme.PrimaryUI_Light

local soundPlayer = Instance.new("Sound", expInfoGui)
soundPlayer.Name = "SoundPlayer"

-- =============================================================================
-- [4] ФУНКЦІЇ
-- =============================================================================

local function createItemCard(itemData, isHolidayActive)
	local card = Instance.new("Frame", scrollingFrame)
	card.Name = "ItemCard"
	card.LayoutOrder = itemData.Price or itemData.OriginalPrice
	card.BackgroundColor3 = Theme.PrimaryUI_Light
	card.BackgroundTransparency = 0.6
	card.BorderSizePixel = 0

	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 24)

	local cardPadding = Instance.new("UIPadding", card)
	cardPadding.PaddingTop = UDim.new(0, 10)
	cardPadding.PaddingBottom = UDim.new(0, 10)
	cardPadding.PaddingLeft = UDim.new(0, 10)
	cardPadding.PaddingRight = UDim.new(0, 10)

	local icon = Instance.new("ImageLabel", card)
	icon.Size = UDim2.new(0, 90, 0, 90)
	icon.Position = UDim2.new(0.5, 0, 0, 0)
	icon.AnchorPoint = Vector2.new(0.5, 0)
	icon.BackgroundTransparency = 1
	icon.Image = "rbxassetid://5123329241"

	if itemData.Type == "DeveloperProduct" then
		icon.Image = "rbxassetid://103973116782117"
	end

	Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)

	local itemName = Instance.new("TextLabel", card)
	itemName.Size = UDim2.new(1, 0, 0, 25)
	itemName.Position = UDim2.new(0.5, 0, 0, 95)
	itemName.AnchorPoint = Vector2.new(0.5, 0)
	itemName.BackgroundTransparency = 1
	itemName.Font = Enum.Font.GothamBold
	itemName.Text = itemData.Name
	itemName.TextSize = 16
	itemName.TextColor3 = Theme.TextPrimary

	local purchaseButton = Instance.new("TextButton", card)
	purchaseButton.Size = UDim2.new(1, 0, 0, 40)
	purchaseButton.Position = UDim2.new(0.5, 0, 1, 0)
	purchaseButton.AnchorPoint = Vector2.new(0.5, 1)
	purchaseButton.BackgroundColor3 = Theme.Accent
	purchaseButton.Font = Enum.Font.GothamBold
	purchaseButton.TextSize = 18
	purchaseButton.TextColor3 = Theme.PrimaryUI

	Instance.new("UICorner", purchaseButton).CornerRadius = UDim.new(0, 16)

	if isHolidayActive and itemData.OriginalPrice and itemData.Price < itemData.OriginalPrice then
		purchaseButton.Text = "R$ "..itemData.Price
		purchaseButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		purchaseButton.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		purchaseButton.TextStrokeTransparency = 0.5
		purchaseButton.TextColor3 = Color3.fromRGB(255, 255, 255)

		local priceGradient = Instance.new("UIGradient", purchaseButton)
		priceGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Theme.Gold_Light),
			ColorSequenceKeypoint.new(1, Theme.Gold_Dark)
		})
		priceGradient.Rotation = 90

		local oldPriceLabel = Instance.new("TextLabel", card)
		oldPriceLabel.Size = UDim2.new(1, 0, 0, 20)
		oldPriceLabel.Position = UDim2.new(0.5, 0, 1, -45)
		oldPriceLabel.AnchorPoint = Vector2.new(0.5, 1)
		oldPriceLabel.BackgroundTransparency = 1
		oldPriceLabel.Font = Enum.Font.Gotham
		oldPriceLabel.TextSize = 14
		oldPriceLabel.RichText = true
		oldPriceLabel.TextColor3 = Theme.TextSecondary
		oldPriceLabel.Text = "<s>R$ "..itemData.OriginalPrice.."</s>"
	else
		purchaseButton.Text = "R$ "..(itemData.Price)
	end

	if itemData.Type == "GamePass" then
		task.spawn(function()
			local success, productInfo = pcall(function()
				return MarketplaceService:GetProductInfo(itemData.Id, Enum.InfoType.GamePass)
			end)
			if success and productInfo and productInfo.IconImageAssetId then
				icon.Image = "rbxassetid://"..productInfo.IconImageAssetId
			end
		end)
		purchaseButton.MouseButton1Click:Connect(function()
			MarketplaceService:PromptGamePassPurchase(player, itemData.Id)
		end)
	elseif itemData.Type == "DeveloperProduct" then
		purchaseButton.MouseButton1Click:Connect(function()
			MarketplaceService:PromptProductPurchase(player, itemData.Id)
		end)
	end

	return card
end

local function fetchProductPrices()
	local maxDisc = 0
	-- Очищаємо таблицю перед заповненням
	productsData = {} 

	for _, itemDataConfig in ipairs(productsDataConfig) do
		local data = table.clone(itemDataConfig)
		local productType = data.Type == "DeveloperProduct" and Enum.InfoType.Product or Enum.InfoType.GamePass

		local success, info = pcall(function()
			return MarketplaceService:GetProductInfo(data.Id, productType)
		end)

		-- Додаємо товар, ТІЛЬКИ якщо він продається (IsForSale) і не було помилок
		if success and info and info.IsForSale then
			data.Price = info.PriceInRobux or 0 -- Захист від nil

			if data.OriginalPrice and data.Price < data.OriginalPrice then
				local discount = ((data.OriginalPrice - data.Price) / data.OriginalPrice) * 100
				maxDisc = math.max(maxDisc, discount)
			end

			table.insert(productsData, data)
		end
		-- Якщо success == false або IsForSale == false, товар просто пропускається

		task.wait(0.05)
	end
	return math.floor(maxDisc + 0.5)
end

local function fadeDescendants(instance, goalTransparency, duration)
	local tweenInfo = TweenInfo.new(duration)
	for _, descendant in ipairs(instance:GetDescendants()) do
		if descendant == closeButton then
			continue
		end

		if descendant:IsA("GuiObject") then
			local props = {}
			if descendant:IsA("Frame") or descendant:IsA("ImageLabel") or descendant:IsA("TextButton") or descendant:IsA("ImageButton") then
				props.BackgroundTransparency = goalTransparency
			end
			if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
				props.TextTransparency = goalTransparency
			end
			if descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
				props.ImageTransparency = goalTransparency
			end
			if descendant:IsA("UIStroke") then
				props.Transparency = goalTransparency
			end
			if next(props) then
				TweenService:Create(descendant, tweenInfo, props):Play()
			end
		end
	end
end

local function showNotification(notificationType)
	local data = purchaseNotifications[notificationType]
	if not data then return end

	notificationContainer.Visible = true
	notificationLabel.Text = data.Text
	notificationLabel.TextColor3 = (notificationType == "Success") and Theme.Success or (notificationType == "Cancelled" and Theme.TextPrimary or Theme.Error)

	soundPlayer.SoundId = "rbxassetid://"..data.Sound
	soundPlayer:Play()

	notificationLabel.TextTransparency = 1
	TweenService:Create(notificationLabel, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()

	task.delay(4, function()
		if notificationContainer.Visible then
			local tween = TweenService:Create(notificationLabel, TweenInfo.new(0.5), { TextTransparency = 1 })
			tween.Completed:Once(function()
				notificationContainer.Visible = false
			end)
			tween:Play()
		end
	end)
end

-- =============================================================================
-- [5] ІНІЦІАЛІЗАЦІЯ
-- =============================================================================

local maxDiscountPercentage = fetchProductPrices()

local holidayStatus = { IsActive = false, EventName = "" }
if getHolidayStatus and getHolidayStatus:IsA("RemoteFunction") then
	local success, result = pcall(function()
		return getHolidayStatus:InvokeServer()
	end)
	if success and result then
		holidayStatus = result
	end
end

-- УМОВА ЗМІНЕНА: Плашка з'являється тільки якщо є знижка більше 0%
if holidayStatus.IsActive and maxDiscountPercentage > 0 then
	local holidayFrame = Instance.new("Frame")
	holidayFrame.Name = "HolidayFrame"
	holidayFrame.LayoutOrder = 2
	holidayFrame.Size = UDim2.new(1, 0, 0, 40)
	holidayFrame.BackgroundColor3 = Theme.PrimaryUI
	holidayFrame.Parent = mainDisplayContainer

	Instance.new("UICorner", holidayFrame).CornerRadius = UDim.new(0, 12)

	local holidayStroke = Instance.new("UIStroke", holidayFrame)
	holidayStroke.Thickness = 1.5
	holidayStroke.Color = Theme.PrimaryUI_Light

	local holidayAnnouncement = Instance.new("TextLabel", holidayFrame)
	holidayAnnouncement.Name = "HolidayAnnouncement"
	holidayAnnouncement.Size = UDim2.new(1, 0, 1, 0)
	holidayAnnouncement.BackgroundTransparency = 1
	holidayAnnouncement.Font = Enum.Font.GothamBold
	holidayAnnouncement.TextSize = 14
	holidayAnnouncement.TextColor3 = Theme.HolidayYellow
	holidayAnnouncement.TextXAlignment = Enum.TextXAlignment.Center
	holidayAnnouncement.Text = string.format("%s | Знижки до %d%%!", holidayStatus.EventName, maxDiscountPercentage)
end

-- Створюємо картки тільки для тих товарів, які пройшли перевірку
for _, itemData in ipairs(productsData) do
	createItemCard(itemData, holidayStatus.IsActive)
end

-- =============================================================================
-- [6] EVENTS
-- =============================================================================

storeButton.MouseEnter:Connect(function()
	TweenService:Create(storeButton, tweenInfoEnter, { BackgroundColor3 = Theme.Accent_Hover }):Play()
end)

storeButton.MouseLeave:Connect(function()
	TweenService:Create(storeButton, tweenInfoLeave, { BackgroundColor3 = Theme.Accent }):Play()
end)

closeButton.MouseEnter:Connect(function()
	TweenService:Create(closeButton, tweenInfoEnter, { TextColor3 = Theme.Error_Hover }):Play()
end)

closeButton.MouseLeave:Connect(function()
	TweenService:Create(closeButton, tweenInfoLeave, { TextColor3 = Theme.Error }):Play()
end)

storeButton.MouseButton1Click:Connect(function()
	if storeWindowFrame.Visible then return end

	storeWindowFrame.Visible = true
	storeWindowFrame.Size = UDim2.new(0, 550 * 0.9, 0, 450 * 0.9)
	storeWindowFrame.Position = UDim2.new(0.5, 0, 0.4, 0)
	storeWindowFrame.BackgroundTransparency = 1

	fadeDescendants(storeWindowFrame, 1, 0)
	fadeDescendants(storeWindowFrame, 0, windowOpenAnimInfo.Time)

	TweenService:Create(storeWindowFrame, windowOpenAnimInfo, {
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 550, 0, 450),
		BackgroundTransparency = 0
	}):Play()
end)

closeButton.MouseButton1Click:Connect(function()
	local originalSize = UDim2.new(0, 550, 0, 450)

	fadeDescendants(storeWindowFrame, 1, windowCloseAnimInfo.Time)

	local closeTween = TweenService:Create(storeWindowFrame, windowCloseAnimInfo, {
		Position = UDim2.new(0.5, 0, 0.6, 0),
		Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset * 0.9, originalSize.Y.Scale, originalSize.Y.Offset * 0.9),
		BackgroundTransparency = 1,
	})

	closeTween.Completed:Once(function()
		storeWindowFrame.Visible = false
	end)

	closeTween:Play()
end)

MarketplaceService.PromptProductPurchaseFinished:Connect(function(userId, assetId, wasPurchased)
	if userId ~= player.UserId then return end
	
	print("assetid: "..assetId.." | wasPurchased: "..tostring(wasPurchased).." | userid: "..userId)

	if wasPurchased then
		showNotification("Success")
	else
		showNotification("Cancelled")
	end
end)

-- =============================================================================
-- [7] EXP DISPLAY UPDATE
-- =============================================================================

local displayedExp = Instance.new("NumberValue")
displayedExp.Value = expValueObject.Value

local activeDisplayTween = nil

local function updateEXPLabelText(value)
	local displayValue = math.floor(value + 0.5)
	local numEXPDigits = #tostring(displayValue)
	local zeroCount = math.max(0, 8 - numEXPDigits)
	local expZeros = string.rep("0", zeroCount)
	expLabel.Text = string.format('<font color="#%s">%s</font><font color="#%s"><b>%d</b> EXP</font>', 
		Theme.TextSecondary:ToHex(), 
		expZeros, 
		Theme.TextPrimary:ToHex(), 
		displayValue
	)
end

local function onEXPValueChanged(newEXP)
	if activeDisplayTween and activeDisplayTween.PlaybackState == Enum.PlaybackState.Playing then
		activeDisplayTween:Cancel()
	end

	activeDisplayTween = TweenService:Create(displayedExp, TweenInfo.new(1.5, Enum.EasingStyle.Quad), { Value = newEXP })
	activeDisplayTween:Play()
end

expValueObject.Changed:Connect(onEXPValueChanged)

displayedExp.Changed:Connect(function()
	updateEXPLabelText(displayedExp.Value)
end)

updateEXPLabelText(expValueObject.Value)