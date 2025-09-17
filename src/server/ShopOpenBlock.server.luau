--[[
	ShopOpenBlock - Server script that detects when players touch the ShopOpenBlock
	Fires a RemoteEvent to open the ShopGUI on the client
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Wait for the ShopOpenBlock to exist in workspace
local shopOpenBlock = Workspace:WaitForChild("ShopOpenBlock")

-- Create RemoteEvents for shop communication
local shopRemoteEvent
local closeShopRemoteEvent

if ReplicatedStorage:FindFirstChild("OpenShopRemote") then
	shopRemoteEvent = ReplicatedStorage.OpenShopRemote
else
	shopRemoteEvent = Instance.new("RemoteEvent")
	shopRemoteEvent.Name = "OpenShopRemote"
	shopRemoteEvent.Parent = ReplicatedStorage
end

if ReplicatedStorage:FindFirstChild("CloseShopRemote") then
	closeShopRemoteEvent = ReplicatedStorage.CloseShopRemote
else
	closeShopRemoteEvent = Instance.new("RemoteEvent")
	closeShopRemoteEvent.Name = "CloseShopRemote"
	closeShopRemoteEvent.Parent = ReplicatedStorage
end

-- Debounce system and tracking
local playerDebounces = {}
local playersWithOpenShops = {} -- Track which players have shops open
local DEBOUNCE_TIME = 3 -- 3 seconds cooldown
local MAX_DISTANCE = 20 -- 20 studs max distance

-- Function to handle shop opening
local function openShopForPlayer(player)
	-- Check if player is on cooldown
	local userId = player.UserId
	local currentTime = tick()

	if playerDebounces[userId] and (currentTime - playerDebounces[userId]) < DEBOUNCE_TIME then
		return -- Still on cooldown, don't open shop
	end

	-- Set debounce for this player
	playerDebounces[userId] = currentTime

	-- Track that this player has shop open
	playersWithOpenShops[userId] = true

	-- Fire to client to open shop
	shopRemoteEvent:FireClient(player)
	print("🛒 Opening shop for " .. player.Name)
end

-- Function to close shop for player
local function closeShopForPlayer(player)
	local userId = player.UserId
	if playersWithOpenShops[userId] then
		playersWithOpenShops[userId] = nil
		closeShopRemoteEvent:FireClient(player)
		print("🚪 Closing shop for " .. player.Name .. " (too far away)")
	end
end

-- Distance checking loop
RunService.Heartbeat:Connect(function()
	for userId, _ in pairs(playersWithOpenShops) do
		local player = Players:GetPlayerByUserId(userId)
		if player and player.Character then
			local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
			if humanoidRootPart then
				local distance = (humanoidRootPart.Position - shopOpenBlock.Position).Magnitude
				if distance > MAX_DISTANCE then
					closeShopForPlayer(player)
				end
			end
		else
			-- Player left or character doesn't exist, remove from tracking
			playersWithOpenShops[userId] = nil
		end
	end
end)

-- Connect the touched event
shopOpenBlock.Touched:Connect(function(hit)
	-- Check if the thing that touched is part of a player's character
	local character = hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid then
		-- Get the player from the character
		local player = Players:GetPlayerFromCharacter(character)
		if player then
			-- Open shop for the player (with debounce protection)
			openShopForPlayer(player)
		end
	end
end)

print("🛒 ShopOpenBlock script loaded - touch to open shop!")
print("⏱️ Debounce: " .. DEBOUNCE_TIME .. " seconds between shop opens per player")
print("📏 Auto-close distance: " .. MAX_DISTANCE .. " studs from ShopOpenBlock")

-- Clean up when players leave
Players.PlayerRemoving:Connect(function(player)
	local userId = player.UserId
	playersWithOpenShops[userId] = nil
	playerDebounces[userId] = nil
end)
