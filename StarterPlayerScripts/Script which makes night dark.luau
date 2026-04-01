local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local originalSettings = {
	timeOfDay = nil,
	effects = {},
	dayNightCycleScript = nil
}

local function createEffect(className, properties)
	if not RunService:IsClient() then return nil end

	local effect = Instance.new(className)
	for prop, value in pairs(properties) do
		pcall(function()
			effect[prop] = value
		end)
	end
	effect.Parent = Lighting
	return effect
end

local function applyDarkNight(player)
	if not originalSettings.timeOfDay then
		originalSettings.timeOfDay = Lighting.TimeOfDay
	end

	-- Stop Day/Night Cycle script
	for _, child in ipairs(Workspace:GetChildren()) do
		if child:IsA("Script") and child.Name == "DayNightCycle" then
			originalSettings.dayNightCycleScript = child
			child.Disabled = true
			break
		end
	end

	for _, child in ipairs(Lighting:GetChildren()) do
		child:Destroy()
	end

	local effects = {
		{
			class = "Sky",
			props = {
				CelestialBodiesShown = true,
				MoonAngularSize = 11,
				StarCount = 3000,
				SunAngularSize = 21
			}
		},
		{
			class = "Atmosphere",
			props = {
				Density = 0.75,
				Color = Color3.fromRGB(11, 2, 24),
				Decay = Color3.fromRGB(2, 27, 40),
				Glare = 0.14,
				Haze = 2.74
			}
		},
		{
			class = "BloomEffect",
			props = {
				Intensity = 1,
				Size = 24,
				Threshold = 2
			}
		},
		{
			class = "BlurEffect",
			props = {
				Size = 1
			}
		},
		{
			class = "ColorCorrectionEffect",
			props = {
				Brightness = 0,
				Contrast = 0,
				Saturation = 0,
				TintColor = Color3.fromRGB(222, 222, 222)
			}
		}
	}

	for _, effectData in ipairs(effects) do
		local effect = createEffect(effectData.class, effectData.props)
		if not effect then
			warn("Failed to create", effectData.class)
		end
	end

	Lighting.TimeOfDay = "00:00:00"

	-- Create and play sound for the player
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://111423607153546"
	sound.PlaybackSpeed = 0.5
	sound.Looped = true
	sound.Parent = player.Character or player
	sound:Play()
	originalSettings.sound = sound
end

local function removeDarkNight(player)
	Lighting.TimeOfDay = originalSettings.timeOfDay or "14:00:00"
	for _, child in ipairs(Lighting:GetChildren()) do
		child:Destroy()
	end

	local sky = Instance.new("Sky")
	sky.SkyboxBk = "http://www.roblox.com/asset/?id=91458024"
	sky.SkyboxDn = "http://www.roblox.com/asset/?id=91457980"
	sky.SkyboxFt = "http://www.roblox.com/asset/?id=91458024"
	sky.SkyboxLf = "http://www.roblox.com/asset/?id=91458024"
	sky.SkyboxRt = "http://www.roblox.com/asset/?id=91458024"
	sky.SkyboxUp = "http://www.roblox.com/asset/?id=91458002"
	sky.Parent = Lighting

	-- Stop and remove sound for the player
	if originalSettings.sound then
		originalSettings.sound:Stop()
		originalSettings.sound:Destroy()
		originalSettings.sound = nil
	end

	-- Restart Day/Night Cycle script
	if originalSettings.dayNightCycleScript then
		originalSettings.dayNightCycleScript.Disabled = false
		originalSettings.dayNightCycleScript = nil
	end
end

ReplicatedStorage.DarkNightEffect.OnClientEvent:Connect(function()
	local player = Players.LocalPlayer
	applyDarkNight(player)
end)

ReplicatedStorage.RemoveDarkNightEffect.OnClientEvent:Connect(function()
	local player = Players.LocalPlayer
	removeDarkNight(player)
end)
