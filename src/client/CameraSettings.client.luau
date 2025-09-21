--[[
	Camera Settings Client - Sets field of view to 140 degrees
	Features: Forces FOV to 140 and maintains first person mode
]]

local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- Configuration
local TARGET_FOV = 140 -- Field of view in degrees
local CHECK_INTERVAL = 1 -- How often to check/enforce settings (seconds)

-- Function to set camera field of view
local function setCameraFOV()
	if player.Character then
		local camera = workspace.CurrentCamera
		if camera then
			-- Set the field of view
			camera.FieldOfView = TARGET_FOV
			print("📷 Set camera FOV to " .. TARGET_FOV .. " degrees")
		end
	end
end

-- Function to enforce camera settings
local function enforceCameraSettings()
	if player.Character then
		local camera = workspace.CurrentCamera
		if camera then
			-- Ensure FOV stays at 140
			if camera.FieldOfView ~= TARGET_FOV then
				camera.FieldOfView = TARGET_FOV
				print("📷 Corrected camera FOV to " .. TARGET_FOV .. " degrees")
			end
		end
	end
end

-- Set initial camera settings when character spawns
local function onCharacterAdded(_character)
	-- Wait for camera to be ready
	task.wait(1)
	setCameraFOV()
	print("✅ Camera settings applied for " .. player.Name)
end

-- Connect to character spawning
player.CharacterAdded:Connect(onCharacterAdded)

-- Handle if character already exists
if player.Character then
	onCharacterAdded(player.Character)
end

-- Periodically enforce camera settings (in case they get changed)
task.spawn(function()
	while true do
		task.wait(CHECK_INTERVAL)
		enforceCameraSettings()
	end
end)

print("📷 Camera Settings Client loaded!")
print("🎯 Target FOV: " .. TARGET_FOV .. " degrees")
print("🔒 First person mode enforced via server")
