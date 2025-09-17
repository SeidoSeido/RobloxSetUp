--[[
	Portal System - Server script that teleports players between PortalEntrance and PortalExit
	Players touching either portal will be teleported to the other one
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Wait for both portals to exist in workspace
local portalEntrance = Workspace:WaitForChild("PortalEntrance")
local portalExit = Workspace:WaitForChild("PortalExit")

-- Cooldown system to prevent rapid teleportation
local teleportCooldowns = {}
local COOLDOWN_TIME = 2 -- 2 seconds cooldown

-- Function to teleport a player
local function teleportPlayer(player, targetPortal)
	local character = player.Character
	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end

	-- Check cooldown
	local userId = player.UserId
	local currentTime = tick()
	if teleportCooldowns[userId] and (currentTime - teleportCooldowns[userId]) < COOLDOWN_TIME then
		return -- Still on cooldown
	end

	-- Set cooldown
	teleportCooldowns[userId] = currentTime

	-- Calculate teleport position (slightly above the target portal)
	local targetPosition = targetPortal.Position + Vector3.new(0, targetPortal.Size.Y / 2 + 5, 0)

	-- Teleport the player
	humanoidRootPart.CFrame = CFrame.new(targetPosition)

	-- Optional: Add teleport effect (you can customize this)
	print("✨ " .. player.Name .. " teleported through the portal!")

	-- Optional: Create a brief visual effect
	local teleportEffect = Instance.new("Explosion")
	teleportEffect.Parent = Workspace
	teleportEffect.Position = targetPosition
	teleportEffect.BlastRadius = 0
	teleportEffect.BlastPressure = 0
	teleportEffect.Visible = false -- Just for the sound effect
end

-- Function to handle portal touch
local function onPortalTouch(hit, targetPortal)
	-- Check if the thing that touched is part of a player's character
	local character = hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid then
		-- Get the player from the character
		local player = Players:GetPlayerFromCharacter(character)
		if player then
			-- Teleport the player to the target portal
			teleportPlayer(player, targetPortal)
		end
	end
end

-- Connect entrance portal (teleports to exit)
portalEntrance.Touched:Connect(function(hit)
	onPortalTouch(hit, portalExit)
end)

-- Connect exit portal (teleports to entrance)
portalExit.Touched:Connect(function(hit)
	onPortalTouch(hit, portalEntrance)
end)

print("🌀 Portal system loaded!")
print("🚪 PortalEntrance ↔ PortalExit teleportation active!")
print("⏱️ Cooldown: " .. COOLDOWN_TIME .. " seconds between teleports")
