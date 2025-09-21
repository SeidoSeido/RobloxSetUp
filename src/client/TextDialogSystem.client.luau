--[[
	Text Dialog System Client - Mysterious typewriter dialog display
	Features: Typewriter animation, floating text only (no container)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for RemoteEvent
local dialogRemoteEvent = ReplicatedStorage:WaitForChild("TextDialogEvent")

-- UI Variables
local dialogScreenGui = nil
local isDialogActive = false

-- Typewriter settings
local TYPEWRITER_SPEED = 0.08 -- Time between each character (seconds)
local EMPHASIS_PAUSE = 0.5 -- Extra pause for dramatic effect
local DISPLAY_TIME = 4 -- How long to show completed text
local FADE_IN_TIME = 0.5
local FADE_OUT_TIME = 1

-- Function to create floating text (no container)
local function createDialogUI()
	-- Main ScreenGui
	dialogScreenGui = Instance.new("ScreenGui")
	dialogScreenGui.Name = "MysteriousDialogGUI"
	dialogScreenGui.Parent = playerGui
	dialogScreenGui.DisplayOrder = 50
	dialogScreenGui.IgnoreGuiInset = true

	-- Dialog text label (floating directly on screen)
	local dialogText = Instance.new("TextLabel")
	dialogText.Name = "DialogText"
	dialogText.Size = UDim2.fromOffset(800, 200)
	dialogText.Position = UDim2.new(0.5, -400, 0.75, -100)
	dialogText.BackgroundTransparency = 1
	dialogText.Text = ""
	dialogText.TextColor3 = Color3.fromRGB(223, 223, 223)
	dialogText.TextScaled = true
	dialogText.TextWrapped = true
	dialogText.Font = Enum.Font.Arcade -- Using our consistent Arcade font
	dialogText.TextXAlignment = Enum.TextXAlignment.Center
	dialogText.TextYAlignment = Enum.TextYAlignment.Center
	dialogText.Parent = dialogScreenGui

	-- Glowing text effect
	local textStroke = Instance.new("UIStroke")
	textStroke.Color = Color3.fromRGB(255, 255, 255)
	textStroke.Thickness = 1
	textStroke.Transparency = 0.5
	textStroke.Parent = dialogText

	return dialogText
end

-- Function to animate typewriter effect
local function typewriterAnimation(textLabel, fullMessage, callback)
	textLabel.Text = ""

	-- Add blinking cursor initially
	textLabel.Text = "_"

	local currentText = ""
	local messageLength = string.len(fullMessage)

	-- Typewriter loop
	for i = 1, messageLength do
		local char = string.sub(fullMessage, i, i)
		currentText = currentText .. char

		-- Update text with cursor
		textLabel.Text = currentText .. "_"

		-- Check for emphasis characters for dramatic pauses
		local pauseTime = TYPEWRITER_SPEED
		if char == "." or char == "…" then
			pauseTime = EMPHASIS_PAUSE
		elseif char == "," then
			pauseTime = TYPEWRITER_SPEED * 2
		end

		task.wait(pauseTime)
	end

	-- Remove cursor and show final text
	textLabel.Text = currentText

	-- Pulse effect for emphasis
	local pulseInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 2, true)
	local pulseTween = TweenService:Create(textLabel, pulseInfo, {
		TextTransparency = 0.3,
	})
	pulseTween:Play()

	-- Wait for display time then callback
	task.wait(DISPLAY_TIME)
	if callback then
		callback()
	end
end

-- Function to show dialog with animations
local function showDialog(message, dialogId)
	if isDialogActive then
		return
	end

	isDialogActive = true
	print("👻 Showing mysterious dialog " .. dialogId .. ": " .. message)

	local textLabel = createDialogUI()

	-- Start completely transparent
	textLabel.TextTransparency = 1

	-- Fade in text only
	local textFadeInTween = TweenService:Create(
		textLabel,
		TweenInfo.new(FADE_IN_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ TextTransparency = 0 }
	)

	textFadeInTween:Play()

	-- Wait for fade in to complete, then start typewriter
	textFadeInTween.Completed:Connect(function()
		typewriterAnimation(textLabel, message, function()
			-- Fade out after message is complete
			local textFadeOutTween = TweenService:Create(
				textLabel,
				TweenInfo.new(FADE_OUT_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
				{ TextTransparency = 1 }
			)

			textFadeOutTween:Play()

			textFadeOutTween.Completed:Connect(function()
				dialogScreenGui:Destroy()
				dialogScreenGui = nil
				isDialogActive = false
				print("✅ Dialog " .. dialogId .. " completed")
			end)
		end)
	end)
end

-- Handle remote events from server
dialogRemoteEvent.OnClientEvent:Connect(function(data)
	print("📜 Client received remote event:", data)
	if data.action == "showDialog" then
		print("👻 Attempting to show dialog:", data.message)
		showDialog(data.message, data.dialogId)
	else
		print("⚠️ Unknown dialog action:", data.action)
	end
end)

print("👻 Text Dialog System Client loaded!")
print("📜 Ready to display mysterious messages")
print("⌨️ Typewriter animation ready")
