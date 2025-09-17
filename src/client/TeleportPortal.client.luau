--[[
	Teleport Portal Client - Handles screen fade effects for portals
	Features: Smooth fade in/out, black screen overlay
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for remote events
local portalEvents = ReplicatedStorage:WaitForChild("PortalEvents")
local fadeScreenEvent = portalEvents:WaitForChild("FadeScreen")

-- Create fade screen GUI
local function createFadeScreen()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TeleportFadeScreen"
	screenGui.DisplayOrder = 100 -- High priority to be on top
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui

	local fadeFrame = Instance.new("Frame")
	fadeFrame.Name = "FadeFrame"
	fadeFrame.Size = UDim2.fromScale(1, 1)
	fadeFrame.Position = UDim2.new(0, 0, 0, 0)
	fadeFrame.BackgroundColor3 = Color3.new(0, 0, 0) -- Black
	fadeFrame.BorderSizePixel = 0
	fadeFrame.BackgroundTransparency = 1 -- Start invisible
	fadeFrame.Parent = screenGui

	-- Add a subtle teleport effect text
	local teleportText = Instance.new("TextLabel")
	teleportText.Name = "TeleportText"
	teleportText.Size = UDim2.fromOffset(400, 100)
	teleportText.Position = UDim2.new(0.5, -200, 0.5, -50)
	teleportText.BackgroundTransparency = 1
	teleportText.Text = "Teleporting."
	teleportText.TextColor3 = Color3.new(1, 1, 1) -- White
	teleportText.TextScaled = true
	teleportText.Font = Enum.Font.Arcade
	teleportText.TextTransparency = 1 -- Start invisible
	teleportText.Parent = fadeFrame

	return screenGui, fadeFrame, teleportText
end

-- Function to animate loading dots
local function animateLoadingDots(textLabel)
	local dotCount = 1

	local connection = task.spawn(function()
		while textLabel and textLabel.Parent do
			if dotCount == 1 then
				textLabel.Text = "Teleporting."
			elseif dotCount == 2 then
				textLabel.Text = "Teleporting.."
			elseif dotCount == 3 then
				textLabel.Text = "Teleporting..."
			end

			dotCount = dotCount + 1
			if dotCount > 3 then
				dotCount = 1
			end

			task.wait(0.5) -- Change dots every 0.5 seconds
		end
	end)

	return connection
end

-- Function to handle fade effects
local function handleFadeEffect(fadeType, duration)
	-- Clean up any existing fade screens first
	local existingScreen = playerGui:FindFirstChild("TeleportFadeScreen")
	if existingScreen then
		existingScreen:Destroy()
	end

	local screenGui, fadeFrame, teleportText = createFadeScreen()

	if fadeType == "fadeIn" then
		-- Fade in to black
		local fadeTween = TweenService:Create(
			fadeFrame,
			TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			{ BackgroundTransparency = 0 }
		)

		local textTween = TweenService:Create(
			teleportText,
			TweenInfo.new(duration * 0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ TextTransparency = 0 }
		)

		fadeTween:Play()
		-- Delay text appearance slightly without blocking
		task.spawn(function()
			task.wait(duration * 0.3)
			textTween:Play()
			-- Start loading dots animation when text appears
			animateLoadingDots(teleportText)
		end)
	elseif fadeType == "fadeOut" then
		-- Start with black screen
		fadeFrame.BackgroundTransparency = 0
		teleportText.TextTransparency = 0

		-- Fade out from black
		local textFadeTween = TweenService:Create(
			teleportText,
			TweenInfo.new(duration * 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ TextTransparency = 1 }
		)

		local fadeTween = TweenService:Create(
			fadeFrame,
			TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			{ BackgroundTransparency = 1 }
		)

		textFadeTween:Play()
		-- Start screen fade after text starts fading without blocking
		task.spawn(function()
			task.wait(duration * 0.3)
			fadeTween:Play()
		end)

		-- Clean up after fade out completes
		fadeTween.Completed:Connect(function()
			if screenGui then
				screenGui:Destroy()
			end
		end)

		-- Safety cleanup in case tween doesn't complete
		task.spawn(function()
			task.wait(duration + 2) -- Wait longer than fade duration
			if screenGui and screenGui.Parent then
				screenGui:Destroy()
			end
		end)
	end
end

-- Connect to server events
fadeScreenEvent.OnClientEvent:Connect(function(fadeType, duration)
	task.spawn(function()
		handleFadeEffect(fadeType, duration or 1)
	end)
end)

print("Teleport Portal Client loaded!")
print("Fade effects ready!")
