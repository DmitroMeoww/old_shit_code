local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local currentCharacter = nil
local currentHumanoid = nil
local seatedConnection = nil

local function setCameraToPlayer(humanoid)
	if humanoid and humanoid.Parent then
		camera.CameraType = Enum.CameraType.Custom
		camera.CameraSubject = humanoid
	end
end

local function fixCameraForVehicleSeat(humanoid)
	if humanoid and humanoid.Parent then
		camera.CameraType = Enum.CameraType.Custom
		camera.CameraSubject = humanoid
	end
end

local function onCharacterAdded(character)
	currentCharacter = character
	currentHumanoid = character:WaitForChild("Humanoid")

	if seatedConnection then
		seatedConnection:Disconnect()
		seatedConnection = nil
	end

	setCameraToPlayer(currentHumanoid)

	seatedConnection = currentHumanoid.Seated:Connect(function(isSeated, seatPart)
		if isSeated then
			if seatPart and seatPart:IsA("VehicleSeat") then
				fixCameraForVehicleSeat(currentHumanoid)
			else
				setCameraToPlayer(currentHumanoid)
			end
		else
			setCameraToPlayer(currentHumanoid)
		end
	end)
end

if localPlayer.Character then
	onCharacterAdded(localPlayer.Character)
end

localPlayer.CharacterAdded:Connect(onCharacterAdded)