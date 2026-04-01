--[[
	VOTEKICK SYSTEM - Client Script
	StarterPlayerScripts
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local VotekickFolder = ReplicatedStorage:WaitForChild("VotekickSystem")
local StartVotekickEvent = VotekickFolder:WaitForChild("StartVotekick")
local CastVoteEvent = VotekickFolder:WaitForChild("CastVote")
local ShowVotingUIEvent = VotekickFolder:WaitForChild("ShowVotingUI")
local UpdateVotesEvent = VotekickFolder:WaitForChild("UpdateVotes")
local EndVotingEvent = VotekickFolder:WaitForChild("EndVoting")
local OpenVotekickMenuEvent = VotekickFolder:WaitForChild("OpenVotekickMenu")
local ChatReminderEvent = VotekickFolder:WaitForChild("ChatReminder")
local NotifyEvent = VotekickFolder:WaitForChild("Notify")

local COLORS = {
	background = Color3.fromRGB(15, 15, 25),
	backgroundTransparent = 0.15,
	accent = Color3.fromRGB(88, 101, 242),
	success = Color3.fromRGB(87, 242, 135),
	danger = Color3.fromRGB(237, 66, 69),
	warning = Color3.fromRGB(254, 231, 92),
	text = Color3.fromRGB(255, 255, 255),
	textSecondary = Color3.fromRGB(185, 187, 190),
	glow = Color3.fromRGB(88, 101, 242)
}

local function createScreenGui(name)
	local gui = Instance.new("ScreenGui")
	gui.Name = name
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = playerGui
	return gui
end

local function addGlow(frame, color)
	local glow = Instance.new("ImageLabel")
	glow.Name = "Glow"
	glow.Size = UDim2.new(1, 60, 1, 60)
	glow.Position = UDim2.new(0.5, 0, 0.5, 0)
	glow.AnchorPoint = Vector2.new(0.5, 0.5)
	glow.BackgroundTransparency = 1
	glow.Image = "rbxassetid://5028857084"
	glow.ImageColor3 = color or COLORS.glow
	glow.ImageTransparency = 0.7
	glow.ZIndex = -1
	glow.Parent = frame

	task.spawn(function()
		while glow and glow.Parent do
			TweenService:Create(glow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				ImageTransparency = 0.85
			}):Play()
			task.wait(1.5)
			if not glow or not glow.Parent then break end
			TweenService:Create(glow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				ImageTransparency = 0.7
			}):Play()
			task.wait(1.5)
		end
	end)

	return glow
end

local function createButton(parent, text, color, size, position)
	local button = Instance.new("TextButton")
	button.Size = size
	button.Position = position
	button.BackgroundColor3 = color
	button.BackgroundTransparency = 0.1
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = COLORS.text
	button.TextSize = 18
	button.Font = Enum.Font.GothamBold
	button.AutoButtonColor = false
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Transparency = 0.5
	stroke.Thickness = 1.5
	stroke.Parent = button

	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
			BackgroundTransparency = 0,
			Size = UDim2.new(size.X.Scale * 1.02, size.X.Offset, size.Y.Scale, size.Y.Offset + 2)
		}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
			BackgroundTransparency = 0.1,
			Size = size
		}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.2), {Transparency = 0.5}):Play()
	end)

	button.MouseButton1Down:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.1), {
			Size = UDim2.new(size.X.Scale * 0.98, size.X.Offset, size.Y.Scale, size.Y.Offset - 2)
		}):Play()
	end)

	button.MouseButton1Up:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.1), {Size = size}):Play()
	end)

	return button
end

local function animateIn(frame, startPos, endPos)
	frame.Position = startPos or UDim2.new(endPos.X.Scale - 0.1, endPos.X.Offset, endPos.Y.Scale, endPos.Y.Offset)
	frame.BackgroundTransparency = 1

	local tween = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = endPos,
		BackgroundTransparency = COLORS.backgroundTransparent
	})
	tween:Play()

	for _, child in pairs(frame:GetDescendants()) do
		if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
			local originalTransparency = child.TextTransparency
			child.TextTransparency = 1
			TweenService:Create(child, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
				TextTransparency = originalTransparency
			}):Play()
		end
	end
end

local function animateOut(frame, callback)
	local tween = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
		Position = UDim2.new(frame.Position.X.Scale - 0.1, frame.Position.X.Offset, frame.Position.Y.Scale, frame.Position.Y.Offset),
		BackgroundTransparency = 1
	})
	tween:Play()
	tween.Completed:Connect(function()
		if callback then callback() end
	end)
end

local function showNotification(message, notifType)
	local notifGui = createScreenGui("Notification")

	local colors = {
		success = COLORS.success,
		error = COLORS.danger,
		warning = COLORS.warning
	}

	local icons = {
		success = "✅",
		error = "❌",
		warning = "⚠️"
	}

	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(0, 350, 0, 50)
	notif.Position = UDim2.new(0.5, -175, 0, -60)
	notif.AnchorPoint = Vector2.new(0, 0)
	notif.BackgroundColor3 = COLORS.background
	notif.BackgroundTransparency = 0.1
	notif.Parent = notifGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = notif

	local stroke = Instance.new("UIStroke")
	stroke.Color = colors[notifType] or COLORS.accent
	stroke.Thickness = 2
	stroke.Parent = notif

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = (icons[notifType] or "ℹ️") .. " " .. message
	label.TextColor3 = COLORS.text
	label.TextSize = 16
	label.Font = Enum.Font.GothamBold
	label.Parent = notif

	TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.new(0.5, -175, 0, 20)
	}):Play()

	task.wait(3)

	TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {
		Position = UDim2.new(0.5, -175, 0, -60)
	}):Play()

	task.wait(0.3)
	notifGui:Destroy()
end

local votekickMenuGui = nil

local function openVotekickMenu()
	if votekickMenuGui then
		votekickMenuGui:Destroy()
	end

	votekickMenuGui = createScreenGui("VotekickMenu")

	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.BorderSizePixel = 0
	overlay.Parent = votekickMenuGui

	TweenService:Create(overlay, TweenInfo.new(0.3), {BackgroundTransparency = 0.6}):Play()

	local mainFrame = Instance.new("Frame")
	mainFrame.Size = UDim2.new(0, 420, 0, 520)
	mainFrame.Position = UDim2.new(0.5, -210, 0.5, -260)
	mainFrame.BackgroundColor3 = COLORS.background
	mainFrame.BackgroundTransparency = 1
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = votekickMenuGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 20)
	corner.Parent = mainFrame

	local stroke = Instance.new("UIStroke")
	stroke.Color = COLORS.accent
	stroke.Transparency = 0.5
	stroke.Thickness = 2
	stroke.Parent = mainFrame

	addGlow(mainFrame, COLORS.accent)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 60)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "🗳️ VOTEKICK"
	title.TextColor3 = COLORS.text
	title.TextSize = 28
	title.Font = Enum.Font.GothamBlack
	title.Parent = mainFrame

	local warning = Instance.new("Frame")
	warning.Size = UDim2.new(1, -30, 0, 45)
	warning.Position = UDim2.new(0, 15, 0, 60)
	warning.BackgroundColor3 = COLORS.danger
	warning.BackgroundTransparency = 0.8
	warning.Parent = mainFrame

	local warningCorner = Instance.new("UICorner")
	warningCorner.CornerRadius = UDim.new(0, 10)
	warningCorner.Parent = warning

	local warningStroke = Instance.new("UIStroke")
	warningStroke.Color = COLORS.danger
	warningStroke.Transparency = 0.5
	warningStroke.Parent = warning

	local warningText = Instance.new("TextLabel")
	warningText.Size = UDim2.new(1, 0, 1, 0)
	warningText.BackgroundTransparency = 1
	warningText.Text = "⚠️ ЗЛОВЖИВАННЯ VOTEKICK КАРАЄТЬСЯ БАНОМ!"
	warningText.TextColor3 = COLORS.warning
	warningText.TextSize = 13
	warningText.Font = Enum.Font.GothamBold
	warningText.Parent = warning

	local playerListLabel = Instance.new("TextLabel")
	playerListLabel.Size = UDim2.new(1, 0, 0, 25)
	playerListLabel.Position = UDim2.new(0, 0, 0, 115)
	playerListLabel.BackgroundTransparency = 1
	playerListLabel.Text = "Виберіть гравця:"
	playerListLabel.TextColor3 = COLORS.textSecondary
	playerListLabel.TextSize = 14
	playerListLabel.Font = Enum.Font.GothamMedium
	playerListLabel.Parent = mainFrame

	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Size = UDim2.new(1, -30, 0, 160)
	scrollFrame.Position = UDim2.new(0, 15, 0, 140)
	scrollFrame.BackgroundColor3 = Color3.new(0, 0, 0)
	scrollFrame.BackgroundTransparency = 0.5
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 4
	scrollFrame.ScrollBarImageColor3 = COLORS.accent
	scrollFrame.ScrollBarImageTransparency = 0.3
	scrollFrame.Parent = mainFrame

	local scrollCorner = Instance.new("UICorner")
	scrollCorner.CornerRadius = UDim.new(0, 10)
	scrollCorner.Parent = scrollFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 6)
	listLayout.Parent = scrollFrame

	local listPadding = Instance.new("UIPadding")
	listPadding.PaddingTop = UDim.new(0, 6)
	listPadding.PaddingLeft = UDim.new(0, 6)
	listPadding.PaddingRight = UDim.new(0, 6)
	listPadding.Parent = scrollFrame

	local selectedPlayer = nil
	local playerButtons = {}

	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player then
			local playerButton = Instance.new("TextButton")
			playerButton.Size = UDim2.new(1, -12, 0, 40)
			playerButton.BackgroundColor3 = COLORS.background
			playerButton.BackgroundTransparency = 0.3
			playerButton.BorderSizePixel = 0
			playerButton.Text = ""
			playerButton.AutoButtonColor = false
			playerButton.Parent = scrollFrame

			local btnCorner = Instance.new("UICorner")
			btnCorner.CornerRadius = UDim.new(0, 8)
			btnCorner.Parent = playerButton

			local btnStroke = Instance.new("UIStroke")
			btnStroke.Color = COLORS.textSecondary
			btnStroke.Transparency = 0.8
			btnStroke.Parent = playerButton

			local playerIcon = Instance.new("TextLabel")
			playerIcon.Size = UDim2.new(0, 30, 0, 30)
			playerIcon.Position = UDim2.new(0, 8, 0.5, -15)
			playerIcon.BackgroundColor3 = COLORS.accent
			playerIcon.BackgroundTransparency = 0.5
			playerIcon.Text = string.sub(p.Name, 1, 1):upper()
			playerIcon.TextColor3 = COLORS.text
			playerIcon.TextSize = 16
			playerIcon.Font = Enum.Font.GothamBold
			playerIcon.Parent = playerButton

			local iconCorner = Instance.new("UICorner")
			iconCorner.CornerRadius = UDim.new(1, 0)
			iconCorner.Parent = playerIcon

			local playerName = Instance.new("TextLabel")
			playerName.Size = UDim2.new(1, -50, 1, 0)
			playerName.Position = UDim2.new(0, 45, 0, 0)
			playerName.BackgroundTransparency = 1
			playerName.Text = p.Name
			playerName.TextColor3 = COLORS.text
			playerName.TextSize = 16
			playerName.Font = Enum.Font.GothamMedium
			playerName.TextXAlignment = Enum.TextXAlignment.Left
			playerName.Parent = playerButton

			playerButtons[p.UserId] = {button = playerButton, stroke = btnStroke, icon = playerIcon}

			playerButton.MouseEnter:Connect(function()
				if selectedPlayer ~= p then
					TweenService:Create(btnStroke, TweenInfo.new(0.2), {Transparency = 0.5}):Play()
				end
			end)

			playerButton.MouseLeave:Connect(function()
				if selectedPlayer ~= p then
					TweenService:Create(btnStroke, TweenInfo.new(0.2), {Transparency = 0.8}):Play()
				end
			end)

			playerButton.MouseButton1Click:Connect(function()
				for _, data in pairs(playerButtons) do
					TweenService:Create(data.stroke, TweenInfo.new(0.2), {Color = COLORS.textSecondary, Transparency = 0.8}):Play()
					TweenService:Create(data.icon, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.accent}):Play()
				end

				TweenService:Create(btnStroke, TweenInfo.new(0.2), {Color = COLORS.accent, Transparency = 0}):Play()
				TweenService:Create(playerIcon, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.success}):Play()
				selectedPlayer = p
			end)
		end
	end

	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 12)

	local reasonLabel = Instance.new("TextLabel")
	reasonLabel.Size = UDim2.new(1, 0, 0, 25)
	reasonLabel.Position = UDim2.new(0, 0, 0, 310)
	reasonLabel.BackgroundTransparency = 1
	reasonLabel.Text = "Причина кіку:"
	reasonLabel.TextColor3 = COLORS.textSecondary
	reasonLabel.TextSize = 14
	reasonLabel.Font = Enum.Font.GothamMedium
	reasonLabel.Parent = mainFrame

	local reasonBox = Instance.new("TextBox")
	reasonBox.Size = UDim2.new(1, -30, 0, 70)
	reasonBox.Position = UDim2.new(0, 15, 0, 335)
	reasonBox.BackgroundColor3 = Color3.new(0, 0, 0)
	reasonBox.BackgroundTransparency = 0.5
	reasonBox.BorderSizePixel = 0
	reasonBox.Text = ""
	reasonBox.PlaceholderText = "Введіть причину кіку..."
	reasonBox.PlaceholderColor3 = COLORS.textSecondary
	reasonBox.TextColor3 = COLORS.text
	reasonBox.TextSize = 14
	reasonBox.Font = Enum.Font.Gotham
	reasonBox.TextWrapped = true
	reasonBox.TextXAlignment = Enum.TextXAlignment.Left
	reasonBox.TextYAlignment = Enum.TextYAlignment.Top
	reasonBox.ClearTextOnFocus = false
	reasonBox.Parent = mainFrame

	local reasonCorner = Instance.new("UICorner")
	reasonCorner.CornerRadius = UDim.new(0, 10)
	reasonCorner.Parent = reasonBox

	local reasonStroke = Instance.new("UIStroke")
	reasonStroke.Color = COLORS.textSecondary
	reasonStroke.Transparency = 0.7
	reasonStroke.Parent = reasonBox

	local reasonPadding = Instance.new("UIPadding")
	reasonPadding.PaddingLeft = UDim.new(0, 12)
	reasonPadding.PaddingTop = UDim.new(0, 10)
	reasonPadding.PaddingRight = UDim.new(0, 12)
	reasonPadding.Parent = reasonBox

	reasonBox.Focused:Connect(function()
		TweenService:Create(reasonStroke, TweenInfo.new(0.2), {Color = COLORS.accent, Transparency = 0}):Play()
	end)

	reasonBox.FocusLost:Connect(function()
		TweenService:Create(reasonStroke, TweenInfo.new(0.2), {Color = COLORS.textSecondary, Transparency = 0.7}):Play()
	end)

	local submitBtn = createButton(
		mainFrame,
		"🗳️ ПОЧАТИ ГОЛОСУВАННЯ",
		COLORS.accent,
		UDim2.new(1, -30, 0, 50),
		UDim2.new(0, 15, 0, 420)
	)

	local cancelBtn = createButton(
		mainFrame,
		"❌ СКАСУВАТИ",
		COLORS.danger,
		UDim2.new(1, -30, 0, 40),
		UDim2.new(0, 15, 0, 478)
	)

	submitBtn.MouseButton1Click:Connect(function()
		if selectedPlayer then
			local reason = reasonBox.Text
			if reason == "" then
				reason = "Не вказано"
			end
			StartVotekickEvent:FireServer(selectedPlayer.UserId, reason)
			animateOut(mainFrame, function()
				votekickMenuGui:Destroy()
				votekickMenuGui = nil
			end)
		else
			showNotification("Виберіть гравця!", "warning")
		end
	end)

	cancelBtn.MouseButton1Click:Connect(function()
		animateOut(mainFrame, function()
			votekickMenuGui:Destroy()
			votekickMenuGui = nil
		end)
	end)

	overlay.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			animateOut(mainFrame, function()
				votekickMenuGui:Destroy()
				votekickMenuGui = nil
			end)
		end
	end)

	animateIn(mainFrame, nil, UDim2.new(0.5, -210, 0.5, -260))
end

local votingGui = nil
local hasVoted = false
local currentRequiredVotes = 1

local function showVotingUI(targetName, reason, initiator, duration, isInitiator, isTarget, eligibleVoters, requiredVotes)
	if votingGui then
		votingGui:Destroy()
	end

	hasVoted = isInitiator or isTarget or false
	currentRequiredVotes = requiredVotes or 1
	votingGui = createScreenGui("VotingUI")

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 380, 0, 340)
	mainFrame.Position = UDim2.new(0, 25, 0.5, -170)
	mainFrame.BackgroundColor3 = COLORS.background
	mainFrame.BackgroundTransparency = 1
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = votingGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 20)
	corner.Parent = mainFrame

	local stroke = Instance.new("UIStroke")
	stroke.Color = COLORS.danger
	stroke.Transparency = 0.3
	stroke.Thickness = 2
	stroke.Parent = mainFrame

	addGlow(mainFrame, COLORS.danger)

	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 50)
	header.BackgroundColor3 = COLORS.danger
	header.BackgroundTransparency = 0.7
	header.Parent = mainFrame

	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 20)
	headerCorner.Parent = header

	local headerFix = Instance.new("Frame")
	headerFix.Size = UDim2.new(1, 0, 0, 20)
	headerFix.Position = UDim2.new(0, 0, 1, -20)
	headerFix.BackgroundColor3 = COLORS.danger
	headerFix.BackgroundTransparency = 0.7
	headerFix.BorderSizePixel = 0
	headerFix.Parent = header

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 1, 0)
	title.BackgroundTransparency = 1
	title.Text = "🗳️ VOTEKICK"
	title.TextColor3 = COLORS.text
	title.TextSize = 22
	title.Font = Enum.Font.GothamBlack
	title.Parent = header

	local infoText = Instance.new("TextLabel")
	infoText.Size = UDim2.new(1, -30, 0, 90)
	infoText.Position = UDim2.new(0, 15, 0, 60)
	infoText.BackgroundTransparency = 1
	infoText.Text = string.format(
		"👤 %s подав votekick на гравця:\n\n🎯 %s\n\n📝 Причина: %s",
		initiator, targetName, reason
	)
	infoText.TextColor3 = COLORS.text
	infoText.TextSize = 14
	infoText.Font = Enum.Font.GothamMedium
	infoText.TextWrapped = true
	infoText.TextXAlignment = Enum.TextXAlignment.Left
	infoText.TextYAlignment = Enum.TextYAlignment.Top
	infoText.Parent = mainFrame

	local statsFrame = Instance.new("Frame")
	statsFrame.Name = "StatsFrame"
	statsFrame.Size = UDim2.new(1, -30, 0, 50)
	statsFrame.Position = UDim2.new(0, 15, 0, 155)
	statsFrame.BackgroundColor3 = Color3.new(0, 0, 0)
	statsFrame.BackgroundTransparency = 0.5
	statsFrame.Parent = mainFrame

	local statsCorner = Instance.new("UICorner")
	statsCorner.CornerRadius = UDim.new(0, 8)
	statsCorner.Parent = statsFrame

	local votesForLabel = Instance.new("TextLabel")
	votesForLabel.Name = "VotesFor"
	votesForLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
	votesForLabel.BackgroundTransparency = 1
	votesForLabel.Text = "✅ ЗА: 1 / " .. requiredVotes
	votesForLabel.TextColor3 = COLORS.success
	votesForLabel.TextSize = 15
	votesForLabel.Font = Enum.Font.GothamBold
	votesForLabel.Parent = statsFrame

	local votesAgainstLabel = Instance.new("TextLabel")
	votesAgainstLabel.Name = "VotesAgainst"
	votesAgainstLabel.Size = UDim2.new(0.5, 0, 0.5, 0)
	votesAgainstLabel.Position = UDim2.new(0.5, 0, 0, 0)
	votesAgainstLabel.BackgroundTransparency = 1
	votesAgainstLabel.Text = "❌ ПРОТИ: 0"
	votesAgainstLabel.TextColor3 = COLORS.danger
	votesAgainstLabel.TextSize = 15
	votesAgainstLabel.Font = Enum.Font.GothamBold
	votesAgainstLabel.Parent = statsFrame

	local totalLabel = Instance.new("TextLabel")
	totalLabel.Name = "Total"
	totalLabel.Size = UDim2.new(1, 0, 0.5, 0)
	totalLabel.Position = UDim2.new(0, 0, 0.5, 0)
	totalLabel.BackgroundTransparency = 1
	totalLabel.Text = "👥 Голосуючих: " .. eligibleVoters .. " | Потрібно: " .. requiredVotes
	totalLabel.TextColor3 = COLORS.textSecondary
	totalLabel.TextSize = 13
	totalLabel.Font = Enum.Font.GothamMedium
	totalLabel.Parent = statsFrame

	local timerFrame = Instance.new("Frame")
	timerFrame.Size = UDim2.new(1, -30, 0, 6)
	timerFrame.Position = UDim2.new(0, 15, 0, 213)
	timerFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
	timerFrame.Parent = mainFrame

	local timerCorner = Instance.new("UICorner")
	timerCorner.CornerRadius = UDim.new(1, 0)
	timerCorner.Parent = timerFrame

	local timerBar = Instance.new("Frame")
	timerBar.Name = "TimerBar"
	timerBar.Size = UDim2.new(1, 0, 1, 0)
	timerBar.BackgroundColor3 = COLORS.warning
	timerBar.Parent = timerFrame

	local timerBarCorner = Instance.new("UICorner")
	timerBarCorner.CornerRadius = UDim.new(1, 0)
	timerBarCorner.Parent = timerBar

	local timerLabel = Instance.new("TextLabel")
	timerLabel.Name = "Timer"
	timerLabel.Size = UDim2.new(1, 0, 0, 20)
	timerLabel.Position = UDim2.new(0, 0, 0, 223)
	timerLabel.BackgroundTransparency = 1
	timerLabel.Text = "⏱️ " .. duration .. " сек"
	timerLabel.TextColor3 = COLORS.warning
	timerLabel.TextSize = 13
	timerLabel.Font = Enum.Font.GothamBold
	timerLabel.Parent = mainFrame

	local voteYesBtn = createButton(
		mainFrame,
		"✅ ТАК",
		COLORS.success,
		UDim2.new(0.46, 0, 0, 50),
		UDim2.new(0.02, 0, 0, 250)
	)
	voteYesBtn.Name = "VoteYes"

	local voteNoBtn = createButton(
		mainFrame,
		"❌ НІ",
		COLORS.danger,
		UDim2.new(0.46, 0, 0, 50),
		UDim2.new(0.52, 0, 0, 250)
	)
	voteNoBtn.Name = "VoteNo"

	local voteStatus = Instance.new("TextLabel")
	voteStatus.Name = "VoteStatus"
	voteStatus.Size = UDim2.new(1, 0, 0, 25)
	voteStatus.Position = UDim2.new(0, 0, 0, 308)
	voteStatus.BackgroundTransparency = 1
	voteStatus.Text = ""
	voteStatus.TextColor3 = COLORS.textSecondary
	voteStatus.TextSize = 12
	voteStatus.Font = Enum.Font.GothamMedium
	voteStatus.Parent = mainFrame

	if isTarget then
		voteYesBtn.BackgroundTransparency = 0.7
		voteNoBtn.BackgroundTransparency = 0.7
		voteYesBtn.Active = false
		voteNoBtn.Active = false
		voteStatus.Text = "🚫 Ви не можете голосувати"
		voteStatus.TextColor3 = COLORS.danger
	elseif isInitiator then
		voteYesBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 80)
		voteNoBtn.BackgroundTransparency = 0.7
		voteStatus.Text = "✓ Ви ініціатор (автоматично ЗА)"
		voteStatus.TextColor3 = COLORS.success
	end

	voteYesBtn.MouseButton1Click:Connect(function()
		if not hasVoted then
			hasVoted = true
			CastVoteEvent:FireServer(true)

			TweenService:Create(voteYesBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(50, 150, 80)}):Play()
			TweenService:Create(voteNoBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.7}):Play()
			voteStatus.Text = "✓ Ви проголосували ЗА"
			voteStatus.TextColor3 = COLORS.success
		end
	end)

	voteNoBtn.MouseButton1Click:Connect(function()
		if not hasVoted then
			hasVoted = true
			CastVoteEvent:FireServer(false)

			TweenService:Create(voteNoBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(150, 50, 50)}):Play()
			TweenService:Create(voteYesBtn, TweenInfo.new(0.3), {BackgroundTransparency = 0.7}):Play()
			voteStatus.Text = "✓ Ви проголосували ПРОТИ"
			voteStatus.TextColor3 = COLORS.danger
		end
	end)

	animateIn(mainFrame, UDim2.new(-0.3, 0, 0.5, -170), UDim2.new(0, 25, 0.5, -170))

	local startTime = tick()
	local totalDuration = duration

	task.spawn(function()
		while votingGui and mainFrame and mainFrame.Parent do
			task.wait(0.1)
			local elapsed = tick() - startTime
			local timeLeft = math.max(0, totalDuration - elapsed)

			if mainFrame:FindFirstChild("Timer") then
				mainFrame.Timer.Text = "⏱️ " .. math.ceil(timeLeft) .. " сек"

				local progress = timeLeft / totalDuration
				if timerBar and timerBar.Parent then
					timerBar.Size = UDim2.new(progress, 0, 1, 0)
				end

				if timeLeft <= 10 then
					mainFrame.Timer.TextColor3 = COLORS.danger
					if timerBar then
						timerBar.BackgroundColor3 = COLORS.danger
					end
				end
			end

			if timeLeft <= 0 then break end
		end
	end)
end

UpdateVotesEvent.OnClientEvent:Connect(function(votesFor, votesAgainst, total, timeLeft, requiredVotes)
	if not votingGui then return end

	if requiredVotes then
		currentRequiredVotes = requiredVotes
	end

	for _, frame in pairs(votingGui:GetDescendants()) do
		if frame.Name == "VotesFor" and frame:IsA("TextLabel") then
			frame.Text = "✅ ЗА: " .. votesFor .. " / " .. currentRequiredVotes
		elseif frame.Name == "VotesAgainst" and frame:IsA("TextLabel") then
			frame.Text = "❌ ПРОТИ: " .. votesAgainst
		elseif frame.Name == "Total" and frame:IsA("TextLabel") then
			frame.Text = "👥 Голосуючих: " .. total .. " | Потрібно: " .. currentRequiredVotes
		end
	end
end)

EndVotingEvent.OnClientEvent:Connect(function(success, targetName, votesFor, votesAgainst, requiredVotes)
	if votingGui then
		local mainFrame = votingGui:FindFirstChild("MainFrame")

		if mainFrame then
			for _, child in pairs(mainFrame:GetChildren()) do
				if child:IsA("GuiObject") and child.Name ~= "Glow" then
					TweenService:Create(child, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
					if child:IsA("TextLabel") or child:IsA("TextButton") then
						TweenService:Create(child, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
					end
				end
			end

			task.wait(0.2)

			local resultFrame = Instance.new("Frame")
			resultFrame.Size = UDim2.new(1, -30, 1, -30)
			resultFrame.Position = UDim2.new(0, 15, 0, 15)
			resultFrame.BackgroundColor3 = success and COLORS.success or COLORS.danger
			resultFrame.BackgroundTransparency = 0.2
			resultFrame.Parent = mainFrame

			local resultCorner = Instance.new("UICorner")
			resultCorner.CornerRadius = UDim.new(0, 15)
			resultCorner.Parent = resultFrame

			local resultIcon = Instance.new("TextLabel")
			resultIcon.Size = UDim2.new(1, 0, 0, 80)
			resultIcon.Position = UDim2.new(0, 0, 0, 30)
			resultIcon.BackgroundTransparency = 1
			resultIcon.Text = success and "✅" or "❌"
			resultIcon.TextSize = 60
			resultIcon.Parent = resultFrame

			local resultTitle = Instance.new("TextLabel")
			resultTitle.Size = UDim2.new(1, 0, 0, 40)
			resultTitle.Position = UDim2.new(0, 0, 0, 110)
			resultTitle.BackgroundTransparency = 1
			resultTitle.Text = success and "VOTEKICK УСПІШНИЙ!" or "VOTEKICK НЕВДАЛИЙ"
			resultTitle.TextColor3 = COLORS.text
			resultTitle.TextSize = 22
			resultTitle.Font = Enum.Font.GothamBlack
			resultTitle.Parent = resultFrame

			local resultInfo = Instance.new("TextLabel")
			resultInfo.Size = UDim2.new(1, -20, 0, 80)
			resultInfo.Position = UDim2.new(0, 10, 0, 160)
			resultInfo.BackgroundTransparency = 1
			resultInfo.Text = success and 
				string.format("%s вигнаний!\n\nЗА: %d / %d | ПРОТИ: %d", targetName, votesFor, requiredVotes or currentRequiredVotes, votesAgainst) or
				string.format("%s залишається\n\nЗА: %d / %d | ПРОТИ: %d", targetName, votesFor, requiredVotes or currentRequiredVotes, votesAgainst)
			resultInfo.TextColor3 = COLORS.text
			resultInfo.TextSize = 16
			resultInfo.Font = Enum.Font.GothamMedium
			resultInfo.TextWrapped = true
			resultInfo.Parent = resultFrame

			resultFrame.BackgroundTransparency = 1
			TweenService:Create(resultFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
				BackgroundTransparency = 0.2
			}):Play()
		end

		task.wait(3)
		if votingGui then
			animateOut(votingGui:FindFirstChild("MainFrame"), function()
				if votingGui then
					votingGui:Destroy()
					votingGui = nil
				end
			end)
		end
	end
end)

OpenVotekickMenuEvent.OnClientEvent:Connect(openVotekickMenu)
ShowVotingUIEvent.OnClientEvent:Connect(showVotingUI)

NotifyEvent.OnClientEvent:Connect(function(message, notifType)
	task.spawn(showNotification, message, notifType)
end)

ChatReminderEvent.OnClientEvent:Connect(function()
	pcall(function()
		StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = "📢 Доступний votekick! Для використання напишіть /votekick",
			Color = COLORS.accent,
			Font = Enum.Font.GothamBold
		})
	end)
end)