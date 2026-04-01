-- =============================================================================
-- ||                            GAME MANAGER SCRIPT                          ||
-- =============================================================================
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

--[[ НАЛАШТУВАННЯ ]]--

local EVENT_NAME_DEFAULT = "День Незалежності!"
local EVENT_NAME_HOLIDAY = "День народження М1!!"

local productsConfig = {
	[2686236007] = { OriginalPrice = 30,   Reward = 100,   Currency = "EXP" },
	[2686236556] = { OriginalPrice = 50,   Reward = 300,   Currency = "EXP" },
	[2686236557] = { OriginalPrice = 100,  Reward = 425,   Currency = "EXP" },
	[2686236554] = { OriginalPrice = 200,  Reward = 650,   Currency = "EXP" },
	[2686236555] = { OriginalPrice = 350,  Reward = 750,   Currency = "EXP" },
	[3330925357] = { OriginalPrice = 1000, Reward = 2500,  Currency = "EXP" },
	[3330926313] = { OriginalPrice = 2000, Reward = 7500,  Currency = "EXP" },
	[3330927094] = { OriginalPrice = 3500, Reward = 11111, Currency = "EXP" },
}

local purchaseHistoryStore = DataStoreService:GetDataStore("PurchaseHistory_V2")

-- Черга покупок (для обробки коли гравця ще немає)
local pendingPurchases = {}

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

-- =============================================================================
--                          АВТОМАТИЧНА ПЕРЕВІРКА ЦІН
-- =============================================================================
local function checkDiscounts()
	print("🔍 Перевірка цін на товари для активації свята...")
	local discountFound = false

	for productId, data in pairs(productsConfig) do
		local success, info = pcall(function()
			return MarketplaceService:GetProductInfo(productId, Enum.InfoType.Product)
		end)

		if success and info then
			local currentPrice = info.PriceInRobux
			if currentPrice < data.OriginalPrice then
				print(string.format("   🔥 ЗНИЖКА ЗНАЙДЕНА! ID: %d | Ціна: %d (Була: %d)", productId, currentPrice, data.OriginalPrice))
				discountFound = true
			end
		else
			warn("   ⚠️ Не вдалося отримати ціну для ID:", productId)
		end
		task.wait(0.1)
	end

	if discountFound then
		isHolidayActive.Value = true
		currentEventName.Value = EVENT_NAME_HOLIDAY
		print("🎉 РЕЖИМ СВЯТА АКТИВОВАНО: " .. currentEventName.Value)
	else
		isHolidayActive.Value = false
		currentEventName.Value = EVENT_NAME_DEFAULT
		print("ℹ️ Знижок не знайдено. Стандартний режим.")
	end
end

-- =============================================================================
--                    ДОПОМІЖНА ФУНКЦІЯ: БЕЗПЕЧНИЙ ПОШУК EXP
-- =============================================================================
local function findPlayerEXP(player, timeout)
	timeout = timeout or 15
	local startTime = tick()

	print(string.format("🔎 Пошук EXP для гравця %s (UserID: %d)...", player.Name, player.UserId))

	while (tick() - startTime) < timeout do
		-- Перевірка чи гравець все ще в грі
		if not player or not player.Parent then
			warn("⚠️ Гравець вийшов під час очікування")
			return nil
		end

		local leaderstats = player:FindFirstChild("leaderstats")

		if leaderstats then
			local exp = leaderstats:FindFirstChild("EXP")

			if exp and exp:IsA("IntValue") then
				print(string.format("✅ EXP знайдено! Поточне значення: %d", exp.Value))
				return exp
			else
				warn("⚠️ leaderstats існує, але EXP не знайдено або має неправильний тип")
				if exp then
					warn(string.format("   Тип EXP: %s (очікувався IntValue)", exp.ClassName))
				end
			end
		end

		task.wait(0.5)
	end

	-- Діагностика якщо не знайдено
	warn("❌ ТАЙМ-АУТ: EXP не знайдено після " .. timeout .. " секунд")
	warn("   Структура гравця:")
	for _, child in ipairs(player:GetChildren()) do
		warn(string.format("      - %s (%s)", child.Name, child.ClassName))
		if child.Name == "leaderstats" then
			for _, subChild in ipairs(child:GetChildren()) do
				warn(string.format("         └─ %s (%s)", subChild.Name, subChild.ClassName))
			end
		end
	end

	return nil
end

-- =============================================================================
--                          ОБРОБКА ПОКУПОК (ВИПРАВЛЕНО)
-- =============================================================================

local function processReceipt(receiptInfo)
	print("🚨🚨🚨 PROCESSRECEIPT ВИКЛИКАНО! 🚨🚨🚨")
	print("═══════════════════════════════════════════════════════════")

	local userId = receiptInfo.PlayerId
	local productId = receiptInfo.ProductId
	local purchaseId = receiptInfo.PurchaseId

	print(string.format("📦 НОВА ПОКУПКА"))
	print(string.format("   UserID: %d", userId))
	print(string.format("   ProductID: %d", productId))
	print(string.format("   PurchaseID: %s", purchaseId))
	print(string.format("   CurrencyType: %s", tostring(receiptInfo.CurrencyType)))
	print(string.format("   CurrencySpent: %d", receiptInfo.CurrencySpent))
	print("═══════════════════════════════════════════════════════════")

	local player = Players:GetPlayerByUserId(userId)
	if not player then
		warn("⚠️ Гравець не в грі. Покупка буде повторена пізніше.")
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local productData = productsConfig[productId]
	if not productData then
		warn("❌ Невідомий ProductID:", productId)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	print(string.format("💰 Товар: %s (Нагорода: +%d %s)", 
		productData.Currency, 
		productData.Reward, 
		productData.Currency
		))

	-- Перевірка повторної покупки
	local purchaseKey = "p_" .. purchaseId
	local success, isPurchased = pcall(function()
		return purchaseHistoryStore:GetAsync(purchaseKey)
	end)

	if success and isPurchased then
		print("✅ Покупка вже оброблена раніше (захист від дублікатів)")
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	-- Пошук EXP з детальною діагностикою
	local expStat = findPlayerEXP(player, 15)

	if not expStat then
		warn("❌ КРИТИЧНА ПОМИЛКА: Не вдалося знайти EXP!")
		warn("   Можливі причини:")
		warn("   1. Скрипт створення leaderstats не працює")
		warn("   2. EXP має неправильну назву (перевірте регістр)")
		warn("   3. EXP не є IntValue")
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Видача нагороди
	local oldValue = expStat.Value
	expStat.Value = expStat.Value + productData.Reward

	print("═══════════════════════════════════════════════════════════")
	print("✅✅✅ ПОКУПКА УСПІШНА ✅✅✅")
	print(string.format("   Гравець: %s", player.Name))
	print(string.format("   Нагорода: +%d %s", productData.Reward, productData.Currency))
	print(string.format("   Було: %d → Стало: %d", oldValue, expStat.Value))
	print("═══════════════════════════════════════════════════════════")

	-- Збереження історії
	pcall(function()
		purchaseHistoryStore:SetAsync(purchaseKey, true)
	end)

	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- =============================================================================
--                             ПІДКЛЮЧЕННЯ
-- =============================================================================

task.spawn(checkDiscounts)

-- КРИТИЧНО: Підключення ProcessReceipt
print("🔌 Підключення MarketplaceService.ProcessReceipt...")
MarketplaceService.ProcessReceipt = processReceipt
print("✅ ProcessReceipt підключено!")

-- Тестове повідомлення кожні 30 секунд
task.spawn(function()
	while true do
		task.wait(30)
		print("💓 [HEARTBEAT] Game Manager активний. ProcessReceipt очікує покупок...")
	end
end)

getHolidayStatus.OnServerInvoke = function(player)
	return {
		IsActive = isHolidayActive.Value,
		EventName = currentEventName.Value,
	}
end

print("═══════════════════════════════════════════════════════════")
print("🚀 GAME MANAGER ЗАВАНТАЖЕНО")
print("   Відстеження покупок: ✅")
print("   Автоматична перевірка знижок: ✅")
print("   Середовище:", game:GetService("RunService"):IsStudio() and "Studio" or "Реальна гра")
print("   Game ID:", game.GameId)
print("═══════════════════════════════════════════════════════════")
print("⏳ Очікування покупок...")
print("   Купіть будь-який товар щоб перевірити ProcessReceipt")