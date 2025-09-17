--[[
	Coin Collection System - Server script that handles coin pickup mechanics
	Features: Proximity detection, smooth attraction animation, money reward
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

-- Import GameManager for money handling
local GameManager = require(ReplicatedStorage.Shared.GameManager)

-- Coin settings
local COIN_VALUE = 100 -- Money value of each coin
local DETECTION_DISTANCE = 5 -- Studs to start attracting
local COLLECTION_DISTANCE = 2 -- Studs to collect coin
local ATTRACTION_SPEED = 0.8 -- Seconds for attraction animation

-- Track active coins and their states
local activeCoins = {}
local coinConnections = {}

-- Function to collect coin and give money
local function collectCoin(coin, player)
	print("💰 " .. player.Name .. " is collecting coin!")

	-- Clean up connections first
	if coinConnections[coin] then
		coinConnections[coin]:Disconnect()
		coinConnections[coin] = nil
	end
	-- Clean up homing connection if it exists
	if coinConnections[coin .. "_homing"] then
		coinConnections[coin .. "_homing"]:Disconnect()
		coinConnections[coin .. "_homing"] = nil
	end
	activeCoins[coin] = nil

	-- Store coin position before destruction
	local coinPosition = coin.Position

	-- Immediately remove the coin from workspace
	coin.Parent = nil

	-- Give money to player
	GameManager.AddMoney(player, COIN_VALUE)

	-- Create a temporary invisible part for the effect
	local effectPart = Instance.new("Part")
	effectPart.Size = Vector3.new(0.1, 0.1, 0.1)
	effectPart.Transparency = 1
	effectPart.CanCollide = false
	effectPart.Anchored = true
	effectPart.Position = coinPosition
	effectPart.Name = "CoinEffect"
	effectPart.Parent = Workspace

	-- Create collection sound
	local collectSound = Instance.new("Sound")
	collectSound.SoundId = "rbxasset://sounds/button.wav"
	collectSound.Volume = 0.5
	collectSound.Pitch = 1.5
	collectSound.Parent = effectPart
	collectSound:Play()

	-- Create money popup effect on the effect part
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(100, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.Parent = effectPart

	local moneyText = Instance.new("TextLabel")
	moneyText.Size = UDim2.fromScale(1, 1)
	moneyText.BackgroundTransparency = 1
	moneyText.Text = "+$" .. COIN_VALUE
	moneyText.TextColor3 = Color3.fromRGB(255, 215, 0)
	moneyText.TextScaled = true
	moneyText.Font = Enum.Font.ArimoBold
	moneyText.Parent = billboard

	-- Animate money text
	local textTween = TweenService:Create(
		billboard,
		TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ StudsOffset = Vector3.new(0, 6, 0) }
	)

	local fadeTween = TweenService:Create(
		moneyText,
		TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ TextTransparency = 1 }
	)

	textTween:Play()
	fadeTween:Play()

	print("💰 " .. player.Name .. " collected coin for $" .. COIN_VALUE .. "!")
	print("💳 " .. player.Name .. "'s balance: $" .. GameManager.GetPlayerData(player).money)

	-- Clean up effect part after animation
	task.spawn(function()
		task.wait(1.5)
		if effectPart and effectPart.Parent then
			effectPart:Destroy()
		end
	end)

	-- Destroy the original coin
	task.spawn(function()
		task.wait(0.1)
		if coin then
			coin:Destroy()
		end
	end)
end

-- Function to create coin attraction effect
local function attractCoinToPlayer(coin, player)
	local character = player.Character
	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then
		return
	end

	-- Mark coin as being attracted
	activeCoins[coin] = {
		player = player,
		attracting = true,
		startTime = tick(),
	}

	-- Play attraction sound
	local attractSound = Instance.new("Sound")
	attractSound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
	attractSound.Volume = 0.3
	attractSound.Pitch = 1.2
	attractSound.Parent = coin
	attractSound:Play()
	Debris:AddItem(attractSound, 2)

	print("💰 Coin attracting to " .. player.Name)

	-- Smooth follow loop - this replaces the old tween system
	local homingConnection
	homingConnection = RunService.Heartbeat:Connect(function(dt)
		-- Safety checks
		if not coin.Parent or not player.Parent or not character.Parent then
			if homingConnection then
				homingConnection:Disconnect()
			end
			return
		end

		local currentHumanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if not currentHumanoidRootPart then
			return
		end

		-- Calculate target position (slightly above player)
		local targetPosition = currentHumanoidRootPart.Position + Vector3.new(0, 2, 0)
		local direction = (targetPosition - coin.Position)
		local distance = direction.Magnitude

		-- Move coin toward player smoothly (20 studs per second)
		if distance > 0.1 then -- Avoid division by zero
			local moveStep = direction.Unit * math.min(distance, 20 * dt)
			coin.CFrame = coin.CFrame + moveStep
		end

		-- Add spinning effect
		coin.CFrame = coin.CFrame * CFrame.Angles(0, math.rad(360 * dt), 0) -- 1 rotation per second

		-- Check for collection
		if distance <= COLLECTION_DISTANCE then
			print("✅ Homing collection triggered at distance: " .. math.floor(distance * 10) / 10)
			if homingConnection then
				homingConnection:Disconnect()
			end
			-- Clean up the main detection loop since we're collecting
			if coinConnections[coin] then
				coinConnections[coin]:Disconnect()
				coinConnections[coin] = nil
			end
			collectCoin(coin, player)
		end
	end)

	-- Store the homing connection so we can clean it up if needed
	coinConnections[coin .. "_homing"] = homingConnection
end

-- Function to setup coin detection
local function setupCoin(coin)
	if activeCoins[coin] then
		return
	end -- Already setup

	-- Initialize coin state
	activeCoins[coin] = {
		player = nil,
		attracting = false,
		startTime = 0,
	}

	print("💰 Coin setup: " .. coin.Name .. " (Value: $" .. COIN_VALUE .. ")")

	-- Variable to store touch connection
	local touchConn

	-- Add touched event as backup collection method
	touchConn = coin.Touched:Connect(function(hit)
		local character = hit.Parent
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			local player = Players:GetPlayerFromCharacter(character)
			if player and activeCoins[coin] then
				print("👆 " .. player.Name .. " touched coin directly!")
				-- Clean up detection loop
				if coinConnections[coin] then
					coinConnections[coin]:Disconnect()
					coinConnections[coin] = nil
				end
				if touchConn then
					touchConn:Disconnect()
				end
				collectCoin(coin, player)
			end
		end
	end)

	-- Create detection loop for this coin
	local connection = RunService.Heartbeat:Connect(function()
		if not coin.Parent then
			-- Coin was destroyed, clean up
			activeCoins[coin] = nil
			if coinConnections[coin] then
				coinConnections[coin]:Disconnect()
				coinConnections[coin] = nil
			end
			if touchConn then
				touchConn:Disconnect()
			end
			return
		end

		local coinData = activeCoins[coin]
		if not coinData then
			return
		end

		-- If coin is already being attracted, the homing system handles collection
		if coinData.attracting and coinData.player then
			-- Skip proximity detection - let homing system handle everything
			return
		end

		-- Check for nearby players to start attraction
		for _, player in pairs(Players:GetPlayers()) do
			if player.Character then
				local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
				if humanoidRootPart then
					local distance = (coin.Position - humanoidRootPart.Position).Magnitude

					-- Start attraction if player is close enough
					if distance <= DETECTION_DISTANCE then
						if coinConnections[coin] then
							coinConnections[coin]:Disconnect()
							coinConnections[coin] = nil
						end
						if touchConn then
							touchConn:Disconnect()
						end
						attractCoinToPlayer(coin, player)
						return
					end
				end
			end
		end
	end)

	coinConnections[coin] = connection
end

-- Find and setup existing coins
local function findAndSetupCoins()
	-- Look for parts named "Coin" in workspace
	for _, obj in pairs(Workspace:GetChildren()) do
		if obj:IsA("BasePart") and obj.Name == "Coin" then
			setupCoin(obj)
		end
	end

	-- Also check in any models that might contain coins
	for _, model in pairs(Workspace:GetChildren()) do
		if model:IsA("Model") then
			for _, obj in pairs(model:GetChildren()) do
				if obj:IsA("BasePart") and obj.Name == "Coin" then
					setupCoin(obj)
				end
			end
		end
	end
end

-- Setup coins when new ones are added
local function onChildAdded(child)
	if child:IsA("BasePart") and child.Name == "Coin" then
		-- Wait a frame to ensure the coin is fully loaded
		task.wait()
		setupCoin(child)
	elseif child:IsA("Model") then
		-- Check if the model contains coins
		child.ChildAdded:Connect(function(subChild)
			if subChild:IsA("BasePart") and subChild.Name == "Coin" then
				task.wait()
				setupCoin(subChild)
			end
		end)
	end
end

-- Connect to workspace changes
Workspace.ChildAdded:Connect(onChildAdded)

-- Clean up when players leave
Players.PlayerRemoving:Connect(function(player)
	-- Cancel any coins being attracted to this player
	for _, coinData in pairs(activeCoins) do
		if coinData.player == player then
			coinData.player = nil
			coinData.attracting = false
		end
	end
end)

-- Initial setup
findAndSetupCoins()

print("💰 Coin Collection System loaded!")
print("🎯 Coin value: $" .. COIN_VALUE)
print("📏 Detection distance: " .. DETECTION_DISTANCE .. " studs")
print("🤏 Collection distance: " .. COLLECTION_DISTANCE .. " studs")
print("⏱️ Attraction speed: " .. ATTRACTION_SPEED .. " seconds")
