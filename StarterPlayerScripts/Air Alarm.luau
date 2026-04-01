local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService") -- Не використовується, можна прибрати, якщо не плануєте додавати анімації
local RunService = game:GetService("RunService") -- Не використовується, можна прибрати

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local warningEvent = ReplicatedStorage:WaitForChild("AirRaidWarningEvent")

local warningScreenGui = nil -- Змінна для збереження GUI
local warningFrame = nil
local warningText = nil
local warningSound = nil -- Змінна для збереження звуку
local isBlinking = false
local blinkCoroutine = nil -- Змінна для збереження корутини миготіння

-- --- Функція створення GUI та Звуку ---
local function createWarningGui()
	if warningScreenGui and warningScreenGui.Parent then -- Якщо GUI вже існує, повертаємо його
		return warningScreenGui
	end

	-- Створюємо ScreenGui
	warningScreenGui = Instance.new("ScreenGui")
	warningScreenGui.Name = "AirRaidWarningGui"
	warningScreenGui.ResetOnSpawn = false -- Важливо!
	warningScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling -- Або Global, якщо треба поверх усього

	-- Створюємо Frame (фон)
	warningFrame = Instance.new("Frame")
	warningFrame.Name = "WarningFrame"
	warningFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	warningFrame.Position = UDim2.fromScale(0.5, 0.5) -- По центру
	warningFrame.Size = UDim2.fromOffset(450, 150) -- Розмір (можна налаштувати)
	warningFrame.BackgroundColor3 = Color3.fromRGB(200, 0, 0) -- Червоний фон
	warningFrame.BorderSizePixel = 0
	warningFrame.Transparency = 0.5 -- Початкова прозорість для миготіння (зробимо видимим перед миготінням)
	warningFrame.Visible = false -- Спочатку приховано
	warningFrame.Parent = warningScreenGui

	-- Створюємо TextLabel (текст)
	warningText = Instance.new("TextLabel")
	warningText.Name = "WarningText"
	warningText.Size = UDim2.fromScale(1, 1) -- Заповнити весь Frame
	warningText.BackgroundTransparency = 1
	warningText.TextColor3 = Color3.fromRGB(255, 255, 255) -- Білий текст
	warningText.Font = Enum.Font.Ubuntu -- Шрифт Ubuntu
	warningText.TextSize = 24 -- Розмір тексту (можна налаштувати)
	warningText.TextWrapped = true
	warningText.TextXAlignment = Enum.TextXAlignment.Center
	warningText.TextYAlignment = Enum.TextYAlignment.Center
	warningText.Text = "Зупиніться! \n Ви грубо порушуєте правила безпеки Київського Метрополітену!\n У вас є 30 секунд, зупиніться НЕГАЙНО або на вас буде накладено штраф!"
	warningText.Parent = warningFrame

	-- Створюємо UICorner (круглі кути)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 15) -- Радіус кутів
	corner.Parent = warningFrame

	-- Створюємо Звук
	warningSound = Instance.new("Sound")
	warningSound.Name = "WarningSound"
	warningSound.SoundId = "rbxassetid://9113084761" -- Переконайтесь, що ID правильний і доступний
	warningSound.Volume = 10 -- Обережно, гучність 2 може бути завеликою
	warningSound.Looped = true -- Звук буде повторюватись
	warningSound.Parent = warningFrame -- Додаємо звук до Frame (або warningScreenGui), щоб він був у грі

	-- Додаємо ScreenGui до PlayerGui
	warningScreenGui.Parent = playerGui

	print("Warning GUI та Sound створено")
	return warningScreenGui
end

-- --- Функція миготіння ---
local function startBlinking()
	if isBlinking then return end -- Якщо вже миготить, нічого не робити
	if not warningFrame or not warningSound then return end -- Перевірка існування елементів

	isBlinking = true
	warningFrame.Visible = true -- Переконуємось, що Frame видимий на початку

	-- Запускаємо звук
	warningSound.Playing = true
	print("Warning sound started playing.")

	-- Створюємо корутину для миготіння
	blinkCoroutine = task.spawn(function()
		local visible = true -- Початковий стан (Frame вже видимий)
		while isBlinking do -- Цикл працює, поки isBlinking true
			-- Змінюємо видимість. Використовуємо Transparency для плавного ефекту (опціонально)
			-- або просто .Visible
			visible = not visible
			if warningFrame then -- Додаткова перевірка
				warningFrame.Visible = visible
				-- Альтернатива з Transparency (закоментовано):
				-- local goal = visible and 0.5 or 1 -- 0.5 - напівпрозорий, 1 - невидимий
				-- TweenService:Create(warningFrame, TweenInfo.new(0.35), {Transparency = goal}):Play()
			else
				break -- Вийти з циклу, якщо Frame зник
			end
			task.wait(0.4) -- Інтервал миготіння (0.4 сек увімкнено, 0.4 сек вимкнено)
		end
		-- Коли цикл закінчується (isBlinking = false), переконуємось, що Frame приховано
		if warningFrame then
			warningFrame.Visible = false
		end
		-- Звук зупиняється у функції stopBlinking()
		print("Blinking coroutine finished.")
	end)
	print("Blinking started.")
end

-- --- Функція зупинки миготіння ---
local function stopBlinking()
	if not isBlinking then return end -- Якщо не миготить, нічого не робити
	isBlinking = false -- Встановлюємо флаг, щоб цикл у корутині завершився

	-- Зупиняємо звук негайно
	if warningSound then
		warningSound.Playing = false
		print("Warning sound stopped.")
	end

	-- Не потрібно явно зупиняти корутину, вона сама завершиться через перевірку isBlinking
	-- Переконаємось, що Frame точно прихований після зупинки (корутина це теж зробить, але для надійності можна і тут)
	if warningFrame then
		warningFrame.Visible = false
	end
	print("Blinking stopped.")
end

-- --- Обробник події від сервера ---
warningEvent.OnClientEvent:Connect(function(showWarning)
	print("Отримано подію від сервера:", showWarning)
	createWarningGui() -- Переконуємось, що GUI та звук існують

	if showWarning then
		startBlinking()
	else
		stopBlinking()
	end
end)

-- --- Додатково: Обробка смерті/виходу гравця (щоб зупинити звук/миготіння) ---
player.CharacterRemoving:Connect(function()
	-- Якщо гравець виходить або його персонаж видаляється,
	-- краще зупинити миготіння та звук, якщо вони активні.
	if isBlinking then
		print("Character removing, stopping warning.")
		stopBlinking()
	end
	-- Якщо GUI потрібно видалити при смерті (суперечить ResetOnSpawn=false),
	-- то тут можна додати: if warningScreenGui then warningScreenGui:Destroy() end
end)


print("AirRaidWarningUIHandler запущено для", player.Name)