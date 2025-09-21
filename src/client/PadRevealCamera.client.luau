--[[
	Pad Reveal Camera Client - Handles cinematic camera sequences for pad reveals
	Features: Fade in/out, camera switching, smooth transitions
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui")

-- Wait for the RemoteEvent
local cameraRemoteEvent = ReplicatedStorage:WaitForChild("PadRevealCameraEvent")

-- Create fade screen
local fadeScreen = Instance.new("ScreenGui")
fadeScreen.Name = "PadRevealFadeScreen"
fadeScreen.Parent = playerGui
fadeScreen.DisplayOrder = 100
fadeScreen.IgnoreGuiInset = true -- This ensures it covers the entire screen including top bar
fadeScreen.ResetOnSpawn = false

local fadeFrame = Instance.new("Frame")
fadeFrame.Size = UDim2.fromScale(1, 1)
fadeFrame.Position = UDim2.fromScale(0, 0)
fadeFrame.BackgroundColor3 = Color3.new(0, 0, 0)
fadeFrame.BackgroundTransparency = 1
fadeFrame.BorderSizePixel = 0
fadeFrame.ZIndex = 10
fadeFrame.Parent = fadeScreen

-- Store original camera settings
local originalCameraType = camera.CameraType
local originalCameraSubject = camera.CameraSubject

-- Function to fade the screen
local function fadeToTransparency(transparency, duration)
	local fadeInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	local fadeTween = TweenService:Create(fadeFrame, fadeInfo, { BackgroundTransparency = transparency })
	fadeTween:Play()
	return fadeTween
end

-- Function to handle cinematic sequence
local function handleCinematicSequence(data)
	print("🎬 Client: Starting cinematic sequence")

	-- Step 1: Fade to black
	print("🌑 Fading to black...")
	local fadeInTween = fadeToTransparency(0, data.fadeDuration) -- Fade to black

	fadeInTween.Completed:Connect(function()
		-- Step 2: Switch camera to cinematic position
		print("📹 Switching to cinematic camera...")
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = data.cameraCFrame

		-- Step 3: Fade from black to show cinematic view
		print("🌅 Fading in cinematic view...")
		local fadeOutTween = fadeToTransparency(1, data.fadeDuration) -- Fade from black

		fadeOutTween.Completed:Connect(function()
			-- Step 4: Wait during camera time + reveal time
			print("🎥 Showing cinematic for " .. (data.cameraDuration + data.revealDuration) .. " seconds...")
			task.wait(data.cameraDuration + data.revealDuration)

			-- Step 5: Fade to black again
			print("🌑 Fading out cinematic...")
			local finalFadeInTween = fadeToTransparency(0, data.fadeDuration) -- Fade to black

			finalFadeInTween.Completed:Connect(function()
				-- Step 6: Restore player camera
				print("👁️ Restoring player camera...")

				-- Reset camera to player character
				if player.Character and player.Character:FindFirstChild("Humanoid") then
					camera.CameraSubject = player.Character.Humanoid
					camera.CameraType = Enum.CameraType.Custom
					print("✅ Camera restored to player character")
				else
					-- Fallback to original settings
					camera.CameraType = originalCameraType
					camera.CameraSubject = originalCameraSubject
					print("⚠️ Used fallback camera restoration")
				end

				-- Step 7: Fade from black back to normal view
				print("🌅 Fading back to player view...")
				local finalFadeOutTween = fadeToTransparency(1, data.fadeDuration) -- Fade from black

				finalFadeOutTween.Completed:Connect(function()
					print("✅ Cinematic sequence completed!")
				end)
			end)
		end)
	end)
end

-- Connect to RemoteEvent
cameraRemoteEvent.OnClientEvent:Connect(function(data)
	if data.action == "startCinematic" then
		handleCinematicSequence(data)
	end
end)

print("🎬 Pad Reveal Camera Client loaded!")
print("📹 Ready to receive cinematic sequences")
