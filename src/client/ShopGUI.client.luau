--[[
	ShopGUI - Modern, animated shop interface with categories and purchase system
	Features: Smooth animations, particle effects, category filtering, purchase flow
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Import GameManager for data
local GameManager = require(ReplicatedStorage.Shared.GameManager)

-- Shop GUI Module
local ShopGUI = {}

-- Shop data structure
local shopData = {
	Seeds = {
		{
			id = "fire_seed",
			name = "Fire Seed",
			description = "Grows fiery creatures for warmth and exploration.",
			price = 50,
			image = "rbxassetid://0", -- You'd replace with actual image IDs
			rarity = "Common",
			color = Color3.fromRGB(255, 100, 100),
		},
		{
			id = "water_seed",
			name = "Water Seed",
			description = "Evolves into aquatic companions for ocean areas.",
			price = 75,
			image = "rbxassetid://0",
			rarity = "Common",
			color = Color3.fromRGB(100, 150, 255),
		},
		{
			id = "legendary_seed",
			name = "Rainbow Seed",
			description = "Rare seed that becomes any element! Unique creature guaranteed.",
			price = 500,
			image = "rbxassetid://0",
			rarity = "Legendary",
			color = Color3.fromRGB(255, 215, 0),
		},
	},
	Tools = {
		{
			id = "magic_watering_can",
			name = "Magic Can",
			description = "Waters all plants instantly with magic!",
			price = 100,
			image = "rbxassetid://0",
			rarity = "Rare",
			color = Color3.fromRGB(100, 255, 200),
		},
		{
			id = "growth_crystal",
			name = "Growth Crystal",
			description = "Speeds up evolution by 50% for 1 hour.",
			price = 25,
			image = "rbxassetid://0",
			rarity = "Common",
			color = Color3.fromRGB(200, 100, 255),
		},
	},
	Decorations = {
		{
			id = "magic_fountain",
			name = "Magic Fountain",
			description = "Beautiful fountain that boosts creature happiness.",
			price = 200,
			image = "rbxassetid://0",
			rarity = "Rare",
			color = Color3.fromRGB(150, 200, 255),
		},
		{
			id = "rainbow_bridge",
			name = "Rainbow Bridge",
			description = "Stunning bridge decoration for your garden.",
			price = 300,
			image = "rbxassetid://0",
			rarity = "Epic",
			color = Color3.fromRGB(255, 180, 255),
		},
	},
	Gamepasses = {
		{
			id = "double_coins_pass",
			name = "Double Coins Pass",
			description = "Earn 2x coins from all activities! Permanent boost.",
			price = 199, -- Robux price
			image = "rbxassetid://0",
			rarity = "Premium",
			color = Color3.fromRGB(255, 215, 0),
			gamepass = true,
		},
		{
			id = "vip_garden_pass",
			name = "VIP Garden Access",
			description = "Unlock exclusive VIP area with rare creatures!",
			price = 299,
			image = "rbxassetid://0",
			rarity = "Premium",
			color = Color3.fromRGB(147, 112, 219),
			gamepass = true,
		},
		{
			id = "instant_hatch_pass",
			name = "Instant Hatch Pass",
			description = "Skip all waiting times! Instant everything.",
			price = 149,
			image = "rbxassetid://0",
			rarity = "Premium",
			color = Color3.fromRGB(255, 69, 0),
			gamepass = true,
		},
		{
			id = "mega_storage_pass",
			name = "Mega Storage Pass",
			description = "Unlimited inventory space for everything!",
			price = 99,
			image = "rbxassetid://0",
			rarity = "Premium",
			color = Color3.fromRGB(50, 205, 50),
			gamepass = true,
		},
		{
			id = "legendary_starter_pass",
			name = "Starter Pack",
			description = "3 legendary creatures, 10K coins, and exclusive tools!",
			price = 399,
			image = "rbxassetid://0",
			rarity = "Premium",
			color = Color3.fromRGB(255, 20, 147),
			gamepass = true,
		},
	},
}

-- Create the main shop GUI
function ShopGUI.CreateShopInterface()
	-- Main ScreenGui
	local shopScreen = Instance.new("ScreenGui")
	shopScreen.Name = "ShopGUI"
	shopScreen.Parent = playerGui
	shopScreen.ResetOnSpawn = false

	-- Background blur effect
	local blurFrame = Instance.new("Frame")
	blurFrame.Name = "BlurBackground"
	blurFrame.Size = UDim2.fromScale(1, 1)
	blurFrame.Position = UDim2.fromScale(0, 0)
	blurFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	blurFrame.BackgroundTransparency = 1
	blurFrame.Parent = shopScreen

	-- Main shop container
	local shopContainer = Instance.new("Frame")
	shopContainer.Name = "ShopContainer"
	shopContainer.Size = UDim2.fromScale(0.8, 0.75)
	shopContainer.Position = UDim2.fromScale(0.1, 0.125)
	shopContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	shopContainer.BorderSizePixel = 0
	shopContainer.Parent = shopScreen

	-- Clean border
	local borderStroke = Instance.new("UIStroke")
	borderStroke.Color = Color3.fromRGB(80, 80, 85)
	borderStroke.Thickness = 1
	borderStroke.Transparency = 0
	borderStroke.Parent = shopContainer -- Header section
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.fromScale(1, 0.15)
	header.Position = UDim2.fromScale(0, 0)
	header.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	header.BorderSizePixel = 0
	header.Parent = shopContainer

	-- Bottom border for header
	local headerBorder = Instance.new("Frame")
	headerBorder.Name = "HeaderBorder"
	headerBorder.Size = UDim2.fromScale(0.9, 0.02)
	headerBorder.Position = UDim2.fromScale(0.05, 0.98)
	headerBorder.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
	headerBorder.BorderSizePixel = 0
	headerBorder.Parent = header -- Shop title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "ShopTitle"
	titleLabel.Size = UDim2.fromScale(0.6, 0.6)
	titleLabel.Position = UDim2.fromScale(0.05, 0.2)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "SHOP"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextScaled = true
	titleLabel.Font = Enum.Font.Arcade
	titleLabel.Parent = header

	-- Money display
	local moneyFrame = Instance.new("Frame")
	moneyFrame.Name = "MoneyDisplay"
	moneyFrame.Size = UDim2.fromScale(0.25, 0.5)
	moneyFrame.Position = UDim2.fromScale(0.65, 0.25)
	moneyFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
	moneyFrame.BorderSizePixel = 0
	moneyFrame.Parent = header

	local moneyCorner = Instance.new("UICorner")
	moneyCorner.CornerRadius = UDim.new(0, 4)
	moneyCorner.Parent = moneyFrame

	local moneyBorder = Instance.new("UIStroke")
	moneyBorder.Color = Color3.fromRGB(80, 80, 85)
	moneyBorder.Thickness = 1
	moneyBorder.Parent = moneyFrame

	local moneyLabel = Instance.new("TextLabel")
	moneyLabel.Name = "MoneyAmount"
	moneyLabel.Size = UDim2.fromScale(1, 1)
	moneyLabel.Position = UDim2.fromScale(0, 0)
	moneyLabel.BackgroundTransparency = 1
	moneyLabel.Text = "$" .. (GameManager.GetPlayerData(player).money or 0)
	moneyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	moneyLabel.TextScaled = true
	moneyLabel.Font = Enum.Font.Arcade
	moneyLabel.Parent = moneyFrame -- Close button
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
	-- Category tabs
	local categoryFrame = Instance.new("Frame")
	categoryFrame.Name = "CategoryTabs"
	categoryFrame.Size = UDim2.fromScale(1, 0.12)
	categoryFrame.Position = UDim2.fromScale(0, 0.15)
	categoryFrame.BackgroundTransparency = 1
	categoryFrame.Parent = shopContainer

	-- Remove the UIListLayout and manually position buttons for true flexbox behavior
	-- Don't use UIListLayout, manually position for equal spacing

	local categories = { "Gamepasses", "Tools", "Decorations", "Seeds" }
	local currentCategory = "Gamepasses"
	local categoryButtons = {}

	-- Create buttons with manual positioning for true flexbox spacing
	local buttonWidth = 0.15 -- 15% width each (smaller buttons)
	local totalGapSpace = 1 - (4 * buttonWidth) -- Remaining space for gaps
	local gapSize = totalGapSpace / 5 -- 5 gaps (before, between, after)

	for i, category in ipairs(categories) do
		local categoryButton = Instance.new("TextButton")
		categoryButton.Name = category .. "Tab"

		-- Calculate position: gap + (i-1) * (buttonWidth + gap)
		local xPosition = gapSize + (i - 1) * (buttonWidth + gapSize)
		categoryButton.Size = UDim2.fromScale(buttonWidth, 0.6)
		categoryButton.Position = UDim2.fromScale(xPosition, 0.2)

		categoryButton.BackgroundTransparency = 1
		categoryButton.BorderSizePixel = 0
		categoryButton.Text = category:upper()
		categoryButton.TextColor3 = category == currentCategory and Color3.fromRGB(255, 255, 255)
			or Color3.fromRGB(180, 180, 180)
		categoryButton.TextScaled = true
		categoryButton.Font = Enum.Font.Arcade
		categoryButton.Parent = categoryFrame

		categoryButtons[category] = categoryButton
	end -- Items scroll frame
	local itemsScroll = Instance.new("ScrollingFrame")
	itemsScroll.Name = "ItemsContainer"
	itemsScroll.Size = UDim2.fromScale(0.9, 0.65)
	itemsScroll.Position = UDim2.fromScale(0.05, 0.3)
	itemsScroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	itemsScroll.BorderSizePixel = 0
	itemsScroll.ScrollBarThickness = 6
	itemsScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 105)
	itemsScroll.Parent = shopContainer

	-- Grid layout for items with fixed responsive sizing
	local itemsLayout = Instance.new("UIGridLayout")
	itemsLayout.CellSize = UDim2.fromOffset(200, 280) -- Fixed size for consistency
	itemsLayout.CellPadding = UDim2.fromOffset(15, 15)
	itemsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	itemsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	itemsLayout.Parent = itemsScroll -- Add padding around the grid
	local gridPadding = Instance.new("UIPadding")
	gridPadding.PaddingTop = UDim.new(0, 20)
	gridPadding.PaddingBottom = UDim.new(0, 20)
	gridPadding.PaddingLeft = UDim.new(0, 20)
	gridPadding.PaddingRight = UDim.new(0, 20)
	gridPadding.Parent = itemsScroll -- Function to create item cards
	local function createItemCard(itemData)
		local itemCard = Instance.new("Frame")
		itemCard.Name = itemData.id
		itemCard.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
		itemCard.BorderSizePixel = 0

		-- Rarity border
		local rarityBorder = Instance.new("UIStroke")
		rarityBorder.Color = itemData.color
		rarityBorder.Thickness = 2
		rarityBorder.Parent = itemCard -- Item image
		local itemImage = Instance.new("ImageLabel")
		itemImage.Name = "ItemImage"
		itemImage.Size = UDim2.fromScale(1, 0.45)
		itemImage.Position = UDim2.fromScale(0, 0)
		itemImage.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
		itemImage.BorderSizePixel = 0
		itemImage.Image = itemData.image
		itemImage.Parent = itemCard -- Subtle rarity indicator
		local rarityIndicator = Instance.new("Frame")
		rarityIndicator.Name = "RarityIndicator"
		rarityIndicator.Size = UDim2.fromScale(0.15, 0.05)
		rarityIndicator.Position = UDim2.fromScale(0.85, 0.02)
		rarityIndicator.BackgroundColor3 = itemData.color
		rarityIndicator.BorderSizePixel = 0
		rarityIndicator.Parent = itemImage

		-- Item name
		local itemName = Instance.new("TextLabel")
		itemName.Name = "ItemName"
		itemName.Size = UDim2.fromScale(0.9, 0.15)
		itemName.Position = UDim2.fromScale(0.05, 0.48)
		itemName.BackgroundTransparency = 1
		itemName.Text = itemData.name:upper()
		itemName.TextColor3 = Color3.fromRGB(255, 255, 255)
		itemName.TextScaled = true
		itemName.Font = Enum.Font.Arcade
		itemName.Parent = itemCard

		-- Add padding to item name
		local namePadding = Instance.new("UIPadding")
		namePadding.PaddingLeft = UDim.new(0, 8)
		namePadding.PaddingRight = UDim.new(0, 8)
		namePadding.Parent = itemName

		-- Item description
		local itemDesc = Instance.new("TextLabel")
		itemDesc.Name = "ItemDescription"
		itemDesc.Size = UDim2.fromScale(0.9, 0.2)
		itemDesc.Position = UDim2.fromScale(0.05, 0.63)
		itemDesc.BackgroundTransparency = 1
		itemDesc.Text = itemData.description
		itemDesc.TextColor3 = Color3.fromRGB(200, 200, 200)
		itemDesc.TextScaled = true
		itemDesc.Font = Enum.Font.SourceSans
		itemDesc.TextWrapped = true
		itemDesc.Parent = itemCard

		-- Add padding to item description
		local descPadding = Instance.new("UIPadding")
		descPadding.PaddingLeft = UDim.new(0, 12)
		descPadding.PaddingRight = UDim.new(0, 12)
		descPadding.PaddingTop = UDim.new(0, 4)
		descPadding.PaddingBottom = UDim.new(0, 4)
		descPadding.Parent = itemDesc

		-- Price and buy button
		local buyButton = Instance.new("TextButton")
		buyButton.Name = "BuyButton"
		buyButton.Size = UDim2.fromScale(0.9, 0.12)
		buyButton.Position = UDim2.fromScale(0.05, 0.86)
		buyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		buyButton.BorderSizePixel = 0
		buyButton.Text = (itemData.gamepass and "R$" or "$") .. itemData.price
		buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		buyButton.TextScaled = true
		buyButton.Font = Enum.Font.Arcade
		buyButton.Parent = itemCard

		-- Buy button functionality
		buyButton.MouseButton1Click:Connect(function()
			if itemData.gamepass then
				-- Handle gamepass purchase (would integrate with Roblox MarketplaceService)
				print("🎮 Gamepass purchase initiated: " .. itemData.name .. " for " .. itemData.price .. " Robux!")
				-- Here you would use MarketplaceService:PromptGamePassPurchase()

				-- Visual feedback for gamepass
				local gamepassTween = TweenService:Create(
					buyButton,
					TweenInfo.new(0.3, Enum.EasingStyle.Bounce),
					{ BackgroundColor3 = Color3.fromRGB(255, 215, 0) }
				)
				gamepassTween:Play()

				gamepassTween.Completed:Connect(function()
					local returnTween = TweenService:Create(
						buyButton,
						TweenInfo.new(0.3, Enum.EasingStyle.Quad),
						{ BackgroundColor3 = Color3.fromRGB(60, 60, 60) }
					)
					returnTween:Play()
				end)
			else
				-- Regular item purchase with coins
				local playerData = GameManager.GetPlayerData(player)
				if playerData.money >= itemData.price then
					-- Purchase successful
					GameManager.RemoveMoney(player, itemData.price)
					GameManager.AddItem(player, itemData.id, 1)

					-- Update money display
					moneyLabel.Text = "$" .. GameManager.GetPlayerData(player).money

					-- Success animation
					local successTween = TweenService:Create(
						buyButton,
						TweenInfo.new(0.2, Enum.EasingStyle.Bounce),
						{ BackgroundColor3 = Color3.fromRGB(50, 255, 50) }
					)
					successTween:Play()

					successTween.Completed:Connect(function()
						local returnTween = TweenService:Create(
							buyButton,
							TweenInfo.new(0.3, Enum.EasingStyle.Quad),
							{ BackgroundColor3 = Color3.fromRGB(60, 60, 60) }
						)
						returnTween:Play()
					end)

					print("✅ Purchased " .. itemData.name .. " for " .. itemData.price .. " coins!")
				else
					-- Not enough money
					local errorTween = TweenService:Create(
						buyButton,
						TweenInfo.new(0.2, Enum.EasingStyle.Bounce),
						{ BackgroundColor3 = Color3.fromRGB(255, 50, 50) }
					)
					errorTween:Play()

					errorTween.Completed:Connect(function()
						local returnTween = TweenService:Create(
							buyButton,
							TweenInfo.new(0.3, Enum.EasingStyle.Quad),
							{ BackgroundColor3 = Color3.fromRGB(60, 60, 60) }
						)
						returnTween:Play()
					end)

					print("❌ Not enough money! Need " .. itemData.price .. " coins.")
				end
			end
		end)

		-- Hover effects
		buyButton.MouseEnter:Connect(function()
			local hoverTween = TweenService:Create(
				buyButton,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad),
				{ BackgroundColor3 = Color3.fromRGB(80, 80, 80) }
			)
			hoverTween:Play()
		end)

		buyButton.MouseLeave:Connect(function()
			local leaveTween = TweenService:Create(
				buyButton,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad),
				{ BackgroundColor3 = Color3.fromRGB(60, 60, 60) }
			)
			leaveTween:Play()
		end)

		itemCard.Parent = itemsScroll
		return itemCard
	end

	-- Function to populate items
	local function populateCategory(category)
		-- Clear existing items
		for _, child in ipairs(itemsScroll:GetChildren()) do
			if child:IsA("Frame") then
				child:Destroy()
			end
		end

		-- Add items for selected category
		for _, itemData in ipairs(shopData[category]) do
			createItemCard(itemData)
		end

		-- Update scroll canvas size
		task.wait(0.1) -- Wait for layout to update
		itemsScroll.CanvasSize = UDim2.fromScale(0, itemsLayout.AbsoluteContentSize.Y / itemsScroll.AbsoluteSize.Y)
	end

	-- Category button functionality
	for category, button in pairs(categoryButtons) do
		button.MouseButton1Click:Connect(function()
			-- Update button states
			for cat, btn in pairs(categoryButtons) do
				btn.TextColor3 = cat == category and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
			end

			currentCategory = category
			populateCategory(category)
		end)
	end -- Close button functionality
	closeButton.MouseButton1Click:Connect(function()
		shopScreen:Destroy()
	end)

	-- Initial population
	populateCategory(currentCategory)

	-- Entrance animation
	shopContainer.Size = UDim2.fromScale(0, 0)
	shopContainer.Position = UDim2.fromScale(0.5, 0.5)

	local openTween =
		TweenService:Create(shopContainer, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.fromScale(0.9, 0.85),
			Position = UDim2.fromScale(0.05, 0.075),
		})
	openTween:Play()

	return shopScreen
end

-- Function to open shop
function ShopGUI.OpenShop()
	-- Close any existing shop
	local existingShop = playerGui:FindFirstChild("ShopGUI")
	if existingShop then
		existingShop:Destroy()
	end

	ShopGUI.CreateShopInterface()
end

-- Keyboard shortcut to open shop (P key)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.P then
		ShopGUI.OpenShop()
	end
end)

-- RemoteEvent listeners for ShopOpenBlock
local openShopRemote = ReplicatedStorage:WaitForChild("OpenShopRemote")
local closeShopRemote = ReplicatedStorage:WaitForChild("CloseShopRemote")

openShopRemote.OnClientEvent:Connect(function()
	ShopGUI.OpenShop()
end)

closeShopRemote.OnClientEvent:Connect(function()
	-- Close any existing shop
	local existingShop = playerGui:FindFirstChild("ShopGUI")
	if existingShop then
		existingShop:Destroy()
	end
end)

return ShopGUI
