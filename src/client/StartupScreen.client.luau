--[[
	Startup Screen - Welcome screen with title and camera view
	Features: "Sanctum Trials" title, blurred background, camera positioning
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera

-- Settings
local BLUR_STRENGTH = 24
local FADE_DURATION = 2

-- Function to set camera to the Camera part
local function setCameraToStartupView()
	print("🔍 Looking for Camera part...")

	-- Look for a Part named "Camera", not the workspace Camera object
	local cameraPart = nil
	for _, child in pairs(Workspace:GetChildren()) do
		if child.Name == "Camera" and child:IsA("BasePart") then
			cameraPart = child
			break
		end
	end

	if cameraPart then
		print("✅ Camera part found!")
		print("📍 Camera part position:", cameraPart.Position)
		print("📍 Camera part CFrame:", cameraPart.CFrame)

		-- Force camera to scriptable mode
		camera.CameraType = Enum.CameraType.Scriptable
		print("📷 Camera type set to Scriptable")

		-- Wait a moment for the change to take effect
		task.wait(0.1)

		-- Set camera position and rotation
		camera.CFrame = cameraPart.CFrame
		print("📷 Camera CFrame set to:", camera.CFrame)
		print("📷 Current camera type:", camera.CameraType)

		-- Double-check the camera was set correctly
		task.wait(0.1)
		if camera.CFrame.Position == cameraPart.CFrame.Position then
			print("✅ Camera successfully positioned!")
		else
			print("⚠️ Camera position mismatch!")
			print("Expected:", cameraPart.CFrame)
			print("Actual:", camera.CFrame)
		end

		return true
	else
		warn("❌ Camera PART not found in workspace!")
		print("🔍 Looking for a Part (not Camera object) named 'Camera'")
		print("🔍 Available BaseParts in workspace:")
		for _, child in pairs(Workspace:GetChildren()) do
			if child:IsA("BasePart") then
				print("  - " .. child.Name .. " (BasePart)")
			end
		end
		return false
	end
end -- Function to create the startup screen
local function createStartupScreen()
	-- Create main ScreenGui
	local startupGui = Instance.new("ScreenGui")
	startupGui.Name = "StartupScreen"
	startupGui.DisplayOrder = 100
	startupGui.IgnoreGuiInset = true
	startupGui.Parent = playerGui

	-- Create blur effect
	local blurEffect = Instance.new("BlurEffect")
	blurEffect.Size = BLUR_STRENGTH
	blurEffect.Parent = camera

	-- Create background frame
	local backgroundFrame = Instance.new("Frame")
	backgroundFrame.Name = "Background"
	backgroundFrame.Size = UDim2.fromScale(1, 1)
	backgroundFrame.Position = UDim2.fromScale(0, 0)
	backgroundFrame.BackgroundColor3 = Color3.new(0, 0, 0)
	backgroundFrame.BackgroundTransparency = 0.3 -- Semi-transparent overlay
	backgroundFrame.BorderSizePixel = 0
	backgroundFrame.Parent = startupGui

	-- Create title container
	local titleContainer = Instance.new("Frame")
	titleContainer.Name = "TitleContainer"
	titleContainer.Size = UDim2.fromOffset(600, 200)
	titleContainer.Position = UDim2.new(0.5, -300, 0.5, -100)
	titleContainer.BackgroundTransparency = 1
	titleContainer.Parent = backgroundFrame

	-- Create main title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.fromScale(1, 0.7)
	titleLabel.Position = UDim2.fromScale(0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "SANCTUM TRIALS"
	titleLabel.TextColor3 = Color3.new(1, 1, 1) -- White
	titleLabel.TextScaled = true
	titleLabel.Font = Enum.Font.Arcade
	titleLabel.TextStrokeTransparency = 0
	titleLabel.Parent = titleContainer

	-- Create subtitle
	local subtitleLabel = Instance.new("TextLabel")
	subtitleLabel.Name = "Subtitle"
	subtitleLabel.Size = UDim2.fromScale(1, 0.3)
	subtitleLabel.Position = UDim2.fromScale(0, 0.7)
	subtitleLabel.BackgroundTransparency = 1
	subtitleLabel.Text = "Click anywhere to begin"
	subtitleLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8) -- Light gray
	subtitleLabel.TextScaled = true
	subtitleLabel.Font = Enum.Font.Arcade
	subtitleLabel.TextTransparency = 0.3
	subtitleLabel.Parent = titleContainer

	-- Add pulsing animation to subtitle
	local pulseAnimation = TweenService:Create(
		subtitleLabel,
		TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
		{ TextTransparency = 0.8 }
	)
	pulseAnimation:Play()

	return startupGui, blurEffect, pulseAnimation
end

-- Function to close startup screen
local function closeStartupScreen(startupGui, blurEffect, pulseAnimation)
	-- Stop animations
	if pulseAnimation then
		pulseAnimation:Cancel()
	end

	-- Fade out the screen
	local fadeOutTween = TweenService:Create(
		startupGui,
		TweenInfo.new(FADE_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{ Enabled = false }
	)

	-- Remove blur
	local blurTween = TweenService:Create(
		blurEffect,
		TweenInfo.new(FADE_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{ Size = 0 }
	)

	fadeOutTween:Play()
	blurTween:Play()

	-- Reset camera to player when fade completes
	fadeOutTween.Completed:Connect(function()
		camera.CameraType = Enum.CameraType.Custom
		camera.CameraSubject = player.Character and player.Character:FindFirstChild("Humanoid")

		-- Clean up
		startupGui:Destroy()
		blurEffect:Destroy()

		print("✨ Startup screen closed - Welcome to Sanctum Trials!")
	end)
end

-- Function to initialize startup screen
local function initStartupScreen()
	print("🚀 Starting initialization...")

	-- Wait for character to load
	if not player.Character then
		print("⏳ Waiting for character...")
		player.CharacterAdded:Wait()
	end

	print("✅ Character loaded, waiting for game to stabilize...")
	task.wait(1) -- Give more time for everything to load

	-- Set camera to startup position
	local cameraSuccess = setCameraToStartupView()

	if not cameraSuccess then
		warn("❌ Failed to set camera - skipping startup screen")
		return
	end

	-- Create startup screen
	local startupGui, blurEffect, pulseAnimation = createStartupScreen()

	-- Handle click to close
	local connection
	connection = UserInputService.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			connection:Disconnect()
			closeStartupScreen(startupGui, blurEffect, pulseAnimation)
		end
	end)

	print("🎮 Startup screen loaded - Sanctum Trials")
end

-- Initialize when player spawns
player.CharacterAdded:Connect(function()
	task.wait(0) -- Wait for everything to load
	initStartupScreen()
end)

-- Initialize immediately if character already exists
if player.Character then
	task.wait(0)
	initStartupScreen()
end
