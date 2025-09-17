--[[
	LeaderBoardGUI - Custom leaderboard with dark theme matching ShopGUI
	Features: Cute design, player stats, dark theme, Tab key override
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Disable the default leaderboard
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)

-- Import GameManager for data
local GameManager = require(ReplicatedStorage.Shared.GameManager)

-- LeaderBoard GUI Module
local LeaderBoardGUI = {}

-- Function to get all players with their stats
local function getAllPlayersStats()
	local playersData = {}

	for _, gamePlayer in pairs(Players:GetPlayers()) do
		local playerData = GameManager.GetPlayerData(gamePlayer)
		table.insert(playersData, {
			player = gamePlayer,
			name = gamePlayer.Name,
			displayName = gamePlayer.DisplayName,
			money = playerData.money or 0,
			items = playerData.inventory and #playerData.inventory or 0,
			joinTime = gamePlayer.AccountAge, -- Days since account creation
		})
	end

	-- Sort players by money (richest first)
	table.sort(playersData, function(a, b)
		return a.money > b.money
	end)

	return playersData
end

-- Function to create player entry
local function createPlayerEntry(playerData, rank)
	local playerEntry = Instance.new("Frame")
	playerEntry.Name = "Player_" .. playerData.name
	playerEntry.Size = UDim2.fromScale(1, 0.1)
	playerEntry.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
	playerEntry.BorderSizePixel = 0

	-- Add subtle border
	local entryBorder = Instance.new("UIStroke")
	entryBorder.Color = Color3.fromRGB(60, 60, 65)
	entryBorder.Thickness = 1
	entryBorder.Transparency = 0.5
	entryBorder.Parent = playerEntry

	-- Add padding
	local entryPadding = Instance.new("UIPadding")
	entryPadding.PaddingLeft = UDim.new(0, 15)
	entryPadding.PaddingRight = UDim.new(0, 15)
	entryPadding.PaddingTop = UDim.new(0, 5)
	entryPadding.PaddingBottom = UDim.new(0, 5)
	entryPadding.Parent = playerEntry

	-- Rank number
	local rankLabel = Instance.new("TextLabel")
	rankLabel.Name = "Rank"
	rankLabel.Size = UDim2.fromScale(0.1, 1)
	rankLabel.Position = UDim2.fromScale(0, 0)
	rankLabel.BackgroundTransparency = 1
	rankLabel.Text = "#" .. rank
	rankLabel.TextColor3 = rank <= 3 and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(200, 200, 200)
	rankLabel.TextScaled = true
	rankLabel.Font = Enum.Font.ArimoBold
	rankLabel.Parent = playerEntry

	-- Player avatar (placeholder)
	local avatarFrame = Instance.new("Frame")
	avatarFrame.Name = "Avatar"
	avatarFrame.Size = UDim2.fromScale(0.08, 0.8)
	avatarFrame.Position = UDim2.fromScale(0.12, 0.1)
	avatarFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
	avatarFrame.BorderSizePixel = 0
	avatarFrame.Parent = playerEntry

	-- Player icon (cute emoji style)
	local playerIcon = Instance.new("TextLabel")
	playerIcon.Size = UDim2.fromScale(1, 1)
	playerIcon.BackgroundTransparency = 1
	playerIcon.Text = rank <= 3 and "👑" or "😊" -- Crown for top 3, smile for others
	playerIcon.TextScaled = true
	playerIcon.Parent = avatarFrame

	-- Player name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "PlayerName"
	nameLabel.Size = UDim2.fromScale(0.3, 1)
	nameLabel.Position = UDim2.fromScale(0.22, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = playerData.displayName ~= playerData.name
			and (playerData.displayName .. " (@" .. playerData.name .. ")")
		or playerData.name
	nameLabel.TextColor3 = playerData.player == player and Color3.fromRGB(100, 255, 100)
		or Color3.fromRGB(255, 255, 255)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.Arcade
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = playerEntry

	-- Money display
	local moneyLabel = Instance.new("TextLabel")
	moneyLabel.Name = "Money"
	moneyLabel.Size = UDim2.fromScale(0.2, 1)
	moneyLabel.Position = UDim2.fromScale(0.54, 0)
	moneyLabel.BackgroundTransparency = 1
	moneyLabel.Text = "💰 $" .. playerData.money
	moneyLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	moneyLabel.TextScaled = true
	moneyLabel.Font = Enum.Font.Arcade
	moneyLabel.TextXAlignment = Enum.TextXAlignment.Center
	moneyLabel.Parent = playerEntry

	-- Items count
	local itemsLabel = Instance.new("TextLabel")
	itemsLabel.Name = "Items"
	itemsLabel.Size = UDim2.fromScale(0.15, 1)
	itemsLabel.Position = UDim2.fromScale(0.76, 0)
	itemsLabel.BackgroundTransparency = 1
	itemsLabel.Text = "📦 " .. playerData.items
	itemsLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
	itemsLabel.TextScaled = true
	itemsLabel.Font = Enum.Font.Arcade
	itemsLabel.TextXAlignment = Enum.TextXAlignment.Center
	itemsLabel.Parent = playerEntry

	-- Join indicator (cute detail)
	local joinLabel = Instance.new("TextLabel")
	joinLabel.Name = "JoinTime"
	joinLabel.Size = UDim2.fromScale(0.12, 1)
	joinLabel.Position = UDim2.fromScale(0.88, 0)
	joinLabel.BackgroundTransparency = 1
	joinLabel.Text = playerData.joinTime < 30 and "🌟 New!" or "⭐ " .. math.floor(playerData.joinTime / 30) .. "mo"
	joinLabel.TextColor3 = playerData.joinTime < 30 and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(180, 180, 180)
	joinLabel.TextScaled = true
	joinLabel.Font = Enum.Font.Arcade
	joinLabel.TextXAlignment = Enum.TextXAlignment.Center
	joinLabel.Parent = playerEntry

	return playerEntry
end

-- Create the main leaderboard GUI
function LeaderBoardGUI.CreateLeaderBoard()
	-- Main ScreenGui
	local leaderboardScreen = Instance.new("ScreenGui")
	leaderboardScreen.Name = "LeaderBoardGUI"
	leaderboardScreen.Parent = playerGui
	leaderboardScreen.ResetOnSpawn = false

	-- Background blur effect (same as shop)
	local blurFrame = Instance.new("Frame")
	blurFrame.Name = "BlurBackground"
	blurFrame.Size = UDim2.fromScale(1, 1)
	blurFrame.Position = UDim2.fromScale(0, 0)
	blurFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	blurFrame.BackgroundTransparency = 0.2
	blurFrame.Parent = leaderboardScreen

	-- Main leaderboard container (same style as shop)
	local leaderboardContainer = Instance.new("Frame")
	leaderboardContainer.Name = "LeaderBoardContainer"
	leaderboardContainer.Size = UDim2.fromScale(0.6, 0.8)
	leaderboardContainer.Position = UDim2.fromScale(0.2, 0.1)
	leaderboardContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	leaderboardContainer.BorderSizePixel = 0
	leaderboardContainer.Parent = leaderboardScreen

	-- Clean border (same as shop)
	local borderStroke = Instance.new("UIStroke")
	borderStroke.Color = Color3.fromRGB(80, 80, 85)
	borderStroke.Thickness = 1
	borderStroke.Transparency = 0
	borderStroke.Parent = leaderboardContainer

	-- Header section (same style as shop)
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.fromScale(1, 0.15)
	header.Position = UDim2.fromScale(0, 0)
	header.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	header.BorderSizePixel = 0
	header.Parent = leaderboardContainer

	-- Bottom border for header
	local headerBorder = Instance.new("Frame")
	headerBorder.Name = "HeaderBorder"
	headerBorder.Size = UDim2.fromScale(0.9, 0.02)
	headerBorder.Position = UDim2.fromScale(0.05, 0.98)
	headerBorder.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
	headerBorder.BorderSizePixel = 0
	headerBorder.Parent = header

	-- Leaderboard title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "LeaderBoardTitle"
	titleLabel.Size = UDim2.fromScale(0.6, 0.6)
	titleLabel.Position = UDim2.fromScale(0.05, 0.2)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "🏆 LEADERBOARD"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextScaled = true
	titleLabel.Font = Enum.Font.Arcade
	titleLabel.Parent = header

	-- Server info
	local serverInfo = Instance.new("TextLabel")
	serverInfo.Name = "ServerInfo"
	serverInfo.Size = UDim2.fromScale(0.3, 0.4)
	serverInfo.Position = UDim2.fromScale(0.65, 0.3)
	serverInfo.BackgroundTransparency = 1
	serverInfo.Text = #Players:GetPlayers() .. " players online"
	serverInfo.TextColor3 = Color3.fromRGB(150, 200, 255)
	serverInfo.TextScaled = true
	serverInfo.Font = Enum.Font.Arcade
	serverInfo.Parent = header

	-- Close button (same as shop)
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.fromScale(0.06, 0.4)
	closeButton.Position = UDim2.fromScale(0.92, 0.3)
	closeButton.BackgroundTransparency = 1
	closeButton.BorderSizePixel = 0
	closeButton.Text = "X"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextScaled = true
	closeButton.Font = Enum.Font.Arcade
	closeButton.Parent = header

	-- Players list scroll frame
	local playersScroll = Instance.new("ScrollingFrame")
	playersScroll.Name = "PlayersContainer"
	playersScroll.Size = UDim2.fromScale(0.9, 0.8)
	playersScroll.Position = UDim2.fromScale(0.05, 0.18)
	playersScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	playersScroll.BorderSizePixel = 0
	playersScroll.ScrollBarThickness = 6
	playersScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 105)
	playersScroll.Parent = leaderboardContainer

	-- List layout for players
	local playersLayout = Instance.new("UIListLayout")
	playersLayout.SortOrder = Enum.SortOrder.LayoutOrder
	playersLayout.Padding = UDim.new(0, 5)
	playersLayout.Parent = playersScroll

	-- Add padding around the list
	local listPadding = Instance.new("UIPadding")
	listPadding.PaddingTop = UDim.new(0, 10)
	listPadding.PaddingBottom = UDim.new(0, 10)
	listPadding.PaddingLeft = UDim.new(0, 10)
	listPadding.PaddingRight = UDim.new(0, 10)
	listPadding.Parent = playersScroll

	-- Function to refresh leaderboard
	local function refreshLeaderBoard()
		-- Clear existing entries
		for _, child in pairs(playersScroll:GetChildren()) do
			if child:IsA("Frame") and child.Name:match("Player_") then
				child:Destroy()
			end
		end

		-- Get updated player data
		local playersData = getAllPlayersStats()

		-- Create entries for each player
		for rank, playerData in ipairs(playersData) do
			local playerEntry = createPlayerEntry(playerData, rank)
			playerEntry.LayoutOrder = rank
			playerEntry.Parent = playersScroll
		end

		-- Update scroll canvas size
		task.wait(0.1) -- Wait for layout to update
		playersScroll.CanvasSize =
			UDim2.fromScale(0, playersLayout.AbsoluteContentSize.Y / playersScroll.AbsoluteSize.Y)

		-- Update server info
		serverInfo.Text = #Players:GetPlayers() .. " players online"
	end

	-- Close button functionality
	closeButton.MouseButton1Click:Connect(function()
		leaderboardScreen:Destroy()
	end)

	-- Initial population
	refreshLeaderBoard()

	-- Auto-refresh every 5 seconds
	task.spawn(function()
		while leaderboardScreen.Parent do
			task.wait(5)
			if leaderboardScreen.Parent then
				refreshLeaderBoard()
			end
		end
	end)

	-- Entrance animation (same as shop)
	leaderboardContainer.Size = UDim2.fromScale(0, 0)
	leaderboardContainer.Position = UDim2.fromScale(0.5, 0.5)

	local openTween =
		TweenService:Create(leaderboardContainer, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.fromScale(0.6, 0.8),
			Position = UDim2.fromScale(0.2, 0.1),
		})
	openTween:Play()

	return leaderboardScreen
end

-- Function to open leaderboard
function LeaderBoardGUI.OpenLeaderBoard()
	-- Close any existing leaderboard
	local existingLeaderBoard = playerGui:FindFirstChild("LeaderBoardGUI")
	if existingLeaderBoard then
		existingLeaderBoard:Destroy()
	end

	LeaderBoardGUI.CreateLeaderBoard()
end

-- Tab key override to open custom leaderboard
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.Tab then
		LeaderBoardGUI.OpenLeaderBoard()
	end
end)

print("🏆 Custom LeaderBoard loaded!")
print("📝 Press Tab to view the leaderboard")
print("🎯 Features: Player rankings, money, items, and cute design!")

return LeaderBoardGUI
