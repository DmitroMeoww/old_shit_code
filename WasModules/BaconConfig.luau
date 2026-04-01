-- BaconConfig ModuleScript

local BaconConfig = {}

-- Mesh IDs для волосся (Hairs)
BaconConfig.Hairs = {
	BrownHair = {
		MeshId = 83293901, -- Pal Hair (Bacon Hair) - TextureId не вказаний, перевіряється тільки MeshId
		TextureId = 6858317867
	},
	GirlHair = {
		MeshId = 81642452,
		TextureId = 6858317942 -- Вказані обидва, перевіряються обидва
	}
	-- Додайте інші типи волосся сюди за потреби
}

-- Mesh ID для голови
BaconConfig.HeadMeshId = 8635368147 -- Переконайтеся, що це правильний ID для стандартної голови Roblox

-- Clothing IDs (сорочки, штани)
BaconConfig.Clothing = {
	Shirts = {
		[144076357] = true, -- Roblox Jacket
		[144076435] = true, -- Checkered Shirt
		-- Додайте інші ID сорочок за замовчуванням сюди
	},
	Pants = {
		[144076759] = true, -- Dark Green Jeans
		[867838635] = true, -- Jean Shorts
		-- Додайте інші ID штанів за замовчуванням сюди
	}
}

-- Target Place ID для телепортації
BaconConfig.TargetPlaceId = 82881769196701 -- ВАШ ID місця призначення

-- Skin Colors (RGB у нормалізованому вигляді: 0-1)
-- Налаштуйте ці кольори, якщо стандартні кольори "беконів" змінилися
BaconConfig.SkinColors = {
	-- Типові світлі кольори для "беконів"
	DefaultWhite = { R = 248/255, G = 248/255, B = 248/255 }, -- RGB(248, 248, 248) - Дуже світло-сірий/Білий
	DefaultYellowish = { R = 255/255, G = 204/255, B = 153/255 }, -- RGB(255, 204, 153) - Типовий "беконний" жовтуватий
	-- Типові кольори для "дівчат-нубів"
	DefaultPinkish = { R = 234/255, G = 184/255, B = 146/255 }, -- RGB(234, 184, 146) - Типовий "нубський" рожево-бежевий
	-- Можна додати інші кольори за замовчуванням, якщо потрібно
}

-- Додатково: Діапазон для сірих кольорів (якщо ви хочете враховувати їх)
-- Встановіть UseGreyRange = true, щоб увімкнути перевірку сірого діапазону
BaconConfig.GreyRangeCheck = {
	UseGreyRange = true,
	MinBrightness = 0.3, -- Мінімальна яскравість (0 = чорний, 1 = білий)
	MaxBrightness = 0.9, -- Максимальна яскравість
	MaxSaturation = 0.1 -- Максимальна насиченість (близькість R, G, B)
}


-- Функція для перевірки, чи є колір "bacon-like" (стандартним)
function BaconConfig.IsBaconSkinColor(color)
	local cfgColors = BaconConfig.SkinColors
	local tolerance = 0.02 -- Допуск на невеликі відхилення кольору

	-- 1. Перевірка на точні кольори зі списку SkinColors
	for colorName, skinColorData in pairs(cfgColors) do
		if type(skinColorData) == "table" and skinColorData.R then -- Перевіряємо, чи це валідний запис кольору
			if math.abs(color.R - skinColorData.R) < tolerance and
				math.abs(color.G - skinColorData.G) < tolerance and
				math.abs(color.B - skinColorData.B) < tolerance then
				-- print("IsBaconSkinColor Debug: Match found for exact color:", colorName)
				return true -- Знайдено відповідний колір
			end
		end
	end

	-- 2. Опціональна перевірка на сірий діапазон
	local greyCfg = BaconConfig.GreyRangeCheck
	if greyCfg.UseGreyRange then
		-- Перевірка на близькість R, G, B (низька насиченість)
		local maxDiff = math.max(math.abs(color.R - color.G), math.abs(color.G - color.B), math.abs(color.R - color.B))
		if maxDiff < greyCfg.MaxSaturation then
			-- Перевірка на яскравість (у межах MinBrightness та MaxBrightness)
			-- Проста яскравість як середнє значення R, G, B
			local brightness = (color.R + color.G + color.B) / 3
			if brightness >= greyCfg.MinBrightness and brightness <= greyCfg.MaxBrightness then
				-- print("IsBaconSkinColor Debug: Match found within grey range.")
				return true -- Колір є сірим у заданому діапазоні
			end
		end
	end

	-- print("IsBaconSkinColor Debug: No default skin color match found.")
	return false -- Жоден стандартний колір або сірий діапазон не підійшов
end


-- Функція для перевірки, чи є волосся "bacon-like" (стандартним) - ОНОВЛЕНА ЛОГІКА
function BaconConfig.IsBaconHair(meshId, textureId)
	-- Переконуємося, що textureId - це рядок, навіть якщо передали nil або порожнє значення
	textureId = textureId and tostring(textureId) or ""
	-- Перетворюємо meshId на число, якщо це можливо
	meshId = tonumber(meshId)

	if not meshId then return false end -- Якщо meshId не є числом, виходимо

	for hairName, hairData in pairs(BaconConfig.Hairs) do
		-- 1. Перевіряємо збіг MeshId
		if meshId == hairData.MeshId then
			-- 2. Перевіряємо TextureId ТІЛЬКИ якщо він вказаний у конфігу для ЦЬОГО волосся
			if hairData.TextureId then
				-- TextureId вказаний у конфігу, тому він ПОВИНЕН збігатися
				local configTextureId = tostring(hairData.TextureId)
				if textureId == configTextureId then
					-- print("IsBaconHair Debug: Match found for '"..hairName.."' (Mesh & Texture required and match)")
					return true -- Збіг MeshId і обов'язкового TextureId
				else
					-- print("IsBaconHair Debug: Mesh match for '"..hairName.."', but required TextureId ("..configTextureId..") does not match ("..textureId..")")
					-- Продовжуємо цикл, можливо, інший запис підійде
				end
			else
				-- TextureId НЕ вказаний у конфігу для цього волосся (як у BrownHair).
				-- Отже, збігу MeshId достатньо.
				-- print("IsBaconHair Debug: Match found for '"..hairName.."' (Only Mesh required)")
				return true -- Збіг MeshId, TextureId не потрібен
			end
		end
	end
	-- Жоден запис у BaconConfig.Hairs не підійшов
	-- print("IsBaconHair Debug: No match found for MeshId:", meshId, "TextureId:", textureId)
	return false
end

-- Опції телепортації (залиште порожнім {}, якщо не потрібні особливі налаштування)
BaconConfig.TeleportOptions = Instance.new("TeleportOptions")
-- BaconConfig.TeleportOptions.ShouldReserveServer = false -- Приклад: не резервувати приватний сервер
-- BaconConfig.TeleportOptions:SetTeleportData({ source = "BaconChecker" }) -- Приклад: передача даних

return BaconConfig