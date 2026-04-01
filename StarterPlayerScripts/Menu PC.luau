task.wait(2)
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")

-- Перевірка на мобільні пристрої
if UserInputService.TouchEnabled then
	script:Destroy()
	print("ООХ чорт, оох чорт ітс мобіле")
	return
end

-------------------------------------------------------------------------
-- ПЕРЕВІРКА ДАТИ ТА ПОВІДОМЛЕННЯ ПРО ОНОВЛЕННЯ
-------------------------------------------------------------------------
local function CheckForUpdates()
	local currentDate = os.date("*t")

	if currentDate.year == 2025 and currentDate.month == 12 and currentDate.day == 26 then
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "UpdateNotification"
		screenGui.IgnoreGuiInset = true
		screenGui.DisplayOrder = 3
		screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(0, 400, 0, 100)
		frame.Position = UDim2.new(0.5, 0, 0.1, 0)
		frame.AnchorPoint = Vector2.new(0.5, 0)
		frame.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
		frame.BorderSizePixel = 0
		frame.Parent = screenGui

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 12)
		corner.Parent = frame

		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, -20, 1, -20)
		textLabel.Position = UDim2.new(0, 10, 0, 10)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = "Увага! Оновленні правила від 26.12.2025.\nПрочитайте їх ще раз!"
		textLabel.TextColor3 = Color3.new(1, 1, 1)
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextSize = 18
		textLabel.TextWrapped = true
		textLabel.Parent = frame

		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://12221967"
		sound.Parent = frame
		sound:Play()

		task.delay(30, function()
			if screenGui and screenGui.Parent then
				screenGui:Destroy()
			end
		end)
	end
end
task.spawn(CheckForUpdates)
-------------------------------------------------------------------------

local changelogData = {
	" Дніпро має вестибюль",
	" Диспетчер повернутий, і тепер має деяке нове меню (поки що скромно)",
	" Оновленні на 5 вагонкі: Лісова, Чернігівська, Дарниця, Гідропарк.",
	" І БАГАТО, БАГАТО чого іншого. Дізнайтесь самі )",
}

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

	{ type = "rule", text = "<b>2.7.1</b> ✅ Обкатка: обов'язково дотримуватись дистанції, їхати ≤30 км/год, подавати сигнал на станціях." },
	{ type = "rule", text = "<b>2.7.2</b> ✅ Машиністи повинні пропускати один одного на кінцевих, уникати заторів, не спавнити багато потягів." },

	{ type = "rule", text = "<b>2.8</b> 🚫 Використання потяга, який створила інша особа." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> кік → бан 3-7 днів." },

	{ type = "rule", text = "<b>2.9</b> 🚫 Рух без інформатора (виняток: обкатка, перегонка, фотопоїзд 81.717)." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> кік" },

	{ type = "rule", text = "<b>2.10</b> 🚫 Ігнорування команд ДСП - Диспетчера." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> кік → бан - 1-3 дні." },

	{ type = "rule", text = "<b>2.11</b> 🚫 Проїзд на червоне світло (без дозволу диспетчера)." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> кік → бан 1–3 дні" },

	{ type = "rule", text = "<b>2.12</b> 🚫 Рух під час повітряної тривоги (ПТ). <font color='#8a94b7'>(Виняток: Дозвіл овнера гри)</font>" },
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

	{ type = "rule", text = "<b>3.6.1</b> 🚫 Образи про сім'ю, батьків, хвороби." },
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
	{ type = "punishment", text = "⛔ <i>Покарання:</i> м'ют від 15 хвилин, до бану на розгляд модерації/адміністрації" },

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
	StationSelected = Color3.fromRGB(255, 118, 0),
	PanelGlow = Color3.fromRGB(42, 35, 58),
	GlassOverlay = Color3.fromRGB(30, 25, 45),
	OutlineSoft = Color3.fromRGB(65, 55, 90)
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
	StationSelected = Color3.fromRGB(100, 200, 255),
	PanelGlow = Color3.fromRGB(35, 45, 70),
	GlassOverlay = Color3.fromRGB(25, 35, 55),
	OutlineSoft = Color3.fromRGB(56, 68, 94)
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
	StationSelected = Color3.fromRGB(68, 214, 196),
	PanelGlow = Color3.fromRGB(28, 54, 108),
	GlassOverlay = Color3.fromRGB(18, 30, 62),
	OutlineSoft = Color3.fromRGB(38, 62, 104)
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
local HOLD_KEY_CODE = Enum.KeyCode.M
local HOLD_DURATION = 1.5
local CAMERA_PATH_DURATION = 20

local tweenInfoEnter = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfoLeave = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local shakeTweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 4, true)

local changeTeamEvent = ReplicatedStorage:WaitForChild("ChangeTeamG")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local leaderstats = player:WaitForChild("leaderstats")
local expStat = leaderstats:WaitForChild("EXP")

local originalWalkSpeed = nil
local hasStartedPlaying = false
local hasShownInitialWindows = false
local hasShownPreviewWarning = false
local rulesAccepted = false
local rulesWindow
local rulesStartTime = 0

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainMenuGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Enabled = true

local isHoldActive = false
local holdStartTime = 0
local menuOpenRequested = false

local isMenuTransitioning = false
local lastMenuActionTime = 0
local MENU_DEBOUNCE_TIME = 0.5

local blurEffect
local blurTween = nil

local selectedRoleData = nil
local selectedStationCircle = nil
local selectedStationData = nil
local finalPlayButton = nil
local finalPlayButtonConnection = nil

local stationGuiElementsMap = {}
local playSummaryLabel = nil

local rolesData = {
	{ Text = "ПАСАЖИР", Color = Color3.fromRGB(88, 255, 197), TeamName = "Passanger", Tagline = "Вільна прогулянка та огляд маршрутів" },
	{ Text = "МАШИНІСТ", Color = Color3.fromRGB(74, 101, 255), TeamName = "Machinist", MaxPlayers = 12, Tagline = "Керуйте поїздом та тримайте графік" },
	{ Text = "ДИСПЕТЧЕР", Color = Color3.fromRGB(255, 175, 75), TeamName = "Диспетчер", MaxPlayers = 1, RequiredEXP = 2000, Tagline = "Контролюйте рух поїздів та розпоряджайтесь рухом", Unavailable = true },
	{ Text = "ЧПС", Color = Color3.fromRGB(189, 147, 249), TeamName = "ЧПС", MaxPlayers = 1, RequiredEXP = 500, Tagline = "Чергова по станції, тримайте порядок" },
	{ Text = "Поліція", Color = Color3.fromRGB(68, 122, 255), TeamName = "Поліція", MaxPlayers = 4, RequiredEXP = 1250, Tagline = "Безпека на платформах та у вагонах", Unavailable = true }
}

local stationsData = {
	{ Name = "Тупік • Лісова", Code = "DEP-L", SpawnerName = "TupikLisova", RequiredRole = "МАШИНІСТ", IsTerminal = true },
	{ Name = "Лісова", Code = "M1-01", SpawnerName = "Lisova", IsDspStation = true },
	{ Name = "Чернігівська", Code = "M1-02", SpawnerName = "Chernigivska" },
	{ Name = "Дарниця", Code = "M1-03", SpawnerName = "Darnytsia" },
	{ Name = "Лівобережна", Code = "M1-04", SpawnerName = "Livoberz" },
	{ Name = "Гідропарк", Code = "M1-05", SpawnerName = "Gidropark" },
	{ Name = "Дніпро", Code = "M1-06", SpawnerName = "Dnipro" },
	{ Name = "Тупік • Дніпро", Code = "DEP-D", SpawnerName = "TupikDnipro", RequiredRole = "МАШИНІСТ", IsTerminal = true }
}

local roleButtonElements = {}
local teamPlayerEventListeners = {}

local loadingFrame = Instance.new("Frame")
loadingFrame.Name = "LoadingScreen"
loadingFrame.Size = UDim2.new(1, 0, 1, 0)
loadingFrame.BackgroundColor3 = Theme.Background
loadingFrame.BackgroundTransparency = 0
loadingFrame.BorderSizePixel = 0
loadingFrame.ZIndex = 100
loadingFrame.Parent = playerGui

local camera = Workspace.CurrentCamera

blurEffect = Lighting:FindFirstChildOfClass("BlurEffect") or Instance.new("BlurEffect")
blurEffect.Name = "MenuBlur"
blurEffect.Size = 0
blurEffect.Enabled = false
blurEffect.Parent = Lighting

local menuCamera = {}
menuCamera.IsActive = false
menuCamera.Paths = {}
menuCamera.CurrentTween = nil
menuCamera.Music = nil
menuCamera.FadeFrame = nil
menuCamera.CurrentPathIndex = 0
menuCamera.MusicEndedConnection = nil

function menuCamera:Initialize()
	self.Music = Instance.new("Sound")
	-- Виправлено: використовуємо musicData замість хардкодженого значення
	self.Music.SoundId = musicData[1] or "rbxassetid://1841998974"
	self.Music.Looped = false
	self.Music.Volume = 0.4
	self.Music.Parent = Workspace

	self.FadeFrame = Instance.new("Frame")
	self.FadeFrame.Name = "CameraFadeFrame"
	self.FadeFrame.Size = UDim2.new(1, 0, 1, 0)
	self.FadeFrame.BackgroundColor3 = Color3.new(0, 0, 0)
	self.FadeFrame.BackgroundTransparency = 1
	self.FadeFrame.BorderSizePixel = 0
	self.FadeFrame.ZIndex = 4
	self.FadeFrame.Parent = screenGui

	local pathContainerOriginal = ReplicatedStorage:WaitForChild("CameraPath", 0.1)
	if not pathContainerOriginal then return end

	local pathContainer = pathContainerOriginal:Clone()
	if not screenGui:FindFirstChild("TempCameraPaths") then
		Instance.new("Folder", screenGui).Name = "TempCameraPaths"
	end
	pathContainer.Parent = screenGui.TempCameraPaths

	local pathFolders = {}
	for _, child in ipairs(pathContainer:GetChildren()) do
		if child:IsA("Folder") then table.insert(pathFolders, child) end
	end
	if #pathFolders == 0 then return end

	table.sort(pathFolders, function(a, b) return a.Name:lower() < b.Name:lower() end)

	for _, pathFolder in ipairs(pathFolders) do
		local parts = {}
		for _, part in ipairs(pathFolder:GetChildren()) do
			if part:IsA("BasePart") then table.insert(parts, part) end
		end
		if #parts > 0 then
			table.sort(parts, function(a, b)
				local numA = tonumber(string.match(a.Name, "%d+")) or 0
				local numB = tonumber(string.match(b.Name, "%d+")) or 0
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
	if not self.IsActive then return end
	self.IsActive = false

	if self.CurrentTween then 
		self.CurrentTween:Cancel()
		self.CurrentTween = nil 
	end

	if self.Music and self.Music.IsPlaying then
		local musicTween = TweenService:Create(self.Music, TweenInfo.new(0.3), {Volume = 0})
		musicTween.Completed:Connect(function() 
			if self.Music then
				self.Music:Stop()
				self.Music.Volume = 0.4 
			end
		end)
		musicTween:Play()
	end

	if self.MusicEndedConnection then
		self.MusicEndedConnection:Disconnect()
		self.MusicEndedConnection = nil
	end

	local tempFolder = screenGui:FindFirstChild("TempCameraPaths")
	if tempFolder then tempFolder:Destroy() end

	camera.CameraType = Enum.CameraType.Custom
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		camera.CameraSubject = player.Character.Humanoid
	end
end

menuCamera:Initialize()

function menuCamera:Fade(fadeIn)
	local duration = 1
	local targetTransparency = fadeIn and 1 or 0
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(self.FadeFrame, tweenInfo, { BackgroundTransparency = targetTransparency })
	tween:Play()
	tween.Completed:Wait()
end

function menuCamera:MoveAlongPath(path)
	if not self.IsActive or not path or #path < 2 then return end
	local segments = #path - 1
	local durationPerSegment = (segments > 0) and (CAMERA_PATH_DURATION / segments) or CAMERA_PATH_DURATION

	for i = 1, #path - 1 do
		if not self.IsActive then break end
		local endPart = path[i+1]
		local moveTweenInfo = TweenInfo.new(durationPerSegment, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		self.CurrentTween = TweenService:Create(camera, moveTweenInfo, { CFrame = endPart.CFrame })
		self.CurrentTween:Play()
		self.CurrentTween.Completed:Wait()
		self.CurrentTween = nil
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

	if blurEffect then 
		blurEffect.Enabled = true
		blurEffect.Size = BLUR_AMOUNT 
	end

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
	holdUI = Instance.new("Frame")
	holdUI.Name = "HoldUI"
	holdUI.Size = UDim2.fromOffset(100, 100)
	holdUI.Position = UDim2.fromScale(0.5, 0.5)
	holdUI.AnchorPoint = Vector2.new(0.5, 0.5)
	holdUI.BackgroundTransparency = 1
	holdUI.ZIndex = 100
	holdUI.Visible = false

	local background = Instance.new("ImageLabel", holdUI)
	background.Image = "rbxassetid://5920953930"
	background.ImageColor3 = Color3.new(0, 0, 0)
	background.ImageTransparency = 0.5
	background.ScaleType = Enum.ScaleType.Slice
	background.SliceCenter = Rect.new(50, 50, 50, 50)
	background.Size = UDim2.fromScale(1, 1)
	background.BackgroundTransparency = 1

	local keyLabel = Instance.new("TextLabel", holdUI)
	keyLabel.Text = "M"
	keyLabel.Font = Enum.Font.GothamBold
	keyLabel.TextSize = 42
	keyLabel.TextColor3 = Color3.new(1, 1, 1)
	keyLabel.Size = UDim2.fromScale(1, 1)
	keyLabel.BackgroundTransparency = 1

	holdIndicator = Instance.new("ImageLabel", holdUI)
	holdIndicator.Image = "rbxassetid://5920953930"
	holdIndicator.ScaleType = Enum.ScaleType.Slice
	holdIndicator.SliceCenter = Rect.new(50, 50, 50, 50)
	holdIndicator.Size = UDim2.new(1, 1)
	holdIndicator.BackgroundTransparency = 1

	holdGradient = Instance.new("UIGradient", holdUI)
	holdGradient.Rotation = -90
	holdGradient.Transparency = NumberSequence.new(1)

	holdIndicator.Parent = holdUI
	holdUI.Parent = screenGui
end

CreateHoldUI()

local BuildPlayPanel, BuildUpdatesPanel, BuildRulesPanel, BuildCreditsPanel
local SetupTeamListeners

local mainShell = nil
local navButtons = {}
local navContainer = nil
local detailShell = nil
local detailContainer = nil
local detailTitleLabel = nil
local detailSubtitleLabel = nil
local detailAccentLine = nil
local heroPanel = nil
local heroTitleLabel = nil
local heroSubtitleLabel = nil
local heroChipsContainer = nil
local heroHalo = nil
local currentPanelKey = nil

local orderedPanelKeys = { "PLAY", "RULES", "UPDATES", "ACADEMY", "CREDITS" }

local panelsConfig = {
	PLAY = {
		label = "Почати зміну",
		subtitle = "Обирайте роль і станцію просто у центрі командування",
		accent = Theme.Success,
		hero = {
			title = "Командний центр",
			subtitle = "Інтерактивна схема лінії та живі статуси ролей допомагають стартувати миттєво.",
			chips = { "Живі обмеження команд", "Інтерактивна лінія станцій", "Миттєвий виїзд" }
		}
	},
	RULES = {
		label = "Регламент",
		subtitle = "Оновлений кодекс поведінки оформлений як службовий файл",
		accent = Theme.Warning,
		hero = {
			title = "Документація",
			subtitle = "Сприймайте правила як офіційний наказ: все структуровано за ролями та випадками.",
			chips = { "Пасажири", "Машиністи", "Загальні норми" }
		}
	},
	UPDATES = {
		label = "Журнал оновлень",
		subtitle = "Хронологія правок, сезонні події та великі релізи",
		accent = Theme.Accent,
		hero = {
			title = "Новини",
			subtitle = "Слідкуйте за оновленнями, новинками у грі. Перше оновлення з цим меню, як вам ?",
			chips = { "Сезонні івенти", "Покращення геймплею" }
		}
	},
	ACADEMY = {
		label = "Академія",
		subtitle = "Перехід до навчального центру метрополітену",
		accent = Color3.fromRGB(255, 215, 0),
		hero = {}
	},
	CREDITS = {
		label = "Команда",
		subtitle = "Люди та ресурси, які створюють атмосферу метро",
		accent = Theme.Accent_Hover,
		hero = {
			title = "Подяки",
			subtitle = "Відзначаємо авторів моделей, звуків та шрифтів у вигляді бейджів.",
			chips = { "Розробники", "Партнери", "Ресурси" }
		}
	}
}

local function resetFrame(frame)
	if not frame then return end
	for _, child in ipairs(frame:GetChildren()) do
		child:Destroy()
	end
end

local function createChip(parent, text, accentColor)
	local chipFrame = Instance.new("Frame")
	chipFrame.Name = "HeroChip"
	chipFrame.BackgroundTransparency = 0.2
	chipFrame.BackgroundColor3 = accentColor
	chipFrame.Size = UDim2.new(1, 0, 0, 0)
	chipFrame.AutomaticSize = Enum.AutomaticSize.Y
	chipFrame.Parent = parent

	local chipCorner = Instance.new("UICorner", chipFrame)
	chipCorner.CornerRadius = UDim.new(0, 14)

	local chipLabel = Instance.new("TextLabel")
	chipLabel.Name = "ChipLabel"
	chipLabel.BackgroundTransparency = 1
	chipLabel.Font = Enum.Font.GothamMedium
	chipLabel.Text = string.upper(text)
	chipLabel.TextSize = 12
	chipLabel.TextColor3 = Theme.TextPrimary
	chipLabel.TextXAlignment = Enum.TextXAlignment.Center
	chipLabel.TextWrapped = true
	chipLabel.Size = UDim2.new(1, 0, 1, 0)
	chipLabel.Parent = chipFrame

	local chipPadding = Instance.new("UIPadding", chipLabel)
	chipPadding.PaddingLeft = UDim.new(0, 14)
	chipPadding.PaddingRight = UDim.new(0, 14)
	chipPadding.PaddingTop = UDim.new(0, 6)
	chipPadding.PaddingBottom = UDim.new(0, 6)
end

local function setHeroState(config, accentColor)
	if not heroPanel then return end
	local heroConfig = config or {}

	if heroTitleLabel then
		heroTitleLabel.Text = heroConfig.title or ""
	end
	if heroSubtitleLabel then
		heroSubtitleLabel.Text = heroConfig.subtitle or ""
	end

	if heroChipsContainer then
		for _, child in ipairs(heroChipsContainer:GetChildren()) do
			if child:IsA("GuiObject") then child:Destroy() end
		end
		if heroConfig.chips then
			for _, chipText in ipairs(heroConfig.chips) do
				createChip(heroChipsContainer, chipText, accentColor or config.accent or Theme.Accent)
			end
		end
	end

	if heroHalo then
		heroHalo.BackgroundColor3 = accentColor or config and config.accent or Theme.Accent
	end
end

local function updateDetailHeader(config)
	if not detailShell then return end
	if detailTitleLabel then
		detailTitleLabel.Text = config.label or ""
	end
	if detailSubtitleLabel then
		detailSubtitleLabel.Text = config.subtitle or ""
	end
	if detailAccentLine then 
		detailAccentLine.BackgroundColor3 = config.accent or Theme.Accent 
	end
end

local function updateNavState()
	for key, info in pairs(navButtons) do
		local isActive = key == currentPanelKey
		local config = panelsConfig[key]
		if not config then continue end
		local accentColor = config.accent or Theme.Accent

		if info.button and info.button.Parent then
			local transparency = isActive and 0.05 or 0.2
			TweenService:Create(info.button, tweenInfoEnter, {BackgroundTransparency = transparency}):Play()
		end
		if info.accent and info.accent.Parent then
			info.accent.Visible = isActive
			TweenService:Create(info.accent, tweenInfoEnter, {BackgroundTransparency = isActive and 0 or 0.2}):Play()
		end
		if info.titleLabel and info.titleLabel.Parent then
			local targetColor = isActive and Theme.TextPrimary or Theme.TextSecondary
			TweenService:Create(info.titleLabel, tweenInfoEnter, {TextColor3 = targetColor}):Play()
		end
		if info.subtitleLabel and info.subtitleLabel.Parent then
			local targetColor = isActive and Theme.TextSecondary or Theme.Disabled
			TweenService:Create(info.subtitleLabel, tweenInfoEnter, {TextColor3 = targetColor}):Play()
		end
		if info.halo then
			info.halo.Visible = isActive
			info.halo.BackgroundColor3 = accentColor
		end
	end
end

local function SwitchPanel(panelKey)
	if panelKey == "ACADEMY" then
		TeleportService:Teleport(70704181078498, player)
		return
	end

	local config = panelsConfig[panelKey]
	if not config then return end
	if currentPanelKey == panelKey then return end
	currentPanelKey = panelKey

	if finalPlayButtonConnection then
		finalPlayButtonConnection:Disconnect()
		finalPlayButtonConnection = nil
	end
	finalPlayButton = nil
	playSummaryLabel = nil
	stationGuiElementsMap = {}
	selectedStationCircle = nil
	selectedStationData = nil

	resetFrame(detailContainer)
	updateDetailHeader(config)
	setHeroState(config.hero, config.accent)
	updateNavState()

	if config.builder then
		config.builder(detailContainer, config)
	end
end

local function buildNavButton(parent, key, config)
	local button = Instance.new("TextButton")
	button.Name = key .. "Nav"
	button.AutoButtonColor = false
	button.BackgroundColor3 = Theme.PrimaryUI
	button.BackgroundTransparency = 0.2
	button.Size = UDim2.new(1, 0, 0, 88)
	button.Text = ""
	button.Parent = parent

	local corner = Instance.new("UICorner", button)
	corner.CornerRadius = UDim.new(0, 16)

	local halo = Instance.new("Frame")
	halo.Name = "Halo"
	halo.Size = UDim2.new(0, 10, 0, 56)
	halo.AnchorPoint = Vector2.new(0, 0.5)
	halo.Position = UDim2.new(0, 0, 0.5, 0) 
	halo.BackgroundColor3 = config.accent or Theme.Accent
	halo.BackgroundTransparency = 0.5
	halo.Visible = false
	halo.Parent = button
	Instance.new("UICorner", halo).CornerRadius = UDim.new(0.5, 0)

	local accent = Instance.new("Frame")
	accent.Name = "AccentGlow"
	accent.Size = UDim2.new(0, 6, 0.9, 0)
	accent.Position = UDim2.new(0, 0, 0.5, 0)
	accent.AnchorPoint = Vector2.new(0, 0.5)
	accent.BackgroundColor3 = config.accent or Theme.Accent
	accent.Parent = button
	accent.Visible = false
	Instance.new("UICorner", accent).CornerRadius = UDim.new(0.5, 0)

	local textContainer = Instance.new("Frame")
	textContainer.Name = "TextContainer"
	textContainer.BackgroundTransparency = 1
	textContainer.Size = UDim2.new(1, -30, 1, -20)
	textContainer.Position = UDim2.new(0, 24, 0, 10)
	textContainer.Parent = button

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Text = config.label
	titleLabel.TextColor3 = Theme.TextSecondary
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 20
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Size = UDim2.new(1, 0, 0, 32)
	titleLabel.Parent = textContainer

	local subtitleLabel = Instance.new("TextLabel")
	subtitleLabel.Name = "Subtitle"
	subtitleLabel.Text = config.subtitle
	subtitleLabel.TextColor3 = Theme.Disabled
	subtitleLabel.Font = Enum.Font.Gotham
	subtitleLabel.TextSize = 14
	subtitleLabel.BackgroundTransparency = 1
	subtitleLabel.TextWrapped = true
	subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	subtitleLabel.Size = UDim2.new(1, 0, 0, 34)
	subtitleLabel.Position = UDim2.new(0, 0, 0, 34)
	subtitleLabel.Parent = textContainer

	button.MouseEnter:Connect(function()
		if currentPanelKey ~= key and button.Parent then
			TweenService:Create(button, tweenInfoEnter, {BackgroundTransparency = 0.1}):Play()
		end
	end)
	button.MouseLeave:Connect(function()
		if currentPanelKey ~= key and button.Parent then
			TweenService:Create(button, tweenInfoLeave, {BackgroundTransparency = 0.2}):Play()
		end
	end)
	button.MouseButton1Click:Connect(function()
		SwitchPanel(key)
	end)

	navButtons[key] = {
		button = button,
		accent = accent,
		titleLabel = titleLabel,
		subtitleLabel = subtitleLabel,
		halo = halo
	}
end

local function BuildMainInterface()
	mainShell = Instance.new("Frame")
	mainShell.Name = "NeoMainMenuShell"
	mainShell.Size = UDim2.new(1, 0, 1, 0)
	mainShell.BackgroundColor3 = Theme.Background
	mainShell.BackgroundTransparency = 0
	mainShell.Visible = false
	mainShell.Parent = screenGui

	local gradient = Instance.new("UIGradient", mainShell)
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Theme.Background),
		ColorSequenceKeypoint.new(0.4, Theme.GlassOverlay),
		ColorSequenceKeypoint.new(1, Theme.Background)
	})
	gradient.Rotation = 35

	local glass = Instance.new("Frame")
	glass.Name = "GlassFrame"
	glass.Size = UDim2.new(0.88, 0, 0.85, 0)
	glass.Position = UDim2.new(0.5, 0, 0.5, 0)
	glass.AnchorPoint = Vector2.new(0.5, 0.5)
	glass.BackgroundColor3 = Theme.PrimaryUI
	glass.BackgroundTransparency = 0.25
	glass.Parent = mainShell

	local glassCorner = Instance.new("UICorner", glass)
	glassCorner.CornerRadius = UDim.new(0, 28)

	local glassStroke = Instance.new("UIStroke", glass)
	glassStroke.Color = Theme.OutlineSoft
	glassStroke.Transparency = 0.4
	glassStroke.Thickness = 1.5

	local glassGradient = Instance.new("UIGradient", glass)
	glassGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Theme.PrimaryUI_Light),
		ColorSequenceKeypoint.new(1, Theme.PrimaryUI)
	})
	glassGradient.Rotation = 90

	local glassPadding = Instance.new("UIPadding", glass)
	glassPadding.PaddingTop = UDim.new(0, 28)
	glassPadding.PaddingBottom = UDim.new(0, 28)
	glassPadding.PaddingLeft = UDim.new(0, 28)
	glassPadding.PaddingRight = UDim.new(0, 28)

	local layout = Instance.new("UIListLayout", glass)
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	layout.VerticalAlignment = Enum.VerticalAlignment.Top
	layout.Padding = UDim.new(0, 24)

	navContainer = Instance.new("Frame")
	navContainer.Name = "Navigation"
	navContainer.Size = UDim2.new(0, 260, 1, 0)
	navContainer.BackgroundTransparency = 1
	navContainer.Parent = glass

	local navHeader = Instance.new("TextLabel")
	navHeader.Name = "NavHeader"
	navHeader.Text = "МЕТРОКОМ+"
	navHeader.Font = Enum.Font.GothamBlack
	navHeader.TextSize = 32
	navHeader.TextColor3 = Theme.TextPrimary
	navHeader.BackgroundTransparency = 1
	navHeader.TextXAlignment = Enum.TextXAlignment.Left
	navHeader.Size = UDim2.new(1, 0, 0, 48)
	navHeader.Parent = navContainer

	local navSubtitle = Instance.new("TextLabel")
	navSubtitle.Name = "NavSubtitle"
	navSubtitle.Text = "Центр управління мережі"
	navSubtitle.Font = Enum.Font.Gotham
	navSubtitle.TextSize = 15
	navSubtitle.TextColor3 = Theme.TextSecondary
	navSubtitle.BackgroundTransparency = 1
	navSubtitle.TextXAlignment = Enum.TextXAlignment.Left
	navSubtitle.Size = UDim2.new(1, 0, 0, 28)
	navSubtitle.Position = UDim2.new(0, 0, 0, 44)
	navSubtitle.Parent = navContainer

	local navListFrame = Instance.new("Frame")
	navListFrame.Name = "NavList"
	navListFrame.BackgroundTransparency = 1
	navListFrame.Size = UDim2.new(1, 0, 1, -96)
	navListFrame.Position = UDim2.new(0, 0, 0, 90)
	navListFrame.Parent = navContainer

	local navListLayout = Instance.new("UIListLayout", navListFrame)
	navListLayout.Padding = UDim.new(0, 12)
	navListLayout.FillDirection = Enum.FillDirection.Vertical
	navListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	navListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

	detailShell = Instance.new("Frame")
	detailShell.Name = "DetailShell"
	detailShell.Size = UDim2.new(0.46, 0, 1, 0)
	detailShell.BackgroundTransparency = 1
	detailShell.Parent = glass

	local detailHeader = Instance.new("Frame")
	detailHeader.Name = "DetailHeader"
	detailHeader.Size = UDim2.new(1, 0, 0, 96)
	detailHeader.BackgroundTransparency = 1
	detailHeader.Parent = detailShell

	detailAccentLine = Instance.new("Frame", detailHeader)
	detailAccentLine.Name = "Accent"
	detailAccentLine.Size = UDim2.new(0, 6, 0, 48)
	detailAccentLine.Position = UDim2.new(0, -18, 0, 24)
	detailAccentLine.BackgroundColor3 = Theme.Accent
	detailAccentLine.BorderSizePixel = 0
	Instance.new("UICorner", detailAccentLine).CornerRadius = UDim.new(0.5, 0)

	detailTitleLabel = Instance.new("TextLabel")
	detailTitleLabel.Name = "DetailTitle"
	detailTitleLabel.BackgroundTransparency = 1
	detailTitleLabel.Font = Enum.Font.GothamBold
	detailTitleLabel.TextSize = 30
	detailTitleLabel.TextColor3 = Theme.TextPrimary
	detailTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	detailTitleLabel.Size = UDim2.new(1, 0, 0, 42)
	detailTitleLabel.Position = UDim2.new(0, 0, 0, 6)
	detailTitleLabel.Parent = detailHeader

	detailSubtitleLabel = Instance.new("TextLabel")
	detailSubtitleLabel.Name = "DetailSubtitle"
	detailSubtitleLabel.BackgroundTransparency = 1
	detailSubtitleLabel.Font = Enum.Font.Gotham
	detailSubtitleLabel.TextSize = 16
	detailSubtitleLabel.TextWrapped = true
	detailSubtitleLabel.TextColor3 = Theme.TextSecondary
	detailSubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	detailSubtitleLabel.Size = UDim2.new(1, -20, 0, 40)
	detailSubtitleLabel.Position = UDim2.new(0, 0, 0, 50)
	detailSubtitleLabel.Parent = detailHeader

	detailContainer = Instance.new("Frame")
	detailContainer.Name = "DetailContainer"
	detailContainer.BackgroundTransparency = 1
	detailContainer.Size = UDim2.new(1, 0, 1, -110)
	detailContainer.Position = UDim2.new(0, 0, 0, 110)
	detailContainer.Parent = detailShell

	local detailPadding = Instance.new("UIPadding", detailContainer)
	detailPadding.PaddingTop = UDim.new(0, 0)
	detailPadding.PaddingBottom = UDim.new(0, 16)
	detailPadding.PaddingRight = UDim.new(0, 12)

	heroPanel = Instance.new("Frame")
	heroPanel.Name = "HeroPanel"
	heroPanel.Size = UDim2.new(0.36, 0, 1, 0)
	heroPanel.BackgroundColor3 = Theme.PrimaryUI_Light
	heroPanel.BackgroundTransparency = 0.15
	heroPanel.Parent = glass

	local heroCorner = Instance.new("UICorner", heroPanel)
	heroCorner.CornerRadius = UDim.new(0, 22)

	local heroStroke = Instance.new("UIStroke", heroPanel)
	heroStroke.Color = Theme.OutlineSoft
	heroStroke.Transparency = 0.55
	heroStroke.Thickness = 1.2

	local heroPadding = Instance.new("UIPadding", heroPanel)
	heroPadding.PaddingTop = UDim.new(0, 32)
	heroPadding.PaddingLeft = UDim.new(0, 28)
	heroPadding.PaddingRight = UDim.new(0, 28)
	heroPadding.PaddingBottom = UDim.new(0, 32)

	heroHalo = Instance.new("Frame", heroPanel)
	heroHalo.Name = "HeroHalo"
	heroHalo.Size = UDim2.new(0, 120, 0, 120)
	heroHalo.AnchorPoint = Vector2.new(0.5, 0)
	heroHalo.Position = UDim2.new(0.5, 0, 0, -40)
	heroHalo.BackgroundColor3 = Theme.Accent
	heroHalo.BackgroundTransparency = 0.85
	Instance.new("UICorner", heroHalo).CornerRadius = UDim.new(1, 0)

	heroTitleLabel = Instance.new("TextLabel")
	heroTitleLabel.Name = "HeroTitle"
	heroTitleLabel.Font = Enum.Font.GothamBold
	heroTitleLabel.TextSize = 26
	heroTitleLabel.TextColor3 = Theme.TextPrimary
	heroTitleLabel.BackgroundTransparency = 1
	heroTitleLabel.TextWrapped = true
	heroTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	heroTitleLabel.Size = UDim2.new(1, 0, 0, 72)
	heroTitleLabel.Parent = heroPanel

	heroSubtitleLabel = Instance.new("TextLabel")
	heroSubtitleLabel.Name = "HeroSubtitle"
	heroSubtitleLabel.Font = Enum.Font.Gotham
	heroSubtitleLabel.TextSize = 17
	heroSubtitleLabel.TextColor3 = Theme.TextSecondary
	heroSubtitleLabel.BackgroundTransparency = 1
	heroSubtitleLabel.TextWrapped = true
	heroSubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	heroSubtitleLabel.Size = UDim2.new(1, 0, 0, 90)
	heroSubtitleLabel.Position = UDim2.new(0, 0, 0, 80)
	heroSubtitleLabel.Parent = heroPanel

	heroChipsContainer = Instance.new("Frame")
	heroChipsContainer.Name = "HeroChips"
	heroChipsContainer.BackgroundTransparency = 1
	heroChipsContainer.Size = UDim2.new(1, 0, 0, 120)
	heroChipsContainer.Position = UDim2.new(0, 0, 0, 188)
	heroChipsContainer.Parent = heroPanel

	local chipsLayout = Instance.new("UIListLayout", heroChipsContainer)
	chipsLayout.FillDirection = Enum.FillDirection.Vertical
	chipsLayout.Padding = UDim.new(0, 8)
	chipsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	chipsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	chipsLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local chipsPadding = Instance.new("UIPadding", heroChipsContainer)
	chipsPadding.PaddingTop = UDim.new(0, 8)
	chipsPadding.PaddingBottom = UDim.new(0, 8)
	chipsPadding.PaddingRight = UDim.new(0, 0)
	chipsPadding.PaddingLeft = UDim.new(0, 0)

	for _, key in ipairs(orderedPanelKeys) do
		local config = panelsConfig[key]
		buildNavButton(navListFrame, key, config)
	end

	mainShell.BackgroundTransparency = 1
end

local function UpdatePlaySummary()
	if not playSummaryLabel then return end
	local roleText = selectedRoleData and selectedRoleData.Text or "Не обрано"
	local stationText = selectedStationData and selectedStationData.Name or "Не обрано"
	playSummaryLabel.Text = string.format("Роль: %s    •    Станція: %s", roleText, stationText)
end

local function EvaluateSpawnPermission()
	local roleSelected = selectedRoleData ~= nil
	local stationSelected = selectedStationData ~= nil
	local roleMatchesStation = true

	if stationSelected and selectedStationData.RequiredRole then
		roleMatchesStation = roleSelected and (selectedStationData.RequiredRole == selectedRoleData.Text)
	end

	local stationRequirementMet = stationSelected

	local dspStationValid = true
	if roleSelected and selectedRoleData.TeamName == "ЧПС" then
		if not stationSelected or not selectedStationData.IsDspStation then
			dspStationValid = false
		end
	end

	local dspStationOccupied = false
	if roleSelected and selectedRoleData.TeamName == "ЧПС" and stationSelected then
		local dspTeam = Teams:FindFirstChild("ЧПС")
		local attributeName = selectedStationData.SpawnerName .. "_OccupiedBy"
		local occupier = dspTeam and dspTeam:GetAttribute(attributeName)
		if occupier and occupier > 0 and occupier ~= player.UserId then
			dspStationOccupied = true
		end
	end

	local roleLimitOk = true
	if roleSelected and selectedRoleData.MaxPlayers and selectedRoleData.MaxPlayers > 0 then
		local team = Teams:FindFirstChild(selectedRoleData.TeamName)
		if team then
			local currentPlayers = #team:GetPlayers()
			local playerIsInTeam = (player.Team == team)
			if currentPlayers >= selectedRoleData.MaxPlayers and not playerIsInTeam then
				roleLimitOk = false
			end
		end
	end

	local expRequirementMet = true
	if roleSelected and selectedRoleData.RequiredEXP and expStat.Value < selectedRoleData.RequiredEXP then
		expRequirementMet = false
	end

	return roleSelected and stationRequirementMet and roleMatchesStation and dspStationValid and not dspStationOccupied and roleLimitOk and expRequirementMet
end

function UpdateSpawnButtonState()
	if not finalPlayButton or not finalPlayButton.Parent then return end
	local canPlay = EvaluateSpawnPermission()
	local stroke = finalPlayButton:FindFirstChildOfClass("UIStroke")

	if canPlay then
		TweenService:Create(finalPlayButton, tweenInfoEnter, { BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Background }):Play()
		if stroke then TweenService:Create(stroke, tweenInfoEnter, { Color = Theme.Accent, Transparency = 1 }):Play() end
		finalPlayButton.Active = true
		finalPlayButton.Selectable = true
	else
		TweenService:Create(finalPlayButton, tweenInfoLeave, { BackgroundColor3 = Theme.PrimaryUI_Light, TextColor3 = Theme.Disabled }):Play()
		if stroke then TweenService:Create(stroke, tweenInfoLeave, { Color = Theme.Disabled, Transparency = 0.3 }):Play() end
		finalPlayButton.Active = false
		finalPlayButton.Selectable = false
	end
end

function UpdateSpawnButtonText()
	if not finalPlayButton or not finalPlayButton.Parent then return end
	if selectedRoleData then
		if selectedRoleData.TeamName == "Machinist" then
			finalPlayButton.Text = "ВИЇХАТИ"
		elseif selectedRoleData.TeamName == "Passanger" then
			finalPlayButton.Text = "В ДОРОГУ"
		else
			finalPlayButton.Text = "ПОСТУПИТИ НА ЗМІНУ"
		end
	else
		finalPlayButton.Text = "ВИЇХАТИ"
	end
end

function UpdateRoleButtonsVisuals()
	if next(roleButtonElements) == nil then return end

	for teamNameKey, elements in pairs(roleButtonElements) do
		local roleData = elements.data
		local titleLabel = elements.titleLabel
		local taglineLabel = elements.taglineLabel
		local metaLabel = elements.metaLabel
		local frame = elements.frame
		local accent = elements.accent
		local button = elements.button

		-- Перевірка чи елементи ще існують
		if not frame or not frame.Parent then continue end

		local canSelect = true
		local isUnavailable = roleData.Unavailable == true
		local metaInfo = {}

		local team = Teams:FindFirstChild(roleData.TeamName)
		if roleData.MaxPlayers and roleData.MaxPlayers > 0 then
			local currentPlayers = team and #team:GetPlayers() or 0
			table.insert(metaInfo, string.format("%d / %d у зміні", currentPlayers, roleData.MaxPlayers))
			local playerIsInTeam = team and player.Team == team
			if currentPlayers >= roleData.MaxPlayers and not playerIsInTeam then
				canSelect = false
			end
		end

		if roleData.RequiredEXP then
			table.insert(metaInfo, string.format("Потрібно %d EXP", roleData.RequiredEXP))
			if expStat.Value < roleData.RequiredEXP then
				canSelect = false
			end
		end

		if isUnavailable then
			canSelect = false
			metaLabel.Text = "⚠️ ТИМЧАСОВО НЕДОСТУПНО"
			metaLabel.TextColor3 = Theme.Error
		else
			metaLabel.Text = (#metaInfo > 0) and table.concat(metaInfo, "  •  ") or "Без обмежень"
		end

		button.Active = canSelect
		local isSelected = selectedRoleData and selectedRoleData.TeamName == roleData.TeamName

		if not canSelect then
			TweenService:Create(frame, tweenInfoLeave, { BackgroundColor3 = Theme.PrimaryUI, BackgroundTransparency = 0.45 }):Play()
			TweenService:Create(titleLabel, tweenInfoLeave, { TextColor3 = Theme.Disabled }):Play()
			TweenService:Create(taglineLabel, tweenInfoLeave, { TextColor3 = Theme.Disabled }):Play()
			local metaColor = isUnavailable and Theme.Error or Theme.Disabled
			TweenService:Create(metaLabel, tweenInfoLeave, { TextColor3 = metaColor }):Play()
			TweenService:Create(accent, tweenInfoLeave, { BackgroundColor3 = Theme.Disabled }):Play()

			if isSelected then
				selectedRoleData = nil
			end
		elseif isSelected then
			TweenService:Create(frame, tweenInfoEnter, { BackgroundColor3 = roleData.Color, BackgroundTransparency = 0.05 }):Play()
			TweenService:Create(titleLabel, tweenInfoEnter, { TextColor3 = Theme.Background }):Play()
			TweenService:Create(taglineLabel, tweenInfoEnter, { TextColor3 = Theme.Background }):Play()
			TweenService:Create(metaLabel, tweenInfoEnter, { TextColor3 = Theme.Background }):Play()
			TweenService:Create(accent, tweenInfoEnter, { BackgroundColor3 = Theme.Background }):Play()
		else
			TweenService:Create(frame, tweenInfoLeave, { BackgroundColor3 = Theme.PrimaryUI, BackgroundTransparency = 0.15 }):Play()
			TweenService:Create(titleLabel, tweenInfoLeave, { TextColor3 = roleData.Color }):Play()
			TweenService:Create(taglineLabel, tweenInfoLeave, { TextColor3 = Theme.TextSecondary }):Play()
			TweenService:Create(metaLabel, tweenInfoLeave, { TextColor3 = Theme.TextSecondary }):Play()
			TweenService:Create(accent, tweenInfoLeave, { BackgroundColor3 = roleData.Color }):Play()
		end
	end
end

function SelectRole(cardFrame, roleData)
	if selectedRoleData and selectedRoleData.TeamName == roleData.TeamName then
		selectedRoleData = nil
	else
		selectedRoleData = roleData
	end
	UpdateRoleButtonsVisuals()
	UpdatePlaySummary()
	UpdateSpawnButtonState()
	UpdateSpawnButtonText()
end

local function setStationCardState(elements, state)
	if not elements or not elements.frame or not elements.frame.Parent then return end

	local frame = elements.frame
	local badge = elements.badge
	local titleLabel = elements.titleLabel
	local codeLabel = elements.codeLabel
	local statusLabel = elements.statusLabel
	local baseColor = elements.baseColor

	if state == "selected" then
		TweenService:Create(frame, tweenInfoEnter, { BackgroundColor3 = Theme.StationSelected, BackgroundTransparency = 0.05 }):Play()
		TweenService:Create(badge, tweenInfoEnter, { BackgroundColor3 = Theme.Background, Size = UDim2.new(0, 18, 0, 18) }):Play()
		TweenService:Create(titleLabel, tweenInfoEnter, { TextColor3 = Theme.Background }):Play()
		TweenService:Create(codeLabel, tweenInfoEnter, { TextColor3 = Theme.Background }):Play()
		TweenService:Create(statusLabel, tweenInfoEnter, { TextColor3 = Theme.Background }):Play()
	elseif state == "disabled" then
		TweenService:Create(frame, tweenInfoLeave, { BackgroundColor3 = Theme.PrimaryUI, BackgroundTransparency = 0.45 }):Play()
		TweenService:Create(badge, tweenInfoLeave, { BackgroundColor3 = Theme.Error, Size = UDim2.new(0, 16, 0, 16) }):Play()
		TweenService:Create(titleLabel, tweenInfoLeave, { TextColor3 = Theme.Error }):Play()
		TweenService:Create(codeLabel, tweenInfoLeave, { TextColor3 = Theme.Error }):Play()
		TweenService:Create(statusLabel, tweenInfoLeave, { TextColor3 = Theme.Error }):Play()
	else
		TweenService:Create(frame, tweenInfoLeave, { BackgroundColor3 = Theme.PrimaryUI, BackgroundTransparency = 0.2 }):Play()
		TweenService:Create(badge, tweenInfoLeave, { BackgroundColor3 = baseColor, Size = UDim2.new(0, 14, 0, 14) }):Play()
		TweenService:Create(titleLabel, tweenInfoLeave, { TextColor3 = Theme.TextPrimary }):Play()
		TweenService:Create(codeLabel, tweenInfoLeave, { TextColor3 = Theme.TextSecondary }):Play()
		TweenService:Create(statusLabel, tweenInfoLeave, { TextColor3 = Theme.TextSecondary }):Play()
	end
	elements.state = state
end

local function SelectStation(button, stationData)
	if selectedStationCircle and stationGuiElementsMap[selectedStationCircle] then
		local previous = stationGuiElementsMap[selectedStationCircle]
		if previous.state ~= "disabled" then
			setStationCardState(previous, "idle")
		end
	end
	selectedStationCircle = button
	selectedStationData = stationData
	local current = stationGuiElementsMap[button]
	if current then
		setStationCardState(current, "selected")
	end
	UpdatePlaySummary()
	UpdateSpawnButtonState()
end

function UpdateDspStationAvailability()
	for button, elements in pairs(stationGuiElementsMap) do
		if not elements or not elements.frame or not elements.frame.Parent then continue end

		local stationData = elements.data
		if stationData.IsDspStation then
			local dspTeam = Teams:FindFirstChild("ЧПС")
			local attributeName = stationData.SpawnerName .. "_OccupiedBy"
			local occupier = dspTeam and dspTeam:GetAttribute(attributeName)
			if occupier and occupier > 0 and occupier ~= player.UserId then
				elements.button:SetAttribute("IsOccupied", true)
				elements.statusLabel.Text = "Зайнята"
				if selectedStationCircle == button then
					selectedStationCircle = nil
					selectedStationData = nil
				end
				setStationCardState(elements, "disabled")
			else
				elements.button:SetAttribute("IsOccupied", false)
				elements.statusLabel.Text = stationData.IsTerminal and "Тупік" or "Вільна"
				if elements.state ~= "selected" then
					setStationCardState(elements, "idle")
				end
			end
		else
			if elements.state ~= "selected" then
				setStationCardState(elements, "idle")
			end
		end
	end
	UpdatePlaySummary()
	UpdateSpawnButtonState()
end

local function TryFinalizeSpawn()
	if not finalPlayButton then return end
	if not finalPlayButton.Active then
		local isShaking = finalPlayButton:GetAttribute("isShaking")
		if not isShaking then
			finalPlayButton:SetAttribute("isShaking", true)
			local origin = finalPlayButton.Position
			local tween = TweenService:Create(finalPlayButton, shakeTweenInfo, { Position = origin + UDim2.new(0, 6, 0, 0) })
			tween.Completed:Connect(function()
				if finalPlayButton and finalPlayButton.Parent then
					finalPlayButton.Position = origin
					finalPlayButton:SetAttribute("isShaking", nil)
				end
			end)
			tween:Play()
		end
		return
	end

	if not selectedRoleData then
		UpdateSpawnButtonState()
		return
	end

	local teamToRequest = selectedRoleData.TeamName
	local stationNameToRequest = selectedStationData and selectedStationData.SpawnerName or nil

	if teamToRequest then
		local spawnSound = Instance.new("Sound")
		spawnSound.SoundId = "rbxassetid://12221944"
		spawnSound.Parent = Workspace
		spawnSound:Play()
		spawnSound.Ended:Connect(function()
			if spawnSound and spawnSound.Parent then
				spawnSound:Destroy()
			end
		end)

		changeTeamEvent:FireServer(teamToRequest, stationNameToRequest)
		hasStartedPlaying = true
		CloseMainMenu()
	end
end

function BuildPlayPanel(container)
	roleButtonElements = {}
	stationGuiElementsMap = {}
	selectedRoleData = nil
	selectedStationData = nil
	selectedStationCircle = nil
	playSummaryLabel = nil

	if finalPlayButtonConnection then
		finalPlayButtonConnection:Disconnect()
		finalPlayButtonConnection = nil
	end
	finalPlayButton = nil

	local columnsFrame = Instance.new("Frame")
	columnsFrame.Name = "Columns"
	columnsFrame.Size = UDim2.new(1, 0, 1, -90)
	columnsFrame.BackgroundTransparency = 1
	columnsFrame.Parent = container

	local columnsLayout = Instance.new("UIListLayout", columnsFrame)
	columnsLayout.FillDirection = Enum.FillDirection.Horizontal
	columnsLayout.Padding = UDim.new(0, 18)
	columnsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	columnsLayout.VerticalAlignment = Enum.VerticalAlignment.Top

	local rolesColumn = Instance.new("Frame", columnsFrame)
	rolesColumn.Name = "RolesColumn"
	rolesColumn.Size = UDim2.new(0.46, 0, 1, 0)
	rolesColumn.BackgroundColor3 = Theme.PrimaryUI
	rolesColumn.BackgroundTransparency = 0.2
	Instance.new("UICorner", rolesColumn).CornerRadius = UDim.new(0, 18)

	local rolesStroke = Instance.new("UIStroke", rolesColumn)
	rolesStroke.Color = Theme.OutlineSoft
	rolesStroke.Transparency = 0.4

	local rolesPadding = Instance.new("UIPadding", rolesColumn)
	rolesPadding.PaddingTop = UDim.new(0, 20)
	rolesPadding.PaddingBottom = UDim.new(0, 20)
	rolesPadding.PaddingLeft = UDim.new(0, 20)
	rolesPadding.PaddingRight = UDim.new(0, 14)

	local rolesTitle = Instance.new("TextLabel", rolesColumn)
	rolesTitle.Text = "РОЛІ"
	rolesTitle.Font = Enum.Font.GothamBold
	rolesTitle.TextSize = 22
	rolesTitle.TextColor3 = Theme.TextPrimary
	rolesTitle.BackgroundTransparency = 1
	rolesTitle.TextXAlignment = Enum.TextXAlignment.Left
	rolesTitle.Size = UDim2.new(1, 0, 0, 28)

	local rolesSubtitle = Instance.new("TextLabel", rolesColumn)
	rolesSubtitle.Text = "Виберіть, за кого хочете грати"
	rolesSubtitle.Font = Enum.Font.Gotham
	rolesSubtitle.TextSize = 15
	rolesSubtitle.TextColor3 = Theme.TextSecondary
	rolesSubtitle.BackgroundTransparency = 1
	rolesSubtitle.TextXAlignment = Enum.TextXAlignment.Left
	rolesSubtitle.Size = UDim2.new(1, 0, 0, 24)
	rolesSubtitle.Position = UDim2.new(0, 0, 0, 28)

	local rolesScroll = Instance.new("ScrollingFrame", rolesColumn)
	rolesScroll.Name = "RolesScroll"
	rolesScroll.Size = UDim2.new(1, -6, 1, -70)
	rolesScroll.Position = UDim2.new(0, 0, 0, 60)
	rolesScroll.BackgroundTransparency = 1
	rolesScroll.BorderSizePixel = 0
	rolesScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	rolesScroll.CanvasSize = UDim2.new()
	rolesScroll.ScrollBarThickness = 4

	local rolesListLayout = Instance.new("UIListLayout", rolesScroll)
	rolesListLayout.FillDirection = Enum.FillDirection.Vertical
	rolesListLayout.Padding = UDim.new(0, 12)
	rolesListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	rolesListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

	for _, roleDataItem in ipairs(rolesData) do
		local card = Instance.new("Frame", rolesScroll)
		card.Name = roleDataItem.TeamName .. "Card"
		card.Size = UDim2.new(1, -6, 0, 96)
		card.BackgroundColor3 = Theme.PrimaryUI
		card.BackgroundTransparency = 0.15
		Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)

		local accent = Instance.new("Frame", card)
		accent.Name = "Accent"
		accent.Size = UDim2.new(0, 6, 1, -24)
		accent.Position = UDim2.new(0, -10, 0, 12)
		accent.BackgroundColor3 = roleDataItem.Color
		accent.BorderSizePixel = 0
		Instance.new("UICorner", accent).CornerRadius = UDim.new(0.5, 0)

		local cardPadding = Instance.new("UIPadding", card)
		cardPadding.PaddingTop = UDim.new(0, 12)
		cardPadding.PaddingBottom = UDim.new(0, 12)
		cardPadding.PaddingLeft = UDim.new(0, 18)
		cardPadding.PaddingRight = UDim.new(0, 18)

		local titleLabel = Instance.new("TextLabel", card)
		titleLabel.Text = roleDataItem.Text
		titleLabel.Font = Enum.Font.GothamBold
		titleLabel.TextSize = 20
		titleLabel.TextColor3 = roleDataItem.Color
		titleLabel.BackgroundTransparency = 1
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.Size = UDim2.new(1, 0, 0, 26)

		local taglineLabel = Instance.new("TextLabel", card)
		taglineLabel.Text = roleDataItem.Tagline or ""
		taglineLabel.Font = Enum.Font.Gotham
		taglineLabel.TextSize = 14
		taglineLabel.TextColor3 = Theme.TextSecondary
		taglineLabel.BackgroundTransparency = 1
		taglineLabel.TextWrapped = true
		taglineLabel.TextXAlignment = Enum.TextXAlignment.Left
		taglineLabel.Size = UDim2.new(1, 0, 0, 34)
		taglineLabel.Position = UDim2.new(0, 0, 0, 28)

		local metaLabel = Instance.new("TextLabel", card)
		metaLabel.Text = ""
		metaLabel.Font = Enum.Font.GothamMedium
		metaLabel.TextSize = 13
		metaLabel.TextColor3 = Theme.TextSecondary
		metaLabel.BackgroundTransparency = 1
		metaLabel.TextXAlignment = Enum.TextXAlignment.Left
		metaLabel.Size = UDim2.new(1, 0, 0, 18)
		metaLabel.Position = UDim2.new(0, 0, 0, 62)

		local button = Instance.new("TextButton", card)
		button.BackgroundTransparency = 1
		button.Size = UDim2.new(1, 0, 1, 0)
		button.Text = ""
		button.AutoButtonColor = false
		button.MouseButton1Click:Connect(function()
			if button.Active then
				SelectRole(card, roleDataItem)
			end
		end)

		roleButtonElements[roleDataItem.TeamName] = {
			frame = card,
			accent = accent,
			titleLabel = titleLabel,
			taglineLabel = taglineLabel,
			metaLabel = metaLabel,
			button = button,
			data = roleDataItem
		}
	end

	local stationsColumn = Instance.new("Frame", columnsFrame)
	stationsColumn.Name = "StationsColumn"
	stationsColumn.Size = UDim2.new(0.54, -18, 1, 0)
	stationsColumn.BackgroundColor3 = Theme.PrimaryUI
	stationsColumn.BackgroundTransparency = 0.2
	Instance.new("UICorner", stationsColumn).CornerRadius = UDim.new(0, 18)

	local stationsStroke = Instance.new("UIStroke", stationsColumn)
	stationsStroke.Color = Theme.OutlineSoft
	stationsStroke.Transparency = 0.4

	local stationsPadding = Instance.new("UIPadding", stationsColumn)
	stationsPadding.PaddingTop = UDim.new(0, 20)
	stationsPadding.PaddingBottom = UDim.new(0, 20)
	stationsPadding.PaddingLeft = UDim.new(0, 26)
	stationsPadding.PaddingRight = UDim.new(0, 26)

	local stationsTitle = Instance.new("TextLabel", stationsColumn)
	stationsTitle.Text = "СХЕМА ЛІНІЇ"
	stationsTitle.Font = Enum.Font.GothamBold
	stationsTitle.TextSize = 22
	stationsTitle.TextColor3 = Theme.TextPrimary
	stationsTitle.BackgroundTransparency = 1
	stationsTitle.TextXAlignment = Enum.TextXAlignment.Left
	stationsTitle.Size = UDim2.new(1, 0, 0, 28)

	local stationsSubtitle = Instance.new("TextLabel", stationsColumn)
	stationsSubtitle.Text = "Оберіть станцію"
	stationsSubtitle.Font = Enum.Font.Gotham
	stationsSubtitle.TextSize = 15
	stationsSubtitle.TextColor3 = Theme.TextSecondary
	stationsSubtitle.BackgroundTransparency = 1
	stationsSubtitle.TextXAlignment = Enum.TextXAlignment.Left
	stationsSubtitle.Size = UDim2.new(1, 0, 0, 24)
	stationsSubtitle.Position = UDim2.new(0, 0, 0, 28)

	local stationsScroll = Instance.new("ScrollingFrame", stationsColumn)
	stationsScroll.Name = "StationsScroll"
	stationsScroll.Size = UDim2.new(1, 0, 1, -72)
	stationsScroll.Position = UDim2.new(0, 0, 0, 60)
	stationsScroll.BackgroundTransparency = 1
	stationsScroll.BorderSizePixel = 0
	stationsScroll.ScrollBarThickness = 4
	stationsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	stationsScroll.CanvasSize = UDim2.new()

	local stationListLayout = Instance.new("UIListLayout", stationsScroll)
	stationListLayout.FillDirection = Enum.FillDirection.Vertical
	stationListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	stationListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	stationListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	stationListLayout.Padding = UDim.new(0, 10)

	local lineAccentColor = Color3.fromRGB(205, 0, 0)

	for index, stationData in ipairs(stationsData) do
		local card = Instance.new("Frame", stationsScroll)
		card.Name = stationData.SpawnerName .. "Card"
		card.Size = UDim2.new(1, -6, 0, 70)
		card.BackgroundColor3 = Theme.PrimaryUI
		card.BackgroundTransparency = 0.2
		card.LayoutOrder = index
		Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

		local cardPadding = Instance.new("UIPadding", card)
		cardPadding.PaddingTop = UDim.new(0, 12)
		cardPadding.PaddingBottom = UDim.new(0, 12)
		cardPadding.PaddingLeft = UDim.new(0, 52)
		cardPadding.PaddingRight = UDim.new(0, 16)

		local line = Instance.new("Frame", card)
		line.Size = UDim2.new(0, 2, 1, 14)
		line.Position = UDim2.new(0, -26, 0, -7)
		line.BackgroundColor3 = lineAccentColor
		line.BorderSizePixel = 0

		local badge = Instance.new("Frame", card)
		badge.Name = "Badge"
		badge.Size = UDim2.new(0, 14, 0, 14)
		badge.Position = UDim2.new(0, -38, 0.5, 0)
		badge.AnchorPoint = Vector2.new(0.5, 0.5)
		badge.BackgroundColor3 = stationData.RequiredRole and Theme.Warning or (stationData.IsTerminal and Theme.Accent or lineAccentColor)
		badge.BorderSizePixel = 0
		Instance.new("UICorner", badge).CornerRadius = UDim.new(1, 0)

		local titleLabel = Instance.new("TextLabel", card)
		titleLabel.Text = stationData.Name
		titleLabel.Font = Enum.Font.GothamBold
		titleLabel.TextSize = 18
		titleLabel.TextColor3 = Theme.TextPrimary
		titleLabel.BackgroundTransparency = 1
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.Size = UDim2.new(1, 0, 0, 28)

		local codeLabel = Instance.new("TextLabel", card)
		codeLabel.Text = stationData.Code or ""
		codeLabel.Font = Enum.Font.GothamMedium
		codeLabel.TextSize = 14
		codeLabel.TextColor3 = Theme.TextSecondary
		codeLabel.BackgroundTransparency = 1
		codeLabel.TextXAlignment = Enum.TextXAlignment.Left
		codeLabel.Size = UDim2.new(0.6, 0, 0, 22)
		codeLabel.Position = UDim2.new(0, 0, 0, 32)

		local statusLabel = Instance.new("TextLabel", card)
		statusLabel.Text = stationData.IsTerminal and "Тупік" or (stationData.RequiredRole or "Вільна")
		statusLabel.Font = Enum.Font.Gotham
		statusLabel.TextSize = 13
		statusLabel.TextColor3 = Theme.TextSecondary
		statusLabel.BackgroundTransparency = 1
		statusLabel.TextXAlignment = Enum.TextXAlignment.Right
		statusLabel.Size = UDim2.new(0.4, 0, 0, 22)
		statusLabel.Position = UDim2.new(0.6, 0, 0, 32)

		local button = Instance.new("TextButton", card)
		button.BackgroundTransparency = 1
		button.Size = UDim2.new(1, 0, 1, 0)
		button.Text = ""
		button.AutoButtonColor = false
		button.MouseButton1Click:Connect(function()
			if button:GetAttribute("IsOccupied") then return end
			SelectStation(button, stationData)
		end)
		button:SetAttribute("IsOccupied", false)

		stationGuiElementsMap[button] = {
			frame = card,
			badge = badge,
			titleLabel = titleLabel,
			codeLabel = codeLabel,
			statusLabel = statusLabel,
			button = button,
			baseColor = badge.BackgroundColor3,
			data = stationData,
			state = "idle"
		}
	end

	local footer = Instance.new("Frame", container)
	footer.Name = "Footer"
	footer.Size = UDim2.new(1, 0, 0, 90)
	footer.Position = UDim2.new(0, 0, 1, -90)
	footer.BackgroundTransparency = 1

	local footerLayout = Instance.new("UIListLayout", footer)
	footerLayout.FillDirection = Enum.FillDirection.Horizontal
	footerLayout.Padding = UDim.new(0, 12)
	footerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	footerLayout.VerticalAlignment = Enum.VerticalAlignment.Center

	local summaryFrame = Instance.new("Frame", footer)
	summaryFrame.Size = UDim2.new(0.62, 0, 1, 0)
	summaryFrame.BackgroundTransparency = 1

	local summaryLabel = Instance.new("TextLabel", summaryFrame)
	summaryLabel.Size = UDim2.new(1, 0, 1, 0)
	summaryLabel.BackgroundTransparency = 1
	summaryLabel.Font = Enum.Font.Gotham
	summaryLabel.TextSize = 16
	summaryLabel.TextColor3 = Theme.TextSecondary
	summaryLabel.TextXAlignment = Enum.TextXAlignment.Left
	summaryLabel.Text = "Роль: Не обрано    •    Станція: Не обрано"
	playSummaryLabel = summaryLabel

	finalPlayButton = Instance.new("TextButton", footer)
	finalPlayButton.Name = "FinalPlay"
	finalPlayButton.Size = UDim2.new(0.35, 0, 0, 56)
	finalPlayButton.AutoButtonColor = false
	finalPlayButton.Font = Enum.Font.GothamBlack
	finalPlayButton.TextSize = 20
	finalPlayButton.TextColor3 = Theme.Disabled
	finalPlayButton.BackgroundColor3 = Theme.PrimaryUI_Light
	finalPlayButton.TextWrapped = true
	Instance.new("UICorner", finalPlayButton).CornerRadius = UDim.new(0, 14)

	local playStroke = Instance.new("UIStroke", finalPlayButton)
	playStroke.Color = Theme.Disabled
	playStroke.Thickness = 1.2

	finalPlayButtonConnection = finalPlayButton.MouseButton1Click:Connect(TryFinalizeSpawn)

	UpdateRoleButtonsVisuals()
	UpdateDspStationAvailability()
	UpdatePlaySummary()
	UpdateSpawnButtonState()
	UpdateSpawnButtonText()
	SetupTeamListeners()
end

function BuildUpdatesPanel(container)
	local scroll = Instance.new("ScrollingFrame", container)
	scroll.Name = "UpdatesScroll"
	scroll.Size = UDim2.new(1, 0, 1, 0)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new()
	scroll.ScrollBarThickness = 6

	local padding = Instance.new("UIPadding", scroll)
	padding.PaddingTop = UDim.new(0, 12)
	padding.PaddingBottom = UDim.new(0, 12)
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)

	local layout = Instance.new("UIListLayout", scroll)
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.Padding = UDim.new(0, 12)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	layout.VerticalAlignment = Enum.VerticalAlignment.Top

	for index, entryText in ipairs(changelogData) do
		local card = Instance.new("Frame", scroll)
		card.Name = "Update" .. index
		card.Size = UDim2.new(1, -12, 0, 72)
		card.BackgroundColor3 = Theme.PrimaryUI
		card.BackgroundTransparency = 0.18
		Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

		local cardPadding = Instance.new("UIPadding", card)
		cardPadding.PaddingTop = UDim.new(0, 12)
		cardPadding.PaddingBottom = UDim.new(0, 12)
		cardPadding.PaddingLeft = UDim.new(0, 18)
		cardPadding.PaddingRight = UDim.new(0, 18)

		local badge = Instance.new("TextLabel", card)
		badge.Size = UDim2.new(0, 44, 0, 44)
		badge.Position = UDim2.new(0, -12, 0, -2)
		badge.BackgroundColor3 = Theme.Accent
		badge.TextColor3 = Theme.Background
		badge.Text = string.format("%02d", index)
		badge.Font = Enum.Font.GothamBlack
		badge.TextSize = 18
		badge.TextXAlignment = Enum.TextXAlignment.Center
		badge.TextYAlignment = Enum.TextYAlignment.Center
		Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 10)

		local textLabel = Instance.new("TextLabel", card)
		textLabel.Size = UDim2.new(1, -60, 1, 0)
		textLabel.Position = UDim2.new(0, 52, 0, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.TextWrapped = true
		textLabel.Font = Enum.Font.Gotham
		textLabel.TextSize = 16
		textLabel.TextColor3 = Theme.TextSecondary
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.Text = entryText
	end
end

function BuildRulesPanel(container)
	local scroll = Instance.new("ScrollingFrame", container)
	scroll.Name = "RulesScroll"
	scroll.Size = UDim2.new(1, 0, 1, 0)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new()
	scroll.ScrollBarThickness = 6

	local padding = Instance.new("UIPadding", scroll)
	padding.PaddingTop = UDim.new(0, 10)
	padding.PaddingBottom = UDim.new(0, 10)
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)

	local layout = Instance.new("UIListLayout", scroll)
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.Padding = UDim.new(0, 10)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	layout.VerticalAlignment = Enum.VerticalAlignment.Top
	layout.SortOrder = Enum.SortOrder.LayoutOrder

	for order, item in ipairs(rulesData) do
		if item.type == "separator" then
			local spacer = Instance.new("Frame", scroll)
			spacer.Size = UDim2.new(1, 0, 0, 14)
			spacer.BackgroundTransparency = 1
			spacer.LayoutOrder = order
		elseif item.type == "subheader" then
			local header = Instance.new("TextLabel", scroll)
			header.Size = UDim2.new(1, -12, 0, 34)
			header.BackgroundTransparency = 1
			header.Font = Enum.Font.GothamBold
			header.TextSize = 22
			header.TextColor3 = Theme.TextPrimary
			header.TextXAlignment = Enum.TextXAlignment.Left
			header.Text = item.text
			header.LayoutOrder = order
		elseif item.type == "blockquote" then
			local quote = Instance.new("Frame", scroll)
			quote.Size = UDim2.new(1, -12, 0, 96)
			quote.BackgroundColor3 = Theme.PrimaryUI
			quote.BackgroundTransparency = 0.12
			quote.LayoutOrder = order
			Instance.new("UICorner", quote).CornerRadius = UDim.new(0, 14)

			local stripe = Instance.new("Frame", quote)
			stripe.Size = UDim2.new(0, 4, 1, -24)
			stripe.Position = UDim2.new(0, -8, 0, 12)
			stripe.BackgroundColor3 = Theme.Warning
			stripe.BorderSizePixel = 0

			local label = Instance.new("TextLabel", quote)
			label.RichText = true
			label.TextWrapped = true
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.GothamMedium
			label.TextSize = 18
			label.TextColor3 = Theme.TextSecondary
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Size = UDim2.new(1, -20, 1, -20)
			label.Position = UDim2.new(0, 16, 0, 10)
			label.Text = item.text
		else
			local ruleFrame = Instance.new("Frame", scroll)
			ruleFrame.Size = UDim2.new(1, -12, 0, 72)
			ruleFrame.BackgroundColor3 = Theme.PrimaryUI
			ruleFrame.BackgroundTransparency = item.type == "punishment" and 0.05 or 0.2
			ruleFrame.LayoutOrder = order
			Instance.new("UICorner", ruleFrame).CornerRadius = UDim.new(0, 10)

			local label = Instance.new("TextLabel", ruleFrame)
			label.RichText = true
			label.TextWrapped = true
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.Gotham
			label.TextSize = 16
			label.TextColor3 = (item.type == "punishment") and Theme.Error or Theme.TextSecondary
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Size = UDim2.new(1, -20, 1, -16)
			label.Position = UDim2.new(0, 12, 0, 8)
			label.Text = item.text
		end
	end
end

function BuildCreditsPanel(container)
	local scroll = Instance.new("ScrollingFrame", container)
	scroll.Name = "CreditsScroll"
	scroll.Size = UDim2.new(1, 0, 1, 0)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new()
	scroll.ScrollBarThickness = 6

	local padding = Instance.new("UIPadding", scroll)
	padding.PaddingTop = UDim.new(0, 12)
	padding.PaddingBottom = UDim.new(0, 12)
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)

	local layout = Instance.new("UIListLayout", scroll)
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.Padding = UDim.new(0, 24)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	layout.VerticalAlignment = Enum.VerticalAlignment.Top

	local sections = {
		{ Title = "Команда", Items = {
			"<b>LeoVerem12</b> — Овнер проєкту",
			"<b>Ezh_3y</b> — Розробник",
			"<b>DEN50678</b> — Розробник"
		}},
		{ Title = "Ресурси", Items = {
			"<b>Kyiv Metrostroi Team</b> — моделі потягів",
			"<b>ZefirLover</b> — таблички",
			"<b>Mint Type</b> — шрифт Proba Nav2",
			"<b>Агенти Змін</b> — навігація",
			"<b>Metrostroi Team</b> — рельси, звуки та інші ресурси"
		}}
	}

	if (month == 10 and day >= 27 and day <= 31) or (month == 11 and day == 3) then
		table.insert(sections[2].Items, "<b>time - feel so sleep</b> — сезонна композиція")
	end

	for _, section in ipairs(sections) do
		local sectionContainer = Instance.new("Frame", scroll)
		sectionContainer.Name = section.Title .. "Container"
		sectionContainer.BackgroundTransparency = 1
		sectionContainer.AutomaticSize = Enum.AutomaticSize.Y
		sectionContainer.Size = UDim2.new(1, 0, 0, 0)

		local sectionLayout = Instance.new("UIListLayout", sectionContainer)
		sectionLayout.FillDirection = Enum.FillDirection.Vertical
		sectionLayout.Padding = UDim.new(0, 8)
		sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder 

		local header = Instance.new("TextLabel", sectionContainer)
		header.Text = section.Title
		header.Font = Enum.Font.GothamBold
		header.TextSize = 20
		header.TextColor3 = Theme.TextPrimary
		header.BackgroundTransparency = 1
		header.TextXAlignment = Enum.TextXAlignment.Left
		header.Size = UDim2.new(1, -12, 0, 30)
		header.LayoutOrder = 1 

		local holder = Instance.new("Frame", sectionContainer)
		holder.Size = UDim2.new(1, -12, 0, 0)
		holder.BackgroundColor3 = Theme.PrimaryUI
		holder.BackgroundTransparency = 0.2
		holder.AutomaticSize = Enum.AutomaticSize.Y
		holder.LayoutOrder = 2 

		Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 12)

		local holderPadding = Instance.new("UIPadding", holder)
		holderPadding.PaddingTop = UDim.new(0, 14)
		holderPadding.PaddingBottom = UDim.new(0, 14)
		holderPadding.PaddingLeft = UDim.new(0, 18)
		holderPadding.PaddingRight = UDim.new(0, 18)

		local holderLayout = Instance.new("UIListLayout", holder)
		holderLayout.FillDirection = Enum.FillDirection.Vertical
		holderLayout.Padding = UDim.new(0, 8)

		for _, itemText in ipairs(section.Items) do
			local itemLabel = Instance.new("TextLabel", holder)
			itemLabel.RichText = true
			itemLabel.Text = "•  " .. itemText
			itemLabel.Font = Enum.Font.Gotham
			itemLabel.TextSize = 16
			itemLabel.TextColor3 = Theme.TextSecondary
			itemLabel.BackgroundTransparency = 1
			itemLabel.TextWrapped = true
			itemLabel.TextXAlignment = Enum.TextXAlignment.Left
			itemLabel.Size = UDim2.new(1, 0, 0, 20)
			itemLabel.AutomaticSize = Enum.AutomaticSize.Y
		end
	end
end

panelsConfig.PLAY.builder = BuildPlayPanel
panelsConfig.UPDATES.builder = BuildUpdatesPanel
panelsConfig.RULES.builder = BuildRulesPanel
panelsConfig.CREDITS.builder = BuildCreditsPanel

local function EnsureMainInterface()
	if mainShell then return end
	BuildMainInterface()
	mainShell.Visible = false
	mainShell.BackgroundTransparency = 1
	if orderedPanelKeys[1] then
		SwitchPanel(orderedPanelKeys[1])
	end
end

local function SetMenuCamera()
	if menuCamera and menuCamera.FadeFrame then
		menuCamera.FadeFrame.Visible = false
		menuCamera.FadeFrame.BackgroundTransparency = 1
		menuCamera.FadeFrame.ZIndex = 0
	end
	blurEffect.Enabled = true
	if blurTween then blurTween:Cancel() end
	blurTween = TweenService:Create(blurEffect, TweenInfo.new(0.3), { Size = BLUR_AMOUNT })
	blurTween:Play()
end

local function RestorePlayerCamera()
	if blurTween then blurTween:Cancel() end
	local outTween = TweenService:Create(blurEffect, TweenInfo.new(0.3), { Size = 0 })
	outTween.Completed:Connect(function()
		if blurEffect then blurEffect.Enabled = false end
	end)
	outTween:Play()
end

function OpenMainMenu(targetPanelKey)
	local currentTime = os.clock()
	if isMenuTransitioning or (currentTime - lastMenuActionTime) < MENU_DEBOUNCE_TIME then return end
	isMenuTransitioning = true
	lastMenuActionTime = currentTime

	EnsureMainInterface()
	menuOpenRequested = false
	screenGui.Enabled = true

	if targetPanelKey then
		SwitchPanel(targetPanelKey)
	elseif not currentPanelKey and orderedPanelKeys[1] then
		SwitchPanel(orderedPanelKeys[1])
	end

	mainShell.Visible = true
	TweenService:Create(mainShell, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
	SetMenuCamera()

	local character = player.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid and originalWalkSpeed == nil then
			originalWalkSpeed = humanoid.WalkSpeed
			humanoid.WalkSpeed = 0
		end
	end

	task.delay(0.3, function()
		isMenuTransitioning = false
	end)
end

function CloseMainMenu()
	local currentTime = os.clock()
	if isMenuTransitioning or (currentTime - lastMenuActionTime) < MENU_DEBOUNCE_TIME then return end
	isMenuTransitioning = true
	lastMenuActionTime = currentTime

	local character = player.Character
	if character and originalWalkSpeed ~= nil then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then humanoid.WalkSpeed = originalWalkSpeed end
		originalWalkSpeed = nil
	end

	RestorePlayerCamera()

	if menuCamera.IsActive then
		menuCamera:Stop()
	end

	TweenService:Create(mainShell, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1 }):Play()
	task.delay(0.22, function()
		if mainShell then mainShell.Visible = false end
		screenGui.Enabled = false
		isMenuTransitioning = false
	end)
end

-------------------------------------------------------------------------
-- ВІТАЛЬНЕ ПОВІДОМЛЕННЯ ПРО PREVIEW ВЕРСІЮ
-------------------------------------------------------------------------
local function ShowPreviewWarning(onComplete)
	hasShownPreviewWarning = true

	local warningGui = Instance.new("ScreenGui")
	warningGui.Name = "PreviewWarningGui"
	warningGui.IgnoreGuiInset = true
	warningGui.DisplayOrder = 150
	warningGui.Parent = playerGui

	-- Затемнення фону
	local overlay = Instance.new("Frame", warningGui)
	overlay.Name = "Overlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.ZIndex = 1

	TweenService:Create(overlay, TweenInfo.new(0.3), { BackgroundTransparency = 0.6 }):Play()

	-- Основна панель
	local panel = Instance.new("Frame", warningGui)
	panel.Name = "WarningPanel"
	panel.Size = UDim2.new(0, 520, 0, 340)
	panel.Position = UDim2.new(0.5, 0, 0.5, 0)
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.BackgroundColor3 = Theme.PrimaryUI
	panel.BackgroundTransparency = 0.05
	panel.ZIndex = 2

	local panelCorner = Instance.new("UICorner", panel)
	panelCorner.CornerRadius = UDim.new(0, 20)

	local panelStroke = Instance.new("UIStroke", panel)
	panelStroke.Color = Theme.Warning
	panelStroke.Thickness = 2
	panelStroke.Transparency = 0.3

	local panelGradient = Instance.new("UIGradient", panel)
	panelGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Theme.PrimaryUI_Light),
		ColorSequenceKeypoint.new(1, Theme.PrimaryUI)
	})
	panelGradient.Rotation = 90

	-- Іконка попередження
	local warningIcon = Instance.new("TextLabel", panel)
	warningIcon.Size = UDim2.new(0, 60, 0, 60)
	warningIcon.Position = UDim2.new(0.5, 0, 0, 25)
	warningIcon.AnchorPoint = Vector2.new(0.5, 0)
	warningIcon.BackgroundColor3 = Theme.Warning
	warningIcon.BackgroundTransparency = 0.1
	warningIcon.Text = "⚠️"
	warningIcon.TextSize = 32
	warningIcon.Font = Enum.Font.GothamBold
	warningIcon.TextColor3 = Theme.Background
	warningIcon.ZIndex = 3

	local iconCorner = Instance.new("UICorner", warningIcon)
	iconCorner.CornerRadius = UDim.new(1, 0)

	-- Заголовок "Увага!"
	local titleLabel = Instance.new("TextLabel", panel)
	titleLabel.Size = UDim2.new(1, -40, 0, 40)
	titleLabel.Position = UDim2.new(0.5, 0, 0, 95)
	titleLabel.AnchorPoint = Vector2.new(0.5, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "Увага!"
	titleLabel.Font = Enum.Font.GothamBlack
	titleLabel.TextSize = 32
	titleLabel.TextColor3 = Theme.Warning
	titleLabel.ZIndex = 3

	-- Основний текст
	local messageLabel = Instance.new("TextLabel", panel)
	messageLabel.Size = UDim2.new(1, -50, 0, 120)
	messageLabel.Position = UDim2.new(0.5, 0, 0, 140)
	messageLabel.AnchorPoint = Vector2.new(0.5, 0)
	messageLabel.BackgroundTransparency = 1
	messageLabel.Text = "M1 (Kyiv, Metro) перейшов в стадію Preview версій. Це означає, що ви можете замічати або бачити баги, невідповідності, або фальшиві зльоти поїздів. Ми знаємо про ці проблеми, і намагаємося вирішити якомога швидше.\n\nДякую за розуміння"
	messageLabel.Font = Enum.Font.Gotham
	messageLabel.TextSize = 16
	messageLabel.TextColor3 = Theme.TextSecondary
	messageLabel.TextWrapped = true
	messageLabel.TextXAlignment = Enum.TextXAlignment.Center
	messageLabel.ZIndex = 3

	-- Кнопка з таймером
	local confirmButton = Instance.new("TextButton", panel)
	confirmButton.Name = "ConfirmButton"
	confirmButton.Size = UDim2.new(0, 220, 0, 50)
	confirmButton.Position = UDim2.new(0.5, 0, 1, -30)
	confirmButton.AnchorPoint = Vector2.new(0.5, 1)
	confirmButton.BackgroundColor3 = Theme.Disabled
	confirmButton.TextColor3 = Theme.TextSecondary
	confirmButton.Font = Enum.Font.GothamBold
	confirmButton.TextSize = 18
	confirmButton.AutoButtonColor = false
	confirmButton.Active = false
	confirmButton.Text = "Я зрозумів. (5)"
	confirmButton.ZIndex = 3

	local buttonCorner = Instance.new("UICorner", confirmButton)
	buttonCorner.CornerRadius = UDim.new(0, 12)

	local buttonStroke = Instance.new("UIStroke", confirmButton)
	buttonStroke.Color = Theme.Disabled
	buttonStroke.Thickness = 1.5
	buttonStroke.Transparency = 0.5

	-- Таймер на кнопці
	local timerFrame = Instance.new("Frame", confirmButton)
	timerFrame.Name = "TimerProgress"
	timerFrame.Size = UDim2.new(0, 0, 1, 0)
	timerFrame.Position = UDim2.new(0, 0, 0, 0)
	timerFrame.BackgroundColor3 = Theme.Success
	timerFrame.BackgroundTransparency = 0.7
	timerFrame.ZIndex = 2

	local timerCorner = Instance.new("UICorner", timerFrame)
	timerCorner.CornerRadius = UDim.new(0, 12)

	-- Запускаємо таймер 5 секунд
	local countdown = 5

	task.spawn(function()
		-- Анімація прогрес-бару
		TweenService:Create(timerFrame, TweenInfo.new(5, Enum.EasingStyle.Linear), { Size = UDim2.new(1, 0, 1, 0) }):Play()

		while countdown > 0 do
			confirmButton.Text = string.format("Я зрозумів. (%d)", countdown)
			task.wait(1)
			countdown = countdown - 1
		end

		-- Активуємо кнопку
		confirmButton.Text = "Я зрозумів."
		confirmButton.Active = true
		confirmButton.BackgroundColor3 = Theme.Success
		confirmButton.TextColor3 = Theme.Background
		buttonStroke.Color = Theme.Success

		-- Анімація появи активної кнопки
		TweenService:Create(confirmButton, TweenInfo.new(0.2), { BackgroundColor3 = Theme.Success }):Play()
		TweenService:Create(buttonStroke, TweenInfo.new(0.2), { Color = Theme.Success, Transparency = 0 }):Play()

		-- Приховуємо прогрес-бар
		timerFrame.Visible = false
	end)

	-- Обробник кнопки
	confirmButton.MouseButton1Click:Connect(function()
		if not confirmButton.Active then return end

		-- Звук підтвердження
		local confirmSound = Instance.new("Sound")
		confirmSound.SoundId = "rbxassetid://12221944"
		confirmSound.Parent = Workspace
		confirmSound:Play()
		confirmSound.Ended:Connect(function()
			if confirmSound and confirmSound.Parent then
				confirmSound:Destroy()
			end
		end)

		-- Закриваємо вікно
		TweenService:Create(overlay, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(panel, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()

		task.delay(0.25, function()
			if warningGui and warningGui.Parent then
				warningGui:Destroy()
			end
			if onComplete then
				onComplete()
			end
		end)
	end)

	-- Hover ефекти для кнопки
	confirmButton.MouseEnter:Connect(function()
		if confirmButton.Active then
			TweenService:Create(confirmButton, tweenInfoEnter, { BackgroundColor3 = Color3.fromRGB(120, 255, 180) }):Play()
		end
	end)

	confirmButton.MouseLeave:Connect(function()
		if confirmButton.Active then
			TweenService:Create(confirmButton, tweenInfoLeave, { BackgroundColor3 = Theme.Success }):Play()
		end
	end)
end

local function ProceedToNextStep(targetPanelKey)
	rulesAccepted = true
	if rulesWindow then
		TweenService:Create(rulesWindow, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1 }):Play()
		task.delay(0.2, function()
			if rulesWindow then rulesWindow:Destroy() end
			rulesWindow = nil
		end)
	end
	OpenMainMenu(targetPanelKey or "UPDATES")
end

local function ShowConfirmationPrompt()
	if not rulesWindow then return end

	local overlay = Instance.new("Frame", rulesWindow)
	overlay.Name = "ConfirmOverlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.ZIndex = 120

	TweenService:Create(overlay, TweenInfo.new(0.2), { BackgroundTransparency = 0.6 }):Play()

	local prompt = Instance.new("Frame", overlay)
	prompt.Name = "ConfirmCard"
	prompt.Size = UDim2.new(0, 420, 0, 220)
	prompt.Position = UDim2.new(0.5, 0, 0.5, 0)
	prompt.AnchorPoint = Vector2.new(0.5, 0.5)
	prompt.BackgroundColor3 = Theme.PrimaryUI
	prompt.BackgroundTransparency = 0.05
	prompt.ZIndex = 121
	Instance.new("UICorner", prompt).CornerRadius = UDim.new(0, 16)

	local promptStroke = Instance.new("UIStroke", prompt)
	promptStroke.Color = Theme.OutlineSoft
	promptStroke.Transparency = 0.4

	local textLabel = Instance.new("TextLabel", prompt)
	textLabel.Size = UDim2.new(1, -40, 0, 110)
	textLabel.Position = UDim2.new(0.5, 0, 0, 26)
	textLabel.AnchorPoint = Vector2.new(0.5, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.RichText = true
	textLabel.TextWrapped = true
	textLabel.Font = Enum.Font.Gotham
	textLabel.TextSize = 18
	textLabel.TextColor3 = Theme.TextPrimary
	textLabel.TextXAlignment = Enum.TextXAlignment.Center
	textLabel.Text = "<b>Ви впевнені, що ознайомились із правилами?</b>\n<font color='#8a94b7'>Незнання не звільняє від відповідальності.</font>"
	textLabel.ZIndex = 122

	local buttonsHolder = Instance.new("Frame", prompt)
	buttonsHolder.Size = UDim2.new(1, -60, 0, 50)
	buttonsHolder.Position = UDim2.new(0.5, 0, 1, -30)
	buttonsHolder.AnchorPoint = Vector2.new(0.5, 1)
	buttonsHolder.BackgroundTransparency = 1
	buttonsHolder.ZIndex = 122

	local buttonsLayout = Instance.new("UIListLayout", buttonsHolder)
	buttonsLayout.FillDirection = Enum.FillDirection.Horizontal
	buttonsLayout.Padding = UDim.new(0, 12)
	buttonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local acceptButton = Instance.new("TextButton", buttonsHolder)
	acceptButton.Size = UDim2.new(0.45, 0, 1, 0)
	acceptButton.BackgroundColor3 = Theme.Success
	acceptButton.TextColor3 = Theme.Background
	acceptButton.Font = Enum.Font.GothamBold
	acceptButton.TextSize = 16
	acceptButton.AutoButtonColor = false
	acceptButton.Text = "Так, я ознайомився"
	acceptButton.ZIndex = 123
	Instance.new("UICorner", acceptButton).CornerRadius = UDim.new(0, 10)

	local backButton = Instance.new("TextButton", buttonsHolder)
	backButton.Size = UDim2.new(0.45, 0, 1, 0)
	backButton.BackgroundColor3 = Theme.Error
	backButton.TextColor3 = Theme.Background
	backButton.Font = Enum.Font.GothamBold
	backButton.TextSize = 16
	backButton.AutoButtonColor = false
	backButton.Text = "Ще читаю"
	backButton.ZIndex = 123
	Instance.new("UICorner", backButton).CornerRadius = UDim.new(0, 10)

	acceptButton.MouseButton1Click:Connect(function()
		ProceedToNextStep("UPDATES")
	end)

	backButton.MouseButton1Click:Connect(function()
		TweenService:Create(overlay, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()
		backButton.Active = false
		acceptButton.Active = false
		task.delay(0.16, function()
			if overlay and overlay.Parent then overlay:Destroy() end
		end)
		rulesStartTime = os.clock()
	end)
end

local function HandleRulesAccepted()
	if os.clock() - rulesStartTime < 5 then
		ShowConfirmationPrompt()
	else
		ProceedToNextStep("UPDATES")
	end
end

function CreateAndShowRulesWindow()
	if hasShownInitialWindows then return end
	hasShownInitialWindows = true

	EnsureMainInterface()
	screenGui.Enabled = true
	SetMenuCamera()

	local overlay = Instance.new("Frame")
	overlay.Name = "RulesOverlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.ZIndex = 90
	overlay.Parent = screenGui

	TweenService:Create(overlay, TweenInfo.new(0.3), { BackgroundTransparency = 0.25 }):Play()
	rulesWindow = overlay

	local panel = Instance.new("Frame", overlay)
	panel.Name = "RulesPanel"
	panel.Size = UDim2.new(0.75, 0, 0.78, 0)
	panel.Position = UDim2.new(0.5, 0, 0.5, 0)
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.BackgroundColor3 = Theme.PrimaryUI
	panel.BackgroundTransparency = 0.1
	panel.ZIndex = 95
	Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 24)

	local panelStroke = Instance.new("UIStroke", panel)
	panelStroke.Color = Theme.OutlineSoft
	panelStroke.Transparency = 0.4

	local panelPadding = Instance.new("UIPadding", panel)
	panelPadding.PaddingTop = UDim.new(0, 26)
	panelPadding.PaddingBottom = UDim.new(0, 26)
	panelPadding.PaddingLeft = UDim.new(0, 28)
	panelPadding.PaddingRight = UDim.new(0, 28)

	local titleLabel = Instance.new("TextLabel", panel)
	titleLabel.Text = "Регламент проєкту"
	titleLabel.Font = Enum.Font.GothamBlack
	titleLabel.TextSize = 28
	titleLabel.TextColor3 = Theme.TextPrimary
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Size = UDim2.new(1, 0, 0, 34)
	titleLabel.ZIndex = 96

	local subtitleLabel = Instance.new("TextLabel", panel)
	subtitleLabel.Text = "Витратьте хвилину, щоб ознайомитись. Усі блоки згруповано за ролями."
	subtitleLabel.Font = Enum.Font.Gotham
	subtitleLabel.TextSize = 16
	subtitleLabel.TextColor3 = Theme.TextSecondary
	subtitleLabel.BackgroundTransparency = 1
	subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	subtitleLabel.TextWrapped = true
	subtitleLabel.Size = UDim2.new(1, 0, 0, 40)
	subtitleLabel.Position = UDim2.new(0, 0, 0, 36)
	subtitleLabel.ZIndex = 96

	local contentContainer = Instance.new("Frame", panel)
	contentContainer.Name = "Content"
	contentContainer.Size = UDim2.new(1, 0, 1, -140)
	contentContainer.Position = UDim2.new(0, 0, 0, 86)
	contentContainer.BackgroundTransparency = 1
	contentContainer.ZIndex = 96

	BuildRulesPanel(contentContainer)

	local acceptButton = Instance.new("TextButton", panel)
	acceptButton.Name = "AcceptButton"
	acceptButton.Size = UDim2.new(0, 400, 0, 54)
	acceptButton.Position = UDim2.new(0.5, 0, 1, -20)
	acceptButton.AnchorPoint = Vector2.new(0.5, 1)
	acceptButton.BackgroundColor3 = Theme.Success
	acceptButton.TextColor3 = Theme.Background
	acceptButton.Font = Enum.Font.GothamBold
	acceptButton.TextSize = 18
	acceptButton.AutoButtonColor = false
	acceptButton.Text = "Я погоджуюсь та готовий починати"
	acceptButton.ZIndex = 96
	Instance.new("UICorner", acceptButton).CornerRadius = UDim.new(0, 14)

	acceptButton.MouseButton1Click:Connect(HandleRulesAccepted)

	rulesStartTime = os.clock()

	local character = player.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid and originalWalkSpeed == nil then
			originalWalkSpeed = humanoid.WalkSpeed
			humanoid.WalkSpeed = 0
		end
	end

	task.spawn(function()
		menuCamera:StartLoop()
	end)
end

function CheckHoldDuration()
	holdUI.Visible = true
	while isHoldActive and RunService:IsRunning() and holdStartTime > 0 do
		local elapsedTime = os.clock() - holdStartTime
		local progress = math.clamp(elapsedTime / HOLD_DURATION, 0, 1)
		local keypoints = {
			NumberSequenceKeypoint.new(0, 0), 
			NumberSequenceKeypoint.new(progress, 0), 
			NumberSequenceKeypoint.new(math.min(1, progress + 0.001), 1), 
			NumberSequenceKeypoint.new(1, 1)
		}
		holdGradient.Transparency = NumberSequence.new(keypoints)

		if elapsedTime >= HOLD_DURATION then
			if not screenGui.Enabled and not menuOpenRequested then
				menuOpenRequested = true
				isHoldActive = false
				holdUI.Visible = false
				holdGradient.Transparency = NumberSequence.new(1)
				task.spawn(OpenMainMenu)
			else 
				isHoldActive = false 
			end
			break
		end
		RunService.Heartbeat:Wait()
	end

	if isHoldActive == false and menuOpenRequested == false then
		holdUI.Visible = false
		holdGradient.Transparency = NumberSequence.new(1)
	end
end

function StartHoldCheck()
	if not rulesAccepted or isHoldActive or screenGui.Enabled then return end
	isHoldActive = true
	holdStartTime = os.clock()
	menuOpenRequested = false
	task.spawn(CheckHoldDuration)
end

function EndHoldCheck()
	if isHoldActive then isHoldActive = false end
end

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe or UserInputService:GetFocusedTextBox() then return end
	if input.KeyCode == HOLD_KEY_CODE then StartHoldCheck() end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == HOLD_KEY_CODE then EndHoldCheck() end
end)

-- PC кнопка меню
local pcMenuGui = Instance.new("ScreenGui")
pcMenuGui.Name = "PCMenuButtonGui"
pcMenuGui.ResetOnSpawn = false
pcMenuGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcMenuGui.IgnoreGuiInset = true
pcMenuGui.DisplayOrder = 999

local buttonFrame = Instance.new("Frame")
buttonFrame.Name = "PCMenuButton"
buttonFrame.Size = UDim2.new(0, 100, 0, 40)
buttonFrame.Position = UDim2.new(1, -15, 0, 15)
buttonFrame.AnchorPoint = Vector2.new(1, 0)
buttonFrame.BackgroundColor3 = Theme.Background
buttonFrame.BackgroundTransparency = 0.3
buttonFrame.BorderSizePixel = 0
buttonFrame.Parent = pcMenuGui

local corner = Instance.new("UICorner", buttonFrame)
corner.CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", buttonFrame)
stroke.Color = Theme.PrimaryUI_Light
stroke.Thickness = 1.5

local label = Instance.new("TextLabel")
label.Name = "Label"
label.Size = UDim2.fromScale(1, 1)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamBold
label.Text = "МЕНЮ"
label.TextColor3 = Theme.TextPrimary
label.TextSize = 18
label.Parent = buttonFrame

local actionButton = Instance.new("TextButton")
actionButton.Name = "ActionButton"
actionButton.Size = UDim2.fromScale(1, 1)
actionButton.Text = ""
actionButton.BackgroundTransparency = 1
actionButton.Parent = buttonFrame

actionButton.MouseButton1Click:Connect(function()
	if not rulesAccepted then return end
	if not screenGui.Enabled then 
		OpenMainMenu() 
	elseif hasStartedPlaying then 
		CloseMainMenu() 
	end
end)

actionButton.MouseEnter:Connect(function() 
	TweenService:Create(buttonFrame, tweenInfoEnter, { BackgroundTransparency = 0.1 }):Play() 
end)

actionButton.MouseLeave:Connect(function() 
	TweenService:Create(buttonFrame, tweenInfoLeave, { BackgroundTransparency = 0.3 }):Play() 
end)

pcMenuGui.Parent = playerGui

SetupTeamListeners = function()
	-- Очищаємо старі підключення
	for teamNameKey, connections in pairs(teamPlayerEventListeners) do
		if connections then
			for _, c in ipairs(connections) do 
				if c then c:Disconnect() end
			end
		end
	end
	teamPlayerEventListeners = {}

	for teamNameKey, elements in pairs(roleButtonElements) do
		local roleData = elements.data
		if roleData.MaxPlayers and roleData.MaxPlayers > 0 then
			local team = Teams:FindFirstChild(roleData.TeamName)
			if team then
				teamPlayerEventListeners[roleData.TeamName] = {}
				table.insert(teamPlayerEventListeners[roleData.TeamName], team.PlayerAdded:Connect(UpdateRoleButtonsVisuals))
				table.insert(teamPlayerEventListeners[roleData.TeamName], team.PlayerRemoved:Connect(UpdateRoleButtonsVisuals))
			end
		end
	end
end

local function SetupDspTeamListener()
	local dspTeam = Teams:FindFirstChild("ЧПС")
	if dspTeam then
		UpdateDspStationAvailability()
		dspTeam.AttributeChanged:Connect(function(attributeName)
			if string.find(attributeName, "_OccupiedBy") then 
				UpdateDspStationAvailability() 
			end
		end)
	end
end

local function OnCharacterAdded(character)
	if hasStartedPlaying then CloseMainMenu() end
end

local function InitialSetup()
	task.wait(0.5)

	if loadingFrame and loadingFrame.Parent then
		TweenService:Create(loadingFrame, TweenInfo.new(LOAD_FADE_TIME), {BackgroundTransparency = 1}):Play()
		task.delay(LOAD_FADE_TIME, function() 
			if loadingFrame and loadingFrame.Parent then 
				loadingFrame:Destroy() 
			end 
		end)
	end

	screenGui.Parent = playerGui

	-- Спочатку показуємо попередження про Preview версію
	if not hasShownPreviewWarning then
		ShowPreviewWarning(function()
			-- Після закриття попередження показуємо правила
			task.spawn(function()
				menuCamera:StartLoop()
			end)

			if not hasShownInitialWindows then 
				CreateAndShowRulesWindow() 
			end
		end)
	else
		task.spawn(function()
			menuCamera:StartLoop()
		end)

		if not hasShownInitialWindows then 
			CreateAndShowRulesWindow() 
		end
	end

	if player.Character then 
		OnCharacterAdded(player.Character) 
	end

	player.CharacterAdded:Connect(OnCharacterAdded)
	Teams.ChildAdded:Connect(SetupTeamListeners)
	Teams.ChildAdded:Connect(SetupDspTeamListener)
	expStat.Changed:Connect(UpdateRoleButtonsVisuals)
	SetupTeamListeners()
	SetupDspTeamListener()
end

task.wait(3)
InitialSetup()task.wait(2)
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")

-- Перевірка на мобільні пристрої
if UserInputService.TouchEnabled then
	script:Destroy()
	print("ООХ чорт, оох чорт ітс мобіле")
	return
end

-------------------------------------------------------------------------
-- ПЕРЕВІРКА ДАТИ ТА ПОВІДОМЛЕННЯ ПРО ОНОВЛЕННЯ
-------------------------------------------------------------------------
local function CheckForUpdates()
	local currentDate = os.date("*t")

	if currentDate.year == 2025 and currentDate.month == 12 and currentDate.day == 26 then
		local screenGui = Instance.new("ScreenGui")
		screenGui.Name = "UpdateNotification"
		screenGui.IgnoreGuiInset = true
		screenGui.DisplayOrder = 3
		screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(0, 400, 0, 100)
		frame.Position = UDim2.new(0.5, 0, 0.1, 0)
		frame.AnchorPoint = Vector2.new(0.5, 0)
		frame.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
		frame.BorderSizePixel = 0
		frame.Parent = screenGui

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 12)
		corner.Parent = frame

		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, -20, 1, -20)
		textLabel.Position = UDim2.new(0, 10, 0, 10)
		textLabel.BackgroundTransparency = 1
		textLabel.Text = "Увага! Оновленні правила від 26.12.2025.\nПрочитайте їх ще раз!"
		textLabel.TextColor3 = Color3.new(1, 1, 1)
		textLabel.Font = Enum.Font.GothamBold
		textLabel.TextSize = 18
		textLabel.TextWrapped = true
		textLabel.Parent = frame

		local sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://12221967"
		sound.Parent = frame
		sound:Play()

		task.delay(30, function()
			if screenGui and screenGui.Parent then
				screenGui:Destroy()
			end
		end)
	end
end
task.spawn(CheckForUpdates)
-------------------------------------------------------------------------

local changelogData = {
	" Дніпро має вестибюль",
	" Диспетчер повернутий, і тепер має деяке нове меню (поки що скромно)",
	" Оновленні на 5 вагонкі: Лісова, Чернігівська, Дарниця, Гідропарк.",
	" І БАГАТО, БАГАТО чого іншого. Дізнайтесь самі )",
}

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

	{ type = "rule", text = "<b>2.7.1</b> ✅ Обкатка: обов'язково дотримуватись дистанції, їхати ≤30 км/год, подавати сигнал на станціях." },
	{ type = "rule", text = "<b>2.7.2</b> ✅ Машиністи повинні пропускати один одного на кінцевих, уникати заторів, не спавнити багато потягів." },

	{ type = "rule", text = "<b>2.8</b> 🚫 Використання потяга, який створила інша особа." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> кік → бан 3-7 днів." },

	{ type = "rule", text = "<b>2.9</b> 🚫 Рух без інформатора (виняток: обкатка, перегонка, фотопоїзд 81.717)." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> кік" },

	{ type = "rule", text = "<b>2.10</b> 🚫 Ігнорування команд ДСП - Диспетчера." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> кік → бан - 1-3 дні." },

	{ type = "rule", text = "<b>2.11</b> 🚫 Проїзд на червоне світло (без дозволу диспетчера)." },
	{ type = "punishment", text = "⛔ <i>Покарання:</i> кік → бан 1–3 дні" },

	{ type = "rule", text = "<b>2.12</b> 🚫 Рух під час повітряної тривоги (ПТ). <font color='#8a94b7'>(Виняток: Дозвіл овнера гри)</font>" },
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

	{ type = "rule", text = "<b>3.6.1</b> 🚫 Образи про сім'ю, батьків, хвороби." },
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
	{ type = "punishment", text = "⛔ <i>Покарання:</i> м'ют від 15 хвилин, до бану на розгляд модерації/адміністрації" },

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
	StationSelected = Color3.fromRGB(255, 118, 0),
	PanelGlow = Color3.fromRGB(42, 35, 58),
	GlassOverlay = Color3.fromRGB(30, 25, 45),
	OutlineSoft = Color3.fromRGB(65, 55, 90)
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
	StationSelected = Color3.fromRGB(100, 200, 255),
	PanelGlow = Color3.fromRGB(35, 45, 70),
	GlassOverlay = Color3.fromRGB(25, 35, 55),
	OutlineSoft = Color3.fromRGB(56, 68, 94)
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
	StationSelected = Color3.fromRGB(68, 214, 196),
	PanelGlow = Color3.fromRGB(28, 54, 108),
	GlassOverlay = Color3.fromRGB(18, 30, 62),
	OutlineSoft = Color3.fromRGB(38, 62, 104)
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
local HOLD_KEY_CODE = Enum.KeyCode.M
local HOLD_DURATION = 1.5
local CAMERA_PATH_DURATION = 20

local tweenInfoEnter = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfoLeave = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local shakeTweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 4, true)

local changeTeamEvent = ReplicatedStorage:WaitForChild("ChangeTeamG")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local leaderstats = player:WaitForChild("leaderstats")
local expStat = leaderstats:WaitForChild("EXP")

local originalWalkSpeed = nil
local hasStartedPlaying = false
local hasShownInitialWindows = false
local hasShownPreviewWarning = false
local rulesAccepted = false
local rulesWindow
local rulesStartTime = 0

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MainMenuGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.Enabled = true

local isHoldActive = false
local holdStartTime = 0
local menuOpenRequested = false

local isMenuTransitioning = false
local lastMenuActionTime = 0
local MENU_DEBOUNCE_TIME = 0.5

local blurEffect
local blurTween = nil

local selectedRoleData = nil
local selectedStationCircle = nil
local selectedStationData = nil
local finalPlayButton = nil
local finalPlayButtonConnection = nil

local stationGuiElementsMap = {}
local playSummaryLabel = nil

local rolesData = {
	{ Text = "ПАСАЖИР", Color = Color3.fromRGB(88, 255, 197), TeamName = "Passanger", Tagline = "Вільна прогулянка та огляд маршрутів" },
	{ Text = "МАШИНІСТ", Color = Color3.fromRGB(74, 101, 255), TeamName = "Machinist", MaxPlayers = 12, Tagline = "Керуйте поїздом та тримайте графік" },
	{ Text = "ДИСПЕТЧЕР", Color = Color3.fromRGB(255, 175, 75), TeamName = "Диспетчер", MaxPlayers = 1, RequiredEXP = 2000, Tagline = "Контролюйте рух поїздів та розпоряджайтесь рухом", Unavailable = true },
	{ Text = "ЧПС", Color = Color3.fromRGB(189, 147, 249), TeamName = "ЧПС", MaxPlayers = 1, RequiredEXP = 500, Tagline = "Чергова по станції, тримайте порядок" },
	{ Text = "Поліція", Color = Color3.fromRGB(68, 122, 255), TeamName = "Поліція", MaxPlayers = 4, RequiredEXP = 1250, Tagline = "Безпека на платформах та у вагонах", Unavailable = true }
}

local stationsData = {
	{ Name = "Тупік • Лісова", Code = "DEP-L", SpawnerName = "TupikLisova", RequiredRole = "МАШИНІСТ", IsTerminal = true },
	{ Name = "Лісова", Code = "M1-01", SpawnerName = "Lisova", IsDspStation = true },
	{ Name = "Чернігівська", Code = "M1-02", SpawnerName = "Chernigivska" },
	{ Name = "Дарниця", Code = "M1-03", SpawnerName = "Darnytsia" },
	{ Name = "Лівобережна", Code = "M1-04", SpawnerName = "Livoberz" },
	{ Name = "Гідропарк", Code = "M1-05", SpawnerName = "Gidropark" },
	{ Name = "Дніпро", Code = "M1-06", SpawnerName = "Dnipro" },
	{ Name = "Тупік • Дніпро", Code = "DEP-D", SpawnerName = "TupikDnipro", RequiredRole = "МАШИНІСТ", IsTerminal = true }
}

local roleButtonElements = {}
local teamPlayerEventListeners = {}

local loadingFrame = Instance.new("Frame")
loadingFrame.Name = "LoadingScreen"
loadingFrame.Size = UDim2.new(1, 0, 1, 0)
loadingFrame.BackgroundColor3 = Theme.Background
loadingFrame.BackgroundTransparency = 0
loadingFrame.BorderSizePixel = 0
loadingFrame.ZIndex = 100
loadingFrame.Parent = playerGui

local camera = Workspace.CurrentCamera

blurEffect = Lighting:FindFirstChildOfClass("BlurEffect") or Instance.new("BlurEffect")
blurEffect.Name = "MenuBlur"
blurEffect.Size = 0
blurEffect.Enabled = false
blurEffect.Parent = Lighting

local menuCamera = {}
menuCamera.IsActive = false
menuCamera.Paths = {}
menuCamera.CurrentTween = nil
menuCamera.Music = nil
menuCamera.FadeFrame = nil
menuCamera.CurrentPathIndex = 0
menuCamera.MusicEndedConnection = nil

function menuCamera:Initialize()
	self.Music = Instance.new("Sound")
	-- Виправлено: використовуємо musicData замість хардкодженого значення
	self.Music.SoundId = musicData[1] or "rbxassetid://1841998974"
	self.Music.Looped = false
	self.Music.Volume = 0.4
	self.Music.Parent = Workspace

	self.FadeFrame = Instance.new("Frame")
	self.FadeFrame.Name = "CameraFadeFrame"
	self.FadeFrame.Size = UDim2.new(1, 0, 1, 0)
	self.FadeFrame.BackgroundColor3 = Color3.new(0, 0, 0)
	self.FadeFrame.BackgroundTransparency = 1
	self.FadeFrame.BorderSizePixel = 0
	self.FadeFrame.ZIndex = 4
	self.FadeFrame.Parent = screenGui

	local pathContainerOriginal = ReplicatedStorage:WaitForChild("CameraPath", 0.1)
	if not pathContainerOriginal then return end

	local pathContainer = pathContainerOriginal:Clone()
	if not screenGui:FindFirstChild("TempCameraPaths") then
		Instance.new("Folder", screenGui).Name = "TempCameraPaths"
	end
	pathContainer.Parent = screenGui.TempCameraPaths

	local pathFolders = {}
	for _, child in ipairs(pathContainer:GetChildren()) do
		if child:IsA("Folder") then table.insert(pathFolders, child) end
	end
	if #pathFolders == 0 then return end

	table.sort(pathFolders, function(a, b) return a.Name:lower() < b.Name:lower() end)

	for _, pathFolder in ipairs(pathFolders) do
		local parts = {}
		for _, part in ipairs(pathFolder:GetChildren()) do
			if part:IsA("BasePart") then table.insert(parts, part) end
		end
		if #parts > 0 then
			table.sort(parts, function(a, b)
				local numA = tonumber(string.match(a.Name, "%d+")) or 0
				local numB = tonumber(string.match(b.Name, "%d+")) or 0
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
	if not self.IsActive then return end
	self.IsActive = false

	if self.CurrentTween then 
		self.CurrentTween:Cancel()
		self.CurrentTween = nil 
	end

	if self.Music and self.Music.IsPlaying then
		local musicTween = TweenService:Create(self.Music, TweenInfo.new(0.3), {Volume = 0})
		musicTween.Completed:Connect(function() 
			if self.Music then
				self.Music:Stop()
				self.Music.Volume = 0.4 
			end
		end)
		musicTween:Play()
	end

	if self.MusicEndedConnection then
		self.MusicEndedConnection:Disconnect()
		self.MusicEndedConnection = nil
	end

	local tempFolder = screenGui:FindFirstChild("TempCameraPaths")
	if tempFolder then tempFolder:Destroy() end

	camera.CameraType = Enum.CameraType.Custom
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		camera.CameraSubject = player.Character.Humanoid
	end
end

menuCamera:Initialize()

function menuCamera:Fade(fadeIn)
	local duration = 1
	local targetTransparency = fadeIn and 1 or 0
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(self.FadeFrame, tweenInfo, { BackgroundTransparency = targetTransparency })
	tween:Play()
	tween.Completed:Wait()
end

function menuCamera:MoveAlongPath(path)
	if not self.IsActive or not path or #path < 2 then return end
	local segments = #path - 1
	local durationPerSegment = (segments > 0) and (CAMERA_PATH_DURATION / segments) or CAMERA_PATH_DURATION

	for i = 1, #path - 1 do
		if not self.IsActive then break end
		local endPart = path[i+1]
		local moveTweenInfo = TweenInfo.new(durationPerSegment, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		self.CurrentTween = TweenService:Create(camera, moveTweenInfo, { CFrame = endPart.CFrame })
		self.CurrentTween:Play()
		self.CurrentTween.Completed:Wait()
		self.CurrentTween = nil
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

	if blurEffect then 
		blurEffect.Enabled = true
		blurEffect.Size = BLUR_AMOUNT 
	end

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
	holdUI = Instance.new("Frame")
	holdUI.Name = "HoldUI"
	holdUI.Size = UDim2.fromOffset(100, 100)
	holdUI.Position = UDim2.fromScale(0.5, 0.5)
	holdUI.AnchorPoint = Vector2.new(0.5, 0.5)
	holdUI.BackgroundTransparency = 1
	holdUI.ZIndex = 100
	holdUI.Visible = false

	local background = Instance.new("ImageLabel", holdUI)
	background.Image = "rbxassetid://5920953930"
	background.ImageColor3 = Color3.new(0, 0, 0)
	background.ImageTransparency = 0.5
	background.ScaleType = Enum.ScaleType.Slice
	background.SliceCenter = Rect.new(50, 50, 50, 50)
	background.Size = UDim2.fromScale(1, 1)
	background.BackgroundTransparency = 1

	local keyLabel = Instance.new("TextLabel", holdUI)
	keyLabel.Text = "M"
	keyLabel.Font = Enum.Font.GothamBold
	keyLabel.TextSize = 42
	keyLabel.TextColor3 = Color3.new(1, 1, 1)
	keyLabel.Size = UDim2.fromScale(1, 1)
	keyLabel.BackgroundTransparency = 1

	holdIndicator = Instance.new("ImageLabel", holdUI)
	holdIndicator.Image = "rbxassetid://5920953930"
	holdIndicator.ScaleType = Enum.ScaleType.Slice
	holdIndicator.SliceCenter = Rect.new(50, 50, 50, 50)
	holdIndicator.Size = UDim2.new(1, 1)
	holdIndicator.BackgroundTransparency = 1

	holdGradient = Instance.new("UIGradient", holdUI)
	holdGradient.Rotation = -90
	holdGradient.Transparency = NumberSequence.new(1)

	holdIndicator.Parent = holdUI
	holdUI.Parent = screenGui
end

CreateHoldUI()

local BuildPlayPanel, BuildUpdatesPanel, BuildRulesPanel, BuildCreditsPanel
local SetupTeamListeners

local mainShell = nil
local navButtons = {}
local navContainer = nil
local detailShell = nil
local detailContainer = nil
local detailTitleLabel = nil
local detailSubtitleLabel = nil
local detailAccentLine = nil
local heroPanel = nil
local heroTitleLabel = nil
local heroSubtitleLabel = nil
local heroChipsContainer = nil
local heroHalo = nil
local currentPanelKey = nil

local orderedPanelKeys = { "PLAY", "RULES", "UPDATES", "ACADEMY", "CREDITS" }

local panelsConfig = {
	PLAY = {
		label = "Почати зміну",
		subtitle = "Обирайте роль і станцію просто у центрі командування",
		accent = Theme.Success,
		hero = {
			title = "Командний центр",
			subtitle = "Інтерактивна схема лінії та живі статуси ролей допомагають стартувати миттєво.",
			chips = { "Живі обмеження команд", "Інтерактивна лінія станцій", "Миттєвий виїзд" }
		}
	},
	RULES = {
		label = "Регламент",
		subtitle = "Оновлений кодекс поведінки оформлений як службовий файл",
		accent = Theme.Warning,
		hero = {
			title = "Документація",
			subtitle = "Сприймайте правила як офіційний наказ: все структуровано за ролями та випадками.",
			chips = { "Пасажири", "Машиністи", "Загальні норми" }
		}
	},
	UPDATES = {
		label = "Журнал оновлень",
		subtitle = "Хронологія правок, сезонні події та великі релізи",
		accent = Theme.Accent,
		hero = {
			title = "Новини",
			subtitle = "Слідкуйте за оновленнями, новинками у грі. Перше оновлення з цим меню, як вам ?",
			chips = { "Сезонні івенти", "Покращення геймплею" }
		}
	},
	ACADEMY = {
		label = "Академія",
		subtitle = "Перехід до навчального центру метрополітену",
		accent = Color3.fromRGB(255, 215, 0),
		hero = {}
	},
	CREDITS = {
		label = "Команда",
		subtitle = "Люди та ресурси, які створюють атмосферу метро",
		accent = Theme.Accent_Hover,
		hero = {
			title = "Подяки",
			subtitle = "Відзначаємо авторів моделей, звуків та шрифтів у вигляді бейджів.",
			chips = { "Розробники", "Партнери", "Ресурси" }
		}
	}
}

local function resetFrame(frame)
	if not frame then return end
	for _, child in ipairs(frame:GetChildren()) do
		child:Destroy()
	end
end

local function createChip(parent, text, accentColor)
	local chipFrame = Instance.new("Frame")
	chipFrame.Name = "HeroChip"
	chipFrame.BackgroundTransparency = 0.2
	chipFrame.BackgroundColor3 = accentColor
	chipFrame.Size = UDim2.new(1, 0, 0, 0)
	chipFrame.AutomaticSize = Enum.AutomaticSize.Y
	chipFrame.Parent = parent

	local chipCorner = Instance.new("UICorner", chipFrame)
	chipCorner.CornerRadius = UDim.new(0, 14)

	local chipLabel = Instance.new("TextLabel")
	chipLabel.Name = "ChipLabel"
	chipLabel.BackgroundTransparency = 1
	chipLabel.Font = Enum.Font.GothamMedium
	chipLabel.Text = string.upper(text)
	chipLabel.TextSize = 12
	chipLabel.TextColor3 = Theme.TextPrimary
	chipLabel.TextXAlignment = Enum.TextXAlignment.Center
	chipLabel.TextWrapped = true
	chipLabel.Size = UDim2.new(1, 0, 1, 0)
	chipLabel.Parent = chipFrame

	local chipPadding = Instance.new("UIPadding", chipLabel)
	chipPadding.PaddingLeft = UDim.new(0, 14)
	chipPadding.PaddingRight = UDim.new(0, 14)
	chipPadding.PaddingTop = UDim.new(0, 6)
	chipPadding.PaddingBottom = UDim.new(0, 6)
end

local function setHeroState(config, accentColor)
	if not heroPanel then return end
	local heroConfig = config or {}

	if heroTitleLabel then
		heroTitleLabel.Text = heroConfig.title or ""
	end
	if heroSubtitleLabel then
		heroSubtitleLabel.Text = heroConfig.subtitle or ""
	end

	if heroChipsContainer then
		for _, child in ipairs(heroChipsContainer:GetChildren()) do
			if child:IsA("GuiObject") then child:Destroy() end
		end
		if heroConfig.chips then
			for _, chipText in ipairs(heroConfig.chips) do
				createChip(heroChipsContainer, chipText, accentColor or config.accent or Theme.Accent)
			end
		end
	end

	if heroHalo then
		heroHalo.BackgroundColor3 = accentColor or config and config.accent or Theme.Accent
	end
end

local function updateDetailHeader(config)
	if not detailShell then return end
	if detailTitleLabel then
		detailTitleLabel.Text = config.label or ""
	end
	if detailSubtitleLabel then
		detailSubtitleLabel.Text = config.subtitle or ""
	end
	if detailAccentLine then 
		detailAccentLine.BackgroundColor3 = config.accent or Theme.Accent 
	end
end

local function updateNavState()
	for key, info in pairs(navButtons) do
		local isActive = key == currentPanelKey
		local config = panelsConfig[key]
		if not config then continue end
		local accentColor = config.accent or Theme.Accent

		if info.button and info.button.Parent then
			local transparency = isActive and 0.05 or 0.2
			TweenService:Create(info.button, tweenInfoEnter, {BackgroundTransparency = transparency}):Play()
		end
		if info.accent and info.accent.Parent then
			info.accent.Visible = isActive
			TweenService:Create(info.accent, tweenInfoEnter, {BackgroundTransparency = isActive and 0 or 0.2}):Play()
		end
		if info.titleLabel and info.titleLabel.Parent then
			local targetColor = isActive and Theme.TextPrimary or Theme.TextSecondary
			TweenService:Create(info.titleLabel, tweenInfoEnter, {TextColor3 = targetColor}):Play()
		end
		if info.subtitleLabel and info.subtitleLabel.Parent then
			local targetColor = isActive and Theme.TextSecondary or Theme.Disabled
			TweenService:Create(info.subtitleLabel, tweenInfoEnter, {TextColor3 = targetColor}):Play()
		end
		if info.halo then
			info.halo.Visible = isActive
			info.halo.BackgroundColor3 = accentColor
		end
	end
end

local function SwitchPanel(panelKey)
	if panelKey == "ACADEMY" then
		TeleportService:Teleport(70704181078498, player)
		return
	end

	local config = panelsConfig[panelKey]
	if not config then return end
	if currentPanelKey == panelKey then return end
	currentPanelKey = panelKey

	if finalPlayButtonConnection then
		finalPlayButtonConnection:Disconnect()
		finalPlayButtonConnection = nil
	end
	finalPlayButton = nil
	playSummaryLabel = nil
	stationGuiElementsMap = {}
	selectedStationCircle = nil
	selectedStationData = nil

	resetFrame(detailContainer)
	updateDetailHeader(config)
	setHeroState(config.hero, config.accent)
	updateNavState()

	if config.builder then
		config.builder(detailContainer, config)
	end
end

local function buildNavButton(parent, key, config)
	local button = Instance.new("TextButton")
	button.Name = key .. "Nav"
	button.AutoButtonColor = false
	button.BackgroundColor3 = Theme.PrimaryUI
	button.BackgroundTransparency = 0.2
	button.Size = UDim2.new(1, 0, 0, 88)
	button.Text = ""
	button.Parent = parent

	local corner = Instance.new("UICorner", button)
	corner.CornerRadius = UDim.new(0, 16)

	local halo = Instance.new("Frame")
	halo.Name = "Halo"
	halo.Size = UDim2.new(0, 10, 0, 56)
	halo.AnchorPoint = Vector2.new(0, 0.5)
	halo.Position = UDim2.new(0, 0, 0.5, 0) 
	halo.BackgroundColor3 = config.accent or Theme.Accent
	halo.BackgroundTransparency = 0.5
	halo.Visible = false
	halo.Parent = button
	Instance.new("UICorner", halo).CornerRadius = UDim.new(0.5, 0)

	local accent = Instance.new("Frame")
	accent.Name = "AccentGlow"
	accent.Size = UDim2.new(0, 6, 0.9, 0)
	accent.Position = UDim2.new(0, 0, 0.5, 0)
	accent.AnchorPoint = Vector2.new(0, 0.5)
	accent.BackgroundColor3 = config.accent or Theme.Accent
	accent.Parent = button
	accent.Visible = false
	Instance.new("UICorner", accent).CornerRadius = UDim.new(0.5, 0)

	local textContainer = Instance.new("Frame")
	textContainer.Name = "TextContainer"
	textContainer.BackgroundTransparency = 1
	textContainer.Size = UDim2.new(1, -30, 1, -20)
	textContainer.Position = UDim2.new(0, 24, 0, 10)
	textContainer.Parent = button

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Text = config.label
	titleLabel.TextColor3 = Theme.TextSecondary
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 20
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Size = UDim2.new(1, 0, 0, 32)
	titleLabel.Parent = textContainer

	local subtitleLabel = Instance.new("TextLabel")
	subtitleLabel.Name = "Subtitle"
	subtitleLabel.Text = config.subtitle
	subtitleLabel.TextColor3 = Theme.Disabled
	subtitleLabel.Font = Enum.Font.Gotham
	subtitleLabel.TextSize = 14
	subtitleLabel.BackgroundTransparency = 1
	subtitleLabel.TextWrapped = true
	subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	subtitleLabel.Size = UDim2.new(1, 0, 0, 34)
	subtitleLabel.Position = UDim2.new(0, 0, 0, 34)
	subtitleLabel.Parent = textContainer

	button.MouseEnter:Connect(function()
		if currentPanelKey ~= key and button.Parent then
			TweenService:Create(button, tweenInfoEnter, {BackgroundTransparency = 0.1}):Play()
		end
	end)
	button.MouseLeave:Connect(function()
		if currentPanelKey ~= key and button.Parent then
			TweenService:Create(button, tweenInfoLeave, {BackgroundTransparency = 0.2}):Play()
		end
	end)
	button.MouseButton1Click:Connect(function()
		SwitchPanel(key)
	end)

	navButtons[key] = {
		button = button,
		accent = accent,
		titleLabel = titleLabel,
		subtitleLabel = subtitleLabel,
		halo = halo
	}
end

local function BuildMainInterface()
	mainShell = Instance.new("Frame")
	mainShell.Name = "NeoMainMenuShell"
	mainShell.Size = UDim2.new(1, 0, 1, 0)
	mainShell.BackgroundColor3 = Theme.Background
	mainShell.BackgroundTransparency = 0
	mainShell.Visible = false
	mainShell.Parent = screenGui

	local gradient = Instance.new("UIGradient", mainShell)
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Theme.Background),
		ColorSequenceKeypoint.new(0.4, Theme.GlassOverlay),
		ColorSequenceKeypoint.new(1, Theme.Background)
	})
	gradient.Rotation = 35

	local glass = Instance.new("Frame")
	glass.Name = "GlassFrame"
	glass.Size = UDim2.new(0.88, 0, 0.85, 0)
	glass.Position = UDim2.new(0.5, 0, 0.5, 0)
	glass.AnchorPoint = Vector2.new(0.5, 0.5)
	glass.BackgroundColor3 = Theme.PrimaryUI
	glass.BackgroundTransparency = 0.25
	glass.Parent = mainShell

	local glassCorner = Instance.new("UICorner", glass)
	glassCorner.CornerRadius = UDim.new(0, 28)

	local glassStroke = Instance.new("UIStroke", glass)
	glassStroke.Color = Theme.OutlineSoft
	glassStroke.Transparency = 0.4
	glassStroke.Thickness = 1.5

	local glassGradient = Instance.new("UIGradient", glass)
	glassGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Theme.PrimaryUI_Light),
		ColorSequenceKeypoint.new(1, Theme.PrimaryUI)
	})
	glassGradient.Rotation = 90

	local glassPadding = Instance.new("UIPadding", glass)
	glassPadding.PaddingTop = UDim.new(0, 28)
	glassPadding.PaddingBottom = UDim.new(0, 28)
	glassPadding.PaddingLeft = UDim.new(0, 28)
	glassPadding.PaddingRight = UDim.new(0, 28)

	local layout = Instance.new("UIListLayout", glass)
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	layout.VerticalAlignment = Enum.VerticalAlignment.Top
	layout.Padding = UDim.new(0, 24)

	navContainer = Instance.new("Frame")
	navContainer.Name = "Navigation"
	navContainer.Size = UDim2.new(0, 260, 1, 0)
	navContainer.BackgroundTransparency = 1
	navContainer.Parent = glass

	local navHeader = Instance.new("TextLabel")
	navHeader.Name = "NavHeader"
	navHeader.Text = "МЕТРОКОМ+"
	navHeader.Font = Enum.Font.GothamBlack
	navHeader.TextSize = 32
	navHeader.TextColor3 = Theme.TextPrimary
	navHeader.BackgroundTransparency = 1
	navHeader.TextXAlignment = Enum.TextXAlignment.Left
	navHeader.Size = UDim2.new(1, 0, 0, 48)
	navHeader.Parent = navContainer

	local navSubtitle = Instance.new("TextLabel")
	navSubtitle.Name = "NavSubtitle"
	navSubtitle.Text = "Центр управління мережі"
	navSubtitle.Font = Enum.Font.Gotham
	navSubtitle.TextSize = 15
	navSubtitle.TextColor3 = Theme.TextSecondary
	navSubtitle.BackgroundTransparency = 1
	navSubtitle.TextXAlignment = Enum.TextXAlignment.Left
	navSubtitle.Size = UDim2.new(1, 0, 0, 28)
	navSubtitle.Position = UDim2.new(0, 0, 0, 44)
	navSubtitle.Parent = navContainer

	local navListFrame = Instance.new("Frame")
	navListFrame.Name = "NavList"
	navListFrame.BackgroundTransparency = 1
	navListFrame.Size = UDim2.new(1, 0, 1, -96)
	navListFrame.Position = UDim2.new(0, 0, 0, 90)
	navListFrame.Parent = navContainer

	local navListLayout = Instance.new("UIListLayout", navListFrame)
	navListLayout.Padding = UDim.new(0, 12)
	navListLayout.FillDirection = Enum.FillDirection.Vertical
	navListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	navListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

	detailShell = Instance.new("Frame")
	detailShell.Name = "DetailShell"
	detailShell.Size = UDim2.new(0.46, 0, 1, 0)
	detailShell.BackgroundTransparency = 1
	detailShell.Parent = glass

	local detailHeader = Instance.new("Frame")
	detailHeader.Name = "DetailHeader"
	detailHeader.Size = UDim2.new(1, 0, 0, 96)
	detailHeader.BackgroundTransparency = 1
	detailHeader.Parent = detailShell

	detailAccentLine = Instance.new("Frame", detailHeader)
	detailAccentLine.Name = "Accent"
	detailAccentLine.Size = UDim2.new(0, 6, 0, 48)
	detailAccentLine.Position = UDim2.new(0, -18, 0, 24)
	detailAccentLine.BackgroundColor3 = Theme.Accent
	detailAccentLine.BorderSizePixel = 0
	Instance.new("UICorner", detailAccentLine).CornerRadius = UDim.new(0.5, 0)

	detailTitleLabel = Instance.new("TextLabel")
	detailTitleLabel.Name = "DetailTitle"
	detailTitleLabel.BackgroundTransparency = 1
	detailTitleLabel.Font = Enum.Font.GothamBold
	detailTitleLabel.TextSize = 30
	detailTitleLabel.TextColor3 = Theme.TextPrimary
	detailTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	detailTitleLabel.Size = UDim2.new(1, 0, 0, 42)
	detailTitleLabel.Position = UDim2.new(0, 0, 0, 6)
	detailTitleLabel.Parent = detailHeader

	detailSubtitleLabel = Instance.new("TextLabel")
	detailSubtitleLabel.Name = "DetailSubtitle"
	detailSubtitleLabel.BackgroundTransparency = 1
	detailSubtitleLabel.Font = Enum.Font.Gotham
	detailSubtitleLabel.TextSize = 16
	detailSubtitleLabel.TextWrapped = true
	detailSubtitleLabel.TextColor3 = Theme.TextSecondary
	detailSubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	detailSubtitleLabel.Size = UDim2.new(1, -20, 0, 40)
	detailSubtitleLabel.Position = UDim2.new(0, 0, 0, 50)
	detailSubtitleLabel.Parent = detailHeader

	detailContainer = Instance.new("Frame")
	detailContainer.Name = "DetailContainer"
	detailContainer.BackgroundTransparency = 1
	detailContainer.Size = UDim2.new(1, 0, 1, -110)
	detailContainer.Position = UDim2.new(0, 0, 0, 110)
	detailContainer.Parent = detailShell

	local detailPadding = Instance.new("UIPadding", detailContainer)
	detailPadding.PaddingTop = UDim.new(0, 0)
	detailPadding.PaddingBottom = UDim.new(0, 16)
	detailPadding.PaddingRight = UDim.new(0, 12)

	heroPanel = Instance.new("Frame")
	heroPanel.Name = "HeroPanel"
	heroPanel.Size = UDim2.new(0.36, 0, 1, 0)
	heroPanel.BackgroundColor3 = Theme.PrimaryUI_Light
	heroPanel.BackgroundTransparency = 0.15
	heroPanel.Parent = glass

	local heroCorner = Instance.new("UICorner", heroPanel)
	heroCorner.CornerRadius = UDim.new(0, 22)

	local heroStroke = Instance.new("UIStroke", heroPanel)
	heroStroke.Color = Theme.OutlineSoft
	heroStroke.Transparency = 0.55
	heroStroke.Thickness = 1.2

	local heroPadding = Instance.new("UIPadding", heroPanel)
	heroPadding.PaddingTop = UDim.new(0, 32)
	heroPadding.PaddingLeft = UDim.new(0, 28)
	heroPadding.PaddingRight = UDim.new(0, 28)
	heroPadding.PaddingBottom = UDim.new(0, 32)

	heroHalo = Instance.new("Frame", heroPanel)
	heroHalo.Name = "HeroHalo"
	heroHalo.Size = UDim2.new(0, 120, 0, 120)
	heroHalo.AnchorPoint = Vector2.new(0.5, 0)
	heroHalo.Position = UDim2.new(0.5, 0, 0, -40)
	heroHalo.BackgroundColor3 = Theme.Accent
	heroHalo.BackgroundTransparency = 0.85
	Instance.new("UICorner", heroHalo).CornerRadius = UDim.new(1, 0)

	heroTitleLabel = Instance.new("TextLabel")
	heroTitleLabel.Name = "HeroTitle"
	heroTitleLabel.Font = Enum.Font.GothamBold
	heroTitleLabel.TextSize = 26
	heroTitleLabel.TextColor3 = Theme.TextPrimary
	heroTitleLabel.BackgroundTransparency = 1
	heroTitleLabel.TextWrapped = true
	heroTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	heroTitleLabel.Size = UDim2.new(1, 0, 0, 72)
	heroTitleLabel.Parent = heroPanel

	heroSubtitleLabel = Instance.new("TextLabel")
	heroSubtitleLabel.Name = "HeroSubtitle"
	heroSubtitleLabel.Font = Enum.Font.Gotham
	heroSubtitleLabel.TextSize = 17
	heroSubtitleLabel.TextColor3 = Theme.TextSecondary
	heroSubtitleLabel.BackgroundTransparency = 1
	heroSubtitleLabel.TextWrapped = true
	heroSubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	heroSubtitleLabel.Size = UDim2.new(1, 0, 0, 90)
	heroSubtitleLabel.Position = UDim2.new(0, 0, 0, 80)
	heroSubtitleLabel.Parent = heroPanel

	heroChipsContainer = Instance.new("Frame")
	heroChipsContainer.Name = "HeroChips"
	heroChipsContainer.BackgroundTransparency = 1
	heroChipsContainer.Size = UDim2.new(1, 0, 0, 120)
	heroChipsContainer.Position = UDim2.new(0, 0, 0, 188)
	heroChipsContainer.Parent = heroPanel

	local chipsLayout = Instance.new("UIListLayout", heroChipsContainer)
	chipsLayout.FillDirection = Enum.FillDirection.Vertical
	chipsLayout.Padding = UDim.new(0, 8)
	chipsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	chipsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	chipsLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local chipsPadding = Instance.new("UIPadding", heroChipsContainer)
	chipsPadding.PaddingTop = UDim.new(0, 8)
	chipsPadding.PaddingBottom = UDim.new(0, 8)
	chipsPadding.PaddingRight = UDim.new(0, 0)
	chipsPadding.PaddingLeft = UDim.new(0, 0)

	for _, key in ipairs(orderedPanelKeys) do
		local config = panelsConfig[key]
		buildNavButton(navListFrame, key, config)
	end

	mainShell.BackgroundTransparency = 1
end

local function UpdatePlaySummary()
	if not playSummaryLabel then return end
	local roleText = selectedRoleData and selectedRoleData.Text or "Не обрано"
	local stationText = selectedStationData and selectedStationData.Name or "Не обрано"
	playSummaryLabel.Text = string.format("Роль: %s    •    Станція: %s", roleText, stationText)
end

local function EvaluateSpawnPermission()
	local roleSelected = selectedRoleData ~= nil
	local stationSelected = selectedStationData ~= nil
	local roleMatchesStation = true

	if stationSelected and selectedStationData.RequiredRole then
		roleMatchesStation = roleSelected and (selectedStationData.RequiredRole == selectedRoleData.Text)
	end

	local stationRequirementMet = stationSelected

	local dspStationValid = true
	if roleSelected and selectedRoleData.TeamName == "ЧПС" then
		if not stationSelected or not selectedStationData.IsDspStation then
			dspStationValid = false
		end
	end

	local dspStationOccupied = false
	if roleSelected and selectedRoleData.TeamName == "ЧПС" and stationSelected then
		local dspTeam = Teams:FindFirstChild("ЧПС")
		local attributeName = selectedStationData.SpawnerName .. "_OccupiedBy"
		local occupier = dspTeam and dspTeam:GetAttribute(attributeName)
		if occupier and occupier > 0 and occupier ~= player.UserId then
			dspStationOccupied = true
		end
	end

	local roleLimitOk = true
	if roleSelected and selectedRoleData.MaxPlayers and selectedRoleData.MaxPlayers > 0 then
		local team = Teams:FindFirstChild(selectedRoleData.TeamName)
		if team then
			local currentPlayers = #team:GetPlayers()
			local playerIsInTeam = (player.Team == team)
			if currentPlayers >= selectedRoleData.MaxPlayers and not playerIsInTeam then
				roleLimitOk = false
			end
		end
	end

	local expRequirementMet = true
	if roleSelected and selectedRoleData.RequiredEXP and expStat.Value < selectedRoleData.RequiredEXP then
		expRequirementMet = false
	end

	return roleSelected and stationRequirementMet and roleMatchesStation and dspStationValid and not dspStationOccupied and roleLimitOk and expRequirementMet
end

function UpdateSpawnButtonState()
	if not finalPlayButton or not finalPlayButton.Parent then return end
	local canPlay = EvaluateSpawnPermission()
	local stroke = finalPlayButton:FindFirstChildOfClass("UIStroke")

	if canPlay then
		TweenService:Create(finalPlayButton, tweenInfoEnter, { BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Background }):Play()
		if stroke then TweenService:Create(stroke, tweenInfoEnter, { Color = Theme.Accent, Transparency = 1 }):Play() end
		finalPlayButton.Active = true
		finalPlayButton.Selectable = true
	else
		TweenService:Create(finalPlayButton, tweenInfoLeave, { BackgroundColor3 = Theme.PrimaryUI_Light, TextColor3 = Theme.Disabled }):Play()
		if stroke then TweenService:Create(stroke, tweenInfoLeave, { Color = Theme.Disabled, Transparency = 0.3 }):Play() end
		finalPlayButton.Active = false
		finalPlayButton.Selectable = false
	end
end

function UpdateSpawnButtonText()
	if not finalPlayButton or not finalPlayButton.Parent then return end
	if selectedRoleData then
		if selectedRoleData.TeamName == "Machinist" then
			finalPlayButton.Text = "ВИЇХАТИ"
		elseif selectedRoleData.TeamName == "Passanger" then
			finalPlayButton.Text = "В ДОРОГУ"
		else
			finalPlayButton.Text = "ПОСТУПИТИ НА ЗМІНУ"
		end
	else
		finalPlayButton.Text = "ВИЇХАТИ"
	end
end

function UpdateRoleButtonsVisuals()
	if next(roleButtonElements) == nil then return end

	for teamNameKey, elements in pairs(roleButtonElements) do
		local roleData = elements.data
		local titleLabel = elements.titleLabel
		local taglineLabel = elements.taglineLabel
		local metaLabel = elements.metaLabel
		local frame = elements.frame
		local accent = elements.accent
		local button = elements.button

		-- Перевірка чи елементи ще існують
		if not frame or not frame.Parent then continue end

		local canSelect = true
		local isUnavailable = roleData.Unavailable == true
		local metaInfo = {}

		local team = Teams:FindFirstChild(roleData.TeamName)
		if roleData.MaxPlayers and roleData.MaxPlayers > 0 then
			local currentPlayers = team and #team:GetPlayers() or 0
			table.insert(metaInfo, string.format("%d / %d у зміні", currentPlayers, roleData.MaxPlayers))
			local playerIsInTeam = team and player.Team == team
			if currentPlayers >= roleData.MaxPlayers and not playerIsInTeam then
				canSelect = false
			end
		end

		if roleData.RequiredEXP then
			table.insert(metaInfo, string.format("Потрібно %d EXP", roleData.RequiredEXP))
			if expStat.Value < roleData.RequiredEXP then
				canSelect = false
			end
		end

		if isUnavailable then
			canSelect = false
			metaLabel.Text = "⚠️ ТИМЧАСОВО НЕДОСТУПНО"
			metaLabel.TextColor3 = Theme.Error
		else
			metaLabel.Text = (#metaInfo > 0) and table.concat(metaInfo, "  •  ") or "Без обмежень"
		end

		button.Active = canSelect
		local isSelected = selectedRoleData and selectedRoleData.TeamName == roleData.TeamName

		if not canSelect then
			TweenService:Create(frame, tweenInfoLeave, { BackgroundColor3 = Theme.PrimaryUI, BackgroundTransparency = 0.45 }):Play()
			TweenService:Create(titleLabel, tweenInfoLeave, { TextColor3 = Theme.Disabled }):Play()
			TweenService:Create(taglineLabel, tweenInfoLeave, { TextColor3 = Theme.Disabled }):Play()
			local metaColor = isUnavailable and Theme.Error or Theme.Disabled
			TweenService:Create(metaLabel, tweenInfoLeave, { TextColor3 = metaColor }):Play()
			TweenService:Create(accent, tweenInfoLeave, { BackgroundColor3 = Theme.Disabled }):Play()

			if isSelected then
				selectedRoleData = nil
			end
		elseif isSelected then
			TweenService:Create(frame, tweenInfoEnter, { BackgroundColor3 = roleData.Color, BackgroundTransparency = 0.05 }):Play()
			TweenService:Create(titleLabel, tweenInfoEnter, { TextColor3 = Theme.Background }):Play()
			TweenService:Create(taglineLabel, tweenInfoEnter, { TextColor3 = Theme.Background }):Play()
			TweenService:Create(metaLabel, tweenInfoEnter, { TextColor3 = Theme.Background }):Play()
			TweenService:Create(accent, tweenInfoEnter, { BackgroundColor3 = Theme.Background }):Play()
		else
			TweenService:Create(frame, tweenInfoLeave, { BackgroundColor3 = Theme.PrimaryUI, BackgroundTransparency = 0.15 }):Play()
			TweenService:Create(titleLabel, tweenInfoLeave, { TextColor3 = roleData.Color }):Play()
			TweenService:Create(taglineLabel, tweenInfoLeave, { TextColor3 = Theme.TextSecondary }):Play()
			TweenService:Create(metaLabel, tweenInfoLeave, { TextColor3 = Theme.TextSecondary }):Play()
			TweenService:Create(accent, tweenInfoLeave, { BackgroundColor3 = roleData.Color }):Play()
		end
	end
end

function SelectRole(cardFrame, roleData)
	if selectedRoleData and selectedRoleData.TeamName == roleData.TeamName then
		selectedRoleData = nil
	else
		selectedRoleData = roleData
	end
	UpdateRoleButtonsVisuals()
	UpdatePlaySummary()
	UpdateSpawnButtonState()
	UpdateSpawnButtonText()
end

local function setStationCardState(elements, state)
	if not elements or not elements.frame or not elements.frame.Parent then return end

	local frame = elements.frame
	local badge = elements.badge
	local titleLabel = elements.titleLabel
	local codeLabel = elements.codeLabel
	local statusLabel = elements.statusLabel
	local baseColor = elements.baseColor

	if state == "selected" then
		TweenService:Create(frame, tweenInfoEnter, { BackgroundColor3 = Theme.StationSelected, BackgroundTransparency = 0.05 }):Play()
		TweenService:Create(badge, tweenInfoEnter, { BackgroundColor3 = Theme.Background, Size = UDim2.new(0, 18, 0, 18) }):Play()
		TweenService:Create(titleLabel, tweenInfoEnter, { TextColor3 = Theme.Background }):Play()
		TweenService:Create(codeLabel, tweenInfoEnter, { TextColor3 = Theme.Background }):Play()
		TweenService:Create(statusLabel, tweenInfoEnter, { TextColor3 = Theme.Background }):Play()
	elseif state == "disabled" then
		TweenService:Create(frame, tweenInfoLeave, { BackgroundColor3 = Theme.PrimaryUI, BackgroundTransparency = 0.45 }):Play()
		TweenService:Create(badge, tweenInfoLeave, { BackgroundColor3 = Theme.Error, Size = UDim2.new(0, 16, 0, 16) }):Play()
		TweenService:Create(titleLabel, tweenInfoLeave, { TextColor3 = Theme.Error }):Play()
		TweenService:Create(codeLabel, tweenInfoLeave, { TextColor3 = Theme.Error }):Play()
		TweenService:Create(statusLabel, tweenInfoLeave, { TextColor3 = Theme.Error }):Play()
	else
		TweenService:Create(frame, tweenInfoLeave, { BackgroundColor3 = Theme.PrimaryUI, BackgroundTransparency = 0.2 }):Play()
		TweenService:Create(badge, tweenInfoLeave, { BackgroundColor3 = baseColor, Size = UDim2.new(0, 14, 0, 14) }):Play()
		TweenService:Create(titleLabel, tweenInfoLeave, { TextColor3 = Theme.TextPrimary }):Play()
		TweenService:Create(codeLabel, tweenInfoLeave, { TextColor3 = Theme.TextSecondary }):Play()
		TweenService:Create(statusLabel, tweenInfoLeave, { TextColor3 = Theme.TextSecondary }):Play()
	end
	elements.state = state
end

local function SelectStation(button, stationData)
	if selectedStationCircle and stationGuiElementsMap[selectedStationCircle] then
		local previous = stationGuiElementsMap[selectedStationCircle]
		if previous.state ~= "disabled" then
			setStationCardState(previous, "idle")
		end
	end
	selectedStationCircle = button
	selectedStationData = stationData
	local current = stationGuiElementsMap[button]
	if current then
		setStationCardState(current, "selected")
	end
	UpdatePlaySummary()
	UpdateSpawnButtonState()
end

function UpdateDspStationAvailability()
	for button, elements in pairs(stationGuiElementsMap) do
		if not elements or not elements.frame or not elements.frame.Parent then continue end

		local stationData = elements.data
		if stationData.IsDspStation then
			local dspTeam = Teams:FindFirstChild("ЧПС")
			local attributeName = stationData.SpawnerName .. "_OccupiedBy"
			local occupier = dspTeam and dspTeam:GetAttribute(attributeName)
			if occupier and occupier > 0 and occupier ~= player.UserId then
				elements.button:SetAttribute("IsOccupied", true)
				elements.statusLabel.Text = "Зайнята"
				if selectedStationCircle == button then
					selectedStationCircle = nil
					selectedStationData = nil
				end
				setStationCardState(elements, "disabled")
			else
				elements.button:SetAttribute("IsOccupied", false)
				elements.statusLabel.Text = stationData.IsTerminal and "Тупік" or "Вільна"
				if elements.state ~= "selected" then
					setStationCardState(elements, "idle")
				end
			end
		else
			if elements.state ~= "selected" then
				setStationCardState(elements, "idle")
			end
		end
	end
	UpdatePlaySummary()
	UpdateSpawnButtonState()
end

local function TryFinalizeSpawn()
	if not finalPlayButton then return end
	if not finalPlayButton.Active then
		local isShaking = finalPlayButton:GetAttribute("isShaking")
		if not isShaking then
			finalPlayButton:SetAttribute("isShaking", true)
			local origin = finalPlayButton.Position
			local tween = TweenService:Create(finalPlayButton, shakeTweenInfo, { Position = origin + UDim2.new(0, 6, 0, 0) })
			tween.Completed:Connect(function()
				if finalPlayButton and finalPlayButton.Parent then
					finalPlayButton.Position = origin
					finalPlayButton:SetAttribute("isShaking", nil)
				end
			end)
			tween:Play()
		end
		return
	end

	if not selectedRoleData then
		UpdateSpawnButtonState()
		return
	end

	local teamToRequest = selectedRoleData.TeamName
	local stationNameToRequest = selectedStationData and selectedStationData.SpawnerName or nil

	if teamToRequest then
		local spawnSound = Instance.new("Sound")
		spawnSound.SoundId = "rbxassetid://12221944"
		spawnSound.Parent = Workspace
		spawnSound:Play()
		spawnSound.Ended:Connect(function()
			if spawnSound and spawnSound.Parent then
				spawnSound:Destroy()
			end
		end)

		changeTeamEvent:FireServer(teamToRequest, stationNameToRequest)
		hasStartedPlaying = true
		CloseMainMenu()
	end
end

function BuildPlayPanel(container)
	roleButtonElements = {}
	stationGuiElementsMap = {}
	selectedRoleData = nil
	selectedStationData = nil
	selectedStationCircle = nil
	playSummaryLabel = nil

	if finalPlayButtonConnection then
		finalPlayButtonConnection:Disconnect()
		finalPlayButtonConnection = nil
	end
	finalPlayButton = nil

	local columnsFrame = Instance.new("Frame")
	columnsFrame.Name = "Columns"
	columnsFrame.Size = UDim2.new(1, 0, 1, -90)
	columnsFrame.BackgroundTransparency = 1
	columnsFrame.Parent = container

	local columnsLayout = Instance.new("UIListLayout", columnsFrame)
	columnsLayout.FillDirection = Enum.FillDirection.Horizontal
	columnsLayout.Padding = UDim.new(0, 18)
	columnsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	columnsLayout.VerticalAlignment = Enum.VerticalAlignment.Top

	local rolesColumn = Instance.new("Frame", columnsFrame)
	rolesColumn.Name = "RolesColumn"
	rolesColumn.Size = UDim2.new(0.46, 0, 1, 0)
	rolesColumn.BackgroundColor3 = Theme.PrimaryUI
	rolesColumn.BackgroundTransparency = 0.2
	Instance.new("UICorner", rolesColumn).CornerRadius = UDim.new(0, 18)

	local rolesStroke = Instance.new("UIStroke", rolesColumn)
	rolesStroke.Color = Theme.OutlineSoft
	rolesStroke.Transparency = 0.4

	local rolesPadding = Instance.new("UIPadding", rolesColumn)
	rolesPadding.PaddingTop = UDim.new(0, 20)
	rolesPadding.PaddingBottom = UDim.new(0, 20)
	rolesPadding.PaddingLeft = UDim.new(0, 20)
	rolesPadding.PaddingRight = UDim.new(0, 14)

	local rolesTitle = Instance.new("TextLabel", rolesColumn)
	rolesTitle.Text = "РОЛІ"
	rolesTitle.Font = Enum.Font.GothamBold
	rolesTitle.TextSize = 22
	rolesTitle.TextColor3 = Theme.TextPrimary
	rolesTitle.BackgroundTransparency = 1
	rolesTitle.TextXAlignment = Enum.TextXAlignment.Left
	rolesTitle.Size = UDim2.new(1, 0, 0, 28)

	local rolesSubtitle = Instance.new("TextLabel", rolesColumn)
	rolesSubtitle.Text = "Виберіть, за кого хочете грати"
	rolesSubtitle.Font = Enum.Font.Gotham
	rolesSubtitle.TextSize = 15
	rolesSubtitle.TextColor3 = Theme.TextSecondary
	rolesSubtitle.BackgroundTransparency = 1
	rolesSubtitle.TextXAlignment = Enum.TextXAlignment.Left
	rolesSubtitle.Size = UDim2.new(1, 0, 0, 24)
	rolesSubtitle.Position = UDim2.new(0, 0, 0, 28)

	local rolesScroll = Instance.new("ScrollingFrame", rolesColumn)
	rolesScroll.Name = "RolesScroll"
	rolesScroll.Size = UDim2.new(1, -6, 1, -70)
	rolesScroll.Position = UDim2.new(0, 0, 0, 60)
	rolesScroll.BackgroundTransparency = 1
	rolesScroll.BorderSizePixel = 0
	rolesScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	rolesScroll.CanvasSize = UDim2.new()
	rolesScroll.ScrollBarThickness = 4

	local rolesListLayout = Instance.new("UIListLayout", rolesScroll)
	rolesListLayout.FillDirection = Enum.FillDirection.Vertical
	rolesListLayout.Padding = UDim.new(0, 12)
	rolesListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	rolesListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

	for _, roleDataItem in ipairs(rolesData) do
		local card = Instance.new("Frame", rolesScroll)
		card.Name = roleDataItem.TeamName .. "Card"
		card.Size = UDim2.new(1, -6, 0, 96)
		card.BackgroundColor3 = Theme.PrimaryUI
		card.BackgroundTransparency = 0.15
		Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)

		local accent = Instance.new("Frame", card)
		accent.Name = "Accent"
		accent.Size = UDim2.new(0, 6, 1, -24)
		accent.Position = UDim2.new(0, -10, 0, 12)
		accent.BackgroundColor3 = roleDataItem.Color
		accent.BorderSizePixel = 0
		Instance.new("UICorner", accent).CornerRadius = UDim.new(0.5, 0)

		local cardPadding = Instance.new("UIPadding", card)
		cardPadding.PaddingTop = UDim.new(0, 12)
		cardPadding.PaddingBottom = UDim.new(0, 12)
		cardPadding.PaddingLeft = UDim.new(0, 18)
		cardPadding.PaddingRight = UDim.new(0, 18)

		local titleLabel = Instance.new("TextLabel", card)
		titleLabel.Text = roleDataItem.Text
		titleLabel.Font = Enum.Font.GothamBold
		titleLabel.TextSize = 20
		titleLabel.TextColor3 = roleDataItem.Color
		titleLabel.BackgroundTransparency = 1
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.Size = UDim2.new(1, 0, 0, 26)

		local taglineLabel = Instance.new("TextLabel", card)
		taglineLabel.Text = roleDataItem.Tagline or ""
		taglineLabel.Font = Enum.Font.Gotham
		taglineLabel.TextSize = 14
		taglineLabel.TextColor3 = Theme.TextSecondary
		taglineLabel.BackgroundTransparency = 1
		taglineLabel.TextWrapped = true
		taglineLabel.TextXAlignment = Enum.TextXAlignment.Left
		taglineLabel.Size = UDim2.new(1, 0, 0, 34)
		taglineLabel.Position = UDim2.new(0, 0, 0, 28)

		local metaLabel = Instance.new("TextLabel", card)
		metaLabel.Text = ""
		metaLabel.Font = Enum.Font.GothamMedium
		metaLabel.TextSize = 13
		metaLabel.TextColor3 = Theme.TextSecondary
		metaLabel.BackgroundTransparency = 1
		metaLabel.TextXAlignment = Enum.TextXAlignment.Left
		metaLabel.Size = UDim2.new(1, 0, 0, 18)
		metaLabel.Position = UDim2.new(0, 0, 0, 62)

		local button = Instance.new("TextButton", card)
		button.BackgroundTransparency = 1
		button.Size = UDim2.new(1, 0, 1, 0)
		button.Text = ""
		button.AutoButtonColor = false
		button.MouseButton1Click:Connect(function()
			if button.Active then
				SelectRole(card, roleDataItem)
			end
		end)

		roleButtonElements[roleDataItem.TeamName] = {
			frame = card,
			accent = accent,
			titleLabel = titleLabel,
			taglineLabel = taglineLabel,
			metaLabel = metaLabel,
			button = button,
			data = roleDataItem
		}
	end

	local stationsColumn = Instance.new("Frame", columnsFrame)
	stationsColumn.Name = "StationsColumn"
	stationsColumn.Size = UDim2.new(0.54, -18, 1, 0)
	stationsColumn.BackgroundColor3 = Theme.PrimaryUI
	stationsColumn.BackgroundTransparency = 0.2
	Instance.new("UICorner", stationsColumn).CornerRadius = UDim.new(0, 18)

	local stationsStroke = Instance.new("UIStroke", stationsColumn)
	stationsStroke.Color = Theme.OutlineSoft
	stationsStroke.Transparency = 0.4

	local stationsPadding = Instance.new("UIPadding", stationsColumn)
	stationsPadding.PaddingTop = UDim.new(0, 20)
	stationsPadding.PaddingBottom = UDim.new(0, 20)
	stationsPadding.PaddingLeft = UDim.new(0, 26)
	stationsPadding.PaddingRight = UDim.new(0, 26)

	local stationsTitle = Instance.new("TextLabel", stationsColumn)
	stationsTitle.Text = "СХЕМА ЛІНІЇ"
	stationsTitle.Font = Enum.Font.GothamBold
	stationsTitle.TextSize = 22
	stationsTitle.TextColor3 = Theme.TextPrimary
	stationsTitle.BackgroundTransparency = 1
	stationsTitle.TextXAlignment = Enum.TextXAlignment.Left
	stationsTitle.Size = UDim2.new(1, 0, 0, 28)

	local stationsSubtitle = Instance.new("TextLabel", stationsColumn)
	stationsSubtitle.Text = "Оберіть станцію"
	stationsSubtitle.Font = Enum.Font.Gotham
	stationsSubtitle.TextSize = 15
	stationsSubtitle.TextColor3 = Theme.TextSecondary
	stationsSubtitle.BackgroundTransparency = 1
	stationsSubtitle.TextXAlignment = Enum.TextXAlignment.Left
	stationsSubtitle.Size = UDim2.new(1, 0, 0, 24)
	stationsSubtitle.Position = UDim2.new(0, 0, 0, 28)

	local stationsScroll = Instance.new("ScrollingFrame", stationsColumn)
	stationsScroll.Name = "StationsScroll"
	stationsScroll.Size = UDim2.new(1, 0, 1, -72)
	stationsScroll.Position = UDim2.new(0, 0, 0, 60)
	stationsScroll.BackgroundTransparency = 1
	stationsScroll.BorderSizePixel = 0
	stationsScroll.ScrollBarThickness = 4
	stationsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	stationsScroll.CanvasSize = UDim2.new()

	local stationListLayout = Instance.new("UIListLayout", stationsScroll)
	stationListLayout.FillDirection = Enum.FillDirection.Vertical
	stationListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	stationListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	stationListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	stationListLayout.Padding = UDim.new(0, 10)

	local lineAccentColor = Color3.fromRGB(205, 0, 0)

	for index, stationData in ipairs(stationsData) do
		local card = Instance.new("Frame", stationsScroll)
		card.Name = stationData.SpawnerName .. "Card"
		card.Size = UDim2.new(1, -6, 0, 70)
		card.BackgroundColor3 = Theme.PrimaryUI
		card.BackgroundTransparency = 0.2
		card.LayoutOrder = index
		Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

		local cardPadding = Instance.new("UIPadding", card)
		cardPadding.PaddingTop = UDim.new(0, 12)
		cardPadding.PaddingBottom = UDim.new(0, 12)
		cardPadding.PaddingLeft = UDim.new(0, 52)
		cardPadding.PaddingRight = UDim.new(0, 16)

		local line = Instance.new("Frame", card)
		line.Size = UDim2.new(0, 2, 1, 14)
		line.Position = UDim2.new(0, -26, 0, -7)
		line.BackgroundColor3 = lineAccentColor
		line.BorderSizePixel = 0

		local badge = Instance.new("Frame", card)
		badge.Name = "Badge"
		badge.Size = UDim2.new(0, 14, 0, 14)
		badge.Position = UDim2.new(0, -38, 0.5, 0)
		badge.AnchorPoint = Vector2.new(0.5, 0.5)
		badge.BackgroundColor3 = stationData.RequiredRole and Theme.Warning or (stationData.IsTerminal and Theme.Accent or lineAccentColor)
		badge.BorderSizePixel = 0
		Instance.new("UICorner", badge).CornerRadius = UDim.new(1, 0)

		local titleLabel = Instance.new("TextLabel", card)
		titleLabel.Text = stationData.Name
		titleLabel.Font = Enum.Font.GothamBold
		titleLabel.TextSize = 18
		titleLabel.TextColor3 = Theme.TextPrimary
		titleLabel.BackgroundTransparency = 1
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.Size = UDim2.new(1, 0, 0, 28)

		local codeLabel = Instance.new("TextLabel", card)
		codeLabel.Text = stationData.Code or ""
		codeLabel.Font = Enum.Font.GothamMedium
		codeLabel.TextSize = 14
		codeLabel.TextColor3 = Theme.TextSecondary
		codeLabel.BackgroundTransparency = 1
		codeLabel.TextXAlignment = Enum.TextXAlignment.Left
		codeLabel.Size = UDim2.new(0.6, 0, 0, 22)
		codeLabel.Position = UDim2.new(0, 0, 0, 32)

		local statusLabel = Instance.new("TextLabel", card)
		statusLabel.Text = stationData.IsTerminal and "Тупік" or (stationData.RequiredRole or "Вільна")
		statusLabel.Font = Enum.Font.Gotham
		statusLabel.TextSize = 13
		statusLabel.TextColor3 = Theme.TextSecondary
		statusLabel.BackgroundTransparency = 1
		statusLabel.TextXAlignment = Enum.TextXAlignment.Right
		statusLabel.Size = UDim2.new(0.4, 0, 0, 22)
		statusLabel.Position = UDim2.new(0.6, 0, 0, 32)

		local button = Instance.new("TextButton", card)
		button.BackgroundTransparency = 1
		button.Size = UDim2.new(1, 0, 1, 0)
		button.Text = ""
		button.AutoButtonColor = false
		button.MouseButton1Click:Connect(function()
			if button:GetAttribute("IsOccupied") then return end
			SelectStation(button, stationData)
		end)
		button:SetAttribute("IsOccupied", false)

		stationGuiElementsMap[button] = {
			frame = card,
			badge = badge,
			titleLabel = titleLabel,
			codeLabel = codeLabel,
			statusLabel = statusLabel,
			button = button,
			baseColor = badge.BackgroundColor3,
			data = stationData,
			state = "idle"
		}
	end

	local footer = Instance.new("Frame", container)
	footer.Name = "Footer"
	footer.Size = UDim2.new(1, 0, 0, 90)
	footer.Position = UDim2.new(0, 0, 1, -90)
	footer.BackgroundTransparency = 1

	local footerLayout = Instance.new("UIListLayout", footer)
	footerLayout.FillDirection = Enum.FillDirection.Horizontal
	footerLayout.Padding = UDim.new(0, 12)
	footerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	footerLayout.VerticalAlignment = Enum.VerticalAlignment.Center

	local summaryFrame = Instance.new("Frame", footer)
	summaryFrame.Size = UDim2.new(0.62, 0, 1, 0)
	summaryFrame.BackgroundTransparency = 1

	local summaryLabel = Instance.new("TextLabel", summaryFrame)
	summaryLabel.Size = UDim2.new(1, 0, 1, 0)
	summaryLabel.BackgroundTransparency = 1
	summaryLabel.Font = Enum.Font.Gotham
	summaryLabel.TextSize = 16
	summaryLabel.TextColor3 = Theme.TextSecondary
	summaryLabel.TextXAlignment = Enum.TextXAlignment.Left
	summaryLabel.Text = "Роль: Не обрано    •    Станція: Не обрано"
	playSummaryLabel = summaryLabel

	finalPlayButton = Instance.new("TextButton", footer)
	finalPlayButton.Name = "FinalPlay"
	finalPlayButton.Size = UDim2.new(0.35, 0, 0, 56)
	finalPlayButton.AutoButtonColor = false
	finalPlayButton.Font = Enum.Font.GothamBlack
	finalPlayButton.TextSize = 20
	finalPlayButton.TextColor3 = Theme.Disabled
	finalPlayButton.BackgroundColor3 = Theme.PrimaryUI_Light
	finalPlayButton.TextWrapped = true
	Instance.new("UICorner", finalPlayButton).CornerRadius = UDim.new(0, 14)

	local playStroke = Instance.new("UIStroke", finalPlayButton)
	playStroke.Color = Theme.Disabled
	playStroke.Thickness = 1.2

	finalPlayButtonConnection = finalPlayButton.MouseButton1Click:Connect(TryFinalizeSpawn)

	UpdateRoleButtonsVisuals()
	UpdateDspStationAvailability()
	UpdatePlaySummary()
	UpdateSpawnButtonState()
	UpdateSpawnButtonText()
	SetupTeamListeners()
end

function BuildUpdatesPanel(container)
	local scroll = Instance.new("ScrollingFrame", container)
	scroll.Name = "UpdatesScroll"
	scroll.Size = UDim2.new(1, 0, 1, 0)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new()
	scroll.ScrollBarThickness = 6

	local padding = Instance.new("UIPadding", scroll)
	padding.PaddingTop = UDim.new(0, 12)
	padding.PaddingBottom = UDim.new(0, 12)
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)

	local layout = Instance.new("UIListLayout", scroll)
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.Padding = UDim.new(0, 12)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	layout.VerticalAlignment = Enum.VerticalAlignment.Top

	for index, entryText in ipairs(changelogData) do
		local card = Instance.new("Frame", scroll)
		card.Name = "Update" .. index
		card.Size = UDim2.new(1, -12, 0, 72)
		card.BackgroundColor3 = Theme.PrimaryUI
		card.BackgroundTransparency = 0.18
		Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

		local cardPadding = Instance.new("UIPadding", card)
		cardPadding.PaddingTop = UDim.new(0, 12)
		cardPadding.PaddingBottom = UDim.new(0, 12)
		cardPadding.PaddingLeft = UDim.new(0, 18)
		cardPadding.PaddingRight = UDim.new(0, 18)

		local badge = Instance.new("TextLabel", card)
		badge.Size = UDim2.new(0, 44, 0, 44)
		badge.Position = UDim2.new(0, -12, 0, -2)
		badge.BackgroundColor3 = Theme.Accent
		badge.TextColor3 = Theme.Background
		badge.Text = string.format("%02d", index)
		badge.Font = Enum.Font.GothamBlack
		badge.TextSize = 18
		badge.TextXAlignment = Enum.TextXAlignment.Center
		badge.TextYAlignment = Enum.TextYAlignment.Center
		Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 10)

		local textLabel = Instance.new("TextLabel", card)
		textLabel.Size = UDim2.new(1, -60, 1, 0)
		textLabel.Position = UDim2.new(0, 52, 0, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.TextWrapped = true
		textLabel.Font = Enum.Font.Gotham
		textLabel.TextSize = 16
		textLabel.TextColor3 = Theme.TextSecondary
		textLabel.TextXAlignment = Enum.TextXAlignment.Left
		textLabel.Text = entryText
	end
end

function BuildRulesPanel(container)
	local scroll = Instance.new("ScrollingFrame", container)
	scroll.Name = "RulesScroll"
	scroll.Size = UDim2.new(1, 0, 1, 0)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new()
	scroll.ScrollBarThickness = 6

	local padding = Instance.new("UIPadding", scroll)
	padding.PaddingTop = UDim.new(0, 10)
	padding.PaddingBottom = UDim.new(0, 10)
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)

	local layout = Instance.new("UIListLayout", scroll)
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.Padding = UDim.new(0, 10)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	layout.VerticalAlignment = Enum.VerticalAlignment.Top
	layout.SortOrder = Enum.SortOrder.LayoutOrder

	for order, item in ipairs(rulesData) do
		if item.type == "separator" then
			local spacer = Instance.new("Frame", scroll)
			spacer.Size = UDim2.new(1, 0, 0, 14)
			spacer.BackgroundTransparency = 1
			spacer.LayoutOrder = order
		elseif item.type == "subheader" then
			local header = Instance.new("TextLabel", scroll)
			header.Size = UDim2.new(1, -12, 0, 34)
			header.BackgroundTransparency = 1
			header.Font = Enum.Font.GothamBold
			header.TextSize = 22
			header.TextColor3 = Theme.TextPrimary
			header.TextXAlignment = Enum.TextXAlignment.Left
			header.Text = item.text
			header.LayoutOrder = order
		elseif item.type == "blockquote" then
			local quote = Instance.new("Frame", scroll)
			quote.Size = UDim2.new(1, -12, 0, 96)
			quote.BackgroundColor3 = Theme.PrimaryUI
			quote.BackgroundTransparency = 0.12
			quote.LayoutOrder = order
			Instance.new("UICorner", quote).CornerRadius = UDim.new(0, 14)

			local stripe = Instance.new("Frame", quote)
			stripe.Size = UDim2.new(0, 4, 1, -24)
			stripe.Position = UDim2.new(0, -8, 0, 12)
			stripe.BackgroundColor3 = Theme.Warning
			stripe.BorderSizePixel = 0

			local label = Instance.new("TextLabel", quote)
			label.RichText = true
			label.TextWrapped = true
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.GothamMedium
			label.TextSize = 18
			label.TextColor3 = Theme.TextSecondary
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Size = UDim2.new(1, -20, 1, -20)
			label.Position = UDim2.new(0, 16, 0, 10)
			label.Text = item.text
		else
			local ruleFrame = Instance.new("Frame", scroll)
			ruleFrame.Size = UDim2.new(1, -12, 0, 72)
			ruleFrame.BackgroundColor3 = Theme.PrimaryUI
			ruleFrame.BackgroundTransparency = item.type == "punishment" and 0.05 or 0.2
			ruleFrame.LayoutOrder = order
			Instance.new("UICorner", ruleFrame).CornerRadius = UDim.new(0, 10)

			local label = Instance.new("TextLabel", ruleFrame)
			label.RichText = true
			label.TextWrapped = true
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.Gotham
			label.TextSize = 16
			label.TextColor3 = (item.type == "punishment") and Theme.Error or Theme.TextSecondary
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Size = UDim2.new(1, -20, 1, -16)
			label.Position = UDim2.new(0, 12, 0, 8)
			label.Text = item.text
		end
	end
end

function BuildCreditsPanel(container)
	local scroll = Instance.new("ScrollingFrame", container)
	scroll.Name = "CreditsScroll"
	scroll.Size = UDim2.new(1, 0, 1, 0)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.CanvasSize = UDim2.new()
	scroll.ScrollBarThickness = 6

	local padding = Instance.new("UIPadding", scroll)
	padding.PaddingTop = UDim.new(0, 12)
	padding.PaddingBottom = UDim.new(0, 12)
	padding.PaddingLeft = UDim.new(0, 8)
	padding.PaddingRight = UDim.new(0, 8)

	local layout = Instance.new("UIListLayout", scroll)
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.Padding = UDim.new(0, 24)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	layout.VerticalAlignment = Enum.VerticalAlignment.Top

	local sections = {
		{ Title = "Команда", Items = {
			"<b>LeoVerem12</b> — Овнер проєкту",
			"<b>Ezh_3y</b> — Розробник",
			"<b>DEN50678</b> — Розробник"
		}},
		{ Title = "Ресурси", Items = {
			"<b>Kyiv Metrostroi Team</b> — моделі потягів",
			"<b>ZefirLover</b> — таблички",
			"<b>Mint Type</b> — шрифт Proba Nav2",
			"<b>Агенти Змін</b> — навігація",
			"<b>Metrostroi Team</b> — рельси, звуки та інші ресурси"
		}}
	}

	if (month == 10 and day >= 27 and day <= 31) or (month == 11 and day == 3) then
		table.insert(sections[2].Items, "<b>time - feel so sleep</b> — сезонна композиція")
	end

	for _, section in ipairs(sections) do
		local sectionContainer = Instance.new("Frame", scroll)
		sectionContainer.Name = section.Title .. "Container"
		sectionContainer.BackgroundTransparency = 1
		sectionContainer.AutomaticSize = Enum.AutomaticSize.Y
		sectionContainer.Size = UDim2.new(1, 0, 0, 0)

		local sectionLayout = Instance.new("UIListLayout", sectionContainer)
		sectionLayout.FillDirection = Enum.FillDirection.Vertical
		sectionLayout.Padding = UDim.new(0, 8)
		sectionLayout.SortOrder = Enum.SortOrder.LayoutOrder 

		local header = Instance.new("TextLabel", sectionContainer)
		header.Text = section.Title
		header.Font = Enum.Font.GothamBold
		header.TextSize = 20
		header.TextColor3 = Theme.TextPrimary
		header.BackgroundTransparency = 1
		header.TextXAlignment = Enum.TextXAlignment.Left
		header.Size = UDim2.new(1, -12, 0, 30)
		header.LayoutOrder = 1 

		local holder = Instance.new("Frame", sectionContainer)
		holder.Size = UDim2.new(1, -12, 0, 0)
		holder.BackgroundColor3 = Theme.PrimaryUI
		holder.BackgroundTransparency = 0.2
		holder.AutomaticSize = Enum.AutomaticSize.Y
		holder.LayoutOrder = 2 

		Instance.new("UICorner", holder).CornerRadius = UDim.new(0, 12)

		local holderPadding = Instance.new("UIPadding", holder)
		holderPadding.PaddingTop = UDim.new(0, 14)
		holderPadding.PaddingBottom = UDim.new(0, 14)
		holderPadding.PaddingLeft = UDim.new(0, 18)
		holderPadding.PaddingRight = UDim.new(0, 18)

		local holderLayout = Instance.new("UIListLayout", holder)
		holderLayout.FillDirection = Enum.FillDirection.Vertical
		holderLayout.Padding = UDim.new(0, 8)

		for _, itemText in ipairs(section.Items) do
			local itemLabel = Instance.new("TextLabel", holder)
			itemLabel.RichText = true
			itemLabel.Text = "•  " .. itemText
			itemLabel.Font = Enum.Font.Gotham
			itemLabel.TextSize = 16
			itemLabel.TextColor3 = Theme.TextSecondary
			itemLabel.BackgroundTransparency = 1
			itemLabel.TextWrapped = true
			itemLabel.TextXAlignment = Enum.TextXAlignment.Left
			itemLabel.Size = UDim2.new(1, 0, 0, 20)
			itemLabel.AutomaticSize = Enum.AutomaticSize.Y
		end
	end
end

panelsConfig.PLAY.builder = BuildPlayPanel
panelsConfig.UPDATES.builder = BuildUpdatesPanel
panelsConfig.RULES.builder = BuildRulesPanel
panelsConfig.CREDITS.builder = BuildCreditsPanel

local function EnsureMainInterface()
	if mainShell then return end
	BuildMainInterface()
	mainShell.Visible = false
	mainShell.BackgroundTransparency = 1
	if orderedPanelKeys[1] then
		SwitchPanel(orderedPanelKeys[1])
	end
end

local function SetMenuCamera()
	if menuCamera and menuCamera.FadeFrame then
		menuCamera.FadeFrame.Visible = false
		menuCamera.FadeFrame.BackgroundTransparency = 1
		menuCamera.FadeFrame.ZIndex = 0
	end
	blurEffect.Enabled = true
	if blurTween then blurTween:Cancel() end
	blurTween = TweenService:Create(blurEffect, TweenInfo.new(0.3), { Size = BLUR_AMOUNT })
	blurTween:Play()
end

local function RestorePlayerCamera()
	if blurTween then blurTween:Cancel() end
	local outTween = TweenService:Create(blurEffect, TweenInfo.new(0.3), { Size = 0 })
	outTween.Completed:Connect(function()
		if blurEffect then blurEffect.Enabled = false end
	end)
	outTween:Play()
end

function OpenMainMenu(targetPanelKey)
	local currentTime = os.clock()
	if isMenuTransitioning or (currentTime - lastMenuActionTime) < MENU_DEBOUNCE_TIME then return end
	isMenuTransitioning = true
	lastMenuActionTime = currentTime

	EnsureMainInterface()
	menuOpenRequested = false
	screenGui.Enabled = true

	if targetPanelKey then
		SwitchPanel(targetPanelKey)
	elseif not currentPanelKey and orderedPanelKeys[1] then
		SwitchPanel(orderedPanelKeys[1])
	end

	mainShell.Visible = true
	TweenService:Create(mainShell, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
	SetMenuCamera()

	local character = player.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid and originalWalkSpeed == nil then
			originalWalkSpeed = humanoid.WalkSpeed
			humanoid.WalkSpeed = 0
		end
	end

	task.delay(0.3, function()
		isMenuTransitioning = false
	end)
end

function CloseMainMenu()
	local currentTime = os.clock()
	if isMenuTransitioning or (currentTime - lastMenuActionTime) < MENU_DEBOUNCE_TIME then return end
	isMenuTransitioning = true
	lastMenuActionTime = currentTime

	local character = player.Character
	if character and originalWalkSpeed ~= nil then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid then humanoid.WalkSpeed = originalWalkSpeed end
		originalWalkSpeed = nil
	end

	RestorePlayerCamera()

	if menuCamera.IsActive then
		menuCamera:Stop()
	end

	TweenService:Create(mainShell, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1 }):Play()
	task.delay(0.22, function()
		if mainShell then mainShell.Visible = false end
		screenGui.Enabled = false
		isMenuTransitioning = false
	end)
end

-------------------------------------------------------------------------
-- ВІТАЛЬНЕ ПОВІДОМЛЕННЯ ПРО PREVIEW ВЕРСІЮ
-------------------------------------------------------------------------
local function ShowPreviewWarning(onComplete)
	hasShownPreviewWarning = true

	local warningGui = Instance.new("ScreenGui")
	warningGui.Name = "PreviewWarningGui"
	warningGui.IgnoreGuiInset = true
	warningGui.DisplayOrder = 150
	warningGui.Parent = playerGui

	-- Затемнення фону
	local overlay = Instance.new("Frame", warningGui)
	overlay.Name = "Overlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.ZIndex = 1

	TweenService:Create(overlay, TweenInfo.new(0.3), { BackgroundTransparency = 0.6 }):Play()

	-- Основна панель
	local panel = Instance.new("Frame", warningGui)
	panel.Name = "WarningPanel"
	panel.Size = UDim2.new(0, 520, 0, 340)
	panel.Position = UDim2.new(0.5, 0, 0.5, 0)
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.BackgroundColor3 = Theme.PrimaryUI
	panel.BackgroundTransparency = 0.05
	panel.ZIndex = 2

	local panelCorner = Instance.new("UICorner", panel)
	panelCorner.CornerRadius = UDim.new(0, 20)

	local panelStroke = Instance.new("UIStroke", panel)
	panelStroke.Color = Theme.Warning
	panelStroke.Thickness = 2
	panelStroke.Transparency = 0.3

	local panelGradient = Instance.new("UIGradient", panel)
	panelGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Theme.PrimaryUI_Light),
		ColorSequenceKeypoint.new(1, Theme.PrimaryUI)
	})
	panelGradient.Rotation = 90

	-- Іконка попередження
	local warningIcon = Instance.new("TextLabel", panel)
	warningIcon.Size = UDim2.new(0, 60, 0, 60)
	warningIcon.Position = UDim2.new(0.5, 0, 0, 25)
	warningIcon.AnchorPoint = Vector2.new(0.5, 0)
	warningIcon.BackgroundColor3 = Theme.Warning
	warningIcon.BackgroundTransparency = 0.1
	warningIcon.Text = "⚠️"
	warningIcon.TextSize = 32
	warningIcon.Font = Enum.Font.GothamBold
	warningIcon.TextColor3 = Theme.Background
	warningIcon.ZIndex = 3

	local iconCorner = Instance.new("UICorner", warningIcon)
	iconCorner.CornerRadius = UDim.new(1, 0)

	-- Заголовок "Увага!"
	local titleLabel = Instance.new("TextLabel", panel)
	titleLabel.Size = UDim2.new(1, -40, 0, 40)
	titleLabel.Position = UDim2.new(0.5, 0, 0, 95)
	titleLabel.AnchorPoint = Vector2.new(0.5, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "Увага!"
	titleLabel.Font = Enum.Font.GothamBlack
	titleLabel.TextSize = 32
	titleLabel.TextColor3 = Theme.Warning
	titleLabel.ZIndex = 3

	-- Основний текст
	local messageLabel = Instance.new("TextLabel", panel)
	messageLabel.Size = UDim2.new(1, -50, 0, 120)
	messageLabel.Position = UDim2.new(0.5, 0, 0, 140)
	messageLabel.AnchorPoint = Vector2.new(0.5, 0)
	messageLabel.BackgroundTransparency = 1
	messageLabel.Text = "M1 (Kyiv, Metro) перейшов в стадію Preview версій. Це означає, що ви можете замічати або бачити баги, невідповідності, або фальшиві зльоти поїздів. Ми знаємо про ці проблеми, і намагаємося вирішити якомога швидше.\n\nДякую за розуміння"
	messageLabel.Font = Enum.Font.Gotham
	messageLabel.TextSize = 16
	messageLabel.TextColor3 = Theme.TextSecondary
	messageLabel.TextWrapped = true
	messageLabel.TextXAlignment = Enum.TextXAlignment.Center
	messageLabel.ZIndex = 3

	-- Кнопка з таймером
	local confirmButton = Instance.new("TextButton", panel)
	confirmButton.Name = "ConfirmButton"
	confirmButton.Size = UDim2.new(0, 220, 0, 50)
	confirmButton.Position = UDim2.new(0.5, 0, 1, -30)
	confirmButton.AnchorPoint = Vector2.new(0.5, 1)
	confirmButton.BackgroundColor3 = Theme.Disabled
	confirmButton.TextColor3 = Theme.TextSecondary
	confirmButton.Font = Enum.Font.GothamBold
	confirmButton.TextSize = 18
	confirmButton.AutoButtonColor = false
	confirmButton.Active = false
	confirmButton.Text = "Я зрозумів. (5)"
	confirmButton.ZIndex = 3

	local buttonCorner = Instance.new("UICorner", confirmButton)
	buttonCorner.CornerRadius = UDim.new(0, 12)

	local buttonStroke = Instance.new("UIStroke", confirmButton)
	buttonStroke.Color = Theme.Disabled
	buttonStroke.Thickness = 1.5
	buttonStroke.Transparency = 0.5

	-- Таймер на кнопці
	local timerFrame = Instance.new("Frame", confirmButton)
	timerFrame.Name = "TimerProgress"
	timerFrame.Size = UDim2.new(0, 0, 1, 0)
	timerFrame.Position = UDim2.new(0, 0, 0, 0)
	timerFrame.BackgroundColor3 = Theme.Success
	timerFrame.BackgroundTransparency = 0.7
	timerFrame.ZIndex = 2

	local timerCorner = Instance.new("UICorner", timerFrame)
	timerCorner.CornerRadius = UDim.new(0, 12)

	-- Запускаємо таймер 5 секунд
	local countdown = 5

	task.spawn(function()
		-- Анімація прогрес-бару
		TweenService:Create(timerFrame, TweenInfo.new(5, Enum.EasingStyle.Linear), { Size = UDim2.new(1, 0, 1, 0) }):Play()

		while countdown > 0 do
			confirmButton.Text = string.format("Я зрозумів. (%d)", countdown)
			task.wait(1)
			countdown = countdown - 1
		end

		-- Активуємо кнопку
		confirmButton.Text = "Я зрозумів."
		confirmButton.Active = true
		confirmButton.BackgroundColor3 = Theme.Success
		confirmButton.TextColor3 = Theme.Background
		buttonStroke.Color = Theme.Success

		-- Анімація появи активної кнопки
		TweenService:Create(confirmButton, TweenInfo.new(0.2), { BackgroundColor3 = Theme.Success }):Play()
		TweenService:Create(buttonStroke, TweenInfo.new(0.2), { Color = Theme.Success, Transparency = 0 }):Play()

		-- Приховуємо прогрес-бар
		timerFrame.Visible = false
	end)

	-- Обробник кнопки
	confirmButton.MouseButton1Click:Connect(function()
		if not confirmButton.Active then return end

		-- Звук підтвердження
		local confirmSound = Instance.new("Sound")
		confirmSound.SoundId = "rbxassetid://12221944"
		confirmSound.Parent = Workspace
		confirmSound:Play()
		confirmSound.Ended:Connect(function()
			if confirmSound and confirmSound.Parent then
				confirmSound:Destroy()
			end
		end)

		-- Закриваємо вікно
		TweenService:Create(overlay, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(panel, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()

		task.delay(0.25, function()
			if warningGui and warningGui.Parent then
				warningGui:Destroy()
			end
			if onComplete then
				onComplete()
			end
		end)
	end)

	-- Hover ефекти для кнопки
	confirmButton.MouseEnter:Connect(function()
		if confirmButton.Active then
			TweenService:Create(confirmButton, tweenInfoEnter, { BackgroundColor3 = Color3.fromRGB(120, 255, 180) }):Play()
		end
	end)

	confirmButton.MouseLeave:Connect(function()
		if confirmButton.Active then
			TweenService:Create(confirmButton, tweenInfoLeave, { BackgroundColor3 = Theme.Success }):Play()
		end
	end)
end

local function ProceedToNextStep(targetPanelKey)
	rulesAccepted = true
	if rulesWindow then
		TweenService:Create(rulesWindow, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1 }):Play()
		task.delay(0.2, function()
			if rulesWindow then rulesWindow:Destroy() end
			rulesWindow = nil
		end)
	end
	OpenMainMenu(targetPanelKey or "UPDATES")
end

local function ShowConfirmationPrompt()
	if not rulesWindow then return end

	local overlay = Instance.new("Frame", rulesWindow)
	overlay.Name = "ConfirmOverlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.ZIndex = 120

	TweenService:Create(overlay, TweenInfo.new(0.2), { BackgroundTransparency = 0.6 }):Play()

	local prompt = Instance.new("Frame", overlay)
	prompt.Name = "ConfirmCard"
	prompt.Size = UDim2.new(0, 420, 0, 220)
	prompt.Position = UDim2.new(0.5, 0, 0.5, 0)
	prompt.AnchorPoint = Vector2.new(0.5, 0.5)
	prompt.BackgroundColor3 = Theme.PrimaryUI
	prompt.BackgroundTransparency = 0.05
	prompt.ZIndex = 121
	Instance.new("UICorner", prompt).CornerRadius = UDim.new(0, 16)

	local promptStroke = Instance.new("UIStroke", prompt)
	promptStroke.Color = Theme.OutlineSoft
	promptStroke.Transparency = 0.4

	local textLabel = Instance.new("TextLabel", prompt)
	textLabel.Size = UDim2.new(1, -40, 0, 110)
	textLabel.Position = UDim2.new(0.5, 0, 0, 26)
	textLabel.AnchorPoint = Vector2.new(0.5, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.RichText = true
	textLabel.TextWrapped = true
	textLabel.Font = Enum.Font.Gotham
	textLabel.TextSize = 18
	textLabel.TextColor3 = Theme.TextPrimary
	textLabel.TextXAlignment = Enum.TextXAlignment.Center
	textLabel.Text = "<b>Ви впевнені, що ознайомились із правилами?</b>\n<font color='#8a94b7'>Незнання не звільняє від відповідальності.</font>"
	textLabel.ZIndex = 122

	local buttonsHolder = Instance.new("Frame", prompt)
	buttonsHolder.Size = UDim2.new(1, -60, 0, 50)
	buttonsHolder.Position = UDim2.new(0.5, 0, 1, -30)
	buttonsHolder.AnchorPoint = Vector2.new(0.5, 1)
	buttonsHolder.BackgroundTransparency = 1
	buttonsHolder.ZIndex = 122

	local buttonsLayout = Instance.new("UIListLayout", buttonsHolder)
	buttonsLayout.FillDirection = Enum.FillDirection.Horizontal
	buttonsLayout.Padding = UDim.new(0, 12)
	buttonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local acceptButton = Instance.new("TextButton", buttonsHolder)
	acceptButton.Size = UDim2.new(0.45, 0, 1, 0)
	acceptButton.BackgroundColor3 = Theme.Success
	acceptButton.TextColor3 = Theme.Background
	acceptButton.Font = Enum.Font.GothamBold
	acceptButton.TextSize = 16
	acceptButton.AutoButtonColor = false
	acceptButton.Text = "Так, я ознайомився"
	acceptButton.ZIndex = 123
	Instance.new("UICorner", acceptButton).CornerRadius = UDim.new(0, 10)

	local backButton = Instance.new("TextButton", buttonsHolder)
	backButton.Size = UDim2.new(0.45, 0, 1, 0)
	backButton.BackgroundColor3 = Theme.Error
	backButton.TextColor3 = Theme.Background
	backButton.Font = Enum.Font.GothamBold
	backButton.TextSize = 16
	backButton.AutoButtonColor = false
	backButton.Text = "Ще читаю"
	backButton.ZIndex = 123
	Instance.new("UICorner", backButton).CornerRadius = UDim.new(0, 10)

	acceptButton.MouseButton1Click:Connect(function()
		ProceedToNextStep("UPDATES")
	end)

	backButton.MouseButton1Click:Connect(function()
		TweenService:Create(overlay, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()
		backButton.Active = false
		acceptButton.Active = false
		task.delay(0.16, function()
			if overlay and overlay.Parent then overlay:Destroy() end
		end)
		rulesStartTime = os.clock()
	end)
end

local function HandleRulesAccepted()
	if os.clock() - rulesStartTime < 5 then
		ShowConfirmationPrompt()
	else
		ProceedToNextStep("UPDATES")
	end
end

function CreateAndShowRulesWindow()
	if hasShownInitialWindows then return end
	hasShownInitialWindows = true

	EnsureMainInterface()
	screenGui.Enabled = true
	SetMenuCamera()

	local overlay = Instance.new("Frame")
	overlay.Name = "RulesOverlay"
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.ZIndex = 90
	overlay.Parent = screenGui

	TweenService:Create(overlay, TweenInfo.new(0.3), { BackgroundTransparency = 0.25 }):Play()
	rulesWindow = overlay

	local panel = Instance.new("Frame", overlay)
	panel.Name = "RulesPanel"
	panel.Size = UDim2.new(0.75, 0, 0.78, 0)
	panel.Position = UDim2.new(0.5, 0, 0.5, 0)
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.BackgroundColor3 = Theme.PrimaryUI
	panel.BackgroundTransparency = 0.1
	panel.ZIndex = 95
	Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 24)

	local panelStroke = Instance.new("UIStroke", panel)
	panelStroke.Color = Theme.OutlineSoft
	panelStroke.Transparency = 0.4

	local panelPadding = Instance.new("UIPadding", panel)
	panelPadding.PaddingTop = UDim.new(0, 26)
	panelPadding.PaddingBottom = UDim.new(0, 26)
	panelPadding.PaddingLeft = UDim.new(0, 28)
	panelPadding.PaddingRight = UDim.new(0, 28)

	local titleLabel = Instance.new("TextLabel", panel)
	titleLabel.Text = "Регламент проєкту"
	titleLabel.Font = Enum.Font.GothamBlack
	titleLabel.TextSize = 28
	titleLabel.TextColor3 = Theme.TextPrimary
	titleLabel.BackgroundTransparency = 1
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Size = UDim2.new(1, 0, 0, 34)
	titleLabel.ZIndex = 96

	local subtitleLabel = Instance.new("TextLabel", panel)
	subtitleLabel.Text = "Витратьте хвилину, щоб ознайомитись. Усі блоки згруповано за ролями."
	subtitleLabel.Font = Enum.Font.Gotham
	subtitleLabel.TextSize = 16
	subtitleLabel.TextColor3 = Theme.TextSecondary
	subtitleLabel.BackgroundTransparency = 1
	subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	subtitleLabel.TextWrapped = true
	subtitleLabel.Size = UDim2.new(1, 0, 0, 40)
	subtitleLabel.Position = UDim2.new(0, 0, 0, 36)
	subtitleLabel.ZIndex = 96

	local contentContainer = Instance.new("Frame", panel)
	contentContainer.Name = "Content"
	contentContainer.Size = UDim2.new(1, 0, 1, -140)
	contentContainer.Position = UDim2.new(0, 0, 0, 86)
	contentContainer.BackgroundTransparency = 1
	contentContainer.ZIndex = 96

	BuildRulesPanel(contentContainer)

	local acceptButton = Instance.new("TextButton", panel)
	acceptButton.Name = "AcceptButton"
	acceptButton.Size = UDim2.new(0, 400, 0, 54)
	acceptButton.Position = UDim2.new(0.5, 0, 1, -20)
	acceptButton.AnchorPoint = Vector2.new(0.5, 1)
	acceptButton.BackgroundColor3 = Theme.Success
	acceptButton.TextColor3 = Theme.Background
	acceptButton.Font = Enum.Font.GothamBold
	acceptButton.TextSize = 18
	acceptButton.AutoButtonColor = false
	acceptButton.Text = "Я погоджуюсь та готовий починати"
	acceptButton.ZIndex = 96
	Instance.new("UICorner", acceptButton).CornerRadius = UDim.new(0, 14)

	acceptButton.MouseButton1Click:Connect(HandleRulesAccepted)

	rulesStartTime = os.clock()

	local character = player.Character
	if character then
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid and originalWalkSpeed == nil then
			originalWalkSpeed = humanoid.WalkSpeed
			humanoid.WalkSpeed = 0
		end
	end

	task.spawn(function()
		menuCamera:StartLoop()
	end)
end

function CheckHoldDuration()
	holdUI.Visible = true
	while isHoldActive and RunService:IsRunning() and holdStartTime > 0 do
		local elapsedTime = os.clock() - holdStartTime
		local progress = math.clamp(elapsedTime / HOLD_DURATION, 0, 1)
		local keypoints = {
			NumberSequenceKeypoint.new(0, 0), 
			NumberSequenceKeypoint.new(progress, 0), 
			NumberSequenceKeypoint.new(math.min(1, progress + 0.001), 1), 
			NumberSequenceKeypoint.new(1, 1)
		}
		holdGradient.Transparency = NumberSequence.new(keypoints)

		if elapsedTime >= HOLD_DURATION then
			if not screenGui.Enabled and not menuOpenRequested then
				menuOpenRequested = true
				isHoldActive = false
				holdUI.Visible = false
				holdGradient.Transparency = NumberSequence.new(1)
				task.spawn(OpenMainMenu)
			else 
				isHoldActive = false 
			end
			break
		end
		RunService.Heartbeat:Wait()
	end

	if isHoldActive == false and menuOpenRequested == false then
		holdUI.Visible = false
		holdGradient.Transparency = NumberSequence.new(1)
	end
end

function StartHoldCheck()
	if not rulesAccepted or isHoldActive or screenGui.Enabled then return end
	isHoldActive = true
	holdStartTime = os.clock()
	menuOpenRequested = false
	task.spawn(CheckHoldDuration)
end

function EndHoldCheck()
	if isHoldActive then isHoldActive = false end
end

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe or UserInputService:GetFocusedTextBox() then return end
	if input.KeyCode == HOLD_KEY_CODE then StartHoldCheck() end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == HOLD_KEY_CODE then EndHoldCheck() end
end)

-- PC кнопка меню
local pcMenuGui = Instance.new("ScreenGui")
pcMenuGui.Name = "PCMenuButtonGui"
pcMenuGui.ResetOnSpawn = false
pcMenuGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcMenuGui.IgnoreGuiInset = true
pcMenuGui.DisplayOrder = 999

local buttonFrame = Instance.new("Frame")
buttonFrame.Name = "PCMenuButton"
buttonFrame.Size = UDim2.new(0, 100, 0, 40)
buttonFrame.Position = UDim2.new(1, -15, 0, 15)
buttonFrame.AnchorPoint = Vector2.new(1, 0)
buttonFrame.BackgroundColor3 = Theme.Background
buttonFrame.BackgroundTransparency = 0.3
buttonFrame.BorderSizePixel = 0
buttonFrame.Parent = pcMenuGui

local corner = Instance.new("UICorner", buttonFrame)
corner.CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", buttonFrame)
stroke.Color = Theme.PrimaryUI_Light
stroke.Thickness = 1.5

local label = Instance.new("TextLabel")
label.Name = "Label"
label.Size = UDim2.fromScale(1, 1)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamBold
label.Text = "МЕНЮ"
label.TextColor3 = Theme.TextPrimary
label.TextSize = 18
label.Parent = buttonFrame

local actionButton = Instance.new("TextButton")
actionButton.Name = "ActionButton"
actionButton.Size = UDim2.fromScale(1, 1)
actionButton.Text = ""
actionButton.BackgroundTransparency = 1
actionButton.Parent = buttonFrame

actionButton.MouseButton1Click:Connect(function()
	if not rulesAccepted then return end
	if not screenGui.Enabled then 
		OpenMainMenu() 
	elseif hasStartedPlaying then 
		CloseMainMenu() 
	end
end)

actionButton.MouseEnter:Connect(function() 
	TweenService:Create(buttonFrame, tweenInfoEnter, { BackgroundTransparency = 0.1 }):Play() 
end)

actionButton.MouseLeave:Connect(function() 
	TweenService:Create(buttonFrame, tweenInfoLeave, { BackgroundTransparency = 0.3 }):Play() 
end)

pcMenuGui.Parent = playerGui

SetupTeamListeners = function()
	-- Очищаємо старі підключення
	for teamNameKey, connections in pairs(teamPlayerEventListeners) do
		if connections then
			for _, c in ipairs(connections) do 
				if c then c:Disconnect() end
			end
		end
	end
	teamPlayerEventListeners = {}

	for teamNameKey, elements in pairs(roleButtonElements) do
		local roleData = elements.data
		if roleData.MaxPlayers and roleData.MaxPlayers > 0 then
			local team = Teams:FindFirstChild(roleData.TeamName)
			if team then
				teamPlayerEventListeners[roleData.TeamName] = {}
				table.insert(teamPlayerEventListeners[roleData.TeamName], team.PlayerAdded:Connect(UpdateRoleButtonsVisuals))
				table.insert(teamPlayerEventListeners[roleData.TeamName], team.PlayerRemoved:Connect(UpdateRoleButtonsVisuals))
			end
		end
	end
end

local function SetupDspTeamListener()
	local dspTeam = Teams:FindFirstChild("ЧПС")
	if dspTeam then
		UpdateDspStationAvailability()
		dspTeam.AttributeChanged:Connect(function(attributeName)
			if string.find(attributeName, "_OccupiedBy") then 
				UpdateDspStationAvailability() 
			end
		end)
	end
end

local function OnCharacterAdded(character)
	if hasStartedPlaying then CloseMainMenu() end
end

local function InitialSetup()
	task.wait(0.5)

	if loadingFrame and loadingFrame.Parent then
		TweenService:Create(loadingFrame, TweenInfo.new(LOAD_FADE_TIME), {BackgroundTransparency = 1}):Play()
		task.delay(LOAD_FADE_TIME, function() 
			if loadingFrame and loadingFrame.Parent then 
				loadingFrame:Destroy() 
			end 
		end)
	end

	screenGui.Parent = playerGui

	-- Спочатку показуємо попередження про Preview версію
	if not hasShownPreviewWarning then
		ShowPreviewWarning(function()
			-- Після закриття попередження показуємо правила
			task.spawn(function()
				menuCamera:StartLoop()
			end)

			if not hasShownInitialWindows then 
				CreateAndShowRulesWindow() 
			end
		end)
	else
		task.spawn(function()
			menuCamera:StartLoop()
		end)

		if not hasShownInitialWindows then 
			CreateAndShowRulesWindow() 
		end
	end

	if player.Character then 
		OnCharacterAdded(player.Character) 
	end

	player.CharacterAdded:Connect(OnCharacterAdded)
	Teams.ChildAdded:Connect(SetupTeamListeners)
	Teams.ChildAdded:Connect(SetupDspTeamListener)
	expStat.Changed:Connect(UpdateRoleButtonsVisuals)
	SetupTeamListeners()
	SetupDspTeamListener()
end

task.wait(3)
InitialSetup()