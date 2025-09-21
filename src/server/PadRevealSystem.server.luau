--[[
	Pad Reveal System - Reveals hidden obby models when stepping on trigger pads
	Features: One-time activation, transparency and collision control, cinematic camera
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create RemoteEvent for camera control
local cameraRemoteEvent = Instance.new("RemoteEvent")
cameraRemoteEvent.Name = "PadRevealCameraEvent"
cameraRemoteEvent.Parent = ReplicatedStorage

-- Track which pads have been activated to prevent multiple uses
local activatedPads = {}

-- Configuration
local REVEAL_DURATION = 3 -- Time in seconds for the reveal animation (slower reveal)
local FADE_EFFECT = true -- Whether to use fade-in animation
local PAD_SINK_DISTANCE = 0.5 -- How much the pad sinks when used (in studs)
local PAD_ANIMATION_TIME = 0.8 -- Time for pad sinking animation
local CAMERA_DURATION = 2 -- Time to show the cinematic camera
local FADE_DURATION = 0.5 -- Time for fade in/out effects

-- Function to reveal a model (make it visible and solid)
local function revealModel(model)
	if not model then
		warn("❌ Model not found for revealing")
		return false
	end

	print("✨ Revealing model: " .. model.Name)

	-- Get all parts in the model
	local parts = {}
	for _, descendant in pairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			table.insert(parts, descendant)
			print(
				"🔍 Found part: " .. descendant.Name .. " (Current transparency: " .. descendant.Transparency .. ")"
			)
		end
	end

	if #parts == 0 then
		warn("⚠️ No parts found in model: " .. model.Name)
		return false
	end

	print("📦 Total parts to reveal: " .. #parts)

	if FADE_EFFECT then
		-- Animate the reveal with fade-in effect
		for _, part in pairs(parts) do
			-- Enable collision immediately
			part.CanCollide = true
			print("🔧 Set CanCollide=true for: " .. part.Name)

			-- Store original transparency (usually should be 0 for visible parts)
			local targetTransparency = 0 -- Force to 0 for visibility
			part.Transparency = 1 -- Start invisible
			print("👻 Set " .. part.Name .. " transparency: 1 -> " .. targetTransparency)

			-- Animate to visible
			local revealTween = TweenService:Create(
				part,
				TweenInfo.new(REVEAL_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Transparency = targetTransparency }
			)
			revealTween:Play()
			print("🎬 Started reveal animation for: " .. part.Name)
		end
	else
		-- Instant reveal without animation
		for _, part in pairs(parts) do
			part.CanCollide = true
			part.Transparency = 0 -- Make fully visible
			print("⚡ Instantly revealed: " .. part.Name)
		end
	end

	return true
end

-- Function to animate pad when used (gray color + sinking)
local function animateUsedPad(padModel)
	if not padModel then
		warn("❌ Pad model not found for animation")
		return false
	end

	print("🎨 Animating used pad: " .. padModel.Name)

	-- Get all parts in the pad model
	local padParts = {}
	for _, descendant in pairs(padModel:GetDescendants()) do
		if descendant:IsA("BasePart") then
			table.insert(padParts, descendant)
		end
	end

	if #padParts == 0 then
		warn("⚠️ No parts found in pad model: " .. padModel.Name)
		return false
	end

	-- Animate each part
	for _, part in pairs(padParts) do
		-- Change to gray color (keep original material/texture)
		part.BrickColor = BrickColor.new("Dark stone grey")
		print("🎨 Changed " .. part.Name .. " to gray")

		-- Sink the part down
		local originalPosition = part.Position
		local sinkPosition = originalPosition - Vector3.new(0, PAD_SINK_DISTANCE, 0)

		local sinkTween = TweenService:Create(
			part,
			TweenInfo.new(PAD_ANIMATION_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Position = sinkPosition }
		)
		sinkTween:Play()
		print("⬇️ Sinking " .. part.Name .. " by " .. PAD_SINK_DISTANCE .. " studs")
	end

	return true
end

-- Function to handle cinematic camera sequence
local function startCinematicSequence(player, cameraPartName, targetModel)
	local cameraPart = Workspace:FindFirstChild(cameraPartName)

	if not cameraPart then
		warn("⚠️ Camera part not found: " .. cameraPartName)
		return false
	end

	print("🎬 Starting cinematic sequence for " .. player.Name)

	-- Calculate total sequence time (fade in + camera time + reveal + fade out)
	local totalTime = FADE_DURATION + CAMERA_DURATION + REVEAL_DURATION + FADE_DURATION

	-- Send camera control to client
	cameraRemoteEvent:FireClient(player, {
		action = "startCinematic",
		cameraCFrame = cameraPart.CFrame,
		targetModel = targetModel.Name,
		fadeDuration = FADE_DURATION,
		cameraDuration = CAMERA_DURATION,
		revealDuration = REVEAL_DURATION,
		totalTime = totalTime,
	})

	print("📹 Sent cinematic data to client for " .. player.Name)
	return true
end

-- Function to setup a reveal pad
local function setupRevealPad(padName, modelName, cameraPartName)
	local pad = Workspace:FindFirstChild(padName)
	local model = Workspace:FindFirstChild(modelName)
	local cameraPart = Workspace:FindFirstChild(cameraPartName or "")

	if not pad then
		warn("⚠️ Pad not found: " .. padName)
		return false
	end

	if not model then
		warn("⚠️ Model not found: " .. modelName)
		return false
	end

	if cameraPartName and not cameraPart then
		warn("⚠️ Camera part not found: " .. cameraPartName)
		return false
	end

	print("🎯 Setting up reveal pad: " .. padName .. " -> " .. modelName)
	if cameraPartName then
		print("📹 Camera part: " .. cameraPartName)
	end

	-- Make the model invisible and non-solid initially
	local partCount = 0
	for _, descendant in pairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			print("🔧 Hiding part: " .. descendant.Name .. " (Was transparency: " .. descendant.Transparency .. ")")
			descendant.CanCollide = false
			descendant.Transparency = 1
			partCount = partCount + 1
		end
	end
	print("📦 Hidden " .. partCount .. " parts in model: " .. modelName)

	-- Store connections so we can disconnect them later
	local padConnections = {}

	-- Connect touch events to all parts in the pad model
	for _, descendant in pairs(pad:GetDescendants()) do
		if descendant:IsA("BasePart") then
			local connection = descendant.Touched:Connect(function(hit)
				print(
					"🤚 Something touched pad: "
						.. padName
						.. " (Hit: "
						.. hit.Name
						.. ", Parent: "
						.. hit.Parent.Name
						.. ")"
				)

				-- Check if it's a player who touched the pad
				local character = hit.Parent
				local humanoid = character:FindFirstChild("Humanoid")
				if humanoid then
					local player = Players:GetPlayerFromCharacter(character)
					if player then
						print("✅ Player detected: " .. player.Name)

						-- Check if this pad has already been activated
						if activatedPads[padName] then
							print("🔒 Pad " .. padName .. " already used")
							return
						end

						print("👤 " .. player.Name .. " stepped on pad: " .. padName)

						-- Mark pad as activated
						activatedPads[padName] = true
						print("🔒 Marked pad as activated: " .. padName)

						-- Always disconnect and animate pad after activation
						for _, conn in pairs(padConnections) do
							conn:Disconnect()
						end
						print("🔌 Pad " .. padName .. " deactivated (purpose fulfilled)")

						-- Animate the pad to show it's used (gray + sink)
						animateUsedPad(pad)
						print("🎨 Animated pad to show it's used")

						-- Start cinematic sequence if camera part exists
						if cameraPartName then
							print("🎬 Starting cinematic sequence...")
							local cinematicSuccess = startCinematicSequence(player, cameraPartName, model)

							if cinematicSuccess then
								-- Wait a moment then reveal the model
								task.wait(FADE_DURATION) -- Wait for fade in
								print("🎬 Starting reveal process...")
								local success = revealModel(model)

								if success then
									print("🎉 " .. player.Name .. " revealed: " .. modelName .. " (cinematic)")
								else
									warn("❌ Failed to reveal model during cinematic")
								end
							else
								-- Fallback to immediate reveal if cinematic fails
								print("🎬 Cinematic failed, falling back to immediate reveal")
								local success = revealModel(model)
								if success then
									print("🎉 " .. player.Name .. " revealed: " .. modelName .. " (immediate)")
								end
							end
						else
							-- No camera part, do immediate reveal
							print("🎬 No camera specified, starting immediate reveal...")
							local success = revealModel(model)
							if success then
								print("🎉 " .. player.Name .. " revealed: " .. modelName .. " (immediate)")
							end
						end
					else
						print("❌ No player found for character: " .. character.Name)
					end
				else
					print("❌ No humanoid found in: " .. character.Name)
				end
			end)
			table.insert(padConnections, connection)
			print("🔗 Connected touch event to: " .. descendant.Name)
		end
	end

	return true
end

-- Setup the specific pad-model pair mentioned
local setupSuccess = setupRevealPad("StepOnPadOnePhaseOne", "GenerateObbyOnePhaseOne", "CameraOnePhaseOne")

if setupSuccess then
	print("✅ Reveal system initialized!")
	print("🎯 Pad: StepOnPadOnePhaseOne")
	print("🏗️ Target: GenerateObbyOnePhaseOne")
	print("📹 Camera: CameraOnePhaseOne")
	print("⚡ One-time activation: Enabled")
	print("🎬 Fade effect: " .. (FADE_EFFECT and "Enabled" or "Disabled"))
	print("🎥 Cinematic camera: Enabled")
else
	warn("❌ Failed to setup reveal system - check part/model names")
end

print("🎮 Pad Reveal System loaded!")
