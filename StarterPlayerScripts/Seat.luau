local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local MAX_INTERACTION_DISTANCE = 16

local seatPrompts = {}
local seatConnections = {}
local charConnections = {}

local originalJumpPower = 0
local activeSeat = nil

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function cleanupSeat(seat)
	if not seat then return end

	local prompt = seatPrompts[seat]
	if prompt then
		prompt:Destroy()
	end

	if seatConnections[seat] then
		seatConnections[seat]:Disconnect()
		seatConnections[seat] = nil
	end

	seatPrompts[seat] = nil

	if activeSeat == seat then
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			activeSeat = nil
			humanoid.JumpPower = originalJumpPower
			humanoid.Sit = false
		end
	end
end

local function onSeatedStateChanged(humanoid, isSitting, seat)
	if isSitting and seat and seat:IsA("Seat") and not seat:IsA("VehicleSeat") then
		activeSeat = seat
		humanoid.JumpPower = 0
	elseif not isSitting and activeSeat then
		local seatToStandFrom = activeSeat
		activeSeat = nil
		humanoid.JumpPower = originalJumpPower

		if seatToStandFrom and seatToStandFrom.Parent then
			seatToStandFrom.Disabled = true

			local seatCFrame = seatToStandFrom.CFrame
			local standPosition = seatCFrame.Position + (seatCFrame.LookVector * 2.5) + Vector3.new(0, 0.5, 0)
			local lookAtPoint = standPosition + seatCFrame.LookVector
			local newCFrame = CFrame.lookAt(standPosition, lookAtPoint)

			local rootPart = humanoid.Parent and humanoid.Parent:FindFirstChild("HumanoidRootPart")
			if rootPart then
				rootPart.CFrame = newCFrame
			end
		end
	end
end

local function setupCharacter(character)
	for _, connection in pairs(charConnections) do
		connection:Disconnect()
	end
	table.clear(charConnections)

	raycastParams.FilterDescendantsInstances = {character}

	local humanoid = character:WaitForChild("Humanoid")
	originalJumpPower = humanoid.JumpPower
	activeSeat = nil

	charConnections.seated = humanoid.Seated:Connect(function(isSitting, seat)
		onSeatedStateChanged(humanoid, isSitting, seat)
	end)

	charConnections.jumping = humanoid.Jumping:Connect(function(isJumping)
		if isJumping and activeSeat then
			humanoid.Sit = false
		end
	end)
end

local function processSeat(seat)
	if not seat:IsA("Seat") or seat:IsA("VehicleSeat") or seatPrompts[seat] then
		return
	end

	seat.Disabled = true

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Сісти"
	prompt.ObjectText = "Сидіння"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 10
	prompt.RequiresLineOfSight = false
	prompt.Enabled = false
	prompt.Parent = seat

	seatConnections[seat] = seat.Destroying:Connect(function()
		cleanupSeat(seat)
	end)

	prompt.Triggered:Connect(function()
		local character = player.Character
		if not character then return end
		local humanoid = character:FindFirstChildOfClass("Humanoid")

		if humanoid and not activeSeat and not seat.Occupant then
			seat.Disabled = false
			seat:Sit(humanoid)
		end
	end)

	seatPrompts[seat] = prompt
end

player.CharacterAdded:Connect(setupCharacter)
if player.Character then
	setupCharacter(player.Character)
end

workspace.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("Seat") then
		processSeat(descendant)
	end
end)

for _, descendant in ipairs(workspace:GetDescendants()) do
	if descendant:IsA("Seat") then
		processSeat(descendant)
	end
end

RunService.RenderStepped:Connect(function()
	local character = player.Character
	if not character then return end

	local rayOrigin = camera.CFrame.Position
	local rayDirection = camera.CFrame.LookVector * MAX_INTERACTION_DISTANCE

	local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

	local targetedSeat = nil
	if raycastResult and raycastResult.Instance and seatPrompts[raycastResult.Instance] then
		targetedSeat = raycastResult.Instance
	end

	for seat, prompt in pairs(seatPrompts) do
		if prompt and prompt.Parent then
			prompt.Enabled = (seat == targetedSeat and not activeSeat)
		end
	end
end)