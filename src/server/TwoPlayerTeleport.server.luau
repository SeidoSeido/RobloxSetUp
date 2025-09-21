--[[
	Two Player Teleport System Server - Handles 2-player teleportation with countdown
	Features: Player detection, countdown timer, teleportation trigger
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

-- Create RemoteEvents
local twoPlayerRemoteEvent = Instance.new("RemoteEvent")
twoPlayerRemoteEvent.Name = "TwoPlayerTeleportEvent"
twoPlayerRemoteEvent.Parent = ReplicatedStorage

-- Configuration
local COUNTDOWN_ONE_PLAYER = 30 -- Countdown when 1 player
local COUNTDOWN_TWO_PLAYERS = 10 -- Countdown when 2 players
local MAX_PLAYERS = 2
local TELEPORT_PLACE_ID = 114873613594760 -- Target place ID

-- Track players and timer
local playersInPart = {}
local currentCountdown = 0
local countdownActive = false
local countdownThread = nil

-- Function to update all clients with current status
local function updateAllClients()
	local playerCount = #playersInPart
	local statusData = {
		action = "updateStatus",
		playerCount = playerCount,
		maxPlayers = MAX_PLAYERS,
		countdown = currentCountdown,
		countdownActive = countdownActive,
	}

	-- Send to all players
	for _, player in pairs(Players:GetPlayers()) do
		twoPlayerRemoteEvent:FireClient(player, statusData)
	end

	print("📊 Updated status: " .. playerCount .. "/" .. MAX_PLAYERS .. " players, countdown: " .. currentCountdown)
end

-- Function to start countdown
local function startCountdown(duration)
	if countdownActive then
		return
	end

	countdownActive = true
	currentCountdown = duration

	print("⏰ Starting countdown: " .. duration .. " seconds")

	-- Start countdown thread
	countdownThread = task.spawn(function()
		while currentCountdown > 0 and countdownActive do
			updateAllClients()
			task.wait(1)
			currentCountdown = currentCountdown - 1
		end

		-- Countdown finished
		if countdownActive and currentCountdown <= 0 then
			print("🚀 Countdown finished! Starting teleportation...")

			-- Send teleportation start event to clients
			local teleportData = {
				action = "startTeleport",
			}

			for _, player in pairs(playersInPart) do
				twoPlayerRemoteEvent:FireClient(player, teleportData)
			end

			-- Wait for animation to play
			task.wait(3)

			-- Teleport all players in the part
			if TELEPORT_PLACE_ID then
				local playersList = {}
				for _, player in pairs(playersInPart) do
					table.insert(playersList, player)
				end

				if #playersList > 0 then
					local success, errorMessage = pcall(function()
						TeleportService:TeleportAsync(TELEPORT_PLACE_ID, playersList)
					end)

					if success then
						print(
							"🚀 Successfully teleported "
								.. #playersList
								.. " players to place ID: "
								.. tostring(TELEPORT_PLACE_ID)
						)
					else
						warn("❌ Failed to teleport players: " .. tostring(errorMessage))
					end
				end
			else
				print("⚠️ No teleport place ID set - teleportation skipped")
			end

			-- Reset system
			playersInPart = {}
			countdownActive = false
			currentCountdown = 0
			updateAllClients()
		end
	end)
end

-- Function to stop countdown
local function stopCountdown()
	if not countdownActive then
		return
	end

	countdownActive = false
	currentCountdown = 0

	if countdownThread then
		task.cancel(countdownThread)
		countdownThread = nil
	end

	print("🛑 Countdown stopped")
	updateAllClients()
end

-- Function to add player to part
local function addPlayer(player)
	-- Check if player already in list
	for _, p in pairs(playersInPart) do
		if p == player then
			return -- Already in list
		end
	end

	-- Check max players
	if #playersInPart >= MAX_PLAYERS then
		print("⚠️ Max players reached, cannot add " .. player.Name)
		return
	end

	-- Add player
	table.insert(playersInPart, player)
	print("➕ Added player: " .. player.Name .. " (" .. #playersInPart .. "/" .. MAX_PLAYERS .. ")")

	-- Start appropriate countdown
	if #playersInPart == 1 then
		startCountdown(COUNTDOWN_ONE_PLAYER)
	elseif #playersInPart == 2 then
		stopCountdown()
		startCountdown(COUNTDOWN_TWO_PLAYERS)
	end

	updateAllClients()
end

-- Function to remove player from part
local function removePlayer(player)
	for i, p in pairs(playersInPart) do
		if p == player then
			table.remove(playersInPart, i)
			print("➖ Removed player: " .. player.Name .. " (" .. #playersInPart .. "/" .. MAX_PLAYERS .. ")")
			break
		end
	end

	-- Handle countdown based on remaining players
	if #playersInPart == 0 then
		stopCountdown()
	elseif #playersInPart == 1 then
		stopCountdown()
		startCountdown(COUNTDOWN_ONE_PLAYER)
	end

	updateAllClients()
end

-- Function to setup the TwoPlayer part
local function setupTwoPlayerPart()
	local twoPlayerPart = Workspace:FindFirstChild("TwoPlayer")

	if not twoPlayerPart then
		warn("⚠️ TwoPlayer part not found in workspace")
		return false
	end

	-- Ensure part is non-collidable
	twoPlayerPart.CanCollide = false
	twoPlayerPart.Transparency = 0.8 -- Slightly visible for debugging

	print("🎯 Setting up TwoPlayer part: " .. twoPlayerPart.Name)

	-- Track players currently inside the region
	local playersInside = {}

	-- Get part boundaries for region detection
	local partCFrame = twoPlayerPart.CFrame
	local partSize = twoPlayerPart.Size

	-- Create region bounds (slightly larger for better detection)
	local regionSize = partSize + Vector3.new(2, 2, 2)

	-- Function to check if a player is inside the part region
	local function isPlayerInRegion(player)
		if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
			return false
		end

		local playerPosition = player.Character.HumanoidRootPart.Position
		local partPosition = partCFrame.Position

		-- Check if player is within the region bounds
		local relativePosition = playerPosition - partPosition
		local halfSize = regionSize * 0.5

		return math.abs(relativePosition.X) <= halfSize.X
			and math.abs(relativePosition.Y) <= halfSize.Y
			and math.abs(relativePosition.Z) <= halfSize.Z
	end

	-- Continuous monitoring instead of touch events
	local function monitorPlayers()
		for _, player in pairs(Players:GetPlayers()) do
			local isInside = isPlayerInRegion(player)
			local wasInside = playersInside[player]

			if isInside and not wasInside then
				-- Player entered
				playersInside[player] = true
				addPlayer(player)
			elseif not isInside and wasInside then
				-- Player left
				playersInside[player] = nil
				removePlayer(player)
			end
		end
	end

	-- Start monitoring with RunService
	RunService.Heartbeat:Connect(monitorPlayers)

	return true
end

-- Handle player leaving game
Players.PlayerRemoving:Connect(function(player)
	removePlayer(player)
end)

-- Initialize the system
local success = setupTwoPlayerPart()

if success then
	print("✅ Two Player Teleport System initialized!")
	print("🎯 Part: TwoPlayer")
	print("👥 Max players: " .. MAX_PLAYERS)
	print("⏰ Countdown (1 player): " .. COUNTDOWN_ONE_PLAYER .. "s")
	print("⏰ Countdown (2 players): " .. COUNTDOWN_TWO_PLAYERS .. "s")
	print("🔗 Teleport place ID: " .. tostring(TELEPORT_PLACE_ID))
else
	warn("❌ Failed to setup Two Player Teleport System - check TwoPlayer part exists")
end

print("🚀 Two Player Teleport System Server loaded!")
