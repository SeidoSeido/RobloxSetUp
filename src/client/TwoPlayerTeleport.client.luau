--[[
	Two Player Teleport System Client - Handles floating UI display
	Features: Status display, countdown timer UI, arcade font styling
]]

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Wait for RemoteEvent
local twoPlayerRemoteEvent = ReplicatedStorage:WaitForChild("TwoPlayerTeleportEvent")

-- UI Configuration
local UI_HEIGHT_OFFSET = 10 -- Height above the part
local FONT = Enum.Font.Arcade
local FONT_SIZE = 36
local PRIMARY_COLOR = Color3.fromRGB(255, 255, 255)
local COUNTDOWN_COLOR = Color3.fromRGB(255, 196, 0)
local READY_COLOR = Color3.fromRGB(0, 255, 0)

-- UI Variables
local twoPlayerPart = nil
local floatingGui = nil
local statusLabel = nil
local countdownLabel = nil
local teleportFrame = nil
local loadingBar = nil
local loadingBackground = nil

-- Current status
local currentPlayerCount = 0
local currentMaxPlayers = 2
local currentCountdown = 0
local isCountdownActive = false
local isTeleporting = false

-- Function to create floating UI
local function createFloatingUI()
	if not twoPlayerPart then
		return
	end

	-- Remove existing GUI
	if floatingGui then
		floatingGui:Destroy()
	end

	-- Create BillboardGui
	floatingGui = Instance.new("BillboardGui")
	floatingGui.Name = "TwoPlayerStatusGUI"
	floatingGui.Size = UDim2.fromOffset(300, 120)
	floatingGui.StudsOffset = Vector3.new(0, UI_HEIGHT_OFFSET, 0)
	floatingGui.AlwaysOnTop = true
	floatingGui.LightInfluence = 0
	floatingGui.MaxDistance = 100
	floatingGui.Parent = twoPlayerPart

	-- Create main frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.fromScale(1, 1)
	mainFrame.Position = UDim2.new(0, 0, 0, 0)
	mainFrame.BackgroundTransparency = 1
	mainFrame.Parent = floatingGui

	-- Create status label (player count)
	statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Size = UDim2.fromScale(1, 0.5)
	statusLabel.Position = UDim2.new(0, 0, 0, 0)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = "0/2"
	statusLabel.TextColor3 = PRIMARY_COLOR
	statusLabel.TextScaled = true
	statusLabel.Font = FONT
	statusLabel.Parent = mainFrame

	-- Add stroke for better visibility
	local statusStroke = Instance.new("UIStroke")
	statusStroke.Color = Color3.fromRGB(0, 0, 0)
	statusStroke.Thickness = 3
	statusStroke.Parent = statusLabel

	-- Create countdown label
	countdownLabel = Instance.new("TextLabel")
	countdownLabel.Name = "CountdownLabel"
	countdownLabel.Size = UDim2.fromScale(1, 0.5)
	countdownLabel.Position = UDim2.fromScale(0, 0.5)
	countdownLabel.BackgroundTransparency = 1
	countdownLabel.Text = ""
	countdownLabel.TextColor3 = COUNTDOWN_COLOR
	countdownLabel.TextScaled = true
	countdownLabel.Font = FONT
	countdownLabel.Visible = false
	countdownLabel.Parent = mainFrame

	-- Add stroke for countdown
	local countdownStroke = Instance.new("UIStroke")
	countdownStroke.Color = Color3.fromRGB(0, 0, 0)
	countdownStroke.Thickness = 3
	countdownStroke.Parent = countdownLabel

	print("🖼️ Created floating UI for TwoPlayer part")
end

-- Function to update status display
local function updateStatusDisplay()
	if not statusLabel then
		return
	end

	-- Update player count text
	local statusText = currentPlayerCount .. "/" .. currentMaxPlayers
	statusLabel.Text = statusText

	-- Change color based on status
	if currentPlayerCount == currentMaxPlayers then
		statusLabel.TextColor3 = READY_COLOR
	else
		statusLabel.TextColor3 = PRIMARY_COLOR
	end

	-- Update countdown display
	if countdownLabel then
		if isCountdownActive and currentCountdown > 0 then
			countdownLabel.Text = "" .. currentCountdown .. "s"
			countdownLabel.Visible = true

			-- Animate countdown text
			local scaleUp = TweenService:Create(
				countdownLabel,
				TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{ TextScaled = false, TextSize = FONT_SIZE + 4 }
			)
			local scaleDown = TweenService:Create(
				countdownLabel,
				TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				{ TextScaled = true }
			)

			scaleUp:Play()
			scaleUp.Completed:Connect(function()
				scaleDown:Play()
			end)
		else
			countdownLabel.Visible = false
		end
	end

	print(
		"📊 UI Updated: " .. statusText .. (isCountdownActive and " (Countdown: " .. currentCountdown .. "s)" or "")
	)
end

-- Function to setup the floating UI
local function setupFloatingUI()
	-- Find the TwoPlayer part
	twoPlayerPart = Workspace:WaitForChild("TwoPlayer", 10)

	if not twoPlayerPart then
		warn("⚠️ TwoPlayer part not found in workspace")
		return false
	end

	print("🎯 Found TwoPlayer part: " .. twoPlayerPart.Name)

	-- Create the floating UI
	createFloatingUI()
	updateStatusDisplay()

	return true
end

-- Handle server updates
twoPlayerRemoteEvent.OnClientEvent:Connect(function(data)
	if data.action == "updateStatus" then
		currentPlayerCount = data.playerCount or 0
		currentMaxPlayers = data.maxPlayers or 2
		currentCountdown = data.countdown or 0
		isCountdownActive = data.countdownActive or false

		print(
			"📨 Received status update: "
				.. currentPlayerCount
				.. "/"
				.. currentMaxPlayers
				.. (isCountdownActive and " (Countdown: " .. currentCountdown .. "s)" or "")
		)

		updateStatusDisplay()
	end
end)

-- Initialize the system
task.spawn(function()
	local success = setupFloatingUI()

	if success then
		print("✅ Two Player Teleport UI initialized!")
		print("🎯 Part: " .. (twoPlayerPart and twoPlayerPart.Name or "Unknown"))
		print("🎨 Font: " .. FONT.Name)
		print("📏 Height offset: " .. UI_HEIGHT_OFFSET .. " studs")
	else
		warn("❌ Failed to setup Two Player Teleport UI")
	end

	print("🚀 Two Player Teleport System Client loaded!")
end)
