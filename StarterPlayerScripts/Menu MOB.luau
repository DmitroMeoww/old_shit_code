task.wait(3)
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

if not UserInputService.TouchEnabled then
	script:Destroy()
	return
end

-------------------------------------------------------------------------
-- ПЕРЕВІРКА ДАТИ ТА ПОВІДОМЛЕННЯ (LEGACY VERSION)
-------------------------------------------------------------------------
local function CheckForLegacyUpdates()
	local currentDate = os.date("*t") -- Отримуємо час клієнта

	-- Перевірка дати: 26 грудня 2025 року
	if currentDate.year == 2025 and currentDate.month == 12 and currentDate.day == 26 then

		local player = Players.LocalPlayer
		if not player then return end
		local playerGui = player:WaitForChild("PlayerGui", 10)
		if not playerGui then return end

		-- Створення GUI повідомлення
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "LegacyUpdateNotification"
		screenGui.IgnoreGuiInset = true
		screenGui.DisplayOrder = 3
		screenGui.Parent = playerGui

		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(0, 400, 0, 80)
		frame.Position = UDim2.new(0.5, 0, 0.15, 0)
		frame.AnchorPoint = Vector2.new(0.5, 0)
		frame.BackgroundColor3 = Color3.fromRGB(255, 85, 85) -- Червоний
		frame.BorderSizePixel = 0
		frame.Parent = screenGui

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = frame

		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 2
		stroke.Color = Color3.fromRGB(255, 255, 255)
		stroke.Parent = frame

		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, -20, 1, -20)
		textLabel.Position = UDim2.new(0, 10, 0, 10)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = "УВАГА! Оновленні правила від 26.12.2025.\nПрочитайте їх ще раз!"
		textLabel.TextColor3 = Color3.new(1, 1, 1)
		textLabel.Font = Enum.Font.GothamBlack
		textLabel.TextSize = 18
		textLabel.TextWrapped = true
		textLabel.Parent = frame

		-- Звук
		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://12221967"
		sound.Parent = frame
		sound:Play()

		-- Видалення через 8 секунд
		task.delay(30, function()
			if screenGui then screenGui:Destroy() end
		end)
	end
end
task.spawn(CheckForLegacyUpdates)
-------------------------------------------------------------------------

local changelogData = {
	" Дніпро має вестибюль",
	" Диспетчер повернутий, і тепер має деяке нове меню (поки що скромно)",
	" Оновленні на 5 вагонкі: Лісова, Чернігівська, Дарниця, Гідропарк.",
	" І БАГАТО, БАГАТО чого іншого. Дізнайтесь самі )",
}


-- ОНОВЛЕНІ ПРАВИЛА (PDF VERSION)
local rulesData = {
	{ type = "blockquote", text = "<b>Пасажир</b> — це особа, яка користується послугами метрополітену для пересування з пункту А до пункту Б." },
	{ type = "blockquote", text = "<b>Машиніст</b> — це працівник метрополітену, відповідальний за безпечне керування потягом і перевезення пасажирів." },

	{ type = "separator" },
	{ type = "subheader", text = "🚶‍♂️ Правила для пасажирів" },

	{ type = "rule", text = "<b>1.1</b> 🚫 Пересування по діючих коліях." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> кік → бан 1 день" },

	{ type = "rule", text = "<b>1.2</b> 🚫 Вхід у кабіну машиніста." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> кік → бан 1–3 дні" },

	{ type = "rule", text = "<b>1.3</b> 🚫 Ігнорування вказівок машиніста, заважання його роботі. (наприклад, залишатись у потязі до депо/тупіка)" },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> бан 1–3 дні" },

	{ type = "rule", text = "<b>1.4</b> 🚫 Керування потягом без ролі «Машиніст»." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> кік → бан 1–3 дні" },

	{ type = "rule", text = "<b>1.5</b> 🚫 Сидіння у задній кабіні без дозволу машиніста." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> кік → бан 3 дні" },

	{ type = "rule", text = "<b>1.6</b> 🚫 Стрибки по вагонах, дах потяга." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> кік → бан 2 дні" },

	{ type = "separator" },
	{ type = "subheader", text = "🚆 Правила для машиністів" },

	{ type = "rule", text = "<b>2.0</b> 🚫 Пускати сторонніх у кабіну." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> кік" },

	{ type = "rule", text = "<b>2.1</b> 🚫 Перевищення швидкості в зонах де дозволено менше. (БЕЗ виключень, навіть якщо в Рухомому Складі немає АЛС.)" },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> кік, потім бан до 14 діб" },

	{ type = "rule", text = "<b>2.2</b> 🚫 Недотримання інтервалу руху. (2 хв стандартно, 1 хв у години пік)" },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> кік → бан 1 день" },

	{ type = "rule", text = "<b>2.3</b> 🚫 Недотримання дистанції (100 м між потягами)." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> кік → бан 1–3 дні" },

	{ type = "rule", text = "<b>2.4</b> 🚫 Намисне таранення потягів." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> бан 3–7 днів" },

	{ type = "rule", text = "<b>2.5</b> 🚫 Перегонка без попередження у чаті." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> кік" },

	{ type = "rule", text = "<b>2.6</b> 🚫 Залишення стрілки у хибному положенні після перегонки." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> бан 1 день" },

	{ type = "rule", text = "<b>2.7</b> 🚫 Безпідставні сигнали." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> кік" },

	{ type = "rule", text = "<b>2.7.1</b> ✅ Обкатка: обов’язково дотримуватись дистанції, їхати ≤30 км/год, подавати сигнал на станціях." },
	{ type = "rule", text = "<b>2.7.2</b> ✅ Машиністи повинні пропускати один одного на кінцевих, уникати заторів, не спавнити багато потягів." },

	{ type = "rule", text = "<b>2.8</b> 🚫 Використання потяга, який створила інша особа." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> кік → бан 3-7 днів." },

	{ type = "rule", text = "<b>2.9</b> 🚫 Рух без інформатора (виняток: обкатка, перегонка, фотопоїзд 81.717)." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> кік" },

	{ type = "rule", text = "<b>2.10</b> 🚫 Ігнорування команд ДСП - Диспетчера." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> кік → бан - 1-3 дні." },

	{ type = "rule", text = "<b>2.11</b> 🚫 Проїзд на червоне світло (без дозволу диспетчера)." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> кік → бан 1–3 дні" },

	{ type = "rule", text = "<b>2.12</b> 🚫 Рух під час повітряної тривоги (ПТ). <font color='#b4b4be'>(Виняток: Дозвіл овнера гри)</font>" },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> кік → бан 2 дні" },

	{ type = "rule", text = "<b>2.13</b> 🚫 Рух зустрічною колією." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> кік → бан 3–7 днів" },

	{ type = "separator" },
	{ type = "subheader", text = "🚨 Загальні правила" },

	{ type = "rule", text = "<b>3.1</b> 🚫 Переводити стрілки перед потягом для сходу з рейок." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> бан 1–7 днів" },

	{ type = "rule", text = "<b>3.2</b> 🚫 Дії, що можуть спричинити схід потяга." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> бан 3–14 днів" },

	{ type = "rule", text = "<b>3.3</b> 🚫 Пересування по колії перед потягом." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> кік → бан 1–3 дні" },

	{ type = "rule", text = "<b>3.4</b> 🚫 Використання чужого пульта управління." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> кік → бан 1–3 дні" },

	{ type = "rule", text = "<b>3.5</b> 🚫 Перевезення пасажирів при обкатці або перегонці." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> кік" },

	{ type = "rule", text = "<b>3.6</b> 🚫 Жебракування («Дай Е-КМ», «Прибулець»)." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> мут → бан 1 день" },

	{ type = "rule", text = "<b>3.6.1</b> 🚫 Образи про сім’ю, батьків, хвороби." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> мут → бан 3–7 днів" },

	{ type = "rule", text = "<b>3.6.2</b> 🚫 Образи про проект та його команду." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> мут → бан 7–14 днів" },

	{ type = "rule", text = "<b>3.6.3</b> 🚫 Осквернення нації, країни, політичні вислови." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> <b>бан назавжди</b>" },

	{ type = "rule", text = "<b>3.7</b> 🚫 Використання репорту без причини." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> бан 1–3 дні" },

	{ type = "rule", text = "<b>3.8</b> 🚫 Видалення чужих потягів (виняток — завада)." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> бан 1–7 днів" },

	{ type = "rule", text = "<b>3.9</b> 🚫 Використання стороннього ПЗ, читів, експлойтів." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> <b>бан назавжди</b>" },

	{ type = "rule", text = "<b>3.9.1</b> 🚫 Зловживання предметами інших ролей (наприклад, кайданки поліції)." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> бан 14–30 днів" },

	{ type = "rule", text = "<b>3.9.2</b> 🚫 Використання багів (якщо знайшли — повідомте в репорт)." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> бан 14–30 днів" },

	{ type = "rule", text = "<b>3.9.3</b> 🚫 Заборонено давати будь-кому любий поїзд, який гравець не має ЕХР (Приклад: Дав Е-КМ другу, котрий має 500 ехр, а Е-КМ коштує 10000. Включно геймпасси)" },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> бан 2–30 днів" },

	{ type = "rule", text = "<b>4.0</b> 🚫 Заборонено введення в оману гравців (наприклад, який інтервал за замовчуванням для поїздів)" },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> м’ют від 15 хвилин, до бану на розгляд модерації/адміністрації" },

	{ type = "rule", text = "<b>4.1</b> 🚫 Заборонено перешкоджати роботі адміністрації та модерації а також уникнення від покарання модерації/адміністрації." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> Залежно від ситуації, на розгляд представника. (Бан виключно до 31д)" },

	{ type = "separator" },
	{ type = "note", text = "📌 <b>Примітка:</b> Правила можуть оновлюватись. Останнє оновлення: 26 грудня 2025 року." },
	{ type = "note", text = "Незнання правил не звільняє від відповідальності.\nСтупінь порушень оцінюється адміністрацією сервера виходячи з ситуації, що сталася." }
}

local function getKyivTime()
	local utcTime = os.time()
	local kyivOffset = 3 * 60 * 60
	return os.date("*t", utcTime + kyivOffset)
end

local halloweenMusicData = { "rbxassetid://127476561892900", "rbxassetid://1838592691" }
local HalloweenTheme = {
	Background = Color3.fromRGB(18, 16, 22),
	PrimaryUI = Color3.fromRGB(42, 35, 58),
	PrimaryUI_Light = Color3.fromRGB(65, 55, 90),
	Accent = Color3.fromRGB(255, 118, 0),
	Accent_Hover = Color3.fromRGB(255, 150, 50),
	TextPrimary = Color3.fromRGB(248, 248, 242),
	TextSecondary = Color3.fromRGB(200, 190, 220),
	Success = Color3.fromRGB(80, 250, 123),
	Warning = Color3.fromRGB(241, 250, 140),
	Error = Color3.fromRGB(255, 85, 85),
	Disabled = Color3.fromRGB(100, 100, 100),
	MetroLine = Color3.fromRGB(118, 45, 238),
	MetroLineHover = Color3.fromRGB(150, 75, 255),
	StationSelected = Color3.fromRGB(255, 118, 0)
}
local newYearMusicData = { "rbxassetid://1846627694", "rbxassetid://9048464297" }
local NewYearTheme = {
	Background = Color3.fromRGB(20, 25, 40),
	PrimaryUI = Color3.fromRGB(35, 45, 70),
	PrimaryUI_Light = Color3.fromRGB(56, 68, 94),
	Accent = Color3.fromRGB(100, 200, 255),
	Accent_Hover = Color3.fromRGB(150, 220, 255),
	TextPrimary = Color3.fromRGB(240, 240, 255),
	TextSecondary = Color3.fromRGB(180, 190, 210),
	Success = Color3.fromRGB(70, 230, 150),
	Warning = Color3.fromRGB(255, 215, 0),
	Error = Color3.fromRGB(255, 100, 100),
	Disabled = Color3.fromRGB(110, 110, 120),
	MetroLine = Color3.fromRGB(255, 215, 0),
	MetroLineHover = Color3.fromRGB(255, 235, 100),
	StationSelected = Color3.fromRGB(100, 200, 255)
}
local defaultMusicData = { "rbxassetid://1841998974" }
local DefaultTheme = {
	Background = Color3.fromRGB(6, 12, 23),
	PrimaryUI = Color3.fromRGB(14, 24, 49),
	PrimaryUI_Light = Color3.fromRGB(30, 48, 91),
	Accent = Color3.fromRGB(68, 214, 196),
	Accent_Hover = Color3.fromRGB(112, 230, 214),
	TextPrimary = Color3.fromRGB(225, 236, 255),
	TextSecondary = Color3.fromRGB(148, 168, 210),
	Success = Color3.fromRGB(88, 255, 197),
	Warning = Color3.fromRGB(255, 201, 92),
	Error = Color3.fromRGB(255, 105, 105),
	Disabled = Color3.fromRGB(85, 98, 130),
	MetroLine = Color3.fromRGB(74, 101, 255),
	MetroLineHover = Color3.fromRGB(120, 137, 255),
	StationSelected = Color3.fromRGB(68, 214, 196)
}
local Theme = DefaultTheme
local musicData = defaultMusicData
local currentTime = getKyivTime()
local day = currentTime.day
local month = currentTime.month
if (month == 10 and day >= 27 and day <= 31) or (month == 11 and day == 3) then
	Theme = HalloweenTheme
	musicData = halloweenMusicData
elseif (month == 12 and day >= 20) or (month == 1 and day <= 10) then
	Theme = NewYearTheme
	musicData = newYearMusicData
end

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")
local BLUR_AMOUNT = 12
local LOAD_FADE_TIME = 0.5
local BOTTOM_BAR_ANIM_TIME = 0.5
local WINDOW_ANIM_TIME = 0.4
local HOLD_KEY_CODE = Enum.KeyCode.M
local HOLD_DURATION = 1.5
local SPAWN_HEIGHT_OFFSET = 5
local CAMERA_PATH_DURATION = 20
local animStyle = Enum.EasingStyle.Quint
local windowOpenAnimInfo = TweenInfo.new(WINDOW_ANIM_TIME, animStyle, Enum.EasingDirection.Out)
local windowCloseAnimInfo = TweenInfo.new(WINDOW_ANIM_TIME, animStyle, Enum.EasingDirection.In)
local tweenInfoEnter = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfoLeave = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local shakeTweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 4, true)
local ruleItemAnimInfo = TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
local changeTeamEvent = ReplicatedStorage:WaitForChild("ChangeTeamG")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local leaderstats = player:WaitForChild("leaderstats")
local expStat = leaderstats:WaitForChild("EXP")
local originalWalkSpeed = nil
local hasStartedPlaying = false
local lastSelectedStationData = nil
local lastSelectedTeamName = nil
local hasShownInitialWindows = false
local rulesAccepted = false
local rulesWindow, rulesContent
local rulesViewWindow, rulesViewContent
local rulesStartTime = 0
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LegacyMenuGui"; screenGui.ResetOnSpawn = false; screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; screenGui.IgnoreGuiInset = true; screenGui.Enabled = true
local isHoldActive = false; local holdStartTime = 0; local menuOpenRequested = false; local activeWindow = nil
local isMenuTransitioning = false; local lastMenuActionTime = 0; local MENU_DEBOUNCE_TIME = 0.5
local blurEffect; local blurTween = nil
local spawnMenuWindow, spawnContent; local creditsWindow, creditsContent; local changelogWindow, changelogContent
local bottomBarFrame = nil
local roleButtons = {}; local selectedRoleButton = nil; local selectedRoleData = nil; local stationCircles = {}; local selectedStationCircle = nil; local selectedStationData = nil; local finalPlayButton = nil
local rolesData = {
	{ Text = "ПАСАЖИР", Color = Color3.fromRGB(80, 250, 123), TeamName = "Passanger" },
	{ Text = "МАШИНІСТ", Color = Color3.fromRGB(77, 141, 255), TeamName = "Machinist", MaxPlayers = 12 },
	{ Text = "ДИСПЕТЧЕР", Color = Color3.fromRGB(255, 175, 75), TeamName = "Диспетчер", MaxPlayers = 1, RequiredEXP = 2000, Unavailable = true },
	{ Text = "ЧПС", Color = Color3.fromRGB(189, 147, 249), TeamName = "ЧПС", MaxPlayers = 1, RequiredEXP = 500 },
	{ Text = "Поліція", Color = Color3.fromRGB(2, 2, 181), TeamName = "Поліція", MaxPlayers = 4, RequiredEXP = 1250, Unavailable = true }
}
local roleButtonElements = {}; local teamPlayerEventListeners = {}
local loadingFrame = Instance.new("Frame"); loadingFrame.Name = "LoadingScreen"; loadingFrame.Size = UDim2.new(1, 0, 1, 0); loadingFrame.BackgroundColor3 = Theme.Background; loadingFrame.BackgroundTransparency = 0; loadingFrame.BorderSizePixel = 0; loadingFrame.ZIndex = 100; loadingFrame.Parent = playerGui
local camera = Workspace.CurrentCamera
local spawnerFolder = Workspace:WaitForChild("Spawners", 20)
blurEffect = Lighting:FindFirstChildOfClass("BlurEffect") or Instance.new("BlurEffect");
blurEffect.Name = "MenuBlur"; blurEffect.Size = 0; blurEffect.Enabled = false; blurEffect.Parent = Lighting;
local menuCamera = {}
menuCamera.IsActive = false; menuCamera.Paths = {}; menuCamera.CurrentTween = nil; menuCamera.Music = nil; menuCamera.FadeFrame = nil; menuCamera.CurrentPathIndex = 0; menuCamera.MusicEndedConnection = nil

function menuCamera:Initialize()
	self.Music = Instance.new("Sound"); self.Music.SoundId = "rbxassetid://1841998974"; self.Music.Looped = false; self.Music.Volume = 0.4; self.Music.Parent = screenGui
	self.FadeFrame = Instance.new("Frame"); self.FadeFrame.Name = "CameraFadeFrame"; self.FadeFrame.Size = UDim2.new(1, 0, 1, 0); self.FadeFrame.BackgroundColor3 = Color3.new(0, 0, 0); self.FadeFrame.BackgroundTransparency = 1; self.FadeFrame.BorderSizePixel = 0; self.FadeFrame.ZIndex = 4; self.FadeFrame.Parent = screenGui
	local pathContainerOriginal = ReplicatedStorage:WaitForChild("CameraPath", 0.1)
	if not pathContainerOriginal then return end
	local pathContainer = pathContainerOriginal:Clone()
	if not screenGui:FindFirstChild("TempCameraPaths") then
		Instance.new("Folder", screenGui).Name = "TempCameraPaths"
	end
	pathContainer.Parent = screenGui.TempCameraPaths
	local pathFolders = {};
	for _, child in ipairs(pathContainer:GetChildren()) do
		if child:IsA("Folder") then table.insert(pathFolders, child) end
	end
	if #pathFolders == 0 then return end
	table.sort(pathFolders, function(a, b) return a.Name:lower() < b.Name:lower() end)
	for _, pathFolder in ipairs(pathFolders) do
		local parts = {};
		for _, part in ipairs(pathFolder:GetChildren()) do
			if part:IsA("BasePart") then table.insert(parts, part) end
		end
		if #parts > 0 then
			table.sort(parts, function(a, b)
				local numA = tonumber(string.match(a.Name, "%d+")) or 0;
				local numB = tonumber(string.match(b.Name, "%d+")) or 0;
				return numA < numB
			end)
			table.insert(self.Paths, parts)
		end
	end
end

function menuCamera:PlayRandomMusic()
	if self.Music and #musicData > 0 then
		if self.Music.IsPlaying then self.Music:Stop() end
		local randomIndex = math.random(1, #musicData)
		local randomSoundId = musicData[randomIndex]
		if self.Music.SoundId == randomSoundId and #musicData > 1 then
			repeat
				randomIndex = math.random(1, #musicData)
				randomSoundId = musicData[randomIndex]
			until self.Music.SoundId ~= randomSoundId
		end
		self.Music.SoundId = randomSoundId
		task.wait()
		if not self.Music.IsLoaded then
			task.spawn(function()
				self.Music.Loaded:Wait()
				if self.IsActive then self.Music:Play() end
			end)
		else
			self.Music:Play()
		end
	end
end

function menuCamera:Stop()
	if not self.IsActive then return end; self.IsActive = false
	if self.CurrentTween then self.CurrentTween:Cancel(); self.CurrentTween = nil end
	if self.Music and self.Music.IsPlaying then
		local musicTween = TweenService:Create(self.Music, TweenInfo.new(0.3), {Volume = 0})
		musicTween.Completed:Connect(function() self.Music:Stop(); self.Music.Volume = 0.4 end); musicTween:Play()
	end
	if self.MusicEndedConnection then
		self.MusicEndedConnection:Disconnect()
		self.MusicEndedConnection = nil
	end
	local tempFolder = screenGui:FindFirstChild("TempCameraPaths")
	if tempFolder then tempFolder:Destroy() end
	camera.CameraType = Enum.CameraType.Custom;
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		camera.CameraSubject = player.Character.Humanoid
	end
end
menuCamera:Initialize()
function menuCamera:Fade(fadeIn)
	local duration = 1; local targetTransparency = fadeIn and 1 or 0
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out); local tween = TweenService:Create(self.FadeFrame, tweenInfo, { BackgroundTransparency = targetTransparency }); tween:Play(); tween.Completed:Wait()
end
function menuCamera:MoveAlongPath(path)
	if not self.IsActive or not path or #path < 2 then return end
	local segments = #path - 1
	local durationPerSegment = (segments > 0) and (CAMERA_PATH_DURATION / segments) or CAMERA_PATH_DURATION
	for i = 1, #path - 1 do
		if not self.IsActive then break end;
		local startPart = path[i];
		local endPart = path[i+1];
		local moveTweenInfo = TweenInfo.new(durationPerSegment, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut);
		self.CurrentTween = TweenService:Create(camera, moveTweenInfo, { CFrame = endPart.CFrame });
		self.CurrentTween:Play();
		self.CurrentTween.Completed:Wait();
		self.CurrentTween = nil;
	end
end
function menuCamera:StartLoop()
	if self.IsActive or #self.Paths == 0 then return end
	self.IsActive = true
	camera.CameraSubject = nil
	camera.CameraType = Enum.CameraType.Scriptable
	RunService.Heartbeat:Wait()
	local randomStartIndex = math.random(1, #self.Paths)
	self.CurrentPathIndex = randomStartIndex
	if self.Paths[randomStartIndex] and #self.Paths[randomStartIndex] > 0 then
		camera.CFrame = self.Paths[randomStartIndex][1].CFrame
	end
	if blurEffect then blurEffect.Enabled = true; blurEffect.Size = BLUR_AMOUNT end
	if self.Music and not self.MusicEndedConnection then
		self.MusicEndedConnection = self.Music.Ended:Connect(function() self:PlayRandomMusic() end)
	end
	self:PlayRandomMusic()
	task.spawn(function()
		self.FadeFrame.BackgroundTransparency = 0
		while self.IsActive do
			local previousPathIndex = self.CurrentPathIndex
			repeat
				self.CurrentPathIndex = math.random(1, #self.Paths)
			until self.CurrentPathIndex ~= previousPathIndex or #self.Paths == 1
			local newPath = self.Paths[self.CurrentPathIndex]
			if #newPath > 0 then camera.CFrame = newPath[1].CFrame end
			self:Fade(true)
			if not self.IsActive then break end
			self:MoveAlongPath(newPath)
			if not self.IsActive then break end
			self:Fade(false)
		end
	end)
end
local holdUI, holdIndicator, holdGradient
function CreateHoldUI()
	holdUI = Instance.new("Frame"); holdUI.Name = "HoldUI"; holdUI.Size = UDim2.fromOffset(100, 100); holdUI.Position = UDim2.fromScale(0.5, 0.5); holdUI.AnchorPoint = Vector2.new(0.5, 0.5); holdUI.BackgroundTransparency = 1; holdUI.ZIndex = 100; holdUI.Visible = false;
	local background = Instance.new("ImageLabel", holdUI); background.Image = "rbxassetid://5920953930"; background.ImageColor3 = Color3.new(0,0,0); background.ImageTransparency = 0.5; background.ScaleType = Enum.ScaleType.Slice; background.SliceCenter = Rect.new(50, 50, 50, 50); background.Size = UDim2.fromScale(1,1); background.BackgroundTransparency = 1;
	local keyLabel = Instance.new("TextLabel", holdUI); keyLabel.Text = "M"; keyLabel.Font = Enum.Font.GothamBold; keyLabel.TextSize = 42; keyLabel.TextColor3 = Color3.new(1,1,1); keyLabel.Size = UDim2.fromScale(1,1); keyLabel.BackgroundTransparency = 1;
	holdIndicator = Instance.new("ImageLabel", holdUI); holdIndicator.Image = "rbxassetid://5920953930"; holdIndicator.ScaleType = Enum.ScaleType.Slice; holdIndicator.SliceCenter = Rect.new(50, 50, 50, 50); holdIndicator.Size = UDim2.new(1,1); holdIndicator.BackgroundTransparency = 1;
	holdGradient = Instance.new("UIGradient", holdUI); holdGradient.Rotation = -90; holdGradient.Transparency = NumberSequence.new(1); holdIndicator.Parent = holdUI; holdUI.Parent = screenGui
end
CreateHoldUI()
local AnimateElementIn, ProceedToNextStep, ShowConfirmationPrompt, HandleRulesAccepted, CreateAndShowRulesWindow, CreateAndShowRulesViewWindow
local SetMenuCamera, RestorePlayerCamera, CloseActiveWindow, OpenWindow, CreateWindow
local OpenMainMenu, CloseMainMenu, UpdateSpawnButtonState, UpdateRoleButtonsVisuals, SelectRole
local CheckHoldDuration, StartHoldCheck, EndHoldCheck

function CreateWindow(name, titleText, width, height)
	local frameWidth = width or 500; local frameHeight = height or 350;
	local windowFrame = Instance.new("Frame"); windowFrame.Name = name; windowFrame.Size = UDim2.new(0, frameWidth, 0, frameHeight); windowFrame.Position = UDim2.new(0.5, 0, 0.5, 0); windowFrame.AnchorPoint = Vector2.new(0.5, 0.5); windowFrame.BackgroundColor3 = Theme.PrimaryUI; windowFrame.BorderSizePixel = 0; windowFrame.Visible = false; windowFrame.ClipsDescendants = true; windowFrame.ZIndex = 10; windowFrame.Parent = screenGui;
	windowFrame:SetAttribute("OriginalSize", windowFrame.Size);
	local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 12); corner.Parent = windowFrame;
	local border = Instance.new("UIStroke"); border.Thickness = 1.5; border.Color = Theme.PrimaryUI_Light; border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; border.Parent = windowFrame;
	local titleBar = Instance.new("Frame"); titleBar.Name = "TitleBar"; titleBar.Size = UDim2.new(1, 0, 0, 45); titleBar.Position = UDim2.new(0, 0, 0, 0); titleBar.BackgroundTransparency = 1; titleBar.Parent = windowFrame;
	local closeButton = Instance.new("TextButton"); closeButton.Name = "CloseButton"; closeButton.Size = UDim2.new(0, 30, 0, 30); closeButton.Position = UDim2.new(1, -15, 0.5, 0); closeButton.AnchorPoint = Vector2.new(1, 0.5); closeButton.BackgroundTransparency = 1; closeButton.Font = Enum.Font.GothamBold; closeButton.Text = "X"; closeButton.TextSize = 20; closeButton.TextColor3 = Theme.TextSecondary; closeButton.ZIndex = titleBar.ZIndex + 1; closeButton.Parent = titleBar;
	closeButton.MouseButton1Click:Connect(function() CloseActiveWindow(true) end);
	closeButton.MouseEnter:Connect(function() TweenService:Create(closeButton, tweenInfoEnter, {TextColor3 = Theme.Error}):Play() end);
	closeButton.MouseLeave:Connect(function() TweenService:Create(closeButton, tweenInfoLeave, {TextColor3 = Theme.TextSecondary}):Play() end);
	local titleSeparator = Instance.new("Frame"); titleSeparator.Name = "TitleSeparator"; titleSeparator.Size = UDim2.new(1, -40, 0, 1); titleSeparator.Position = UDim2.new(0.5, 0, 1, 0); titleSeparator.AnchorPoint = Vector2.new(0.5, 1); titleSeparator.BackgroundColor3 = Theme.PrimaryUI_Light; titleSeparator.BorderSizePixel = 0; titleSeparator.Parent = titleBar;
	local titleLabel = Instance.new("TextLabel"); titleLabel.Name = "Title"; titleLabel.Size = UDim2.new(1, 0, 1, 0); titleLabel.BackgroundTransparency = 1; titleLabel.Font = Enum.Font.GothamBold; titleLabel.Text = titleText or "Window"; titleLabel.TextSize = 22; titleLabel.TextColor3 = Theme.TextPrimary; titleLabel.TextXAlignment = Enum.TextXAlignment.Center; titleLabel.Parent = titleBar;
	local contentFrame = Instance.new("Frame"); contentFrame.Name = "ContentFrame"; contentFrame.Size = UDim2.new(1, -20, 1, -60); contentFrame.Position = UDim2.new(0.5, 0, 0, 50); contentFrame.AnchorPoint = Vector2.new(0.5, 0); contentFrame.BackgroundTransparency = 1; contentFrame.BorderSizePixel = 0; contentFrame.Parent = windowFrame;
	return windowFrame, contentFrame
end
function CloseActiveWindow(forceClose)
	local windowToClose = activeWindow;
	if windowToClose and windowToClose.Visible then
		local originalSize = windowToClose:GetAttribute("OriginalSize");
		if not originalSize then return false end;
		if blurTween then blurTween:Cancel() end;
		blurTween = TweenService:Create(blurEffect, TweenInfo.new(0.3), { Size = 8 });
		blurTween:Play();
		local closeTween = TweenService:Create(windowToClose, windowCloseAnimInfo, {
			Position = UDim2.new(0.5, 0, 0.6, 0),
			Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset * 0.9, originalSize.Y.Scale, originalSize.Y.Offset * 0.9),
			BackgroundTransparency = 1,
		});
		closeTween.Completed:Connect(function()
			if windowToClose and windowToClose.Parent then
				windowToClose.Visible = false;
				windowToClose.Position = UDim2.new(0.5, 0, 0.5, 0);
				if activeWindow == windowToClose then activeWindow = nil end
			end
		end);
		closeTween:Play();
		return true
	end;
	return false
end
function OpenWindow(windowInstance)
	if not windowInstance or windowInstance == activeWindow then return end;
	local closingStarted = CloseActiveWindow(true);
	local originalSize = windowInstance:GetAttribute("OriginalSize");
	blurEffect.Enabled = true;
	if blurTween then blurTween:Cancel() end;
	blurTween = TweenService:Create(blurEffect, TweenInfo.new(0.3), { Size = BLUR_AMOUNT });
	blurTween:Play();
	local function DoOpen()
		windowInstance.Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset * 0.9, originalSize.Y.Scale, originalSize.Y.Offset * 0.9);
		windowInstance.Position = UDim2.new(0.5, 0, 0.4, 0);
		windowInstance.BackgroundTransparency = 1;
		windowInstance.Visible = true;
		activeWindow = windowInstance;
		TweenService:Create(windowInstance, windowOpenAnimInfo, { Position = UDim2.new(0.5, 0, 0.5, 0), Size = originalSize, BackgroundTransparency = 0 }):Play()
	end;
	if closingStarted then task.wait(WINDOW_ANIM_TIME * 0.5) end;
	DoOpen()
end
function SetMenuCamera()
	if #menuCamera.Paths > 0 then menuCamera:StartLoop()
	else
		blurEffect.Enabled = true;
		if blurTween then blurTween:Cancel() end;
		blurTween = TweenService:Create(blurEffect, TweenInfo.new(0.5), { Size = BLUR_AMOUNT });
		blurTween:Play()
	end
end
function RestorePlayerCamera()
	menuCamera:Stop();
	if blurTween then blurTween:Cancel() end;
	local outTween = TweenService:Create(blurEffect, TweenInfo.new(0.5), { Size = 0 });
	outTween.Completed:Connect(function() if blurEffect then blurEffect.Enabled = false end end);
	outTween:Play()
end
function ProceedToNextStep()
	rulesAccepted = true
	OpenMainMenu()
	OpenWindow(changelogWindow)
	task.delay(WINDOW_ANIM_TIME, function()
		if rulesWindow and rulesWindow.Parent then
			rulesWindow:Destroy()
			rulesWindow = nil
		end
	end)
end
function OpenMainMenu()
	local currentTime = os.clock()
	if isMenuTransitioning or (currentTime - lastMenuActionTime) < MENU_DEBOUNCE_TIME then return end
	isMenuTransitioning = true
	lastMenuActionTime = currentTime
	local character = player.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid and originalWalkSpeed == nil then
			originalWalkSpeed = humanoid.WalkSpeed
			humanoid.WalkSpeed = 0
		end
	end
	screenGui.Enabled = true
	menuOpenRequested = false
	if bottomBarFrame then
		bottomBarFrame.Visible = true
		local closeBtn = bottomBarFrame:FindFirstChild("CloseMainMenuButton")
		if closeBtn then closeBtn.Visible = hasStartedPlaying end
	end
	if selectedRoleData then SelectRole(nil, nil) end
	if selectedStationCircle then
		local prevContainer = selectedStationCircle.Parent;
		local prevIcon = prevContainer:FindFirstChild("StationIcon");
		local prevLabel = prevContainer:FindFirstChild("StationLabel");
		local prevGlow = prevContainer:FindFirstChild("SelectionGlow");
		local prevCheck = prevContainer:FindFirstChild("CheckIcon");
		if prevIcon then TweenService:Create(prevIcon, tweenInfoLeave, { BackgroundColor3 = prevIcon:GetAttribute("OriginalColor"), Size = UDim2.new(0, 24, 0, 24) }):Play() end
		if prevLabel then TweenService:Create(prevLabel, tweenInfoLeave, { TextColor3 = prevLabel:GetAttribute("OriginalColor"), TextSize = 12 }):Play() end
		if prevGlow then prevGlow.Visible = false end
		if prevCheck then prevCheck.Visible = false end
		selectedStationCircle, selectedStationData = nil, nil
	end
	CloseActiveWindow(true)
	activeWindow = nil
	UpdateSpawnButtonState()
	if not menuCamera.IsActive then SetMenuCamera() end
	if bottomBarFrame then
		bottomBarFrame.Position = UDim2.new(0.5, 0, 1.1, 0)
		TweenService:Create(bottomBarFrame, TweenInfo.new(BOTTOM_BAR_ANIM_TIME, animStyle, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, 0, 1, -15) }):Play()
	end
	task.delay(BOTTOM_BAR_ANIM_TIME + 0.1, function()
		isMenuTransitioning = false
	end)
end
function AnimateElementIn(element, delay)
	task.delay(delay, function()
		if not element or not element.Parent then return end;
		if element:IsA("GuiObject") then
			element.Visible = false;
			local originalPos;
			if element:IsA("TextLabel") or element:IsA("TextButton") then
				element.TextTransparency = 1;
				originalPos = element.Position;
				element.Position = originalPos + UDim2.fromOffset(0, 15)
			end;
			element.Visible = true;
			if element:IsA("TextLabel") or element:IsA("TextButton") then
				TweenService:Create(element, ruleItemAnimInfo, { Position = originalPos, TextTransparency = 0 }):Play()
			end
		end
	end)
end
function ShowConfirmationPrompt()
	local promptOverlay = Instance.new("Frame"); promptOverlay.Name = "ConfirmationOverlay"; promptOverlay.Size = UDim2.fromScale(1, 1); promptOverlay.BackgroundColor3 = Color3.new(0, 0, 0); promptOverlay.BackgroundTransparency = 1; promptOverlay.ZIndex = rulesWindow.ZIndex + 5; promptOverlay.Parent = rulesWindow;
	TweenService:Create(promptOverlay, TweenInfo.new(0.3), {BackgroundTransparency = 0.8}):Play();
	local promptFrame = Instance.new("Frame"); promptFrame.Name = "ConfirmationPrompt"; promptFrame.Size = UDim2.new(0, 420, 0, 190); promptFrame.Position = UDim2.fromScale(0.5, 0.5); promptFrame.AnchorPoint = Vector2.new(0.5, 0.5); promptFrame.BackgroundColor3 = Theme.PrimaryUI; promptFrame.BorderSizePixel = 0; Instance.new("UICorner", promptFrame).CornerRadius = UDim.new(0, 12); Instance.new("UIStroke", promptFrame).Color = Theme.PrimaryUI_Light; promptFrame.Parent = promptOverlay;
	local message = Instance.new("TextLabel"); message.Size = UDim2.new(1, -40, 0, 80); message.Position = UDim2.new(0.5, 0, 0.15, 0); message.AnchorPoint = Vector2.new(0.5, 0); message.BackgroundTransparency = 1; message.Font = Enum.Font.Gotham; message.TextSize = 18; message.TextColor3 = Theme.TextPrimary; message.TextWrapped = true; message.RichText = true; message.Text = "<b>Ви впевнені, що прочитали правила?</b><br/><br/><font color='#b4b4be'>Пам'ятайте, незнання правил не звільняє від відповідальності.</font>"; message.Parent = promptFrame;
	local buttonContainer = Instance.new("Frame"); buttonContainer.Size = UDim2.new(1, -40, 0, 50); buttonContainer.Position = UDim2.new(0.5, 0, 0.95, 0); buttonContainer.AnchorPoint = Vector2.new(0.5, 1); buttonContainer.BackgroundTransparency = 1; local listLayout = Instance.new("UIListLayout", buttonContainer); listLayout.FillDirection = Enum.FillDirection.Horizontal; listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; listLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom; listLayout.Padding = UDim.new(0, 15); buttonContainer.Parent = promptFrame;
	local yesButton = Instance.new("TextButton"); yesButton.Name = "YesButton"; yesButton.Size = UDim2.new(0.45, 0, 0.8, 0); yesButton.BackgroundColor3 = Theme.Success; yesButton.Font = Enum.Font.GothamBold; yesButton.Text = "Так, я прочитав"; yesButton.TextSize = 16; yesButton.TextColor3 = Theme.Background; Instance.new("UICorner", yesButton).CornerRadius = UDim.new(0, 8); yesButton.Parent = buttonContainer;
	local noButton = Instance.new("TextButton"); noButton.Name = "NoButton"; noButton.Size = UDim2.new(0.45, 0, 0.8, 0); noButton.BackgroundColor3 = Theme.Error; noButton.Font = Enum.Font.GothamBold; noButton.Text = "Ні, ні! Поверніть мене!"; noButton.TextSize = 16; noButton.TextColor3 = Theme.Background; Instance.new("UICorner", noButton).CornerRadius = UDim.new(0, 8); noButton.Parent = buttonContainer;
	yesButton.MouseButton1Click:Connect(function() ProceedToNextStep() end);
	noButton.MouseButton1Click:Connect(function()
		local tween = TweenService:Create(promptOverlay, TweenInfo.new(0.3), {BackgroundTransparency = 1});
		tween.Completed:Connect(function() promptOverlay:Destroy() end);
		tween:Play();
		rulesStartTime = os.clock()
	end)
end
function HandleRulesAccepted()
	if os.clock() - rulesStartTime < 5.0 then ShowConfirmationPrompt() else ProceedToNextStep() end
end

local function populateRulesContent(contentFrame, isInitialWindow)
	local scrollingFrame = Instance.new("ScrollingFrame"); scrollingFrame.Size = UDim2.new(1, 0, 1, isInitialWindow and -65 or 0); scrollingFrame.Position = UDim2.new(0.5, 0, 0, 0); scrollingFrame.AnchorPoint = Vector2.new(0.5, 0); scrollingFrame.BackgroundTransparency = 1; scrollingFrame.BorderSizePixel = 0; scrollingFrame.CanvasSize = UDim2.new(); scrollingFrame.ScrollBarThickness = 6; scrollingFrame.ScrollBarImageColor3 = Theme.PrimaryUI_Light; scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y; scrollingFrame.Parent = contentFrame;
	local listLayout = Instance.new("UIListLayout", scrollingFrame); listLayout.Padding = UDim.new(0, 5); listLayout.HorizontalAlignment = UserInputService.TouchEnabled and Enum.HorizontalAlignment.Center or Enum.HorizontalAlignment.Left; listLayout.FillDirection = Enum.FillDirection.Vertical;
	local padding = Instance.new("UIPadding", scrollingFrame); padding.PaddingTop = UDim.new(0, 0); padding.PaddingLeft = UDim.new(0, 15); padding.PaddingRight = UDim.new(0, 15); padding.PaddingBottom = UDim.new(0, 15);
	local function createTextElement(params)
		local label = Instance.new("TextLabel"); label.BackgroundTransparency = 1; label.TextWrapped = true; label.RichText = true; label.AutomaticSize = Enum.AutomaticSize.Y; label.TextXAlignment = Enum.TextXAlignment.Left; label.Size = UDim2.new(1, -10, 0, 0);
		for prop, value in pairs(params) do label[prop] = value end;
		label.Parent = scrollingFrame;
		return label;
	end;
	task.spawn(function()
		local animationDelay = isInitialWindow and 0.0 or 0.1;
		for _, ruleItem in ipairs(rulesData) do
			local element;
			if ruleItem.type == "blockquote" then element = createTextElement({Text = "“"..ruleItem.text.."”", Font = Enum.Font.SourceSansItalic, TextColor3 = Theme.TextSecondary, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Center})
			elseif ruleItem.type == "subheader" then element = createTextElement({Text = ruleItem.text, Font = Enum.Font.GothamBold, TextColor3 = Theme.TextPrimary, TextSize = 24})
			elseif ruleItem.type == "rule" then element = createTextElement({Text = "  " .. ruleItem.text, Font = Enum.Font.Gotham, TextColor3 = Theme.TextSecondary, TextSize = 18})
			elseif ruleItem.type == "punishment" then element = createTextElement({Text = "<font color='#" .. Theme.Error:ToHex() .. "'>  " .. ruleItem.text .. "</font>", Font = Enum.Font.Gotham, TextColor3 = Theme.TextSecondary, TextSize = 17})
			elseif ruleItem.type == "note" then element = createTextElement({Text = ruleItem.text, Font = Enum.Font.Gotham, TextColor3 = Theme.TextSecondary, TextSize = 17})
			elseif ruleItem.type == "separator" then local separator = Instance.new("Frame", scrollingFrame); separator.Size = UDim2.new(1, 0, 0, 25); separator.BackgroundTransparency = 1; element = separator; end;
			if element and isInitialWindow then AnimateElementIn(element, animationDelay); animationDelay = animationDelay + 0.04 end
			task.wait()
		end;
		if isInitialWindow then
			local acceptButton = Instance.new("TextButton"); acceptButton.Name = "AcceptRulesButton"; acceptButton.Text = "Я ОЗНАЙОМИВСЯ ТА ПОГОДЖУЮСЬ З ПРАВИЛАМИ"; acceptButton.Font = Enum.Font.GothamBold; acceptButton.TextSize = 16; acceptButton.TextColor3 = Theme.Background; acceptButton.BackgroundColor3 = Theme.Success; acceptButton.Size = UDim2.new(0.9, 0, 0, 50); Instance.new("UICorner", acceptButton).CornerRadius = UDim.new(0, 8); acceptButton.Position = UDim2.new(0.5, 0, 1, -10); acceptButton.AnchorPoint = Vector2.new(0.5, 1); acceptButton.Parent = contentFrame;
			acceptButton.MouseEnter:Connect(function() acceptButton.BackgroundColor3 = Color3.fromHex("61D981") end);
			acceptButton.MouseLeave:Connect(function() acceptButton.BackgroundColor3 = Theme.Success end);
			acceptButton.MouseButton1Click:Connect(HandleRulesAccepted);
			AnimateElementIn(acceptButton, animationDelay)
		end
	end)
end

function CreateAndShowRulesWindow()
	if hasShownInitialWindows then return end;
	hasShownInitialWindows = true;
	screenGui.Enabled = true;
	rulesWindow, rulesContent = CreateWindow("RulesWindow", "M1 - ПРАВИЛА ГРИ", 700, 500);
	if UserInputService.TouchEnabled then rulesWindow.Size = UDim2.new(0.95, 0, 0.85, 0); rulesWindow:SetAttribute("OriginalSize", rulesWindow.Size) end
	if rulesWindow:FindFirstChild("TitleBar") then
		local titleLabel = rulesWindow.TitleBar:FindFirstChild("Title");
		if titleLabel then titleLabel.TextSize = 24 end;
		local closeButton = rulesWindow.TitleBar:FindFirstChild("CloseButton");
		if closeButton then closeButton.Visible = false end
	end;
	populateRulesContent(rulesContent, true);
	SetMenuCamera();
	local character = player.Character;
	if character and character:FindFirstChildOfClass("Humanoid") then
		if originalWalkSpeed == nil then originalWalkSpeed = character.Humanoid.WalkSpeed end
		character.Humanoid.WalkSpeed = 0
	end;
	if blurTween then blurTween:Cancel() end;
	blurEffect.Enabled = true;
	blurTween = TweenService:Create(blurEffect, TweenInfo.new(0.3), {Size = BLUR_AMOUNT});
	blurTween:Play();
	OpenWindow(rulesWindow);
	rulesStartTime = os.clock()
end

function CreateAndShowRulesViewWindow()
	if rulesViewWindow and rulesViewWindow.Parent then OpenWindow(rulesViewWindow); return end
	rulesViewWindow, rulesViewContent = CreateWindow("RulesViewWindow", "M1 - ПРАВИЛА ГРИ", 700, 500);
	rulesViewContent.Size = UDim2.new(1, -20, 1, -20);
	rulesViewContent.Position = UDim2.new(0.5, 0, 0.5, 0);
	rulesViewContent.AnchorPoint = Vector2.new(0.5, 0.5);
	if UserInputService.TouchEnabled then rulesViewWindow.Size = UDim2.new(0.95, 0, 0.85, 0); rulesViewWindow:SetAttribute("OriginalSize", rulesViewWindow.Size) end
	populateRulesContent(rulesViewContent, false);
	OpenWindow(rulesViewWindow);
end

bottomBarFrame = Instance.new("Frame"); bottomBarFrame.Name = "BottomBar"; bottomBarFrame.Size = UDim2.new(0.5, 0, 0, 70); bottomBarFrame.Position = UDim2.new(0.5, 0, 1, -15); bottomBarFrame.AnchorPoint = Vector2.new(0.5, 1); bottomBarFrame.BackgroundColor3 = Theme.Background; bottomBarFrame.BorderSizePixel = 0; bottomBarFrame.ZIndex = 5; bottomBarFrame.Visible = false; bottomBarFrame.Parent = screenGui;
local barCorner = Instance.new("UICorner", bottomBarFrame); barCorner.CornerRadius = UDim.new(0, 12);
local barStroke = Instance.new("UIStroke", bottomBarFrame); barStroke.Color = Theme.PrimaryUI_Light; barStroke.Thickness = 2;
local sizeConstraint = Instance.new("UISizeConstraint", bottomBarFrame); sizeConstraint.MinSize = Vector2.new(600, 70); sizeConstraint.MaxSize = Vector2.new(800, 70);
local logoImage = Instance.new("ImageLabel"); logoImage.Name = "LogoUTS"; logoImage.Image = "rbxassetid://117741805646185"; logoImage.ImageColor3 = Theme.TextSecondary; logoImage.BackgroundTransparency = 1; logoImage.Size = UDim2.new(0, 30, 0, 30); logoImage.Position = UDim2.new(0, 20, 0.5, 0); logoImage.AnchorPoint = Vector2.new(0, 0.5); logoImage.ScaleType = Enum.ScaleType.Fit; logoImage.Parent = bottomBarFrame;
local buttonContainer = Instance.new("Frame"); buttonContainer.Name = "ButtonContainer"; buttonContainer.Size = UDim2.new(1, -150, 1, 0); buttonContainer.Position = UDim2.new(0.5, 0, 0.5, 0); buttonContainer.AnchorPoint = Vector2.new(0.5, 0.5); buttonContainer.BackgroundTransparency = 1; buttonContainer.Parent = bottomBarFrame;
local listLayout = Instance.new("UIListLayout"); listLayout.Padding = UDim.new(0, 15); listLayout.SortOrder = Enum.SortOrder.LayoutOrder; listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; listLayout.VerticalAlignment = Enum.VerticalAlignment.Center; listLayout.FillDirection = Enum.FillDirection.Horizontal; listLayout.Parent = buttonContainer;
local closeMainMenuButton = Instance.new("TextButton"); closeMainMenuButton.Name = "CloseMainMenuButton"; closeMainMenuButton.Size = UDim2.new(0, 30, 0, 30); closeMainMenuButton.Position = UDim2.new(1, -20, 0.5, 0); closeMainMenuButton.AnchorPoint = Vector2.new(1, 0.5); closeMainMenuButton.BackgroundTransparency = 1; closeMainMenuButton.Font = Enum.Font.GothamBold; closeMainMenuButton.Text = "X"; closeMainMenuButton.TextSize = 22; closeMainMenuButton.TextColor3 = Theme.TextSecondary; closeMainMenuButton.ZIndex = bottomBarFrame.ZIndex + 1; closeMainMenuButton.Parent = bottomBarFrame;

spawnMenuWindow, spawnContent = CreateWindow("SpawnMenuWindow", "", 750, 480);
creditsWindow, creditsContent = CreateWindow("CreditsWindow", "ПОДЯКИ", 500, 400);
changelogWindow, changelogContent = CreateWindow("ChangelogWindow", "ЩО НОВОГО", 600, 400);

if UserInputService.TouchEnabled then
	local function scaleWindow(window, aspect)
		window.Size = UDim2.new(0.95, 0, 0.8, 0)
		if not window:FindFirstChildOfClass("UIAspectRatioConstraint") then
			local aspectRatio = Instance.new("UIAspectRatioConstraint"); aspectRatio.AspectRatio = aspect; aspectRatio.Parent = window
		end
		window:SetAttribute("OriginalSize", window.Size)
	end
	scaleWindow(spawnMenuWindow, 750 / 480)
	scaleWindow(creditsWindow, 500 / 400)
	scaleWindow(changelogWindow, 600 / 400)
end
closeMainMenuButton.MouseButton1Click:Connect(function() if hasStartedPlaying then CloseMainMenu() end end)

do
	local scrollFrame = Instance.new("ScrollingFrame"); scrollFrame.Name = "ScrollContent"; scrollFrame.Size = UDim2.fromScale(1, 1); scrollFrame.BackgroundTransparency = 1; scrollFrame.BorderSizePixel = 0; scrollFrame.ScrollBarThickness = 6; scrollFrame.ScrollBarImageColor3 = Theme.PrimaryUI_Light; scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y; scrollFrame.Parent = changelogContent;
	local listLayout = Instance.new("UIListLayout", scrollFrame); listLayout.Padding = UDim.new(0, 10); listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; listLayout.SortOrder = Enum.SortOrder.LayoutOrder;
	local padding = Instance.new("UIPadding", scrollFrame); padding.PaddingTop = UDim.new(0, 15); padding.PaddingLeft = UDim.new(0, 15); padding.PaddingRight = UDim.new(0, 15);
	for _, text in ipairs(changelogData) do
		local entry = Instance.new("TextLabel"); entry.Name = "ChangelogEntry"; entry.Size = UDim2.new(1, -10, 0, 0); entry.BackgroundTransparency = 1; entry.Font = Enum.Font.Gotham; entry.TextSize = 16; entry.TextColor3 = Theme.TextSecondary; entry.Text = text; entry.TextWrapped = true; entry.TextXAlignment = Enum.TextXAlignment.Left; entry.AutomaticSize = Enum.AutomaticSize.Y; entry.Parent = scrollFrame
	end
end
do
	local scrollFrame = Instance.new("ScrollingFrame"); scrollFrame.Name = "ScrollContent"; scrollFrame.Size = UDim2.fromScale(1, 1); scrollFrame.BackgroundTransparency = 1; scrollFrame.BorderSizePixel = 0; scrollFrame.ScrollBarThickness = 6; scrollFrame.ScrollBarImageColor3 = Theme.PrimaryUI_Light; scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y; scrollFrame.Parent = creditsContent;
	local creditsListLayout = Instance.new("UIListLayout", scrollFrame); creditsListLayout.Padding = UDim.new(0, 10); creditsListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; creditsListLayout.SortOrder = Enum.SortOrder.LayoutOrder;
	local creditsPadding = Instance.new("UIPadding", scrollFrame); creditsPadding.PaddingTop = UDim.new(0, 15); creditsPadding.PaddingLeft = UDim.new(0, 15); creditsPadding.PaddingRight = UDim.new(0, 15);
	local function createHeader(text, order)
		local header = Instance.new("TextLabel"); header.Name = "Header"; header.LayoutOrder = order; header.Size = UDim2.new(1, 0, 0, 30); header.BackgroundTransparency = 1; header.Font = Enum.Font.GothamBold; header.TextSize = 20; header.TextColor3 = Theme.TextPrimary; header.Text = text; header.TextXAlignment = Enum.TextXAlignment.Left; header.Parent = scrollFrame; return header
	end;
	local function createCreditEntry(text, order)
		local entry = Instance.new("TextLabel"); entry.Name = "CreditEntry"; entry.LayoutOrder = order; entry.Size = UDim2.new(1, -10, 0, 0); entry.BackgroundTransparency = 1; entry.Font = Enum.Font.Gotham; entry.TextSize = 16; entry.TextColor3 = Theme.TextSecondary; entry.RichText = true; entry.Text = "  •  " .. text; entry.TextWrapped = true; entry.TextXAlignment = Enum.TextXAlignment.Left; entry.AutomaticSize = Enum.AutomaticSize.Y; entry.Parent = scrollFrame; return entry
	end;
	local function createSeparator(order)
		local separator = Instance.new("Frame"); separator.Size = UDim2.new(1,0,0,15); separator.BackgroundTransparency = 1; separator.LayoutOrder = order; separator.Parent = scrollFrame; return separator
	end;
	createSeparator(3); createHeader("ГОЛОВНА КОМАНДА РОЗРОБНИКІВ", 4); createCreditEntry("<b>LeoVerem12</b> - Овнер проєкту", 5); createCreditEntry("<b>Ezh_3y</b> - Розробник", 6); createCreditEntry("<b>DEN50678</b> - Розробник", 7);
	createSeparator(9); createHeader("ВИКОРИСТАНІ РЕСУРСИ", 10); createCreditEntry("<b>Kyiv Metrostroi Team</b> - моделі потягів (Ем-502, 81-540.2к)", 11); createCreditEntry("<b>ZefirLover</b> - Переніс табличкі", 12); createCreditEntry("<b>Mint Type</b> - шрифт Proba Nav2", 13); createCreditEntry("<b>Агенти Змін</b> - Навігація (викладіть орігінали будь ласочка)", 14); createCreditEntry("<b>Metrostroi Team</b> - Використані рельси, звуки та ще деякі речі", 15);
	if (month == 10 and day == 28) or (month == 11 and day == 3) then
		createCreditEntry("<b>time - feel so sleep</b> - Хелловінська пісня", 16)	
	end
end
do
	local titleBarSpawn = spawnMenuWindow:FindFirstChild("TitleBar"); if titleBarSpawn then titleBarSpawn.Visible = false end;
	local spawnCloseButton = Instance.new("TextButton"); spawnCloseButton.Name = "SpawnCloseButton"; spawnCloseButton.Size = UDim2.new(0, 35, 0, 35); spawnCloseButton.Position = UDim2.new(1, -15, 0, 15); spawnCloseButton.AnchorPoint = Vector2.new(1, 0); spawnCloseButton.BackgroundTransparency = 1; spawnCloseButton.Font = Enum.Font.GothamBold; spawnCloseButton.Text = "X"; spawnCloseButton.TextSize = 22; spawnCloseButton.TextColor3 = Theme.TextSecondary; spawnCloseButton.ZIndex = spawnMenuWindow.ZIndex + 5; spawnCloseButton.Parent = spawnMenuWindow;
	spawnCloseButton.MouseButton1Click:Connect(function() CloseActiveWindow(true) end);
	spawnCloseButton.MouseEnter:Connect(function() TweenService:Create(spawnCloseButton, tweenInfoEnter, {TextColor3 = Theme.Error}):Play() end);
	spawnCloseButton.MouseLeave:Connect(function() TweenService:Create(spawnCloseButton, tweenInfoLeave, {TextColor3 = Theme.TextSecondary}):Play() end);
	local contentFrameSpawn = spawnMenuWindow:FindFirstChild("ContentFrame"); if contentFrameSpawn then contentFrameSpawn.Position = UDim2.new(0.5, 0, 0.5, 0); contentFrameSpawn.Size = UDim2.new(1, -20, 1, -20); contentFrameSpawn.AnchorPoint = Vector2.new(0.5, 0.5) end;
	local spawnMainTitle = Instance.new("TextLabel", spawnContent); spawnMainTitle.Name = "SpawnMainTitle"; spawnMainTitle.Text = "ВИБІР РОЛІ ТА МІСЦЯ"; spawnMainTitle.Font = Enum.Font.GothamBold; spawnMainTitle.TextSize = 26; spawnMainTitle.TextColor3 = Theme.TextPrimary; spawnMainTitle.BackgroundTransparency = 1; spawnMainTitle.Size = UDim2.new(1, 0, 0.1, 0); spawnMainTitle.Position = UDim2.new(0.5, 0, 0.05, 0); spawnMainTitle.AnchorPoint = Vector2.new(0.5, 0);
	local rolesFrame = Instance.new("Frame", spawnContent); rolesFrame.Name = "RolesFrame"; rolesFrame.Size = UDim2.new(1, 0, 0.2, 0); rolesFrame.Position = UDim2.new(0.5, 0, 0.18, 0); rolesFrame.AnchorPoint = Vector2.new(0.5, 0); rolesFrame.BackgroundTransparency = 1;
	local rolesLayout = Instance.new("UIListLayout", rolesFrame); rolesLayout.FillDirection = Enum.FillDirection.Horizontal; rolesLayout.VerticalAlignment = Enum.VerticalAlignment.Center; rolesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center; rolesLayout.Padding = UDim.new(0, 15);
	local separator1 = Instance.new("Frame", spawnContent); separator1.Name = "Separator1"; separator1.Size = UDim2.new(0.9, 0, 0, 2); separator1.Position = UDim2.new(0.5, 0, 0.42, 0); separator1.AnchorPoint = Vector2.new(0.5, 0.5); separator1.BackgroundColor3 = Theme.PrimaryUI_Light;
	local stationsFrame = Instance.new("Frame", spawnContent); stationsFrame.Name = "StationsFrame"; stationsFrame.Size = UDim2.new(0.95, 0, 0.4, 0); stationsFrame.Position = UDim2.new(0.5, 0, 0.45, 0); stationsFrame.AnchorPoint = Vector2.new(0.5, 0); stationsFrame.BackgroundTransparency = 1;
	local stationsTitle = Instance.new("TextLabel", stationsFrame); stationsTitle.Name = "StationsTitle"; stationsTitle.Text = "ОБЕРІТЬ СТАНЦІЮ"; stationsTitle.Font = Enum.Font.GothamBold; stationsTitle.TextSize = 18; stationsTitle.TextColor3 = Theme.TextPrimary; stationsTitle.BackgroundTransparency = 1; stationsTitle.Size = UDim2.new(1, 0, 0, 25); stationsTitle.Position = UDim2.new(0.5, 0, 0, 0); stationsTitle.AnchorPoint = Vector2.new(0.5, 0); stationsTitle.TextXAlignment = Enum.TextXAlignment.Center;
	local metroContainer = Instance.new("Frame", stationsFrame); metroContainer.Name = "MetroContainer"; metroContainer.Size = UDim2.new(1, 0, 1, -35); metroContainer.Position = UDim2.new(0.5, 0, 0, 35); metroContainer.AnchorPoint = Vector2.new(0.5, 0); metroContainer.BackgroundTransparency = 1;
	local stationLine = Instance.new("Frame", metroContainer); stationLine.Name = "MetroLine"; stationLine.Size = UDim2.new(0.9, 0, 0, 6); stationLine.Position = UDim2.new(0.5, 0, 0.4, 0); stationLine.AnchorPoint = Vector2.new(0.5, 0.5); stationLine.BackgroundColor3 = Theme.MetroLine; stationLine.BorderSizePixel = 0; Instance.new("UICorner", stationLine).CornerRadius = UDim.new(0, 3);
	local lineGradient = Instance.new("UIGradient", stationLine); lineGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Theme.MetroLine), ColorSequenceKeypoint.new(0.5, Theme.MetroLineHover), ColorSequenceKeypoint.new(1, Theme.MetroLine)};
	local lineShadow = Instance.new("Frame", metroContainer); lineShadow.Name = "LineShadow"; lineShadow.Size = UDim2.new(0.9, 0, 0, 6); lineShadow.Position = UDim2.new(0.5, 2, 0.4, 2); lineShadow.AnchorPoint = Vector2.new(0.5, 0.5); lineShadow.BackgroundColor3 = Color3.new(0, 0, 0); lineShadow.BackgroundTransparency = 0.8; lineShadow.BorderSizePixel = 0; lineShadow.ZIndex = stationLine.ZIndex - 1; Instance.new("UICorner", lineShadow).CornerRadius = UDim.new(0, 3);
	local stationsData = {
		{ Name = "ТУПІК", Pos = 0.08, SpawnerName = "TupikLisova", RequiredRole = "МАШИНІСТ", IsTerminal = true }, 
		{ Name = "ЛІСОВА", Pos = 0.22, SpawnerName = "Lisova", RequiredRole = nil, IsDspStation = true },
		{ Name = "ЧЕРНІГІВСЬКА", Pos = 0.36, SpawnerName = "Chernigivska", RequiredRole = nil}, 
		{ Name = "ДАРНИЦЯ", Pos = 0.50, SpawnerName = "Darnytsia", RequiredRole = nil }, 
		{ Name = "ЛІВОБЕРЕЖНА", Pos = 0.64, SpawnerName = "Livoberz", RequiredRole = nil },
		{ Name = "ГІДРОПАРК", Pos = 0.78, SpawnerName = "Gidropark", RequiredRole = nil },
		{ Name = "ДНІПРО", Pos = 0.92, SpawnerName = "Dnipro", RequiredRole = nil }, 
		{ Name = "ТУПІК", Pos = 1.06, SpawnerName = "TupikDnipro", RequiredRole = "МАШИНІСТ", IsTerminal = true }
	};
	local stationGuiElements = {}; local defaultStationColor = Theme.TextSecondary; local selectedStationColor = Theme.StationSelected; local requiredRoleColor = Theme.Warning; local occupiedColor = Theme.Error; local terminalColor = Theme.Accent;
	local function SelectStation(stationButton, stationData)
		if selectedStationCircle then
			local prevContainer = selectedStationCircle.Parent; local prevIcon = prevContainer:FindFirstChild("StationIcon"); local prevLabel = prevContainer:FindFirstChild("StationLabel"); local prevGlow = prevContainer:FindFirstChild("SelectionGlow"); local prevCheck = prevContainer:FindFirstChild("CheckIcon");
			TweenService:Create(prevIcon, tweenInfoLeave, { BackgroundColor3 = prevIcon:GetAttribute("OriginalColor"), Size = UDim2.new(0, 24, 0, 24) }):Play();
			TweenService:Create(prevLabel, tweenInfoLeave, { TextColor3 = prevLabel:GetAttribute("OriginalColor"), TextSize = 12 }):Play();
			if prevGlow then prevGlow.Visible = false end; if prevCheck then prevCheck.Visible = false end;
		end;
		selectedStationCircle = stationButton; selectedStationData = stationData;
		local container = stationButton.Parent; local icon = container:FindFirstChild("StationIcon"); local label = container:FindFirstChild("StationLabel"); local glow = container:FindFirstChild("SelectionGlow"); local check = container:FindFirstChild("CheckIcon");
		TweenService:Create(icon, tweenInfoEnter, { BackgroundColor3 = selectedStationColor, Size = UDim2.new(0, 28, 0, 28) }):Play();
		TweenService:Create(label, tweenInfoEnter, { TextColor3 = selectedStationColor, TextSize = 14 }):Play();
		if glow then glow.Visible = true end;
		if check then check.Visible = true; check.TextColor3 = selectedStationColor; end
		UpdateSpawnButtonState();
	end;
	for i, data in ipairs(stationsData) do
		local stationContainer = Instance.new("Frame", metroContainer); stationContainer.Name = data.Name:gsub("[%s%.%\n']+", "") .. "Container"; stationContainer.Size = UDim2.new(0, 80, 1, 0); stationContainer.Position = UDim2.new(data.Pos * 0.9 / 1.06, -40, 0, 0); stationContainer.BackgroundTransparency = 1;
		local selectionGlow = Instance.new("Frame", stationContainer); selectionGlow.Name = "SelectionGlow"; selectionGlow.Size = UDim2.new(0, 40, 0, 40); selectionGlow.Position = UDim2.new(0.5, 0, 0.4, 0); selectionGlow.AnchorPoint = Vector2.new(0.5, 0.5); selectionGlow.BackgroundColor3 = selectedStationColor; selectionGlow.BackgroundTransparency = 0.7; selectionGlow.BorderSizePixel = 0; selectionGlow.Visible = false; selectionGlow.ZIndex = 1; Instance.new("UICorner", selectionGlow).CornerRadius = UDim.new(1, 0);
		local stationIcon = Instance.new("Frame", stationContainer); stationIcon.Name = "StationIcon"; stationIcon.Size = UDim2.new(0, 24, 0, 24); stationIcon.Position = UDim2.new(0.5, 0, 0.4, 0); stationIcon.AnchorPoint = Vector2.new(0.5, 0.5); stationIcon.BorderSizePixel = 0; stationIcon.ZIndex = 3;
		local iconColor = defaultStationColor; if data.IsTerminal then iconColor = terminalColor; elseif data.RequiredRole then iconColor = requiredRoleColor; elseif data.IsDspStation then iconColor = Theme.Accent_Hover; end;
		stationIcon.BackgroundColor3 = iconColor; stationIcon:SetAttribute("OriginalColor", iconColor); Instance.new("UICorner", stationIcon).CornerRadius = UDim.new(1, 0);
		local iconStroke = Instance.new("UIStroke", stationIcon); iconStroke.Color = Theme.Background; iconStroke.Thickness = 3;
		local innerIcon = Instance.new("Frame", stationIcon); innerIcon.Name = "InnerIcon"; innerIcon.Size = UDim2.new(0, 8, 0, 8); innerIcon.Position = UDim2.new(0.5, 0, 0.5, 0); innerIcon.AnchorPoint = Vector2.new(0.5, 0.5); innerIcon.BackgroundColor3 = Theme.Background; innerIcon.BorderSizePixel = 0; Instance.new("UICorner", innerIcon).CornerRadius = UDim.new(1, 0);
		if data.IsTerminal then innerIcon.BackgroundColor3 = Theme.TextPrimary; innerIcon.Size = UDim2.new(0, 6, 0, 6); end;
		local checkIcon = Instance.new("TextLabel", stationContainer); checkIcon.Name = "CheckIcon"; checkIcon.Text = " "; checkIcon.Font = Enum.Font.GothamBold; checkIcon.TextSize = 16; checkIcon.TextColor3 = selectedStationColor; checkIcon.BackgroundTransparency = 1; checkIcon.Visible = false; checkIcon.Size = UDim2.new(0, 20, 0, 20); checkIcon.Position = UDim2.new(0.5, 0, 0.4, 0); checkIcon.AnchorPoint = Vector2.new(0.5, 0.5); checkIcon.ZIndex = stationIcon.ZIndex + 2;
		local stationLabel = Instance.new("TextLabel", stationContainer); stationLabel.Name = "StationLabel"; stationLabel.Text = data.Name; stationLabel.Font = Enum.Font.GothamBold; stationLabel.TextSize = 12; stationLabel.TextColor3 = iconColor; stationLabel:SetAttribute("OriginalColor", iconColor); stationLabel.BackgroundTransparency = 1; stationLabel.TextWrapped = true; stationLabel.TextXAlignment = Enum.TextXAlignment.Center; stationLabel.Size = UDim2.new(1, 0, 0, 40); stationLabel.Position = UDim2.new(0.5, 0, 0.65, 0); stationLabel.AnchorPoint = Vector2.new(0.5, 0);
		local labelShadow = Instance.new("TextLabel", stationContainer); labelShadow.Name = "LabelShadow"; labelShadow.Text = data.Name; labelShadow.Font = Enum.Font.GothamBold; labelShadow.TextSize = 12; labelShadow.TextColor3 = Color3.new(0, 0, 0); labelShadow.TextTransparency = 0.8; labelShadow.BackgroundTransparency = 1; labelShadow.TextWrapped = true; labelShadow.TextXAlignment = Enum.TextXAlignment.Center; labelShadow.Size = UDim2.new(1, 0, 0, 40); labelShadow.Position = UDim2.new(0.5, 1, 0.65, 1); labelShadow.AnchorPoint = Vector2.new(0.5, 0); labelShadow.ZIndex = stationLabel.ZIndex - 1;
		local stationButton = Instance.new("TextButton", stationContainer); stationButton.Name = "StationButton"; stationButton.Size = UDim2.new(1, 0, 1, 0); stationButton.BackgroundTransparency = 1; stationButton.Text = ""; stationButton.ZIndex = 5;
		stationButton.MouseEnter:Connect(function() if selectedStationCircle ~= stationButton and not stationButton:GetAttribute("IsOccupied") then TweenService:Create(stationIcon, tweenInfoEnter, { Size = UDim2.new(0, 26, 0, 26), BackgroundTransparency = 0.8 }):Play(); TweenService:Create(stationLabel, tweenInfoEnter, { TextSize = 13 }):Play(); end end);
		stationButton.MouseLeave:Connect(function() if selectedStationCircle ~= stationButton and not stationButton:GetAttribute("IsOccupied") then TweenService:Create(stationIcon, tweenInfoLeave, { Size = UDim2.new(0, 24, 0, 24), BackgroundTransparency = 0 }):Play(); TweenService:Create(stationLabel, tweenInfoLeave, { TextSize = 12 }):Play(); end end);
		stationGuiElements[data.SpawnerName] = { button = stationButton, icon = stationIcon, label = stationLabel, container = stationContainer, glow = selectionGlow, data = data };
		table.insert(stationCircles, stationButton);
		stationButton.MouseButton1Click:Connect(function() SelectStation(stationButton, data) end);
	end;
	function UpdateDspStationAvailability()
		local dspTeam = Teams:FindFirstChild("ЧПС"); if not dspTeam then return end;
		for spawnerName, elements in pairs(stationGuiElements) do
			if elements.data.IsDspStation then
				local attributeName = spawnerName .. "_OccupiedBy"; local occupierId = dspTeam:GetAttribute(attributeName);
				if occupierId and occupierId > 0 and occupierId ~= player.UserId then
					elements.button:SetAttribute("IsOccupied", true); elements.label.TextColor3 = occupiedColor; TweenService:Create(elements.icon, tweenInfoLeave, { BackgroundColor3 = occupiedColor }):Play()
					local check = elements.container:FindFirstChild("CheckIcon"); if check then check.Visible = false end
				else
					elements.button:SetAttribute("IsOccupied", false); elements.label.TextColor3 = elements.label:GetAttribute("OriginalColor") or Theme.TextSecondary;
					if selectedStationData ~= elements.data then TweenService:Create(elements.icon, tweenInfoLeave, { BackgroundColor3 = elements.icon:GetAttribute("OriginalColor") }):Play() end
				end
			end
		end;
		UpdateSpawnButtonState()
	end;
	finalPlayButton = Instance.new("TextButton", spawnContent); finalPlayButton.Name = "FinalPlayButton"; finalPlayButton.Text = "УВІЙТИ В ГРУ"; finalPlayButton.Font = Enum.Font.GothamBold; finalPlayButton.TextSize = 20; finalPlayButton.Size = UDim2.new(0.5, 0, 0, 50); finalPlayButton.Position = UDim2.new(0.5, 0, 0.93, 0); finalPlayButton.AnchorPoint = Vector2.new(0.5, 0.5); finalPlayButton.BorderSizePixel = 0; Instance.new("UICorner", finalPlayButton).CornerRadius = UDim.new(0, 8);
	local playStroke = Instance.new("UIStroke", finalPlayButton); playStroke.Thickness = 1.5; playStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; playStroke.Color = Theme.Disabled
end

function UpdateSpawnButtonState()
	if not finalPlayButton then return end;
	local roleIsActuallySelected = selectedRoleData ~= nil; local stationSelected = selectedStationData ~= nil; local roleMatchesStation = not selectedStationData or not selectedStationData.RequiredRole or (selectedRoleData and selectedStationData.RequiredRole == selectedRoleData.Text); local stationRequirementMet = stationSelected;
	local dspStationValid = true; if selectedRoleData and selectedRoleData.TeamName == "ЧПС" then if not selectedStationData or not selectedStationData.IsDspStation then dspStationValid = false end end;
	local dspStationOccupied = false; if selectedRoleData and selectedRoleData.TeamName == "ЧПС" and stationSelected then local dspTeam = Teams:FindFirstChild("ЧПС"); local attributeName = selectedStationData.SpawnerName .. "_OccupiedBy"; if dspTeam and dspTeam:GetAttribute(attributeName) and dspTeam:GetAttribute(attributeName) > 0 and dspTeam:GetAttribute(attributeName) ~= player.UserId then dspStationOccupied = true end end;
	local roleLimitOk = true; if selectedRoleData and selectedRoleData.MaxPlayers and selectedRoleData.MaxPlayers > 0 then local team = Teams:FindFirstChild(selectedRoleData.TeamName); if team then local currentPlayersInTeam = #team:GetPlayers(); local playerIsInThisTeam = (player.Team == team); if currentPlayersInTeam >= selectedRoleData.MaxPlayers and not playerIsInThisTeam then roleLimitOk = false end end end;
	local expRequirementMet = true; if selectedRoleData and selectedRoleData.RequiredEXP then if expStat.Value < selectedRoleData.RequiredEXP then expRequirementMet = false end end;
	local canPlay = roleIsActuallySelected and stationRequirementMet and roleMatchesStation and dspStationValid and roleLimitOk and not dspStationOccupied and expRequirementMet;
	local btnStroke = finalPlayButton:FindFirstChildOfClass("UIStroke");
	if canPlay then TweenService:Create(finalPlayButton, tweenInfoEnter, { BackgroundColor3 = Theme.Success, TextColor3 = Theme.Background }):Play(); if btnStroke then TweenService:Create(btnStroke, tweenInfoEnter, { Color = Theme.Success, Enabled = false }):Play() end; finalPlayButton.Active, finalPlayButton.Selectable = true, true
	else TweenService:Create(finalPlayButton, tweenInfoLeave, { BackgroundColor3 = Theme.PrimaryUI_Light, TextColor3 = Theme.Disabled }):Play(); if btnStroke then TweenService:Create(btnStroke, tweenInfoLeave, { Color = Theme.Disabled, Enabled = true }):Play() end; finalPlayButton.Active, finalPlayButton.Selectable = false, false end
end
function UpdateRoleButtonsVisuals()
	if not spawnMenuWindow or not spawnMenuWindow.Parent then return end;
	for teamNameKey, elements in pairs(roleButtonElements) do
		local roleData = elements.data; 
		local textLabel = elements.textLabel; 
		local inputCatcher = elements.inputCatcher; 
		local frame = elements.frame; 
		local stroke = elements.stroke;

		local isCurrentlySelected = (selectedRoleData and selectedRoleData.TeamName == roleData.TeamName); 
		local canSelectThisRole = true;
		local isUnavailable = (roleData.Unavailable == true); -- Перевірка статусу

		-- Логіка формування тексту
		if isUnavailable then
			canSelectThisRole = false;
			textLabel.Text = string.format("%s<br/><font color='#%s' size='10'>ТИМЧАСОВО НЕДОСТУПНО</font>", roleData.Text, Theme.Error:ToHex());
		elseif roleData.MaxPlayers and roleData.MaxPlayers > 0 then
			local team = Teams:FindFirstChild(roleData.TeamName); 
			local currentPlayersInTeam = 0; 
			if team then currentPlayersInTeam = #team:GetPlayers() end; 
			textLabel.Text = string.format("%s<br/><font size='10'>%d / %d</font>", roleData.Text, currentPlayersInTeam, roleData.MaxPlayers);

			local playerIsInThisTeam = (player.Team == team); 
			if currentPlayersInTeam >= roleData.MaxPlayers and not playerIsInThisTeam then 
				canSelectThisRole = false 
			end
		else 
			textLabel.Text = roleData.Text 
		end;

		-- Перевірка EXP (якщо роль не закрита через Unavailable)
		if not isUnavailable and roleData.RequiredEXP then
			if expStat.Value < roleData.RequiredEXP then 
				canSelectThisRole = false; 
				local reasonText = string.format("<font color='#%s' size='9'>ПОТРІБНО %d EXP</font>", Theme.Error:ToHex(), roleData.RequiredEXP); 
				textLabel.Text = roleData.Text .. "<br/>" .. reasonText 
			end
		end;

		inputCatcher.Active = canSelectThisRole;

		-- Візуальні стани
		if not canSelectThisRole then
			TweenService:Create(frame, tweenInfoLeave, { BackgroundColor3 = Theme.PrimaryUI }):Play(); 
			TweenService:Create(textLabel, tweenInfoLeave, { TextColor3 = Theme.Disabled }):Play(); 
			TweenService:Create(stroke, tweenInfoLeave, { Color = isUnavailable and Theme.Error or Theme.Disabled }):Play();

			if isCurrentlySelected then SelectRole(nil, nil) end
		else 
			if not isCurrentlySelected then 
				TweenService:Create(frame, tweenInfoLeave, { BackgroundColor3 = Theme.PrimaryUI }):Play(); 
				TweenService:Create(textLabel, tweenInfoLeave, { TextColor3 = roleData.Color }):Play(); 
				TweenService:Create(stroke, tweenInfoLeave, { Color = roleData.Color }):Play() 
			end
		end
	end
end
function SelectRole(button, roleData)
	if selectedRoleData and roleButtonElements[selectedRoleData.TeamName] then
		local prevElements = roleButtonElements[selectedRoleData.TeamName];
		TweenService:Create(prevElements.frame, tweenInfoLeave, { BackgroundColor3 = Theme.PrimaryUI }):Play(); TweenService:Create(prevElements.textLabel, tweenInfoLeave, { TextColor3 = prevElements.data.Color }):Play(); TweenService:Create(prevElements.stroke, tweenInfoLeave, { Color = prevElements.data.Color }):Play()
	end;
	if selectedRoleData and roleData and selectedRoleData.TeamName == roleData.TeamName then selectedRoleButton = nil; selectedRoleData = nil
	else
		selectedRoleButton = button; selectedRoleData = roleData;
		if selectedRoleData and roleButtonElements[selectedRoleData.TeamName] then
			local newElements = roleButtonElements[selectedRoleData.TeamName];
			TweenService:Create(newElements.frame, tweenInfoEnter, { BackgroundColor3 = newElements.data.Color }):Play(); TweenService:Create(newElements.textLabel, tweenInfoEnter, { TextColor3 = Theme.Background }):Play(); TweenService:Create(newElements.stroke, tweenInfoEnter, { Color = newElements.data.Color }):Play()
		end
	end;
	UpdateRoleButtonsVisuals(); UpdateSpawnButtonState()
end
local menuButtonsData = {
	{ Text = "ГРАТИ", HighlightColor = Theme.Success, Action = function() OpenWindow(spawnMenuWindow); UpdateRoleButtonsVisuals() end, Order = 1 },
	{ Text = "ПРАВИЛА", HighlightColor = Theme.Warning, Action = function() CreateAndShowRulesViewWindow() end, Order = 2 },
	{ Text = "ПОДЯКИ", HighlightColor = Theme.Accent_Hover, Action = function() OpenWindow(creditsWindow) end, Order = 3 },
	{ Text = "АКАДЕМІЯ", HighlightColor = Theme.MetroLine, Action = function() TeleportService:Teleport(70704181078498, player) end, Order = 4 },
}
for _, buttonData in ipairs(menuButtonsData) do
	local buttonFrame = Instance.new("TextButton"); buttonFrame.Name = buttonData.Text:gsub("%s+", ""); buttonFrame.Size = UDim2.new(0, 0, 0, 45); buttonFrame.AutomaticSize = Enum.AutomaticSize.X; buttonFrame.AnchorPoint = Vector2.new(0.5, 0.5); buttonFrame.BackgroundTransparency = 1; buttonFrame.LayoutOrder = buttonData.Order; buttonFrame.Parent = buttonContainer; buttonFrame.Font = Enum.Font.GothamBold; buttonFrame.Text = buttonData.Text; buttonFrame.TextSize = 18; buttonFrame.TextColor3 = Theme.TextSecondary;
	local pad = Instance.new("UIPadding", buttonFrame); pad.PaddingLeft = UDim.new(0, 15); pad.PaddingRight = UDim.new(0, 15);
	local highlight = Instance.new("Frame", buttonFrame); highlight.Name = "Highlight"; highlight.BackgroundColor3 = buttonData.HighlightColor; highlight.Size = UDim2.new(1, 0, 0, 3); highlight.Position = UDim2.new(0.5, 0, 1.2, 0); highlight.AnchorPoint = Vector2.new(0.5, 1); highlight.BorderSizePixel = 0; highlight.Visible = false; Instance.new("UICorner", highlight).CornerRadius = UDim.new(0, 3);
	buttonFrame.MouseEnter:Connect(function() highlight.Visible = true; TweenService:Create(buttonFrame, tweenInfoEnter, { TextColor3 = Theme.TextPrimary }):Play(); TweenService:Create(highlight, tweenInfoEnter, { Position = UDim2.new(0.5, 0, 1, 0) }):Play() end);
	buttonFrame.MouseLeave:Connect(function() TweenService:Create(buttonFrame, tweenInfoLeave, { TextColor3 = Theme.TextSecondary }):Play(); TweenService:Create(highlight, tweenInfoLeave, { Position = UDim2.new(0.5, 0, 1.2, 0) }):Play(); task.wait(0.2); if not highlight:IsDescendantOf(game) or buttonFrame.SelectionGroup ~= true then highlight.Visible = false end end);
	buttonFrame.MouseButton1Click:Connect(function() if buttonData.Action then buttonData.Action() end end)
end
local rolesContainer = spawnMenuWindow:FindFirstChild("ContentFrame"):FindFirstChild("RolesFrame");
if rolesContainer then
	for i, roleData_item in ipairs(rolesData) do
		local roleButtonFrame = Instance.new("Frame"); roleButtonFrame.Name = roleData_item.Text; roleButtonFrame.Size = UDim2.new(0, 120, 0, 50); roleButtonFrame.BackgroundColor3 = Theme.PrimaryUI; roleButtonFrame.BorderSizePixel = 0; roleButtonFrame.ClipsDescendants = true; roleButtonFrame.LayoutOrder = i; roleButtonFrame.Parent = rolesContainer;
		Instance.new("UICorner", roleButtonFrame).CornerRadius = UDim.new(0, 8);
		local frameStroke = Instance.new("UIStroke", roleButtonFrame); frameStroke.Thickness = 1.5; frameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; frameStroke.Color = roleData_item.Color;
		local buttonText = Instance.new("TextLabel"); buttonText.Name = "Text"; buttonText.Size = UDim2.new(1, 0, 1, 0); buttonText.BackgroundTransparency = 1; buttonText.Font = Enum.Font.GothamBold; buttonText.RichText = true; buttonText.Text = roleData_item.Text; buttonText.TextColor3 = roleData_item.Color; buttonText.TextSize = 14; buttonText.TextYAlignment = Enum.TextYAlignment.Center; buttonText.ZIndex = roleButtonFrame.ZIndex + 3; buttonText.Parent = roleButtonFrame;
		local inputCatcher = Instance.new("TextButton"); inputCatcher.Name = "InputCatcher"; inputCatcher.Size = UDim2.new(1, 0, 1, 0); inputCatcher.BackgroundTransparency = 1; inputCatcher.Text = ""; inputCatcher.ZIndex = roleButtonFrame.ZIndex + 5; inputCatcher.Parent = roleButtonFrame;
		roleButtonElements[roleData_item.TeamName] = {frame = roleButtonFrame, textLabel = buttonText, inputCatcher = inputCatcher, stroke = frameStroke, data = roleData_item};
		table.insert(roleButtons, roleButtonFrame);
		inputCatcher.MouseButton1Click:Connect(function() if inputCatcher.Active then SelectRole(roleButtonFrame, roleData_item) end end)
	end
end
function CloseMainMenu()
	local currentTime = os.clock()
	if not screenGui.Enabled or isMenuTransitioning or (currentTime - lastMenuActionTime) < MENU_DEBOUNCE_TIME then return end
	isMenuTransitioning = true
	lastMenuActionTime = currentTime
	local character = player.Character;
	if character and originalWalkSpeed ~= nil then
		local humanoid = character:FindFirstChildOfClass("Humanoid"); if humanoid then humanoid.WalkSpeed = originalWalkSpeed end; originalWalkSpeed = nil
	end;
	RestorePlayerCamera(); CloseActiveWindow(true);
	if bottomBarFrame then TweenService:Create(bottomBarFrame, TweenInfo.new(BOTTOM_BAR_ANIM_TIME, animStyle, Enum.EasingDirection.In), { Position = UDim2.new(0.5, 0, 1.1, 0) }):Play(); end
	task.wait(BOTTOM_BAR_ANIM_TIME);
	if screenGui and screenGui.Parent then screenGui.Enabled = false end
	isMenuTransitioning = false
end
finalPlayButton.MouseButton1Click:Connect(function()
	if not finalPlayButton.Active then
		local isShaking = finalPlayButton:GetAttribute("isShaking");
		if not isShaking then
			finalPlayButton:SetAttribute("isShaking", true);
			local op = finalPlayButton.Position; local t = TweenService:Create(finalPlayButton, shakeTweenInfo, { Position = op + UDim2.new(0, 5, 0, 0) });
			t.Completed:Connect(function() if finalPlayButton then finalPlayButton.Position = op; finalPlayButton:SetAttribute("isShaking", nil) end end);
			t:Play()
		end;
		return
	end;
	if not selectedRoleData then UpdateSpawnButtonState(); return end
	local teamToRequest = selectedRoleData.TeamName;
	local stationNameToRequest = selectedStationData and selectedStationData.SpawnerName or nil;
	if teamToRequest == "Диспетчер" then stationNameToRequest = nil end;
	if teamToRequest then
		changeTeamEvent:FireServer(teamToRequest, stationNameToRequest);
		if teamToRequest == "Диспетчер" then lastSelectedStationData = nil else lastSelectedStationData = selectedStationData end;
		hasStartedPlaying = true; lastSelectedTeamName = teamToRequest; CloseMainMenu()
	end
end)
function CheckHoldDuration()
	holdUI.Visible = true;
	while isHoldActive and RunService:IsRunning() and holdStartTime > 0 do
		local elapsedTime = os.clock() - holdStartTime;
		local progress = math.clamp(elapsedTime / HOLD_DURATION, 0, 1);
		local keypoints = {NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(progress, 0), NumberSequenceKeypoint.new(math.min(1, progress + 0.001), 1), NumberSequenceKeypoint.new(1, 1)};
		holdGradient.Transparency = NumberSequence.new(keypoints);
		if elapsedTime >= HOLD_DURATION then
			if not screenGui.Enabled and not menuOpenRequested then
				menuOpenRequested = true; isHoldActive = false; holdUI.Visible = false; holdGradient.Transparency = NumberSequence.new(1);
				task.spawn(OpenMainMenu);
			else isHoldActive = false end;
			break
		end;
		RunService.Heartbeat:Wait()
	end;
	if isHoldActive == false and menuOpenRequested == false then
		holdUI.Visible = false; holdGradient.Transparency = NumberSequence.new(1);
	end
end
function StartHoldCheck()
	if not rulesAccepted or isHoldActive or screenGui.Enabled then return end;
	isHoldActive = true; holdStartTime = os.clock(); menuOpenRequested = false;
	task.spawn(CheckHoldDuration)
end
function EndHoldCheck()
	if isHoldActive then isHoldActive = false end
end
UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe or UserInputService:GetFocusedTextBox() then return end;
	if input.KeyCode == HOLD_KEY_CODE then StartHoldCheck() end
end);
UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == HOLD_KEY_CODE then EndHoldCheck() end
end)
if UserInputService.TouchEnabled then
	local mobileMenuGui = Instance.new("ScreenGui"); mobileMenuGui.Name = "MobileMenuButtonGui"; mobileMenuGui.ResetOnSpawn = false; mobileMenuGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; mobileMenuGui.IgnoreGuiInset = true; mobileMenuGui.DisplayOrder = 999;
	local buttonFrame = Instance.new("Frame"); buttonFrame.Name = "MobileMenuButton"; buttonFrame.Size = UDim2.new(0, 55, 0, 55); buttonFrame.Position = UDim2.new(1, -15, 0, 15); buttonFrame.AnchorPoint = Vector2.new(1, 0); buttonFrame.BackgroundColor3 = Theme.Background; buttonFrame.BackgroundTransparency = 0.3; buttonFrame.BorderSizePixel = 0; buttonFrame.Parent = mobileMenuGui;
	local corner = Instance.new("UICorner", buttonFrame); corner.CornerRadius = UDim.new(0.5, 0); local stroke = Instance.new("UIStroke", buttonFrame); stroke.Color = Theme.PrimaryUI_Light; stroke.Thickness = 1.5;
	local icon = Instance.new("TextLabel"); icon.Name = "Icon"; icon.Size = UDim2.fromScale(1, 1); icon.BackgroundTransparency = 1; icon.Font = Enum.Font.SourceSansBold; icon.Text = "☰"; icon.TextColor3 = Theme.TextPrimary; icon.TextSize = 30; icon.Parent = buttonFrame;
	local actionButton = Instance.new("TextButton"); actionButton.Name = "ActionButton"; actionButton.Size = UDim2.fromScale(1, 1); actionButton.Text = ""; actionButton.BackgroundTransparency = 1; actionButton.Parent = buttonFrame;
	actionButton.MouseButton1Click:Connect(function() if not rulesAccepted then return end; if not screenGui.Enabled then OpenMainMenu() elseif hasStartedPlaying then CloseMainMenu() end end);
	actionButton.MouseEnter:Connect(function() TweenService:Create(buttonFrame, tweenInfoEnter, { BackgroundTransparency = 0.1 }):Play() end);
	actionButton.MouseLeave:Connect(function() TweenService:Create(buttonFrame, tweenInfoLeave, { BackgroundTransparency = 0.3 }):Play() end);
	mobileMenuGui.Parent = playerGui
else
	local pcMenuGui = Instance.new("ScreenGui"); pcMenuGui.Name = "PCMenuButtonGui"; pcMenuGui.ResetOnSpawn = false; pcMenuGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; pcMenuGui.IgnoreGuiInset = true; pcMenuGui.DisplayOrder = 999;
	local buttonFrame = Instance.new("Frame"); buttonFrame.Name = "PCMenuButton"; buttonFrame.Size = UDim2.new(0, 100, 0, 40); buttonFrame.Position = UDim2.new(1, -15, 0, 15); buttonFrame.AnchorPoint = Vector2.new(1, 0); buttonFrame.BackgroundColor3 = Theme.Background; buttonFrame.BackgroundTransparency = 0.3; buttonFrame.BorderSizePixel = 0; buttonFrame.Parent = pcMenuGui;
	local corner = Instance.new("UICorner", buttonFrame); corner.CornerRadius = UDim.new(0, 8); local stroke = Instance.new("UIStroke", buttonFrame); stroke.Color = Theme.PrimaryUI_Light; stroke.Thickness = 1.5;
	local label = Instance.new("TextLabel"); label.Name = "Label"; label.Size = UDim2.fromScale(1, 1); label.BackgroundTransparency = 1; label.Font = Enum.Font.GothamBold; label.Text = "МЕНЮ"; label.TextColor3 = Theme.TextPrimary; label.TextSize = 18; label.Parent = buttonFrame;
	local actionButton = Instance.new("TextButton"); actionButton.Name = "ActionButton"; actionButton.Size = UDim2.fromScale(1, 1); actionButton.Text = ""; actionButton.BackgroundTransparency = 1; actionButton.Parent = buttonFrame;
	actionButton.MouseButton1Click:Connect(function() if not rulesAccepted then return end; if not screenGui.Enabled then OpenMainMenu() elseif hasStartedPlaying then CloseMainMenu() end end);
	actionButton.MouseEnter:Connect(function() TweenService:Create(buttonFrame, tweenInfoEnter, { BackgroundTransparency = 0.1 }):Play() end);
	actionButton.MouseLeave:Connect(function() TweenService:Create(buttonFrame, tweenInfoLeave, { BackgroundTransparency = 0.3 }):Play() end);
	pcMenuGui.Parent = playerGui
end

local function SetupTeamListeners()
	for teamNameKey, elements in pairs(roleButtonElements) do
		local roleData = elements.data;
		if roleData.MaxPlayers and roleData.MaxPlayers > 0 then
			local team = Teams:FindFirstChild(roleData.TeamName);
			if team then
				if teamPlayerEventListeners[roleData.TeamName] then for _, c in ipairs(teamPlayerEventListeners[roleData.TeamName]) do c:Disconnect() end end;
				teamPlayerEventListeners[roleData.TeamName] = {};
				table.insert(teamPlayerEventListeners[roleData.TeamName], team.PlayerAdded:Connect(UpdateRoleButtonsVisuals));
				table.insert(teamPlayerEventListeners[roleData.TeamName], team.PlayerRemoved:Connect(UpdateRoleButtonsVisuals))
			end
		end
	end
end
local function SetupDspTeamListener()
	local dspTeam = Teams:FindFirstChild("ЧПС");
	if dspTeam then
		UpdateDspStationAvailability();
		dspTeam.AttributeChanged:Connect(function(attributeName)
			if string.find(attributeName, "_OccupiedBy") then UpdateDspStationAvailability() end
		end)
	end
end
local function OnCharacterAdded(character)
	if hasStartedPlaying then CloseMainMenu() end
end
local function InitialSetup()
	task.wait(1)
	if loadingFrame and loadingFrame.Parent then
		TweenService:Create(loadingFrame, TweenInfo.new(LOAD_FADE_TIME), {BackgroundTransparency = 1}):Play();
		task.delay(LOAD_FADE_TIME, function() if loadingFrame and loadingFrame.Parent then loadingFrame:Destroy() end end);
	end;
	screenGui.Parent = playerGui;
	if not hasShownInitialWindows then CreateAndShowRulesWindow() end
	if player.Character then OnCharacterAdded(player.Character) end;
	player.CharacterAdded:Connect(OnCharacterAdded);
	Teams.ChildAdded:Connect(SetupTeamListeners);
	Teams.ChildAdded:Connect(SetupDspTeamListener);
	expStat.Changed:Connect(UpdateRoleButtonsVisuals);
	SetupTeamListeners();
	SetupDspTeamListener()
end;
wait(5)
InitialSetup()