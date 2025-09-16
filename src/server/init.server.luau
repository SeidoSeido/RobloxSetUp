--[[
	Server Script - Manages game state, player data, and server-side systems
	This script runs on the server and handles data persistence and validation
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Import modules
local GameManager = require(ReplicatedStorage.Shared.GameManager)

-- In a real game, you would import ProfileService here for data persistence
-- local ProfileService = require(game.ServerScriptService.ServerPackages.ProfileService)

print("🚀 Game Server Starting...")

-- Initialize the game manager
GameManager.Initialize():andThen(function()
	print("✅ GameManager initialized successfully!")
end)

-- Handle player joining
Players.PlayerAdded:Connect(function(player)
	print("🎮 Player joined:", player.Name)

	-- Initialize player data
	GameManager.InitializePlayer(player)
		:andThen(function(_playerData)
			print("✅ Player data loaded for:", player.Name)

			-- Start the player with a welcome quest
			wait(2) -- Wait a moment for client to load
			GameManager.StartQuest(player, "collectItems")

			-- Give starting items
			GameManager.AddItem(player, "wood", 10)
			GameManager.AddItem(player, "stone", 5)

			print("🎁 Starting items given to:", player.Name)
		end)
		:catch(function(error)
			warn("❌ Failed to initialize player:", player.Name, error)
		end)
end)

-- Handle player leaving
Players.PlayerRemoving:Connect(function(player)
	print("👋 Player leaving:", player.Name)

	-- Save player data before they leave
	GameManager.SavePlayerData(player):andThen(function(success)
		if success then
			print("💾 Player data saved for:", player.Name)
		else
			warn("❌ Failed to save player data for:", player.Name)
		end
	end)
end)

-- Set up periodic data saving (every 5 minutes)
spawn(function()
	while true do
		wait(300) -- 5 minutes

		print("💾 Auto-saving all player data...")

		for _, player in ipairs(Players:GetPlayers()) do
			GameManager.SavePlayerData(player)
				:andThen(function(success)
					if success then
						print("✅ Auto-saved data for:", player.Name)
					end
				end)
				:catch(function(error)
					warn("❌ Auto-save failed for:", player.Name, error)
				end)
		end
	end
end)

-- Create a welcome message for new players
local function createWelcomeMessage()
	local message = Instance.new("Hint")
	message.Text = "🏗️ Welcome to the Building Demo! Press H to build your first house!"
	message.Parent = workspace

	-- Remove message after 10 seconds
	game:GetService("Debris"):AddItem(message, 10)
end

-- Show welcome message when server starts
wait(2)
createWelcomeMessage()

-- Server-side building validation and logging
local buildingCounts = {
	houses = 0,
	towers = 0,
	skyscrapers = 0,
	castles = 0,
}

-- Monitor game events
GameManager.OnEvent("PlayerLevelUp", function(player, data)
	print("🎉 " .. player.Name .. " leveled up to level " .. data.newLevel .. "!")

	-- Server-side level up rewards and checks
	if data.newLevel == 10 then
		GameManager.AddItem(player, "blueprint", 1)
		print("🎁 " .. player.Name .. " received a blueprint for reaching level 10!")
	end
end)

GameManager.OnEvent("AchievementUnlocked", function(player, achievement)
	print("🏆 " .. player.Name .. " unlocked achievement: " .. achievement.name)

	-- Announce major achievements to all players
	if achievement.name == "Architect" then
		local message = Instance.new("Message")
		message.Text = "🏆 " .. player.Name .. " became an Architect! (Built 10 buildings)"
		message.Parent = workspace
		game:GetService("Debris"):AddItem(message, 5)
	end
end)

-- Track building statistics
local originalOnBuildingBuilt = GameManager.OnBuildingBuilt
GameManager.OnBuildingBuilt = function(player, buildingType)
	-- Call original function
	originalOnBuildingBuilt(player, buildingType)

	-- Track server statistics
	if buildingType == "house" then
		buildingCounts.houses = buildingCounts.houses + 1
	elseif buildingType == "tower" then
		buildingCounts.towers = buildingCounts.towers + 1
	elseif buildingType == "skyscraper" then
		buildingCounts.skyscrapers = buildingCounts.skyscrapers + 1
	elseif buildingType == "castle" then
		buildingCounts.castles = buildingCounts.castles + 1
	end

	print(
		"📊 Building Statistics - Houses: "
			.. buildingCounts.houses
			.. ", Towers: "
			.. buildingCounts.towers
			.. ", Skyscrapers: "
			.. buildingCounts.skyscrapers
			.. ", Castles: "
			.. buildingCounts.castles
	)
end

-- Server command system for testing
game.Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		local args = string.split(message, " ")
		local command = args[1]:lower()

		-- Admin commands (in a real game, you'd check if player is admin)
		if command == "/givemoney" and #args >= 2 then
			local amount = tonumber(args[2])
			if amount then
				GameManager.AddMoney(player, amount)
				print("💰 Gave " .. amount .. " money to " .. player.Name)
			end
		elseif command == "/giveexp" and #args >= 2 then
			local amount = tonumber(args[2])
			if amount then
				GameManager.AddExperience(player, amount)
				print("⭐ Gave " .. amount .. " experience to " .. player.Name)
			end
		elseif command == "/giveitem" and #args >= 3 then
			local itemName = args[2]
			local quantity = tonumber(args[3]) or 1
			GameManager.AddItem(player, itemName, quantity)
			print("📦 Gave " .. quantity .. "x " .. itemName .. " to " .. player.Name)
		elseif command == "/startquest" and #args >= 2 then
			local questId = args[2]
			if GameManager.StartQuest(player, questId) then
				print("📜 Started quest '" .. questId .. "' for " .. player.Name)
			else
				print("❌ Quest '" .. questId .. "' not found")
			end
		elseif command == "/stats" then
			local data = GameManager.GetPlayerData(player)
			if data then
				print("📊 Stats for " .. player.Name .. ":")
				print("   Level: " .. data.level)
				print("   Experience: " .. data.experience)
				print("   Money: " .. data.money)
				print("   Buildings Built: " .. data.stats.buildingsBuilt)
				print("   Items Collected: " .. data.stats.itemsCollected)
			end
		elseif command == "/leaderboard" then
			local leaderboard = GameManager.GetLeaderboard("level", 5)
			print("🏆 Top 5 Players by Level:")
			for i, entry in ipairs(leaderboard) do
				print("   " .. i .. ". " .. entry.player.Name .. " - Level " .. entry.value)
			end
		end
	end)
end)

-- Cleanup when server shuts down
game:BindToClose(function()
	print("💾 Server shutting down, saving all player data...")

	for _, player in ipairs(Players:GetPlayers()) do
		local success = GameManager.SavePlayerData(player):await()
		if success then
			print("✅ Final save completed for:", player.Name)
		else
			warn("❌ Final save failed for:", player.Name)
		end
	end

	print("🛑 Server shutdown complete")
end)

print("✅ Game Server Ready!")
print("🎮 Players can now join and start building!")
print("📝 Available commands: /givemoney, /giveexp, /giveitem, /startquest, /stats, /leaderboard")
