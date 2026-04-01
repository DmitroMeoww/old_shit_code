-- =========================================================================
-- MILICIA - CLIENT SCRIPT (Версія з оновленим дизайном кнопок)
-- =========================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local GameRemotes = ReplicatedStorage:WaitForChild("GameRemotes")
local JailEvent = GameRemotes:WaitForChild("JailEvent")
local PoliceLocatorEvent = GameRemotes:WaitForChild("PoliceLocatorEvent")
local RequestReleaseEvent = GameRemotes:WaitForChild("RequestReleaseEvent")
local ReleasePlayerEvent = GameRemotes:WaitForChild("ReleasePlayerEvent")

--[[ Theme - Взято з вашого Modernized Menu для консистентності дизайну ]]--
local Theme = {
	Background = Color3.fromRGB(26, 28, 32),
	PrimaryUI = Color3.fromRGB(40, 42, 54),
	PrimaryUI_Light = Color3.fromRGB(56, 58, 74),
	Accent = Color3.fromRGB(77, 141, 255),
	Accent_Hover = Color3.fromRGB(128, 174, 255),
	TextPrimary = Color3.fromRGB(248, 248, 242),
	TextSecondary = Color3.fromRGB(180, 180, 190),
	Success = Color3.fromRGB(80, 250, 123),
	Success_Hover = Color3.fromRGB(120, 255, 160), -- Додано світліший зелений для наведення
	Warning = Color3.fromRGB(241, 250, 140),
	Error = Color3.fromRGB(255, 85, 85),
	Disabled = Color3.fromRGB(100, 100, 100),
}

local POLICE_TEAM_NAME = "Поліція"

local jailUI = nil
local policeButton = nil
local isWanted = false
local jailEndTime = 0
local jailStaticFine = 0
local managedWantedGuis = {}

local tweenInfo_Fast = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local tweenInfo_Slow = TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local tweenInfo_Hover = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) -- Для анімацій кнопок

-- ==============================================================================
-- НОВА ФУНКЦІЯ: Створення стилізованої кнопки за вашим дизайном
-- ==============================================================================
local function createStyledButton(params)
	local button = Instance.new("TextButton")
	button.Name = params.Name or "StyledButton"
	button.Parent = params.Parent
	button.Size = params.Size
	button.Position = params.Position
	button.AnchorPoint = params.AnchorPoint or Vector2.new(0.5, 0.5)

	button.Text = params.Text
	button.Font = Enum.Font.GothamBold
	button.TextSize = params.TextSize or 18

	local mainColor = params.MainColor or Theme.Accent
	local hoverColor = params.HoverColor or Theme.Accent_Hover
	local textColor = params.TextColor or Theme.TextPrimary

	button.BackgroundColor3 = mainColor
	button.TextColor3 = textColor

	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

	if params.Stroke then
		local stroke = Instance.new("UIStroke", button)
		stroke.Color = params.StrokeColor or Theme.PrimaryUI_Light
		stroke.Thickness = 1.5
	end

	button.MouseEnter:Connect(function()
		TweenService:Create(button, tweenInfo_Hover, { BackgroundColor3 = hoverColor }):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, tweenInfo_Hover, { BackgroundColor3 = mainColor }):Play()
	end)

	return button
end
-- ==============================================================================

local function createTracer(startPosition, endPosition)
	local attachment0 = Instance.new("Attachment", workspace.Terrain)
	attachment0.Position = startPosition
	local attachment1 = Instance.new("Attachment", workspace.Terrain)
	attachment1.Position = endPosition
	local beam = Instance.new("Beam", attachment0)
	beam.Attachment0, beam.Attachment1 = attachment0, attachment1
	beam.Color = ColorSequence.new(Theme.Error)
	beam.Transparency, beam.Width0, beam.Width1 = NumberSequence.new(0.4), 0.5, 0.5
	beam.Segments, beam.FaceCamera = 1, true
	beam.Enabled = true
	Debris:AddItem(attachment0, 15)
end

local function showPopup(message, duration, color)
	local popupGui = Instance.new("ScreenGui", playerGui)
	popupGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	popupGui.DisplayOrder = 999
	local frame = Instance.new("Frame", popupGui)
	frame.Name = "PopupFrame"
	frame.Size = UDim2.new(0, 350, 0, 60)
	frame.Position = UDim2.new(0.5, 0, -0.2, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.BackgroundColor3 = Theme.PrimaryUI
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", frame).Color = color
	local label = Instance.new("TextLabel", frame)
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency, label.Font = 1, Enum.Font.GothamBold
	label.Text, label.TextColor3, label.TextSize, label.TextWrapped = message, Theme.TextPrimary, 18, true
	TweenService:Create(frame, tweenInfo_Slow, { Position = UDim2.new(0.5, 0, 0.05, 0) }):Play()
	task.delay(duration, function()
		if not frame or not frame.Parent then return end
		local tweenOut = TweenService:Create(frame, tweenInfo_Fast, { Position = UDim2.new(0.5, 0, -0.2, 0) })
		tweenOut.Completed:Connect(function() popupGui:Destroy() end)
		tweenOut:Play()
	end)
end

function createJailUI()
	if jailUI then jailUI:Destroy() end
	jailUI = Instance.new("ScreenGui", playerGui)
	jailUI.Name, jailUI.ResetOnSpawn, jailUI.ZIndexBehavior = "JailUI", false, Enum.ZIndexBehavior.Sibling
	local mainFrame = Instance.new("Frame", jailUI)
	mainFrame.Name, mainFrame.Size, mainFrame.Position = "JailFrame", UDim2.new(0, 380, 0, 180), UDim2.new(0.5, 0, 0.05, 0)
	mainFrame.AnchorPoint, mainFrame.BackgroundColor3 = Vector2.new(0.5, 0), Theme.PrimaryUI
	Instance.new("UICorner", mainFrame).CornerRadius, Instance.new("UIStroke", mainFrame).Color = UDim.new(0, 12), Theme.Error
	local title = Instance.new("TextLabel", mainFrame)
	title.Size, title.BackgroundTransparency, title.Font, title.Text, title.TextColor3, title.TextSize = UDim2.new(1, 0, 0, 45), 1, Enum.Font.GothamBold, "ВИ В ТЮРМІ", Theme.Error, 24
	local timerLabel = Instance.new("TextLabel", mainFrame)
	timerLabel.Name, timerLabel.Size, timerLabel.Position, timerLabel.AnchorPoint, timerLabel.BackgroundTransparency, timerLabel.Font, timerLabel.TextColor3, timerLabel.TextSize = "TimerLabel", UDim2.new(1, -40, 0, 30), UDim2.new(0.5, 0, 0, 50), Vector2.new(0.5, 0), 1, Enum.Font.Gotham, Theme.TextPrimary, 18
	local fineLabel = Instance.new("TextLabel", mainFrame)
	fineLabel.Name, fineLabel.Size, fineLabel.Position, fineLabel.AnchorPoint, fineLabel.BackgroundTransparency, fineLabel.Font, fineLabel.TextColor3, fineLabel.TextSize = "FineLabel", UDim2.new(1, -40, 0, 25), UDim2.new(0.5, 0, 0, 80), Vector2.new(0.5, 0), 1, Enum.Font.Gotham, Theme.Warning, 16
	local payButton = Instance.new("TextButton", mainFrame)
	payButton.Name, payButton.Size, payButton.Position, payButton.AnchorPoint, payButton.BackgroundColor3, payButton.Font, payButton.Text, payButton.TextColor3, payButton.TextSize = "PayButton", UDim2.new(1, -40, 0, 40), UDim2.new(0.5, 0, 1, -20), Vector2.new(0.5, 1), Theme.Success, Enum.Font.GothamBold, "СПЛАТИТИ ШТРАФ", Theme.Background, 18
	Instance.new("UICorner", payButton).CornerRadius = UDim.new(0, 8)
	local buttonStroke = Instance.new("UIStroke", payButton)
	buttonStroke.Thickness = 1.5
	buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	buttonStroke.Color = Theme.Success
	payButton.MouseButton1Click:Connect(function() JailEvent:FireServer("PayFine") end)
	local closeButton = Instance.new("TextButton", mainFrame)
	closeButton.Name, closeButton.Size, closeButton.Position, closeButton.AnchorPoint, closeButton.BackgroundTransparency, closeButton.Font, closeButton.Text, closeButton.TextColor3, closeButton.TextSize = "CloseButton", UDim2.new(0, 30, 0, 30), UDim2.new(1, -15, 0, 15), Vector2.new(0.5, 0.5), 1, Enum.Font.SourceSansBold, "✕", Theme.TextSecondary, 24
	closeButton.MouseButton1Click:Connect(function() mainFrame:TweenPosition(UDim2.new(0.5, 0, 1.2, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.3, true) end)
	mainFrame.Position = UDim2.new(0.5, 0, -0.2, 0)
	TweenService:Create(mainFrame, tweenInfo_Slow, { Position = UDim2.new(0.5, 0, 0.05, 0) }):Play()
end

function createPoliceButton()
	if policeButton and policeButton.Parent then return end
	local screenGui = playerGui:FindFirstChild("PoliceToolGUI") or Instance.new("ScreenGui", playerGui)
	screenGui.Name, screenGui.ZIndexBehavior, screenGui.ResetOnSpawn = "PoliceToolGUI", Enum.ZIndexBehavior.Sibling, false
	policeButton = Instance.new("TextButton", screenGui)
	policeButton.Name, policeButton.Size, policeButton.Position, policeButton.AnchorPoint, policeButton.BackgroundColor3, policeButton.TextColor3, policeButton.Font, policeButton.Text, policeButton.TextSize, policeButton.Visible = "FindCriminalsButton", UDim2.fromOffset(200, 50), UDim2.new(0.5, 0, 1, 60), Vector2.new(0.5, 1), Theme.Accent, Theme.TextPrimary, Enum.Font.GothamBold, "🔍 ЗНАЙТИ ЗЛОЧИНЦІВ", 16, false
	Instance.new("UICorner", policeButton).CornerRadius = UDim.new(0, 8)
	local buttonStroke = Instance.new("UIStroke", policeButton)
	buttonStroke.Thickness, buttonStroke.ApplyStrokeMode, buttonStroke.Color = 1.5, Enum.ApplyStrokeMode.Border, Theme.Accent_Hover
	policeButton.MouseButton1Click:Connect(function() PoliceLocatorEvent:FireServer("FindCriminals") end)
	policeButton.MouseEnter:Connect(function() TweenService:Create(policeButton, tweenInfo_Fast, { BackgroundColor3 = Theme.Accent_Hover }):Play() end)
	policeButton.MouseLeave:Connect(function() TweenService:Create(policeButton, tweenInfo_Fast, { BackgroundColor3 = Theme.Accent }):Play() end)
end

function updateJailUI()
	if not jailUI or not jailUI.Parent or jailEndTime == 0 then return end
	local frame = jailUI:FindFirstChild("JailFrame")
	if not frame then return end
	local timeLeft = math.max(0, jailEndTime - tick())
	local minutes = math.floor(timeLeft / 60)
	local seconds = math.floor(timeLeft % 60)
	frame.TimerLabel.Text = string.format("ЧАС ДО ЗВІЛЬНЕННЯ: %d:%02d", minutes, seconds)
	frame.FineLabel.Text = "ШТРАФ: " .. jailStaticFine .. " EXP"
	local payButton = frame:FindFirstChild("PayButton")
	if payButton then
		local buttonStroke = payButton:FindFirstChildOfClass("UIStroke")
		local canPay = jailStaticFine > 0
		payButton.Active = canPay
		if canPay then
			payButton.BackgroundColor3 = Theme.Success
			if buttonStroke then buttonStroke.Color = Theme.Success end
			payButton.Text = "СПЛАТИТИ ШТРАФ (" .. jailStaticFine .. " EXP)"
		else
			payButton.BackgroundColor3 = Theme.Disabled
			if buttonStroke then buttonStroke.Color = Theme.Disabled end
			payButton.Text = "СПЛАТА НЕМОЖЛИВА"
		end
	end
end

function createWantedIndicator()
	if playerGui:FindFirstChild("WantedIndicator") then return end
	local indicatorGui = Instance.new("ScreenGui", playerGui)
	indicatorGui.Name, indicatorGui.ResetOnSpawn = "WantedIndicator", false
	local frame = Instance.new("Frame", indicatorGui)
	frame.AnchorPoint, frame.Position, frame.Size, frame.BackgroundColor3, frame.BackgroundTransparency = Vector2.new(0.5, 1), UDim2.new(0.5, 0, 1, -80), UDim2.new(0, 220, 0, 40), Theme.PrimaryUI, 0.2
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
	local frameStroke = Instance.new("UIStroke", frame)
	frameStroke.Thickness, frameStroke.ApplyStrokeMode, frameStroke.Color = 1.5, Enum.ApplyStrokeMode.Border, Theme.Error
	local text = Instance.new("TextLabel", frame)
	text.Size, text.BackgroundTransparency, text.Font, text.Text, text.TextColor3, text.TextSize = UDim2.fromScale(1, 1), 1, Enum.Font.GothamBold, "⚠️ ВИ У РОЗШУКУ", Theme.Error, 20
end

local function createWantedTextForPolice(character)
	if not character or not character:FindFirstChild("Head") then return nil end
	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Name = "WantedGui"
	billboardGui.Adornee = character.Head
	billboardGui.Size = UDim2.new(0, 200, 0, 50)
	billboardGui.StudsOffset = Vector3.new(0, 3, 0)
	billboardGui.MaxDistance = 150
	billboardGui.AlwaysOnTop = true
	billboardGui.Parent = character.Head
	local frame = Instance.new("Frame", billboardGui)
	frame.BackgroundColor3 = Color3.fromRGB(26, 28, 32)
	frame.BackgroundTransparency = 0.3
	frame.Size = UDim2.fromScale(1, 1)
	frame.BorderSizePixel = 0
	local corner = Instance.new("UICorner", frame)
	corner.CornerRadius = UDim.new(0, 8)
	local stroke = Instance.new("UIStroke", frame)
	stroke.Color = Color3.fromRGB(255, 85, 85)
	stroke.Thickness = 2
	local textLabel = Instance.new("TextLabel", frame)
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.Position = UDim2.fromScale(0, 0)
	textLabel.Text = "У РОЗШУКУ"
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextSize = 18
	textLabel.TextStrokeTransparency = 0.5
	textLabel.TextStrokeColor3 = Color3.fromRGB(255, 85, 85)
	return billboardGui
end

local function updatePlayerWantedGui(targetPlayer)
	local character = targetPlayer.Character
	if not character or not character:FindFirstChild("Head") then return end

	local isPolice = player.Team and player.Team.Name == POLICE_TEAM_NAME
	local isTargetWanted = character:GetAttribute("isWanted")
	local existingGui = character.Head:FindFirstChild("WantedGui")

	if isPolice and isTargetWanted and not existingGui then
		managedWantedGuis[targetPlayer] = createWantedTextForPolice(character)
	elseif (not isPolice or not isTargetWanted) and existingGui then
		existingGui:Destroy()
		managedWantedGuis[targetPlayer] = nil
	end
end

local function checkState()
	if not policeButton or not policeButton.Parent then createPoliceButton() end
	if player.Team and player.Team.Name == POLICE_TEAM_NAME then
		if not policeButton.Visible then
			policeButton.Visible = true
			TweenService:Create(policeButton, tweenInfo_Slow, { Position = UDim2.new(0.5, 0, 1, -55) }):Play()
		end
	else
		if policeButton.Visible then
			local tween = TweenService:Create(policeButton, tweenInfo_Slow, { Position = UDim2.new(0.5, 0, 1, 60) })
			tween.Completed:Connect(function()
				if policeButton and not (player.Team and player.Team.Name == POLICE_TEAM_NAME) then
					policeButton.Visible = false
				end
			end)
			tween:Play()
		end
	end
	local wantedGui = playerGui:FindFirstChild("WantedIndicator")
	if isWanted and not wantedGui then
		createWantedIndicator()
	elseif not isWanted and wantedGui then
		wantedGui:Destroy()
	end
	for _, otherPlayer in pairs(Players:GetPlayers()) do
		updatePlayerWantedGui(otherPlayer)
	end
end

JailEvent.OnClientEvent:Connect(function(action, ...)
	local args = {...}
	if action == "ShowJailUI" then
		local jailTime, fine = args[1], args[2]
		createJailUI()
		jailEndTime = tick() + jailTime
		jailStaticFine = fine
		isWanted = false
		checkState()
		pcall(function() StarterGui:SetCore("ResetButtonCallback", false) end)
	elseif action == "HideJailUI" then
		jailEndTime = 0
		if jailUI then
			local ui, frame = jailUI, jailUI:FindFirstChild("JailFrame")
			jailUI = nil
			if frame then
				local tween = TweenService:Create(frame, tweenInfo_Fast, {Position = UDim2.new(0.5, 0, -0.2, 0)})
				tween.Completed:Connect(function() ui:Destroy() end)
				tween:Play()
			else ui:Destroy() end
			showPopup(args[1] or "Ви вільні!", 4, Theme.Success)
		end
		isWanted = false
		checkState()
		pcall(function() StarterGui:SetCore("ResetButtonCallback", true) end)
	elseif action == "UpdateJailTime" then
		jailEndTime = tick() + args[1]
		if args[2] then showPopup(args[2], 4, Theme.Error) end
	elseif action == "ShowWarning" then
		if args[1] then showPopup(args[1], 4, Theme.Warning) end
	elseif action == "ShowReward" then
		if args[1] then showPopup(args[1], 4, Theme.Success) end
	elseif action == "SetWantedStatus" then
		isWanted = args[1]
		checkState()
	elseif action == "ShowNotification" then
		if args[1] then showPopup(args[1], 5, Theme.Error) end
	elseif action == "ShowReleasePrompt" then
		local targetPlayer = args[1]
		if not targetPlayer then return end

		local releaseGui = Instance.new("ScreenGui", playerGui)
		releaseGui.Name = "ReleasePromptGui"
		releaseGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		Debris:AddItem(releaseGui, 15)

		-- ========== Створення кнопки поліцейського у новому стилі ==========
		local button = createStyledButton({
			Parent = releaseGui,
			Name = "ReleaseButton",
			Text = "ВІДПУСТИТИ " .. string.upper(targetPlayer.Name),
			Size = UDim2.new(0, 300, 0, 50),
			Position = UDim2.new(0.3, 0, 0.8, 0),
			MainColor = Theme.Success,
			HoverColor = Theme.Success_Hover,
			TextColor = Theme.Background, -- Темний текст на світлому фоні
			Stroke = false -- Обводка не потрібна, кнопка яскрава
		})

		button.MouseButton1Click:Connect(function()
			ReleasePlayerEvent:FireServer(targetPlayer)
			releaseGui:Destroy()
		end)
		-- =================================================================
	end
end)

PoliceLocatorEvent.OnClientEvent:Connect(function(action, data)
	if action == "ShowCriminals" then
		if not player.Team or player.Team.Name ~= POLICE_TEAM_NAME then return end
		local wantedPositions = (type(data) == "table" and data) or {}
		local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not myRoot then return end
		if #wantedPositions == 0 then
			showPopup("Злочинців не знайдено", 3, Theme.Warning)
		else
			for _, pos in ipairs(wantedPositions) do
				createTracer(myRoot.Position, pos)
			end
			showPopup("Знайдено злочинців: " .. #wantedPositions, 3, Theme.Success)
		end
	elseif action == "CooldownActive" then
		showPopup("Локатор перезаряджається: " .. math.floor(data) .. "с", 3, Theme.Accent)
	end
end)

local function handleCuffStateChanged(character)
	local isCuffed = character:GetAttribute("isCuffed")
	pcall(function() StarterGui:SetCore("ResetButtonCallback", not isCuffed) end)

	local apologyGui = playerGui:FindFirstChild("ApologyGui")
	if apologyGui then apologyGui:Destroy() end

	if isCuffed then
		local leaderstats = player:FindFirstChild("leaderstats")
		local exp = leaderstats and leaderstats:FindFirstChild("EXP")
		if exp and exp.Value < 2000 then
			apologyGui = Instance.new("ScreenGui", playerGui)
			apologyGui.Name = "ApologyGui"
			apologyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			apologyGui.ResetOnSpawn = false

			-- ========== Створення кнопки злочинця у новому стилі ==========
			local button = createStyledButton({
				Parent = apologyGui,
				Name = "RequestButton",
				Text = "ПОПРОСИТИ ВІДПУСТИТИ",
				Size = UDim2.new(0, 300, 0, 50),
				Position = UDim2.new(0.5, 0, 0.65, 0), -- Позиція вище
				MainColor = Theme.PrimaryUI_Light, -- Колір з меню
				HoverColor = Theme.Accent, -- Колір при наведенні
				TextColor = Theme.TextSecondary,
				Stroke = true,
				StrokeColor = Theme.Accent
			})

			-- Окремо анімація для тексту
			button.MouseEnter:Connect(function()
				TweenService:Create(button, tweenInfo_Hover, { TextColor3 = Theme.TextPrimary }):Play()
			end)
			button.MouseLeave:Connect(function()
				TweenService:Create(button, tweenInfo_Hover, { TextColor3 = Theme.TextSecondary }):Play()
			end)
			-- =============================================================

			button.MouseButton1Click:Connect(function()
				RequestReleaseEvent:FireServer()
				showPopup("Прохання надіслано офіцеру", 3, Theme.Success)
				button.Active = false
				button.Text = "ОЧІКУВАННЯ..."
				-- Повертаємо кольори до неактивного стану
				TweenService:Create(button, tweenInfo_Hover, {
					BackgroundColor3 = Theme.PrimaryUI,
					TextColor3 = Theme.Disabled
				}):Play()
			end)
		end
	end
end

local function onNewCharacter(character)
	checkState()
	updatePlayerWantedGui(player)
	character:GetAttributeChangedSignal("isCuffed"):Connect(function() handleCuffStateChanged(character) end)
	character:GetAttributeChangedSignal("isWanted"):Connect(function() updatePlayerWantedGui(player) end)
	handleCuffStateChanged(character)
end

local function onNewPlayer(newPlayer)
	newPlayer.CharacterAdded:Connect(function(character)
		updatePlayerWantedGui(newPlayer)
		character:GetAttributeChangedSignal("isWanted"):Connect(function() updatePlayerWantedGui(newPlayer) end)
	end)
	if newPlayer.Character then
		updatePlayerWantedGui(newPlayer)
		newPlayer.Character:GetAttributeChangedSignal("isWanted"):Connect(function() updatePlayerWantedGui(newPlayer) end)
	end
end

RunService.Heartbeat:Connect(function() if jailEndTime > 0 then updateJailUI() end end)
player:GetPropertyChangedSignal("Team"):Connect(checkState)
player.CharacterAdded:Connect(onNewCharacter)
Players.PlayerAdded:Connect(onNewPlayer)

task.wait(2)
createPoliceButton()
checkState()
for _, p in ipairs(Players:GetPlayers()) do onNewPlayer(p) end
if player.Character then onNewCharacter(player.Character) end