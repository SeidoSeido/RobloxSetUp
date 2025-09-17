--[[
	Player Customization - Makes all players uniform gray avatars
	Features: Removes accessories, clothing, decals, and face. Sets gray body colors.
]]

local Players = game:GetService("Players")

-- Function to remove all accessories from character
local function removeAccessories(character)
	-- Remove all accessories (hats, hair, etc.)
	for _, accessory in pairs(character:GetChildren()) do
		if accessory:IsA("Accessory") then
			accessory:Destroy()
		end
	end
end

-- Function to remove clothing
local function removeClothing(character)
	-- Remove shirts, pants, and t-shirts
	for _, item in pairs(character:GetChildren()) do
		if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
			item:Destroy()
		end
	end
end

-- Function to remove face
local function removeFace(character)
	local head = character:FindFirstChild("Head")
	if head then
		-- Remove face decal
		local face = head:FindFirstChild("face")
		if face then
			face:Destroy()
		end

		-- Remove any other decals on head
		for _, decal in pairs(head:GetChildren()) do
			if decal:IsA("Decal") then
				decal:Destroy()
			end
		end
	end
end

-- Function to set gray body colors
local function setGrayBodyColors(character)
	-- Find body colors object
	local bodyColors = character:FindFirstChild("Body Colors")
	if not bodyColors then
		-- Create body colors if it doesn't exist
		bodyColors = Instance.new("BodyColors")
		bodyColors.Parent = character
	end

	-- Set all body parts to gray
	local grayColor = BrickColor.new("Medium stone grey")
	bodyColors.HeadColor = grayColor
	bodyColors.LeftArmColor = grayColor
	bodyColors.LeftLegColor = grayColor
	bodyColors.RightArmColor = grayColor
	bodyColors.RightLegColor = grayColor
	bodyColors.TorsoColor = grayColor
end

-- Function to customize character
local function customizeCharacter(character)
	-- Wait a moment for character to fully load
	task.wait(0.5)

	print("🎭 Customizing character: " .. character.Name)

	-- Remove all customizations
	removeAccessories(character)
	removeClothing(character)
	removeFace(character)
	setGrayBodyColors(character)

	print("✅ Character customized: " .. character.Name)
end

-- Function to handle player joining
local function onPlayerAdded(player)
	print("👤 Player joined: " .. player.Name)

	-- Handle initial spawn
	player.CharacterAdded:Connect(function(character)
		task.spawn(function()
			customizeCharacter(character)
		end)
	end)

	-- Handle if character already exists
	if player.Character then
		task.spawn(function()
			customizeCharacter(player.Character)
		end)
	end
end

-- Connect to player events
Players.PlayerAdded:Connect(onPlayerAdded)

-- Handle players already in game
for _, player in pairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

print("🎭 Player Customization System loaded!")
print("🎨 All players will be uniform gray avatars with no accessories")
