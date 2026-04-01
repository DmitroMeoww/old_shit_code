-- [ MERGED SCRIPT: Game Manager + Billboard System ] --

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MessagingService = game:GetService("MessagingService")
local RunService = game:GetService("RunService")

-- === CONFIGURATION ===

-- 1. Billboard Config
local BillboardConfig = {
	WebhookURL = "https://discord.com/api/webhooks/1395775062866399283/d2GazpIJtkiyHoldCWs9pAutw1ocyU4nRST9ha_fnoL7hs3FRRRPaSlBby77QKN6qufA",
	Tariffs = {
		[1] = { Robux = 60,   EXP = 1250, DevProductId = 3338541996 },
		[2] = { Robux = 100,  EXP = 1500, DevProductId = 3338541995 },
		[3] = { Robux = nil,  EXP = 1650, DevProductId = nil },
		[4] = { Robux = nil,  EXP = 1750, DevProductId = nil },
		[5] = { Robux = nil,  EXP = 1850, DevProductId = nil },
		[6] = { Robux = nil,  EXP = 1950, DevProductId = nil },
		[7] = { Robux = nil,  EXP = 2880, DevProductId = nil },
	},
	DefaultTexture = "rbxassetid://82579436141101",
	MessageTopic = "UpdateBillboardTopic_V1"
}

-- 2. EXP Products Config
local EVENT_NAME_DEFAULT = "День Незалежності!"
local EVENT_NAME_HOLIDAY = "День народження М1!!"

local expProductsConfig = {
	[2686236007] = { OriginalPrice = 30,   Reward = 100,   Currency = "EXP" },
	[2686236556] = { OriginalPrice = 50,   Reward = 300,   Currency = "EXP" },
	[2686236557] = { OriginalPrice = 100,  Reward = 425,   Currency = "EXP" },
	[2686236554] = { OriginalPrice = 200,  Reward = 650,   Currency = "EXP" },
	[2686236555] = { OriginalPrice = 350,  Reward = 750,   Currency = "EXP" },
	[3330925357] = { OriginalPrice = 1000, Reward = 2500,  Currency = "EXP" },
	[3330926313] = { OriginalPrice = 2500, Reward = 7500,  Currency = "EXP" },
	[3330927094] = { OriginalPrice = 3500, Reward = 11111, Currency = "EXP" },
}

-- === VARIABLES & DATASTORES ===

local billboardDataStore = DataStoreService:GetDataStore("BillboardData_V3")
local purchaseHistoryStore = DataStoreService:GetDataStore("PurchaseHistory_V2")

local billboardState = {}
local billboardModels = {}
local pendingBillboardPurchases = {} -- Store info for Robux billboard buys

-- Remotes for Billboards
local Events = ReplicatedStorage:WaitForChild("BillboardConfig")
local requestPurchaseEvent = Events:WaitForChild("RequestPurchase")
local showPurchaseGUIEvent = Events:WaitForChild("ShowPurchaseGUI")
local purchaseResultEvent = Events:WaitForChild("PurchaseResult")

-- Holiday Status Objects
local isHolidayActive = Instance.new("BoolValue")
isHolidayActive.Name = "IsHolidayActive"
isHolidayActive.Value = false
isHolidayActive.Parent = ReplicatedStorage

local currentEventName = Instance.new("StringValue")
currentEventName.Name = "CurrentEventName"
currentEventName.Value = EVENT_NAME_DEFAULT
currentEventName.Parent = ReplicatedStorage

local getHolidayStatus = Instance.new("RemoteFunction")
getHolidayStatus.Name = "GetHolidayStatus"
getHolidayStatus.Parent = ReplicatedStorage

-- === HELPER FUNCTIONS ===

local function findPlayerEXP(player, timeout)
	timeout = timeout or 5
	local startTime = tick()
	while (tick() - startTime) < timeout do
		if not player or not player.Parent then return nil end
		local ls = player:FindFirstChild("leaderstats")
		if ls then
			local exp = ls:FindFirstChild("EXP")
			if exp and exp:IsA("IntValue") then return exp end
		end
		task.wait(0.5)
	end
	return nil
end

local function sendDiscordLog(player, billboardNumber, imageId, days, paymentInfo)
	if not BillboardConfig.WebhookURL or BillboardConfig.WebhookURL == "YOUR_DISCORD_WEBHOOK_URL_HERE" then return end
	task.spawn(function()
		local success, result = pcall(function()
			local embed = {
				["title"] = "✅ Нова реклама на білборді!",
				["color"] = 3066993,
				["description"] = "Гравець **" .. player.Name .. "** успішно розмістив нову рекламу.",
				["fields"] = {
					{name = "👤 Гравець", value = player.Name, inline = true},
					{name = "📋 Білборд №", value = tostring(billboardNumber), inline = true},
					{name = "🖼️ ID", value = "`" .. tostring(imageId) .. "`", inline = false},
					{name = "⏳ Днів", value = tostring(days), inline = true},
					{name = "💳 Оплата", value = tostring(paymentInfo.Cost) .. " " .. paymentInfo.Type, inline = true},
				},
				["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
			}
			HttpService:PostAsync(BillboardConfig.WebhookURL, HttpService:JSONEncode({embeds = {embed}}), Enum.HttpContentType.ApplicationJson)
		end)
		if not success then warn("Discord Log Error: ", result) end
	end)
end

local function checkDiscounts()
	print("🔍 Checking discounts...")
	local discountFound = false
	for productId, data in pairs(expProductsConfig) do
		local success, info = pcall(function()
			return MarketplaceService:GetProductInfo(productId, Enum.InfoType.Product)
		end)
		if success and info and info.PriceInRobux < data.OriginalPrice then
			print(string.format("🔥 Discount found! ID: %d | Now: %d", productId, info.PriceInRobux))
			discountFound = true
		end
		task.wait(0.1)
	end

	isHolidayActive.Value = discountFound
	currentEventName.Value = discountFound and EVENT_NAME_HOLIDAY or EVENT_NAME_DEFAULT
	print("Holiday Mode: " .. tostring(discountFound))
end

-- === BILLBOARD LOGIC ===

local function updateBillboardVisuals(billboardNumber)
	local model = billboardModels[billboardNumber]
	if not model then return end

	local decalObject = model.Bill:FindFirstChild("Img")
	if not (decalObject and decalObject:IsA("Decal")) then return end

	local data = billboardState[billboardNumber]
	local textureToSet = BillboardConfig.DefaultTexture

	if data and data.ImageId and data.Expiration > os.time() then
		textureToSet = "rbxassetid://" .. tostring(data.ImageId)
	else
		if billboardState[billboardNumber] then
			billboardState[billboardNumber] = nil
			pcall(function() billboardDataStore:RemoveAsync(tostring(billboardNumber)) end)
		end
	end
	decalObject.Texture = textureToSet
end

local function finalizeBillboardPurchase(player, billboardNumber, imageId, days, paymentInfo)
	if billboardState[billboardNumber] and os.time() < billboardState[billboardNumber].Expiration then
		purchaseResultEvent:FireClient(player, false, "Вже орендовано іншим гравцем.")
		return false
	end

	-- Validate ImageID (basic check)
	if not tonumber(imageId) then 
		purchaseResultEvent:FireClient(player, false, "Невірний ID зображення.")
		return false 
	end

	local currentTime = os.time()
	local expirationTime = currentTime + (days * 24 * 60 * 60)
	local purchaseData = {
		OwnerId = player.UserId, OwnerName = player.Name, ImageId = tostring(imageId),
		PurchaseTime = currentTime, Expiration = expirationTime, Days = days
	}

	billboardState[billboardNumber] = purchaseData

	-- Save & Sync
	pcall(function() billboardDataStore:SetAsync(tostring(billboardNumber), purchaseData) end)
	pcall(function() 
		MessagingService:PublishAsync(BillboardConfig.MessageTopic, HttpService:JSONEncode({billboardNumber = billboardNumber, data = purchaseData})) 
	end)

	updateBillboardVisuals(billboardNumber)
	sendDiscordLog(player, billboardNumber, imageId, days, paymentInfo)
	purchaseResultEvent:FireClient(player, true, "Рекламу розміщено!")
	return true
end

-- === INTERACTION & EVENTS ===

local function onBillboardClicked(player, billboardModel)
	local signLabel = billboardModel.Bill.Nomer.SurfaceGui.SIGN
	local billboardNumber = tonumber(signLabel.Text)
	if not billboardNumber then return end

	local data = billboardState[billboardNumber]
	if data and os.time() < data.Expiration then
		showPurchaseGUIEvent:FireClient(player, billboardModel, true, {
			OwnerName = data.OwnerName, ImageId = data.ImageId,
			PurchaseTime = data.PurchaseTime, ExpirationTime = data.Expiration
		})
	else
		showPurchaseGUIEvent:FireClient(player, billboardModel, false)
	end
end

local function onRequestPurchase(player, billboardNumber, imageId, days, paymentType)
	local tariff = BillboardConfig.Tariffs[days]
	if not tariff then return purchaseResultEvent:FireClient(player, false, "Невірний тариф.") end

	-- EXP Payment Logic
	if paymentType == "EXP" then
		local expStat = findPlayerEXP(player)
		if expStat and expStat.Value >= tariff.EXP then
			expStat.Value -= tariff.EXP
			finalizeBillboardPurchase(player, billboardNumber, imageId, days, {Type = "EXP", Cost = tariff.EXP})
		else
			purchaseResultEvent:FireClient(player, false, "Недостатньо EXP.")
		end

		-- Robux Payment Logic
	elseif paymentType == "Robux" then
		if not tariff.Robux or not tariff.DevProductId then return purchaseResultEvent:FireClient(player, false, "Недоступно.") end

		local key = player.UserId .. "_" .. tariff.DevProductId
		pendingBillboardPurchases[key] = {
			billboardNumber = billboardNumber, imageId = imageId, days = days, timestamp = os.time()
		}
		MarketplaceService:PromptProductPurchase(player, tariff.DevProductId)
	end
end

-- === UNIFIED PROCESS RECEIPT ===
-- Ця функція обробляє І покупку EXP, І покупку Білбордів за робукси

local function processReceipt(receiptInfo)
	print("🛒 ProcessReceipt called for ProductID:", receiptInfo.ProductId)

	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end

	-- 1. CHECK IF IT IS AN EXP PRODUCT
	local expProductData = expProductsConfig[receiptInfo.ProductId]

	if expProductData then
		print("➡️ Identified as EXP Product")
		local purchaseKey = "p_" .. receiptInfo.PurchaseId
		local success, isPurchased = pcall(function() return purchaseHistoryStore:GetAsync(purchaseKey) end)

		if success and isPurchased then return Enum.ProductPurchaseDecision.PurchaseGranted end

		local expStat = findPlayerEXP(player, 15)
		if not expStat then 
			warn("❌ Could not find EXP for player " .. player.Name)
			return Enum.ProductPurchaseDecision.NotProcessedYet 
		end

		expStat.Value = expStat.Value + expProductData.Reward
		print(string.format("✅ Gave %d EXP to %s", expProductData.Reward, player.Name))

		pcall(function() purchaseHistoryStore:SetAsync(purchaseKey, true) end)
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	-- 2. CHECK IF IT IS A BILLBOARD PRODUCT
	local purchaseKey = receiptInfo.PlayerId .. "_" .. receiptInfo.ProductId
	local pendingData = pendingBillboardPurchases[purchaseKey]

	-- Find tariff info to confirm it's a billboard product ID
	local foundTariff
	for _, tariff in pairs(BillboardConfig.Tariffs) do
		if tariff.DevProductId == receiptInfo.ProductId then foundTariff = tariff; break end
	end

	if foundTariff then
		print("➡️ Identified as Billboard Product")
		if not pendingData or os.time() - pendingData.timestamp > 300 then
			-- If no pending data (player crashed? logic lost?), handle gracefully or grant if already processed logic existed
			pendingBillboardPurchases[purchaseKey] = nil
			return Enum.ProductPurchaseDecision.PurchaseGranted -- Granting to avoid charge loop, but item might be lost if pending data is gone
		end

		local finalized = finalizeBillboardPurchase(player, pendingData.billboardNumber, pendingData.imageId, pendingData.days, {Type = "Robux", Cost = foundTariff.Robux})
		pendingBillboardPurchases[purchaseKey] = nil

		if finalized then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		else
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
	end

	warn("❓ Unknown ProductID:", receiptInfo.ProductId)
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

-- === INITIALIZATION ===

local function onInitialLoad()
	local billboardsFolder = workspace:FindFirstChild("Billboards")
	if not billboardsFolder then return end

	for _, model in ipairs(billboardsFolder:GetChildren()) do
		if model:IsA("Model") and model:FindFirstChild("Bill") and model.Bill:FindFirstChild("Nomer") then
			local signLabel = model.Bill.Nomer.SurfaceGui.SIGN
			local bNum = tonumber(signLabel.Text)
			if bNum then
				billboardModels[bNum] = model
				local cd = model.Bill:FindFirstChild("ClickDetector") or Instance.new("ClickDetector", model.Bill)
				cd.MaxActivationDistance = 60
				cd.MouseClick:Connect(function(plr) onBillboardClicked(plr, model) end)

				local s, d = pcall(function() return billboardDataStore:GetAsync(tostring(bNum)) end)
				if s and d and os.time() < d.Expiration then
					billboardState[bNum] = d
				end
				updateBillboardVisuals(bNum)
			end
		end
	end
end

-- Setup Connections
getHolidayStatus.OnServerInvoke = function() return {IsActive = isHolidayActive.Value, EventName = currentEventName.Value} end
requestPurchaseEvent.OnServerEvent:Connect(onRequestPurchase)

pcall(function()
	MessagingService:SubscribeAsync(BillboardConfig.MessageTopic, function(message)
		local s, d = pcall(function() return HttpService:JSONDecode(message.Data) end)
		if s and d.billboardNumber and d.data then
			print("Syncing billboard #"..d.billboardNumber)
			billboardState[d.billboardNumber] = d.data
			updateBillboardVisuals(d.billboardNumber)
		end
	end)
end)

task.spawn(checkDiscounts)
task.spawn(function() while true do task.wait(30) print("💓 [HEARTBEAT] Merged Manager Running") end end)

-- CRITICAL: Assign ProcessReceipt
MarketplaceService.ProcessReceipt = processReceipt

onInitialLoad()
print("🚀 MERGED SCRIPT LOADED: Billboard System & EXP Manager active.")