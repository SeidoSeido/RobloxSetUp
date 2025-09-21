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

-- Track if startup screen has been shown
local hasShownStartupScreen = false

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
	titleLabel.Size = UDim2.fromScale(1, 3)
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

-- Function to close startup screen with smooth transitions
local function closeStartupScreen(startupGui, blurEffect, pulseAnimation)
	print("🎬 Starting smooth transition...")

	-- Stop animations
	if pulseAnimation then
		pulseAnimation:Cancel()
	end

	-- Find the title elements to fade them out first
	local titleContainer = startupGui:FindFirstChild("Background"):FindFirstChild("TitleContainer")
	local titleLabel = titleContainer:FindFirstChild("Title")
	local subtitleLabel = titleContainer:FindFirstChild("Subtitle")

	-- Phase 1: Fade out title and subtitle first (0.5 seconds)
	local titleFadeOut = TweenService:Create(
		titleLabel,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{ TextTransparency = 1, TextStrokeTransparency = 1 }
	)

	local subtitleFadeOut = TweenService:Create(
		subtitleLabel,
		TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
		{ TextTransparency = 1 }
	)

	titleFadeOut:Play()
	subtitleFadeOut:Play()

	-- Wait for title to fade out before continuing
	titleFadeOut.Completed:Connect(function()
		-- Now proceed with the black transition

		-- Create a transition overlay for smooth fade
		local transitionFrame = Instance.new("Frame")
		transitionFrame.Name = "TransitionOverlay"
		transitionFrame.Size = UDim2.fromScale(1, 1)
		transitionFrame.Position = UDim2.fromScale(0, 0)
		transitionFrame.BackgroundColor3 = Color3.new(0, 0, 0) -- Black
		transitionFrame.BorderSizePixel = 0
		transitionFrame.BackgroundTransparency = 1 -- Start invisible
		transitionFrame.Parent = startupGui

		-- Phase 2: Fade to black (0.8 seconds)
		local fadeToBlackTween = TweenService:Create(
			transitionFrame,
			TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			{ BackgroundTransparency = 0 }
		)

		fadeToBlackTween:Play()

		-- Phase 3: When fade to black completes, switch camera and start fade out
		fadeToBlackTween.Completed:Connect(function()
			print("🎥 Switching camera to player...")

			-- Reset camera to player
			camera.CameraType = Enum.CameraType.Custom
			if player.Character and player.Character:FindFirstChild("Humanoid") then
				camera.CameraSubject = player.Character.Humanoid
			end

			-- Wait a moment for camera to settle
			task.wait(0.3)

			-- Phase 4: Fade out from black (1.2 seconds)
			local fadeFromBlackTween = TweenService:Create(
				transitionFrame,
				TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{ BackgroundTransparency = 1 }
			)

			-- Also remove blur gradually
			local blurTween = TweenService:Create(
				blurEffect,
				TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{ Size = 0 }
			)

			fadeFromBlackTween:Play()
			blurTween:Play()

			-- Final cleanup when everything is done
			fadeFromBlackTween.Completed:Connect(function()
				-- Clean up all startup screen elements
				startupGui:Destroy()
				blurEffect:Destroy()

				print("✨ Startup screen transition completed - Welcome to Sanctum Trials!")
			end)
		end)
	end)
end
local function initStartupScreen()
	-- Only show startup screen once per game session
	if hasShownStartupScreen then
		print("🎮 Startup screen already shown - skipping")
		return
	end

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
		hasShownStartupScreen = true -- Mark as shown even if failed
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
			-- Mark as shown after player closes it
			hasShownStartupScreen = true
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
