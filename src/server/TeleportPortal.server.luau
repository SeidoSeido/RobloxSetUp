--[[
	Teleport Portal System - Sophisticated portal with fade transitions
	Features: 5-second delay, screen fade in/out, smooth teleportation
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Portal settings
local TELEPORT_DELAY = 5 -- Seconds to wait before teleport
local FADE_DURATION = 1 -- Duration of fade in/out
local COOLDOWN_TIME = 2 -- Cooldown between portal uses per player

-- Track players using portals to prevent spam
local playerCooldowns = {}
local playersInPortal = {}

-- Create RemoteEvents for client communication
local function createRemoteEvents()
	local remoteEvents = Instance.new("Folder")
	remoteEvents.Name = "PortalEvents"
	remoteEvents.Parent = ReplicatedStorage

	local fadeScreenEvent = Instance.new("RemoteEvent")
	fadeScreenEvent.Name = "FadeScreen"
	fadeScreenEvent.Parent = remoteEvents

	return fadeScreenEvent
end

-- Get or create the remote events
local fadeScreenEvent = ReplicatedStorage:FindFirstChild("PortalEvents")
if not fadeScreenEvent then
	fadeScreenEvent = createRemoteEvents()
else
	fadeScreenEvent = fadeScreenEvent:FindFirstChild("FadeScreen")
end

-- Function to teleport player with fade effect
local function teleportPlayerWithFade(player, entrance, exit)
	local character = player.Character
	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end

	-- Check cooldown
	if playerCooldowns[player.UserId] and tick() - playerCooldowns[player.UserId] < COOLDOWN_TIME then
		return
	end

	-- Check if player is already in a portal
	if playersInPortal[player.UserId] then
		return
	end

	-- Mark player as in portal
	playersInPortal[player.UserId] = true
	playerCooldowns[player.UserId] = tick()

	print("🌀 " .. player.Name .. " entered portal: " .. entrance.Name)

	-- Freeze the player during teleportation (without ragdoll)
	local humanoid = character:FindFirstChild("Humanoid")
	local originalWalkSpeed = 16
	if humanoid then
		originalWalkSpeed = humanoid.WalkSpeed
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
	end

	-- Start fade in to black
	fadeScreenEvent:FireClient(player, "fadeIn", FADE_DURATION)

	-- Wait for fade in to complete + delay
	task.wait(FADE_DURATION + TELEPORT_DELAY)

	-- Find the exit portal
	local exitPortal = Workspace:FindFirstChild(exit.Name)
	if not exitPortal then
		print("❌ Exit portal not found: " .. exit.Name)
		-- Cleanup and exit
		if humanoid then
			humanoid.WalkSpeed = originalWalkSpeed
			humanoid.JumpPower = 50
		end
		playersInPortal[player.UserId] = nil
		fadeScreenEvent:FireClient(player, "fadeOut", FADE_DURATION)
		return
	end

	-- Calculate teleport position (slightly above the exit)
	local exitCFrame
	if exitPortal:IsA("Model") and exitPortal.PrimaryPart then
		exitCFrame = exitPortal.PrimaryPart.CFrame
	elseif exitPortal:IsA("BasePart") then
		exitCFrame = exitPortal.CFrame
	else
		-- Try to find a part in the model
		local exitPart = exitPortal:FindFirstChildWhichIsA("BasePart")
		if exitPart then
			exitCFrame = exitPart.CFrame
		else
			print("❌ Could not find teleport position for: " .. exit.Name)
			if humanoid then
				humanoid.WalkSpeed = originalWalkSpeed
				humanoid.JumpPower = 50
			end
			playersInPortal[player.UserId] = nil
			fadeScreenEvent:FireClient(player, "fadeOut", FADE_DURATION)
			return
		end
	end

	-- Teleport the player (with slight offset to avoid clipping)
	local teleportPosition = exitCFrame.Position + Vector3.new(0, 5, 0)
	humanoidRootPart.CFrame = CFrame.new(teleportPosition)

	print("✨ " .. player.Name .. " teleported to: " .. exit.Name)

	-- Unfreeze the player
	if humanoid then
		humanoid.WalkSpeed = originalWalkSpeed
		humanoid.JumpPower = 50
	end

	-- Start fade out from black
	fadeScreenEvent:FireClient(player, "fadeOut", FADE_DURATION)

	-- Wait a bit then clear portal status
	task.wait(FADE_DURATION + 0.5)
	playersInPortal[player.UserId] = nil
end

-- Function to setup portal entrance
local function setupPortalEntrance(entrance, exitName)
	if not entrance then
		return
	end

	print("🌀 Setting up portal entrance: " .. entrance.Name .. " -> " .. exitName)

	-- Function to handle touch
	local function onTouch(hit, part)
		local character = hit.Parent
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			local player = Players:GetPlayerFromCharacter(character)
			if player then
				-- Create exit reference
				local exit = { Name = exitName }

				-- Start teleportation process in a separate thread
				task.spawn(function()
					teleportPlayerWithFade(player, entrance, exit)
				end)
			end
		end
	end

	-- Connect touch events to all parts in the model
	if entrance:IsA("Model") then
		for _, part in pairs(entrance:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Touched:Connect(function(hit)
					onTouch(hit, part)
				end)
			end
		end
	elseif entrance:IsA("BasePart") then
		entrance.Touched:Connect(function(hit)
			onTouch(hit, entrance)
		end)
	end
end

-- Function to find and setup all portals
local function setupPortals()
	-- Look for TeleportObbyOneEntrance
	local entrance = Workspace:FindFirstChild("TeleportObbyOneEntrance")
	if entrance then
		setupPortalEntrance(entrance, "TeleportObbyOneExit")
	else
		print("⚠️ Portal entrance not found: TeleportObbyOneEntrance")
	end

	-- You can add more portal pairs here
	-- Example:
	-- local entrance2 = Workspace:FindFirstChild("TeleportObbyTwoEntrance")
	-- if entrance2 then
	--     setupPortalEntrance(entrance2, "TeleportObbyTwoExit")
	-- end
end

-- Setup portals when new models are added
local function onChildAdded(child)
	if child.Name == "TeleportObbyOneEntrance" then
		task.wait(0.1) -- Wait for model to fully load
		setupPortalEntrance(child, "TeleportObbyOneExit")
	end
	-- Add more portal entrance names here as needed
end

-- Connect to workspace changes
Workspace.ChildAdded:Connect(onChildAdded)

-- Clean up when players leave
Players.PlayerRemoving:Connect(function(player)
	playerCooldowns[player.UserId] = nil
	playersInPortal[player.UserId] = nil
end)

-- Initial setup
setupPortals()

print("🌀 Teleport Portal System loaded!")
print("🚪 Entrance: TeleportObbyOneEntrance")
print("🏁 Exit: TeleportObbyOneExit")
print("⏱️ Teleport delay: " .. TELEPORT_DELAY .. " seconds")
print("🎬 Fade duration: " .. FADE_DURATION .. " seconds")
print("❄️ Cooldown: " .. COOLDOWN_TIME .. " seconds")
