--[[
	Client Script - Simple client initialization for Spirit Garden
	This script runs on each player's client and initializes basic systems
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Get local player
local player = Players.LocalPlayer

-- Import GameManager
local GameManager = require(ReplicatedStorage.Shared.GameManager)

-- Initialize game manager for this player
GameManager.InitializePlayer(player):andThen(function(playerData)
	print("✨ Welcome to Spirit Garden! ✨")
	print("Player initialized with data:", playerData)
	print("")
	print("🎮 Controls:")
	print("   P - Open Shop")
	print("   E - Open Inventory")
	print("   G - Get starter items")
	print("")
	print("🌱 Start your magical garden adventure!")
end)

-- Simple starter items function (G key)
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.G then
		-- Give some starter items for testing
		GameManager.AddItem(player, "fire_seed", 3)
		GameManager.AddItem(player, "water_seed", 2)
		GameManager.AddItem(player, "wood", 25)
		GameManager.AddItem(player, "stone", 15)
		GameManager.AddMoney(player, 100)
		print("🎁 Added starter items and money!")
	end
end)

-- Set up some event listeners for feedback
GameManager.OnEvent("PlayerLevelUp", function(p, data)
	if p == player then
		print("🎉 Level Up! You are now level " .. data.newLevel .. "!")
		print("💰 Bonus money: " .. data.bonusMoney)
	end
end)

GameManager.OnEvent("AchievementUnlocked", function(p, achievement)
	if p == player then
		print("🏆 Achievement Unlocked: " .. achievement.name)
		print("📖 " .. achievement.description)
	end
end)

print("🌟 Spirit Garden Client Ready!")
print("Press P to open the shop, E for inventory!")
