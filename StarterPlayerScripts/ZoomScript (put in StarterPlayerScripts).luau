--- script by meguy1 ---

wait(0.2)

-- Change this to the key you want
local activationKey =			Enum.KeyCode.B
local secondaryActivationKey =	Enum.KeyCode.ButtonY
local maxZoom = 20				-- Zoom amount (less is more)
local speed = 0.2				-- Speed of zoom (from 0 to 1, exclusive)
local sensitivityFactor = 0.2	-- How fast the camera moves when zoomed in
local rightClickZoomInFirstPerson = false	-- Right click to zoom in first-person only


local runService = game:GetService("RunService")
local initialFOV = workspace.CurrentCamera.FieldOfView
local cam = workspace.CurrentCamera
local zoom = false
local zoomInConnection = nil
local zoomOutConnection = nil
local inputService = game:GetService("UserInputService")
local initialSensitivity = inputService.MouseDeltaSensitivity

local zoomInAnim = function()
	local currentZoom = cam.FieldOfView
	if zoomOutConnection then
		zoomOutConnection:Disconnect()
	end
	zoomInConnection = runService.RenderStepped:Connect(function()
		if not zoom or math.abs(cam.FieldOfView - maxZoom) < 0.5 then
			zoomInConnection:Disconnect()
		end
		cam.FieldOfView = currentZoom
		currentZoom = (currentZoom*(1-speed) + maxZoom*speed)
	end)
end

local zoomOutAnim = function()
	local currentZoom = cam.FieldOfView
	if zoomInConnection then
		zoomInConnection:Disconnect()
	end
	zoomOutConnection = runService.RenderStepped:Connect(function()
		if zoom or math.abs(cam.FieldOfView - initialFOV) < 0.5 then
			zoomOutConnection:Disconnect()
		end
		cam.FieldOfView = currentZoom
		currentZoom = (currentZoom*(1-speed) + initialFOV*speed)
	end)
end

function onKeyPress(actionName, userInputState, inputObject)
	if userInputState == Enum.UserInputState.Begin then
		zoom = true
		spawn(zoomInAnim)
		inputService.MouseDeltaSensitivity = initialSensitivity * sensitivityFactor
	elseif userInputState == Enum.UserInputState.End then
		zoom = false
		spawn(zoomOutAnim)
		inputService.MouseDeltaSensitivity = initialSensitivity
	end
end

-- If we want to be able to zoom in by right clicking while in first person
if rightClickZoomInFirstPerson then
	inputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		
		if not zoom and input.UserInputType == Enum.UserInputType.MouseButton2 then
			local goodToZoom = false
			
			if cam.CameraType == Enum.CameraType.Scriptable then
				goodToZoom = true
			else
				-- If the player is in first person, then use left click to zoom in
				local character = game.Players.LocalPlayer.Character
				if character then
					local head = character:FindFirstChild("Head")
					if head then
						if (head.Position - cam.CFrame.Position).Magnitude < 1 then
							goodToZoom = true
						end
					end
				end
			end
			
			if goodToZoom then
				onKeyPress(nil, Enum.UserInputState.Begin, nil)
			end
		end
	end)
	
	inputService.InputEnded:Connect(function(input, gameProcessed)
		if zoom and input.UserInputType == Enum.UserInputType.MouseButton2 then
			onKeyPress(nil, Enum.UserInputState.End, nil)
		end
	end)
end

game.ContextActionService:BindAction("keyPress", onKeyPress, false, activationKey)
game.ContextActionService:BindAction("keyPress2", onKeyPress, false, secondaryActivationKey)
