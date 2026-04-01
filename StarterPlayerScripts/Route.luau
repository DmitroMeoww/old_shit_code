-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService") -- Для Esc

-- Player
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- RemoteEvents
local OPEN_ROUTE_MENU_EVENT = ReplicatedStorage:WaitForChild("OpenRouteMenuEvent")
local SET_ROUTE_EVENT = ReplicatedStorage:WaitForChild("SetRouteEvent")

-- Змінна для збереження посилання на активний Part з декалями
local currentTargetPartWithDecals = nil

-- GUI Елементи (будуть створені)
local routeMenuScreenGui
local mainFrame
local titleLabel
local instructionLabel
local routeInput
local confirmButton
local closeButton

-- Функція для створення або отримання GUI
local function createOrGetRouteMenu()
	if routeMenuScreenGui and routeMenuScreenGui.Parent then
		-- GUI вже існує, просто повертаємо елементи
		return routeMenuScreenGui, mainFrame, titleLabel, instructionLabel, routeInput, confirmButton, closeButton
	end

	-- Створення ScreenGui
	routeMenuScreenGui = Instance.new("ScreenGui")
	routeMenuScreenGui.Name = "RouteMenuGui"
	routeMenuScreenGui.ResetOnSpawn = false -- Щоб не зникав при респавні персонажа
	routeMenuScreenGui.DisplayOrder = 1000 -- Щоб був поверх інших GUI
	routeMenuScreenGui.Enabled = true

	-- Створення основного Frame
	mainFrame = Instance.new("Frame")
	mainFrame.Name = "Frame"
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.Position = UDim2.fromScale(0.5, 0.5)
	mainFrame.Size = UDim2.fromOffset(320, 240) -- Трохи ширше і вище
	mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	mainFrame.BorderColor3 = Color3.fromRGB(100, 100, 120)
	mainFrame.BorderSizePixel = 2
	mainFrame.Visible = false -- Починаємо схованим
	mainFrame.Parent = routeMenuScreenGui

	-- Створення заголовку
	titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, 0, 0, 30)
	titleLabel.Position = UDim2.fromScale(0, 0)
	titleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	titleLabel.BorderColor3 = Color3.fromRGB(80, 80, 100)
	titleLabel.BorderSizePixel = 1
	titleLabel.Text = "Вибір Маршруту"
	titleLabel.Font = Enum.Font.Ubuntu
	titleLabel.TextSize = 16
	titleLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Center
	titleLabel.TextYAlignment = Enum.TextYAlignment.Center
	titleLabel.Parent = mainFrame

	-- Створення інструкції
	instructionLabel = Instance.new("TextLabel")
	instructionLabel.Name = "InstructionLabel"
	instructionLabel.Size = UDim2.new(1, -20, 0, 30)
	instructionLabel.Position = UDim2.fromOffset(10, 40) -- Під заголовком
	instructionLabel.Text = "Введіть номер маршруту (0-50):"
	instructionLabel.TextColor3 = Color3.fromRGB(210, 210, 220)
	instructionLabel.BackgroundTransparency = 1
	instructionLabel.Font = Enum.Font.Gotham
	instructionLabel.TextSize = 15
	instructionLabel.TextWrapped = true
	instructionLabel.TextXAlignment = Enum.TextXAlignment.Center
	instructionLabel.Parent = mainFrame

	-- Створення поля вводу
	routeInput = Instance.new("TextBox")
	routeInput.Name = "RouteInput"
	routeInput.Size = UDim2.new(1, -60, 0, 40)
	routeInput.Position = UDim2.new(0.5, 0, 0, 85) -- Під інструкцією, по центру
	routeInput.AnchorPoint = Vector2.new(0.5, 0)
	routeInput.PlaceholderText = "0-50"
	routeInput.ClearTextOnFocus = false -- Користувач може захотіти редагувати
	routeInput.Font = Enum.Font.GothamBold
	routeInput.TextSize = 20
	routeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	routeInput.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	routeInput.BorderColor3 = Color3.fromRGB(120, 120, 140)
	routeInput.BorderSizePixel = 1
	routeInput.Parent = mainFrame

	-- Створення кнопки Підтвердити
	confirmButton = Instance.new("TextButton")
	confirmButton.Name = "ConfirmButton"
	confirmButton.Size = UDim2.new(0.5, -15, 0, 40) -- Половина ширини мінус відступ
	confirmButton.Position = UDim2.fromOffset(10, mainFrame.Size.Y.Offset - 50) -- 10px відступ зліва, 10px+40px висоти від низу
	confirmButton.Text = "OK"
	confirmButton.Font = Enum.Font.GothamBold
	confirmButton.TextSize = 18
	confirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	confirmButton.BackgroundColor3 = Color3.fromRGB(70, 140, 70)
	confirmButton.Parent = mainFrame

	-- Створення кнопки Закрити
	closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0.5, -15, 0, 40)
	closeButton.Position = UDim2.new(0.5, 5, 0, mainFrame.Size.Y.Offset - 50) -- Праворуч від центру
	closeButton.Text = "Закрити"
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextSize = 18
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.BackgroundColor3 = Color3.fromRGB(160, 60, 60)
	closeButton.Parent = mainFrame

	-- Розміщуємо GUI в PlayerGui
	routeMenuScreenGui.Parent = playerGui

	return routeMenuScreenGui, mainFrame, titleLabel, instructionLabel, routeInput, confirmButton, closeButton
end

-- Функція для відкриття меню
local function openMenu(targetPart)
	createOrGetRouteMenu() -- Переконуємось, що GUI створено


	currentTargetPartWithDecals = targetPart
	if routeInput then routeInput.Text = "" end
	if mainFrame then mainFrame.Visible = true end
	if routeInput then routeInput:CaptureFocus() end
	print("Меню вибору маршруту відкрито для ", currentTargetPartWithDecals and currentTargetPartWithDecals:GetFullName() or "НЕВІДОМО")
end

-- Функція для закриття меню
local function closeMenu()
	if mainFrame then mainFrame.Visible = false end
	if routeInput and routeInput:IsFocused() then routeInput:ReleaseFocus() end
	currentTargetPartWithDecals = nil
	print("Меню вибору маршруту закрито")
end

-- Ініціалізація GUI при запуску скрипта
createOrGetRouteMenu()

-- Обробка події від сервера на відкриття меню
OPEN_ROUTE_MENU_EVENT.OnClientEvent:Connect(openMenu)

-- Обробка кліку на кнопку підтвердження
if confirmButton then
	confirmButton.MouseButton1Click:Connect(function()
		if not currentTargetPartWithDecals then
			warn("RouteMenuHandler: Немає цільового парта для встановлення маршруту.")
			closeMenu()
			return
		end

		local inputText = routeInput and routeInput.Text or ""
		local number = tonumber(inputText)

		if number then
			if number >= 0 and number <= 50 and math.floor(number) == number then
				SET_ROUTE_EVENT:FireServer(currentTargetPartWithDecals, inputText)
				closeMenu()
			else
				if routeInput then
					local oldText = routeInput.Text
					routeInput.Text = "0-50!"
					routeInput.TextColor3 = Color3.fromRGB(255,100,100)
					task.wait(1.5)
					if routeInput then -- Перевірка, чи GUI ще існує
						routeInput.Text = oldText
						routeInput.TextColor3 = Color3.fromRGB(255,255,255)
					end
				end
				warn("Некоректне число: ", inputText, ". Має бути ціле від 0 до 50.")
			end
		else
			if routeInput then
				local oldText = routeInput.Text
				routeInput.Text = "Не число!"
				routeInput.TextColor3 = Color3.fromRGB(255,100,100)
				task.wait(1.5)
				if routeInput then -- Перевірка, чи GUI ще існує
					routeInput.Text = oldText
					routeInput.TextColor3 = Color3.fromRGB(255,255,255)
				end
			end
			warn("Введено не число: ", inputText)
		end
	end)
end

-- Обробка натискання Enter в TextBox
if routeInput then
	routeInput.FocusLost:Connect(function(enterPressed)
		if enterPressed and mainFrame and mainFrame.Visible and currentTargetPartWithDecals and confirmButton then
			confirmButton.MouseButton1Click:Fire()
		end
	end)
end

-- Обробка кліку на кнопку закриття
if closeButton then
	closeButton.MouseButton1Click:Connect(closeMenu)
end

-- Обробка натискання Escape для закриття меню
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then return end -- Не обробляти, якщо гра вже обробила (наприклад, чат)

	if input.KeyCode == Enum.KeyCode.Escape then
		if mainFrame and mainFrame.Visible then
			closeMenu()
		end
	end
end)

print("Клієнтський скрипт RouteMenuHandler (з динамічним GUI) завантажено.")