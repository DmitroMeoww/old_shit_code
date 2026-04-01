--[ FILE: Script | LOCATION: ServerScriptService ]--

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MessagingService = game:GetService("MessagingService")

local billboardDataStore = DataStoreService:GetDataStore("BillboardData_V3")
local MESSAGE_TOPIC = "UpdateBillboardTopic_V1"

local Events = ReplicatedStorage:WaitForChild("BillboardConfig")
local requestPurchaseEvent = Events:WaitForChild("RequestPurchase")
local showPurchaseGUIEvent = Events:WaitForChild("ShowPurchaseGUI")
local purchaseResultEvent = Events:WaitForChild("PurchaseResult")

-- СЕРВЕРНА КОНФІГУРАЦІЯ
local Config = {
	-- !!! ВАЖЛИВО: ВСТАВТЕ СЮДИ URL ВАШОГО DISCORD ВЕБХУКА !!!
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
	DefaultTexture = "rbxassetid://82579436141101"
}

local billboardState = {}
local billboardModels = {}
local pendingPurchases = {}

--[[------------------------------------------------------------------------------------------
	LOGGING & CORE FUNCTIONS
------------------------------------------------------------------------------------------]]

local function sendDiscordLog(player, billboardNumber, imageId, days, paymentInfo)
	if not Config.WebhookURL or Config.WebhookURL == "YOUR_DISCORD_WEBHOOK_URL_HERE" then
		warn("Discord вебхук не налаштовано. Лог не буде відправлено.")
		return
	end

	task.spawn(function()
		local success, result = pcall(function()
			local embed = {
				["title"] = "✅ Нова реклама на білборді!",
				["color"] = 3066993, -- Green
				["description"] = "Гравець **" .. player.Name .. "** успішно розмістив нову рекламу.",
				["fields"] = {
					{name = "👤 Гравець", value = "[" .. player.Name .. "](https://www.roblox.com/users/" .. player.UserId .. "/profile)", inline = true},
					{name = "📋 Білборд №", value = tostring(billboardNumber), inline = true},
					{name = "🖼️ ID Зображення", value = "`" .. tostring(imageId) .. "`", inline = false},
					{name = "⏳ Тривалість", value = tostring(days) .. (days == 1 and " день" or " дн."), inline = true},
					{name = "💳 Оплата", value = tostring(paymentInfo.Cost) .. " " .. paymentInfo.Type, inline = true},
				},
				["thumbnail"] = {url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=150&height=150&format=png"},
				["footer"] = {text = "Лог системи білбордів | ID гравця: " .. player.UserId},
				["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
			}
			local data = {username = "Логи Білбордів", embeds = {embed}}
			HttpService:PostAsync(Config.WebhookURL, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
		end)
		if not success then
			warn("Помилка відправки логу в Discord: ", result)
		end
	end)
end


-- // --- [ ВИПРАВЛЕНА ФУНКЦІЯ ] --- \\
local function updateBillboardVisuals(billboardNumber)
	local model = billboardModels[billboardNumber]
	if not model then return end

	-- Шукаємо Decal з назвою "Img"
	local decalObject = model.Bill:FindFirstChild("Img")

	-- Перевіряємо, чи це дійсно Decal
	if not (decalObject and decalObject:IsA("Decal")) then
		warn("Помилка на білборді #"..tostring(billboardNumber)..": не знайдено об'єкт Decal з назвою 'Img' всередині 'Bill'")
		return
	end

	local data = billboardState[billboardNumber]
	local textureToSet = Config.DefaultTexture

	if data and data.ImageId and data.Expiration > os.time() then
		textureToSet = "rbxassetid://" .. tostring(data.ImageId)
	else
		-- Якщо термін дії минув, очищуємо дані
		if billboardState[billboardNumber] then
			billboardState[billboardNumber] = nil
			pcall(function() billboardDataStore:RemoveAsync(tostring(billboardNumber)) end)
		end
	end

	-- Встановлюємо властивість "Texture" для Decal
	decalObject.Texture = textureToSet
	print("Білборд #" .. tostring(billboardNumber) .. " оновлено: " .. textureToSet)
end
-- \\ --- [ КІНЕЦЬ ВИПРАВЛЕННЯ ] --- //


local function finalizePurchase(player, billboardNumber, imageId, days, paymentInfo)
	if billboardState[billboardNumber] and os.time() < billboardState[billboardNumber].Expiration then
		purchaseResultEvent:FireClient(player, false, "На жаль, хтось вас випередив.")
		return false
	end

	local tariff = Config.Tariffs[days]
	if not (tonumber(imageId) and tariff) then
		purchaseResultEvent:FireClient(player, false, "Неправильні дані покупки.")
		return false
	end

	local currentTime = os.time()
	local expirationTime = currentTime + (days * 24 * 60 * 60)

	local purchaseData = {
		OwnerId = player.UserId, OwnerName = player.Name, ImageId = tostring(imageId),
		PurchaseTime = currentTime, Expiration = expirationTime, Days = days
	}
	billboardState[billboardNumber] = purchaseData

	local success, err = pcall(function()
		billboardDataStore:SetAsync(tostring(billboardNumber), purchaseData)
	end)
	if not success then
		warn("НЕ ВДАЛОСЯ ЗБЕРЕГТИ ДАНІ БІЛБОРДА #" .. billboardNumber .. ": " .. tostring(err))
	end

	local successMsg, errorMsg = pcall(function()
		local messageData = {billboardNumber = billboardNumber, data = purchaseData}
		MessagingService:PublishAsync(MESSAGE_TOPIC, HttpService:JSONEncode(messageData))
	end)
	if not successMsg then warn("MessagingService PublishAsync error:", errorMsg) end

	updateBillboardVisuals(billboardNumber)
	task.spawn(sendDiscordLog, player, billboardNumber, imageId, days, paymentInfo)
	purchaseResultEvent:FireClient(player, true, "Рекламу успішно розміщено!")
	return true
end

--[[------------------------------------------------------------------------------------------
	EVENT HANDLING (Без змін)
------------------------------------------------------------------------------------------]]
-- (Уся інша частина серверного скрипта залишається без змін)

local function onBillboardClicked(player, billboardModel)
	local signLabel = billboardModel.Bill.Nomer.SurfaceGui.SIGN
	local billboardNumber = tonumber(signLabel.Text)
	if not billboardNumber then return end

	local data = billboardState[billboardNumber]
	if data and os.time() < data.Expiration then
		local infoPackage = {
			OwnerName = data.OwnerName, ImageId = data.ImageId,
			PurchaseTime = data.PurchaseTime, ExpirationTime = data.Expiration
		}
		showPurchaseGUIEvent:FireClient(player, billboardModel, true, infoPackage)
	else
		showPurchaseGUIEvent:FireClient(player, billboardModel, false)
	end
end

local function onRequestPurchase(player, billboardNumber, imageId, days, paymentType)
	local tariff = Config.Tariffs[days]
	if not tariff then return purchaseResultEvent:FireClient(player, false, "Невірний тариф.") end

	if billboardState[billboardNumber] and os.time() < billboardState[billboardNumber].Expiration then
		return purchaseResultEvent:FireClient(player, false, "Цей білборд вже орендовано.")
	end

	if paymentType == "EXP" then
		local leaderstats = player:FindFirstChild("leaderstats")
		local exp = leaderstats and leaderstats:FindFirstChild("EXP")
		if exp and exp.Value >= tariff.EXP then
			exp.Value -= tariff.EXP
			local paymentInfo = {Type = "EXP", Cost = tariff.EXP}
			finalizePurchase(player, billboardNumber, imageId, days, paymentInfo)
		else
			purchaseResultEvent:FireClient(player, false, "Недостатньо EXP для покупки.")
		end
	elseif paymentType == "Robux" then
		if not tariff.Robux or not tariff.DevProductId then
			return purchaseResultEvent:FireClient(player, false, "Цей товар недоступний.")
		end
		local purchaseKey = player.UserId .. "_" .. tariff.DevProductId
		pendingPurchases[purchaseKey] = {
			billboardNumber = billboardNumber, imageId = imageId, days = days, timestamp = os.time()
		}
		MarketplaceService:PromptProductPurchase(player, tariff.DevProductId)
	else
		purchaseResultEvent:FireClient(player, false, "Невірний тип оплати.")
	end
end

local function processReceipt(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end

	local purchaseKey = receiptInfo.PlayerId .. "_" .. receiptInfo.ProductId
	local purchaseData = pendingPurchases[purchaseKey]

	if not purchaseData or os.time() - purchaseData.timestamp > 300 then
		pendingPurchases[purchaseKey] = nil
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	pendingPurchases[purchaseKey] = nil 

	local foundTariff
	for _, tariff in pairs(Config.Tariffs) do
		if tariff.DevProductId == receiptInfo.ProductId then foundTariff = tariff; break end
	end
	if not foundTariff then return Enum.ProductPurchaseDecision.NotProcessedYet end

	local paymentInfo = {Type = "Robux", Cost = foundTariff.Robux}
	local wasFinalized = finalizePurchase(player, purchaseData.billboardNumber, purchaseData.imageId, purchaseData.days, paymentInfo)

	return wasFinalized and Enum.ProductPurchaseDecision.PurchaseGranted or Enum.ProductPurchaseDecision.NotProcessedYet
end

--[[------------------------------------------------------------------------------------------
	INITIALIZATION (Без змін)
------------------------------------------------------------------------------------------]]

local function onInitialLoad()
	for _, model in ipairs(workspace.Billboards:GetChildren()) do
		if model:IsA("Model") and model:FindFirstChild("Bill") and model.Bill:FindFirstChild("Nomer") then
			local signLabel = model.Bill.Nomer.SurfaceGui.SIGN
			if signLabel and tonumber(signLabel.Text) then
				local billboardNumber = tonumber(signLabel.Text)
				billboardModels[billboardNumber] = model
				local clickDetector = model.Bill:FindFirstChild("ClickDetector") or Instance.new("ClickDetector", model.Bill)
				clickDetector.MaxActivationDistance = 60
				clickDetector.MouseClick:Connect(function(player) onBillboardClicked(player, model) end)

				local success, data = pcall(function() return billboardDataStore:GetAsync(tostring(billboardNumber)) end)
				if success and data and os.time() < data.Expiration then
					billboardState[billboardNumber] = data
				end
				updateBillboardVisuals(billboardNumber)
			end
		end
	end
end

local function onMessageReceived(message)
	local success, decodedData = pcall(function() return HttpService:JSONDecode(message.Data) end)
	if success and decodedData.billboardNumber and decodedData.data then
		print(`Отримано оновлення для білборду #{decodedData.billboardNumber} від іншого серверу.`)
		billboardState[decodedData.billboardNumber] = decodedData.data
		updateBillboardVisuals(decodedData.billboardNumber)
	end
end
pcall(function() MessagingService:SubscribeAsync(MESSAGE_TOPIC, onMessageReceived) end)

-- Connect Events
requestPurchaseEvent.OnServerEvent:Connect(onRequestPurchase)
MarketplaceService.ProcessReceipt = processReceipt

onInitialLoad()
print("Система білбордів успішно завантажена з синхронізацією.")