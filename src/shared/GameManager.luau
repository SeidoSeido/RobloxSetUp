--[[
	GameManager - Core game mechanics using Promise, Networker, and ProfileService
	Features: Player data, inventory, economy, quests, and multiplayer systems
]]

local GameManager = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Import your packages
local Promise = require(ReplicatedStorage.Packages.Promise)
-- Note: Networker would be used for client-server communication in full implementation

-- Game state
local playerData = {}
local gameSettings = {
	startingMoney = 100,
	experienceMultiplier = 1.0,
	maxLevel = 100,
}

-- Player data structure
local function createDefaultPlayerData()
	return {
		level = 1,
		experience = 0,
		money = gameSettings.startingMoney,
		inventory = {},
		achievements = {},
		settings = {
			musicEnabled = true,
			soundEnabled = true,
		},
		stats = {
			totalPlayTime = 0,
			itemsCollected = 0,
			buildingsBuilt = 0,
		},
	}
end

-- Initialize player data
function GameManager.InitializePlayer(player)
	return Promise.new(function(resolve, _reject)
		if playerData[player.UserId] then
			resolve(playerData[player.UserId])
			return
		end

		-- Create new player data
		local data = createDefaultPlayerData()
		playerData[player.UserId] = data

		print("Initialized player:", player.Name)
		resolve(data)
	end):catch(function(error)
		warn("Failed to initialize player:", player.Name, error)
	end)
end

-- Save player data (placeholder - would use ProfileService on server)
function GameManager.SavePlayerData(player)
	return Promise.new(function(resolve)
		local data = playerData[player.UserId]
		if data then
			-- In real implementation, this would save to ProfileService
			print("Saved data for:", player.Name)
			resolve(true)
		else
			resolve(false)
		end
	end)
end

-- Get player data
function GameManager.GetPlayerData(player)
	return playerData[player.UserId] or createDefaultPlayerData()
end

-- Experience and leveling system
function GameManager.AddExperience(player, amount)
	local data = GameManager.GetPlayerData(player)
	if not data then
		return
	end

	data.experience = data.experience + (amount * gameSettings.experienceMultiplier)

	-- Check for level up
	local expNeeded = data.level * 100 -- Simple formula: level * 100 XP needed
	while data.experience >= expNeeded and data.level < gameSettings.maxLevel do
		data.level = data.level + 1
		data.experience = data.experience - expNeeded
		expNeeded = data.level * 100

		-- Level up rewards
		data.money = data.money + (data.level * 10)

		print(player.Name .. " leveled up to level " .. data.level .. "!")

		-- Fire level up event (would use Networker to notify client)
		GameManager.FireEvent("PlayerLevelUp", player, {
			newLevel = data.level,
			bonusMoney = data.level * 10,
		})
	end
end

-- Money system
function GameManager.AddMoney(player, amount)
	local data = GameManager.GetPlayerData(player)
	if data then
		data.money = data.money + amount
		GameManager.FireEvent("MoneyChanged", player, data.money)
		return true
	end
	return false
end

function GameManager.RemoveMoney(player, amount)
	local data = GameManager.GetPlayerData(player)
	if data and data.money >= amount then
		data.money = data.money - amount
		GameManager.FireEvent("MoneyChanged", player, data.money)
		return true
	end
	return false
end

-- Inventory system
function GameManager.AddItem(player, itemName, quantity)
	quantity = quantity or 1
	local data = GameManager.GetPlayerData(player)
	if not data then
		return false
	end

	if data.inventory[itemName] then
		data.inventory[itemName] = data.inventory[itemName] + quantity
	else
		data.inventory[itemName] = quantity
	end

	data.stats.itemsCollected = data.stats.itemsCollected + quantity

	GameManager.FireEvent("ItemAdded", player, {
		item = itemName,
		quantity = quantity,
		totalQuantity = data.inventory[itemName],
	})

	return true
end

function GameManager.RemoveItem(player, itemName, quantity)
	quantity = quantity or 1
	local data = GameManager.GetPlayerData(player)
	if not data or not data.inventory[itemName] or data.inventory[itemName] < quantity then
		return false
	end

	data.inventory[itemName] = data.inventory[itemName] - quantity
	if data.inventory[itemName] <= 0 then
		data.inventory[itemName] = nil
	end

	GameManager.FireEvent("ItemRemoved", player, {
		item = itemName,
		quantity = quantity,
	})

	return true
end

function GameManager.GetItemCount(player, itemName)
	local data = GameManager.GetPlayerData(player)
	return data and data.inventory[itemName] or 0
end

-- Achievement system
local achievements = {
	firstBuild = {
		name = "First Builder",
		description = "Build your first structure",
		reward = { money = 50, experience = 25 },
	},
	collector = {
		name = "Collector",
		description = "Collect 100 items",
		requirement = function(data)
			return data.stats.itemsCollected >= 100
		end,
		reward = { money = 200, experience = 100 },
	},
	architect = {
		name = "Architect",
		description = "Build 10 structures",
		requirement = function(data)
			return data.stats.buildingsBuilt >= 10
		end,
		reward = { money = 500, experience = 250 },
	},
	levelTen = {
		name = "Veteran",
		description = "Reach level 10",
		requirement = function(data)
			return data.level >= 10
		end,
		reward = { money = 1000, experience = 0 },
	},
}

function GameManager.CheckAchievements(player)
	local data = GameManager.GetPlayerData(player)
	if not data then
		return
	end

	for achievementId, achievement in pairs(achievements) do
		if not data.achievements[achievementId] and achievement.requirement and achievement.requirement(data) then
			-- Grant achievement
			data.achievements[achievementId] = true

			-- Give rewards
			if achievement.reward.money then
				GameManager.AddMoney(player, achievement.reward.money)
			end
			if achievement.reward.experience then
				GameManager.AddExperience(player, achievement.reward.experience)
			end

			GameManager.FireEvent("AchievementUnlocked", player, {
				id = achievementId,
				name = achievement.name,
				description = achievement.description,
				reward = achievement.reward,
			})

			print(player.Name .. " unlocked achievement: " .. achievement.name)
		end
	end
end

-- Quest system
local activeQuests = {}

local questTemplates = {
	buildHouse = {
		name = "Home Builder",
		description = "Build a house structure",
		objectives = {
			{ type = "build", target = "house", current = 0, required = 1 },
		},
		rewards = { money = 150, experience = 75 },
	},
	collectItems = {
		name = "Gatherer",
		description = "Collect 20 wood pieces",
		objectives = {
			{ type = "collect", target = "wood", current = 0, required = 20 },
		},
		rewards = { money = 100, experience = 50 },
	},
	exploreArea = {
		name = "Explorer",
		description = "Visit 5 different areas",
		objectives = {
			{ type = "visit", target = "areas", current = 0, required = 5 },
		},
		rewards = { money = 200, experience = 100 },
	},
}

function GameManager.StartQuest(player, questId)
	if not questTemplates[questId] then
		return false
	end

	local quest = {}
	for key, value in pairs(questTemplates[questId]) do
		if type(value) == "table" then
			quest[key] = {}
			for k, v in pairs(value) do
				quest[key][k] = v
			end
		else
			quest[key] = value
		end
	end

	quest.id = questId
	quest.startTime = tick()

	if not activeQuests[player.UserId] then
		activeQuests[player.UserId] = {}
	end
	activeQuests[player.UserId][questId] = quest

	GameManager.FireEvent("QuestStarted", player, quest)
	return true
end

function GameManager.UpdateQuestProgress(player, questType, target, amount)
	amount = amount or 1
	local playerQuests = activeQuests[player.UserId]
	if not playerQuests then
		return
	end

	for questId, quest in pairs(playerQuests) do
		for _, objective in ipairs(quest.objectives) do
			if objective.type == questType and objective.target == target then
				objective.current = math.min(objective.current + amount, objective.required)

				GameManager.FireEvent("QuestProgressUpdated", player, {
					questId = questId,
					objective = objective,
				})

				-- Check if quest is complete
				if GameManager.IsQuestComplete(quest) then
					GameManager.CompleteQuest(player, questId)
				end
				break
			end
		end
	end
end

function GameManager.IsQuestComplete(quest)
	for _, objective in ipairs(quest.objectives) do
		if objective.current < objective.required then
			return false
		end
	end
	return true
end

function GameManager.CompleteQuest(player, questId)
	local playerQuests = activeQuests[player.UserId]
	if not playerQuests or not playerQuests[questId] then
		return
	end

	local quest = playerQuests[questId]

	-- Give rewards
	if quest.rewards.money then
		GameManager.AddMoney(player, quest.rewards.money)
	end
	if quest.rewards.experience then
		GameManager.AddExperience(player, quest.rewards.experience)
	end

	-- Remove from active quests
	playerQuests[questId] = nil

	GameManager.FireEvent("QuestCompleted", player, {
		questId = questId,
		name = quest.name,
		rewards = quest.rewards,
	})

	-- Check achievements after quest completion
	GameManager.CheckAchievements(player)

	print(player.Name .. " completed quest: " .. quest.name)
end

-- Event system (would use Networker in real implementation)
local eventListeners = {}

function GameManager.FireEvent(eventName, player, data)
	if eventListeners[eventName] then
		for _, callback in ipairs(eventListeners[eventName]) do
			callback(player, data)
		end
	end

	-- This would use Networker to send to client
	print("Event fired:", eventName, "for", player.Name)
end

function GameManager.OnEvent(eventName, callback)
	if not eventListeners[eventName] then
		eventListeners[eventName] = {}
	end
	table.insert(eventListeners[eventName], callback)
end

-- Building tracking (integrates with BuildingGenerator)
function GameManager.OnBuildingBuilt(player, buildingType)
	local data = GameManager.GetPlayerData(player)
	if data then
		data.stats.buildingsBuilt = data.stats.buildingsBuilt + 1

		-- Add experience based on building complexity
		local expReward = 10
		if buildingType == "house" then
			expReward = 25
		elseif buildingType == "tower" then
			expReward = 50
		elseif buildingType == "castle" then
			expReward = 100
		elseif buildingType == "skyscraper" then
			expReward = 75
		end

		GameManager.AddExperience(player, expReward)

		-- Update quest progress
		GameManager.UpdateQuestProgress(player, "build", buildingType, 1)
		GameManager.UpdateQuestProgress(player, "build", "any", 1)

		-- Check for first build achievement
		if data.stats.buildingsBuilt == 1 then
			data.achievements.firstBuild = true
			GameManager.AddMoney(player, achievements.firstBuild.reward.money)
			GameManager.AddExperience(player, achievements.firstBuild.reward.experience)
			GameManager.FireEvent("AchievementUnlocked", player, achievements.firstBuild)
		end

		GameManager.CheckAchievements(player)
		print(player.Name .. " built a " .. buildingType .. " and gained " .. expReward .. " XP!")
	end
end

-- Shop system
local shopItems = {
	wood = { name = "Wood", price = 10, description = "Basic building material" },
	stone = { name = "Stone", price = 15, description = "Sturdy building material" },
	blueprint = { name = "Blueprint", price = 100, description = "Unlock new building designs" },
	speedBoost = { name = "Speed Boost", price = 50, description = "Build 50% faster for 5 minutes" },
	expBoost = { name = "XP Boost", price = 75, description = "Gain 2x experience for 10 minutes" },
}

function GameManager.BuyItem(player, itemId, quantity)
	quantity = quantity or 1
	local item = shopItems[itemId]
	if not item then
		return false
	end

	local totalCost = item.price * quantity
	if GameManager.RemoveMoney(player, totalCost) then
		GameManager.AddItem(player, itemId, quantity)
		print(player.Name .. " bought " .. quantity .. "x " .. item.name .. " for " .. totalCost .. " money")
		return true
	else
		print(player.Name .. " doesn't have enough money to buy " .. item.name)
		return false
	end
end

function GameManager.SellItem(player, itemId, quantity)
	quantity = quantity or 1
	local item = shopItems[itemId]
	if not item then
		return false
	end

	if GameManager.RemoveItem(player, itemId, quantity) then
		local sellPrice = math.floor(item.price * 0.7 * quantity) -- 70% of buy price
		GameManager.AddMoney(player, sellPrice)
		print(player.Name .. " sold " .. quantity .. "x " .. item.name .. " for " .. sellPrice .. " money")
		return true
	else
		print(player.Name .. " doesn't have enough " .. item.name .. " to sell")
		return false
	end
end

-- Utility functions
function GameManager.GetLeaderboard(category, limit)
	category = category or "level"
	limit = limit or 10

	local leaderboard = {}
	for userId, data in pairs(playerData) do
		local player = Players:GetPlayerByUserId(userId)
		if player then
			table.insert(leaderboard, {
				player = player,
				value = data[category] or 0,
			})
		end
	end

	table.sort(leaderboard, function(a, b)
		return a.value > b.value
	end)

	-- Trim to limit
	for i = limit + 1, #leaderboard do
		leaderboard[i] = nil
	end

	return leaderboard
end

-- Initialize the game manager
function GameManager.Initialize()
	print("GameManager initialized!")

	-- Set up some sample quests
	GameManager.OnEvent("PlayerLevelUp", function(player, data)
		if data.newLevel == 5 then
			GameManager.StartQuest(player, "buildHouse")
		elseif data.newLevel == 3 then
			GameManager.StartQuest(player, "collectItems")
		end
	end)

	return Promise.resolve(true)
end

return GameManager
