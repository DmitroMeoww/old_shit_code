local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService") -- Сервіс для чату
local Clouds = game.Workspace.Terrain.Clouds
local Atmosphere = lighting:WaitForChild("Atmosphere")

local API_KEY = "9e8887cde6024f02bc9160307240710"
local LOCATION = "Kyiv"
local ADMIN_USER_ID = 1385423455 -- Ваш ID для доступу до команд

-- Знаходимо папку зі снігом у сховищі
local SnowAssetsFolder = ReplicatedStorage:WaitForChild("SnowAssets")

local cityNameValue = script:FindFirstChild("CityName") or Instance.new("StringValue")
cityNameValue.Name = "CityName"
cityNameValue.Value = LOCATION
cityNameValue.Parent = script

-- Збереження оригінальної атмосфери
local origAtmosDensity = Atmosphere.Density
local origAtmosHaze = Atmosphere.Haze
local origAtmosColor = Atmosphere.Color
local origAtmosDecay = Atmosphere.Decay

-- ЗМІННІ КОНТРОЛЮ
local SIMULATION_MODE_ENABLED = false 
local TWEEN_DURATION = 10 

-- Змінна для примусової погоди (якщо nil, то працює API)
local forcedWeatherType = nil 

-- Перевірка зими (Грудень - Січень)
local function isWinterSeason()
	if SIMULATION_MODE_ENABLED then return true end
	local date = os.date("*t")
	return (date.month == 12 or date.month == 1)
end

-- === ЛОГІКА СНІГУ ===
local function toggleSnow(isActive)
	if isActive then
		if SnowAssetsFolder.Parent ~= workspace then
			SnowAssetsFolder.Parent = workspace
			print("❄️ Snow Activated")
		end

		for _, part in pairs(SnowAssetsFolder:GetChildren()) do
			if part:IsA("BasePart") then
				for _, child in pairs(part:GetChildren()) do
					if child.Name == "ClonedEmitter" then child:Destroy() end
				end
				local template = part:FindFirstChild("SnowEmitter")
				if template then
					for i = 1, 14 do
						local clone = template:Clone()
						clone.Name = "ClonedEmitter"
						clone.Parent = part
						clone.Enabled = true
						clone.Speed = NumberRange.new(30, 30)
						clone.Rate = 20
						clone.Lifetime = NumberRange.new(5, 8) 
					end
				end
			end
		end
	else
		if SnowAssetsFolder.Parent == workspace then
			print("🚫 Snow Deactivated")
			for _, part in pairs(SnowAssetsFolder:GetChildren()) do
				for _, child in pairs(part:GetChildren()) do
					if child.Name == "ClonedEmitter" then child:Destroy() end
				end
			end
			SnowAssetsFolder.Parent = ReplicatedStorage
		end
	end
end

-- === ЗАСТОСУВАННЯ ЕФЕКТІВ ===
function applyWeatherEffects(weatherType)
	print("Applying Weather Type Code:", weatherType)

	local settings = {
		CloudCover = 0, CloudDensity = 0.1, CloudColor = Color3.new(1,1,1),
		AtmosDensity = origAtmosDensity, AtmosHaze = origAtmosHaze, AtmosColor = origAtmosColor, AtmosDecay = origAtmosDecay,
		Bloom = {0.4, 24, 2}
	}

	local rainEnabled = false
	local snowActive = false

	if weatherType == 1 then -- Rain
		settings.CloudCover = 0.7; settings.CloudDensity = 1; settings.CloudColor = Color3.fromRGB(36,44,53)
		settings.Bloom = {0.1, 10, 2.5}
		rainEnabled = true

	elseif weatherType == 4 then -- Heavy Rain
		settings.CloudCover = 1; settings.CloudDensity = 0.3; settings.CloudColor = Color3.fromRGB(22,22,22)
		settings.AtmosDensity = origAtmosDensity * 1.2
		settings.Bloom = {0.2, 15, 3}
		rainEnabled = true

	elseif weatherType == 9 then -- Thunderstorm
		settings.CloudCover = 1; settings.CloudDensity = 1; settings.CloudColor = Color3.fromRGB(38,38,51)
		settings.AtmosDensity = origAtmosDensity * 1.5
		settings.Bloom = {0.3, 20, 2.8}
		rainEnabled = true

	elseif weatherType == 5 then -- SNOW
		snowActive = true 
		settings.CloudCover = 0.85; settings.CloudDensity = 0.9; settings.CloudColor = Color3.fromRGB(230, 230, 245)
		settings.Bloom = {0.5, 30, 1.5}
		-- Ваші налаштування атмосфери для снігу
		settings.AtmosDensity = 0.409; settings.AtmosHaze = 10
		settings.AtmosColor = Color3.fromRGB(249, 249, 249); settings.AtmosDecay = Color3.fromRGB(180, 126, 40)
	end

	pcall(function()
		TweenService:Create(Clouds, TweenInfo.new(TWEEN_DURATION), {Cover = settings.CloudCover, Density = settings.CloudDensity, Color = settings.CloudColor}):Play()
		TweenService:Create(Atmosphere, TweenInfo.new(TWEEN_DURATION), {Density = settings.AtmosDensity, Haze = settings.AtmosHaze, Color = settings.AtmosColor, Decay = settings.AtmosDecay}):Play()
		local bloom = lighting:FindFirstChild("Bloom") or Instance.new("BloomEffect", lighting)
		TweenService:Create(bloom, TweenInfo.new(TWEEN_DURATION), {Intensity = settings.Bloom[1], Size = settings.Bloom[2], Threshold = settings.Bloom[3]}):Play()
	end)

	for _, plr in pairs(game.Players:GetPlayers()) do
		local gui = plr:FindFirstChild("PlayerGui")
		if gui then
			local rainEff = gui:FindFirstChild("RainEffects")
			if not rainEff and script:FindFirstChild("RainEffects") then
				rainEff = script.RainEffects:Clone(); rainEff.Parent = gui
			end
			if rainEff and rainEff:FindFirstChild("RainScript") then
				rainEff.RainScript:FindFirstChild("ENABLED").Value = rainEnabled
			end
		end
	end

	toggleSnow(snowActive)
end

-- === ФУНКЦІЇ ОТРИМАННЯ ДАНИХ ===
function getCurrentWeather()
	local url = "http://api.weatherapi.com/v1/current.json?key=" .. API_KEY .. "&q=" .. cityNameValue.Value
	local success, response = pcall(function() return HttpService:GetAsync(url) end)
	if success then
		local data = HttpService:JSONDecode(response)
		if data and data.current then
			return data.current.condition.text:lower(), data.current.is_day == 1
		end
	end
	return "clear", true
end

function determineWeatherType(condition, isDay)
	local isWinter = isWinterSeason()
	local code = 0 

	if string.find(condition, "thunder") then code = 9
	elseif string.find(condition, "heavy rain") or string.find(condition, "torrent") then code = 4
	elseif string.find(condition, "rain") or string.find(condition, "shower") or string.find(condition, "drizzle") then code = 1
	elseif string.find(condition, "snow") or string.find(condition, "blizzard") then code = 5
	elseif string.find(condition, "overcast") then code = 2
	elseif string.find(condition, "fog") or string.find(condition, "mist") then code = 3
	elseif string.find(condition, "clear") and not isDay then code = 8
	end

	if isWinter and (code == 1 or code == 4 or code == 9 or code == 5) then
		return 5
	end
	return code
end

-- === СИСТЕМА КОМАНД (TextChatService) ===
local function createSlashCommand(name, alias, weatherCode)
	local cmdsFolder = TextChatService:FindFirstChild("TextChatCommands")
	if not cmdsFolder then
		cmdsFolder = Instance.new("Folder")
		cmdsFolder.Name = "TextChatCommands"
		cmdsFolder.Parent = TextChatService
	end

	local cmd = Instance.new("TextChatCommand")
	cmd.Name = name
	cmd.PrimaryAlias = alias
	cmd.Parent = cmdsFolder

	cmd.Triggered:Connect(function(origin, message)
		if origin.UserId == ADMIN_USER_ID then
			forcedWeatherType = weatherCode
			print("Admin changed weather to:", name)

			if weatherCode == nil then
				-- Якщо SYNC, запускаємо перевірку API
				local c, d = getCurrentWeather()
				local t = determineWeatherType(c, d)
				applyWeatherEffects(t)
			else
				-- Інакше ставимо примусово
				applyWeatherEffects(weatherCode)
			end
		end
	end)
end

-- Реєстрація команд
createSlashCommand("ForceSnow", "/snow", 5)       -- Сніг
createSlashCommand("ForceRain", "/rain", 1)       -- Дощ
createSlashCommand("ForceHeavyRain", "/heavy", 4) -- Злива
createSlashCommand("ForceStorm", "/storm", 9)     -- Гроза
createSlashCommand("ForceClear", "/clear", 0)     -- Ясно
createSlashCommand("SyncWeather", "/sync", nil)   -- Повернути реальну погоду

-- === ГОЛОВНИЙ ЦИКЛ ===
game.Players.PlayerAdded:Connect(function(plr)
	wait(2)
	-- Якщо адмін щось форсував, новий гравець побачить це
	if forcedWeatherType ~= nil then
		applyWeatherEffects(forcedWeatherType)
	else
		local c, isDay = getCurrentWeather()
		applyWeatherEffects(determineWeatherType(c, isDay))
	end
end)

while true do
	if forcedWeatherType == nil then
		-- Працюємо як зазвичай через API
		print("--- Checking API Weather ---")
		local condition, isDay = getCurrentWeather()
		local wType = determineWeatherType(condition, isDay)
		applyWeatherEffects(wType)
	else
		-- Нічого не робимо, бо адмін заморозив погоду
		print("--- Weather overridden by Admin ---")
	end

	if SIMULATION_MODE_ENABLED then wait(10) else wait(600) end
end