--[[
	GUI Demo Script - Shows off the Shop and Inventory GUIs
	Place this in StarterPlayerScripts to test the GUIs
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- Wait for the GUIs to load
wait(2)

-- The GUI modules are standalone scripts that auto-register their keyboard shortcuts
-- ShopGUI.client.luau handles P key
-- InventoryGUI.client.luau handles I key

-- Import GameManager
local GameManager = require(ReplicatedStorage.Shared.GameManager)

-- Initialize player with some starting items for demo
spawn(function()
	wait(1)
	GameManager.InitializePlayer(player):andThen(function()
		-- Give player some starting money and items for demo
		GameManager.AddMoney(player, 500)
		GameManager.AddItem(player, "fire_seed", 5)
		GameManager.AddItem(player, "water_seed", 3)
		GameManager.AddItem(player, "wood", 50)
		GameManager.AddItem(player, "stone", 25)
		GameManager.AddItem(player, "magic_watering_can", 1)

		print("🎮 GUI Demo Ready!")
		print("📝 Controls:")
		print("   P - Open Shop")
		print("   I - Open Inventory")
		print("   G - Get demo items & money")
	end)
end)

-- Create instruction GUI
local function createInstructionGUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GUIInstructions"
	screenGui.Parent = player.PlayerGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(0.3, 0.2)
	frame.Position = UDim2.fromScale(0.02, 0.02)
	frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.fromScale(1, 0.3)
	title.Position = UDim2.fromScale(0, 0)
	title.BackgroundTransparency = 1
	title.Text = "🎮 GUI DEMO CONTROLS"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.Parent = frame

	local instructions = {
		"P - Open Shop 🏪",
		"I - Open Inventory 🎒",
		"G - Get Demo Items 💰",
	}

	for i, instruction in ipairs(instructions) do
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 0.2)
		label.Position = UDim2.fromScale(0, 0.3 + (i - 1) * 0.2)
		label.BackgroundTransparency = 1
		label.Text = instruction
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextScaled = true
		label.Font = Enum.Font.Gotham
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = frame
	end
end

-- Create instructions
createInstructionGUI()

-- Demo controls
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.G then
		-- Give demo items
		GameManager.AddMoney(player, 100)
		GameManager.AddItem(player, "fire_seed", 2)
		GameManager.AddItem(player, "growth_crystal", 3)
		print("💰 Added demo money and items!")
	end
end)
