local Players = game:GetService("Players")
local player = Players.LocalPlayer

local cooldown = false
local COOLDOWN_TIME = 10
local DAMAGE = 50

local function damagePlayer()
	if cooldown then return end
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		local humanoid = player.Character.Humanoid
		humanoid.Health = humanoid.Health - DAMAGE
		cooldown = true
		task.wait(COOLDOWN_TIME)
		cooldown = false
	end
end

local function setupTouchedEvents()
	if not player.Character then return end
	local character = player.Character

	for _, part in pairs(character:GetChildren()) do
		if part:IsA("BasePart") then
			part.Touched:Connect(function(hit)
				if hit.Name == "KR" then
					damagePlayer()
				end
			end)
		end
	end
end

local function onCharacterAdded(character)
	character:WaitForChild("HumanoidRootPart")
	task.wait(0.5)
	cooldown = false
	setupTouchedEvents()
end

player.CharacterAdded:Connect(onCharacterAdded)

if player.Character then
	onCharacterAdded(player.Character)
end