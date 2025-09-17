--[[
	Door System - Server script that makes doors functional
	Works with DoorModel containing doorFrame and Door part
	Features: Click to open/close, smooth animations, door state management
]]

local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

-- Find the DoorModel in workspace
local doorModel = Workspace:WaitForChild("DoorModel")
local _doorFrame = doorModel:WaitForChild("doorFrame") -- Store reference but don't use yet
local door = doorModel:WaitForChild("Door")

print("🔧 DoorModel found: " .. doorModel.Name)
print("🔧 Door found: " .. door.Name)
print("🔧 Door CanCollide: " .. tostring(door.CanCollide))
print("🔧 Door Material: " .. tostring(door.Material))

-- Door settings
local DOOR_OPEN_ANGLE = 90 -- Degrees to rotate when opening
local ANIMATION_TIME = 0.8 -- Seconds for door animation
local AUTO_CLOSE_TIME = 5 -- Seconds before auto-closing (0 to disable)

-- Door state tracking
local isDoorOpen = false
local isDoorAnimating = false
local autoCloseConnection = nil

-- Store original door position and rotation
local originalCFrame = door.CFrame

-- Function to play door sound
local function playDoorSound(soundType)
	local sound = Instance.new("Sound")
	sound.Volume = 0.5
	sound.Parent = door

	if soundType == "open" then
		sound.SoundId = "rbxasset://sounds/door_open.wav"
	elseif soundType == "close" then
		sound.SoundId = "rbxasset://sounds/door_close.wav"
	elseif soundType == "creak" then
		sound.SoundId = "rbxasset://sounds/impact_wood.mp3"
	end

	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

-- Function to close the door (defined early)
local function closeDoor()
	if not isDoorOpen or isDoorAnimating then
		return
	end

	isDoorAnimating = true
	isDoorOpen = false

	print("🚪 Door closing...")
	playDoorSound("close")

	-- Cancel auto-close timer
	if autoCloseConnection then
		autoCloseConnection:Disconnect()
		autoCloseConnection = nil
	end

	-- Create closing animation back to original position
	local closeTween = TweenService:Create(
		door,
		TweenInfo.new(ANIMATION_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ CFrame = originalCFrame }
	)

	closeTween:Play()

	closeTween.Completed:Connect(function()
		isDoorAnimating = false
		print("✅ Door closed!")
	end)
end

-- Function to calculate door rotation
local function calculateDoorRotation(angle)
	-- Find the hinge point (usually the edge of the door closest to the frame)
	local doorSize = door.Size
	local hingeOffset = Vector3.new(-doorSize.X / 2, 0, 0) -- Left edge of door

	-- Calculate the hinge position in world space
	local hingePosition = door.CFrame:PointToWorldSpace(hingeOffset)

	-- Create rotation around the hinge
	local rotationCFrame = CFrame.new(hingePosition) * CFrame.Angles(0, math.rad(angle), 0)
	local offsetFromHinge = originalCFrame.Position - hingePosition
	local rotatedOffset = rotationCFrame:VectorToWorldSpace(offsetFromHinge)

	-- Calculate final door position
	local newPosition = hingePosition + rotatedOffset
	local newCFrame = CFrame.new(newPosition) * CFrame.Angles(0, math.rad(angle), 0) * originalCFrame.Rotation

	return newCFrame
end

-- Function to open the door
local function openDoor()
	if isDoorOpen or isDoorAnimating then
		return
	end

	isDoorAnimating = true
	isDoorOpen = true

	print("🚪 Door opening...")
	playDoorSound("open")

	-- Calculate target rotation
	local targetCFrame = calculateDoorRotation(DOOR_OPEN_ANGLE)

	-- Create opening animation
	local openTween = TweenService:Create(
		door,
		TweenInfo.new(ANIMATION_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ CFrame = targetCFrame }
	)

	openTween:Play()

	openTween.Completed:Connect(function()
		isDoorAnimating = false
		print("✅ Door opened!")

		-- Set up auto-close if enabled
		if AUTO_CLOSE_TIME > 0 then
			if autoCloseConnection then
				autoCloseConnection:Disconnect()
			end

			autoCloseConnection = task.delay(AUTO_CLOSE_TIME, function()
				closeDoor()
			end)
		end
	end)
end

-- Function to toggle door state
local function toggleDoor()
	if isDoorAnimating then
		return
	end

	if isDoorOpen then
		closeDoor()
	else
		openDoor()
	end
end

-- Make door clickable
local clickDetector = Instance.new("ClickDetector")
clickDetector.MaxActivationDistance = 20 -- Increased range for easier clicking
clickDetector.Parent = door

print("🔧 ClickDetector created and parented to door: " .. door.Name)
print("🔧 Door position: " .. tostring(door.Position))
print("🔧 Door size: " .. tostring(door.Size))

-- Connect click event
clickDetector.MouseClick:Connect(function(player)
	print("🖱️ " .. player.Name .. " clicked the door")
	print("🔧 Door state - Open: " .. tostring(isDoorOpen) .. ", Animating: " .. tostring(isDoorAnimating))
	toggleDoor()
end)

-- Add hover effect for better UX
clickDetector.MouseHoverEnter:Connect(function(player)
	-- Add slight glow effect when hovering
	local selectionBox = Instance.new("SelectionBox")
	selectionBox.Name = "DoorHover_" .. player.Name
	selectionBox.Adornee = door
	selectionBox.Color3 = Color3.fromRGB(255, 255, 100)
	selectionBox.Transparency = 0.8
	selectionBox.LineThickness = 0.1
	selectionBox.Parent = door
end)

clickDetector.MouseHoverLeave:Connect(function(player)
	-- Remove glow effect when not hovering
	local selectionBox = door:FindFirstChild("DoorHover_" .. player.Name)
	if selectionBox then
		selectionBox:Destroy()
	end
end)

-- Backup: Also make door clickable by touching it (for testing)
door.Touched:Connect(function(hit)
	local character = hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid then
		local player = game.Players:GetPlayerFromCharacter(character)
		if player then
			print("👆 " .. player.Name .. " touched the door (backup method)")
			toggleDoor()
		end
	end
end)

-- Optional: Add proximity opening (uncomment if you want doors to open when players get close)
--[[
local function checkProximity()
	local playersNearby = {}
	
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local distance = (player.Character.HumanoidRootPart.Position - door.Position).Magnitude
			if distance <= 8 then -- 8 studs proximity
				table.insert(playersNearby, player)
			end
		end
	end
	
	-- Open door if players are nearby and door is closed
	if #playersNearby > 0 and not isDoorOpen and not isDoorAnimating then
		print("🚶 Players nearby, opening door...")
		openDoor()
	end
	-- Close door if no players nearby and door is open (and auto-close is disabled)
	if #playersNearby == 0 and isDoorOpen and not isDoorAnimating and AUTO_CLOSE_TIME == 0 then
		print("👻 No players nearby, closing door...")
		closeDoor()
	end
end

-- Run proximity check every second
RunService.Heartbeat:Connect(function()
	-- Only check every 60 frames (roughly 1 second at 60 FPS)
	if tick() % 1 < 0.016 then
		checkProximity()
	end
end)
--]]

print("🚪 Door system loaded for DoorModel!")
print("🖱️ Click the door to open/close it")
print("⏱️ Animation time: " .. ANIMATION_TIME .. " seconds")
if AUTO_CLOSE_TIME > 0 then
	print("🕐 Auto-close after: " .. AUTO_CLOSE_TIME .. " seconds")
else
	print("🔒 Auto-close disabled - manual operation only")
end
