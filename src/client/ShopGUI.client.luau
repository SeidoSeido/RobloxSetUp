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
			description = "Grows into a fiery creature that helps with garden warmth and volcano exploration.",
			price = 50,
			image = "rbxassetid://0", -- You'd replace with actual image IDs
			rarity = "Common",
			color = Color3.fromRGB(255, 100, 100),
		},
		{
			id = "water_seed",
			name = "Water Seed",
			description = "Evolves into an aquatic companion perfect for ocean dimensions.",
			price = 75,
			image = "rbxassetid://0",
			rarity = "Common",
			color = Color3.fromRGB(100, 150, 255),
		},
		{
			id = "legendary_seed",
			name = "Legendary Rainbow Seed",
			description = "Extremely rare seed that can become any element! Guaranteed unique creature.",
			price = 500,
			image = "rbxassetid://0",
			rarity = "Legendary",
			color = Color3.fromRGB(255, 215, 0),
		},
	},
	Tools = {
		{
			id = "magic_watering_can",
			name = "Magic Watering Can",
			description = "Waters all plants instantly with sparkly magic water!",
			price = 100,
			image = "rbxassetid://0",
			rarity = "Rare",
			color = Color3.fromRGB(100, 255, 200),
		},
		{
			id = "growth_crystal",
			name = "Growth Crystal",
			description = "Speeds up creature evolution by 50% for 1 hour.",
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
			description = "Beautiful fountain that makes nearby creatures happier.",
			price = 200,
			image = "rbxassetid://0",
			rarity = "Rare",
			color = Color3.fromRGB(150, 200, 255),
		},
		{
			id = "rainbow_bridge",
			name = "Rainbow Bridge",
			description = "Stunning bridge decoration that spans across your garden.",
			price = 300,
			image = "rbxassetid://0",
			rarity = "Epic",
			color = Color3.fromRGB(255, 180, 255),
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
	blurFrame.BackgroundTransparency = 0.3
	blurFrame.Parent = shopScreen

	-- Main shop container
	local shopContainer = Instance.new("Frame")
	shopContainer.Name = "ShopContainer"
	shopContainer.Size = UDim2.fromScale(0.9, 0.85)
	shopContainer.Position = UDim2.fromScale(0.05, 0.075)
	shopContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
	shopContainer.BorderSizePixel = 0
	shopContainer.Parent = shopScreen

	-- Rounded corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 20)
	corner.Parent = shopContainer

	-- Magical border glow
	local borderGlow = Instance.new("UIStroke")
	borderGlow.Color = Color3.fromRGB(100, 200, 255)
	borderGlow.Thickness = 3
	borderGlow.Transparency = 0.5
	borderGlow.Parent = shopContainer

	-- Header section
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.fromScale(1, 0.12)
	header.Position = UDim2.fromScale(0, 0)
	header.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	header.BorderSizePixel = 0
	header.Parent = shopContainer

	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 20)
	headerCorner.Parent = header

	-- Shop title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "ShopTitle"
	titleLabel.Size = UDim2.fromScale(0.7, 1)
	titleLabel.Position = UDim2.fromScale(0.05, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "✨ MAGICAL SPIRIT SHOP ✨"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextScaled = true
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Parent = header

	-- Money display
	local moneyFrame = Instance.new("Frame")
	moneyFrame.Name = "MoneyDisplay"
	moneyFrame.Size = UDim2.fromScale(0.2, 0.7)
	moneyFrame.Position = UDim2.fromScale(0.75, 0.15)
	moneyFrame.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
	moneyFrame.BorderSizePixel = 0
	moneyFrame.Parent = header

	local moneyCorner = Instance.new("UICorner")
	moneyCorner.CornerRadius = UDim.new(0, 10)
	moneyCorner.Parent = moneyFrame

	local moneyLabel = Instance.new("TextLabel")
	moneyLabel.Name = "MoneyAmount"
	moneyLabel.Size = UDim2.fromScale(1, 1)
	moneyLabel.Position = UDim2.fromScale(0, 0)
	moneyLabel.BackgroundTransparency = 1
	moneyLabel.Text = "💰 " .. (GameManager.GetPlayerData(player).money or 0)
	moneyLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
	moneyLabel.TextScaled = true
	moneyLabel.Font = Enum.Font.GothamBold
	moneyLabel.Parent = moneyFrame

	-- Close button
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.fromScale(0.08, 0.6)
	closeButton.Position = UDim2.fromScale(0.9, 0.2)
	closeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	closeButton.BorderSizePixel = 0
	closeButton.Text = "✕"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextScaled = true
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = header

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 10)
	closeCorner.Parent = closeButton

	-- Category tabs
	local categoryFrame = Instance.new("Frame")
	categoryFrame.Name = "CategoryTabs"
	categoryFrame.Size = UDim2.fromScale(1, 0.08)
	categoryFrame.Position = UDim2.fromScale(0, 0.12)
	categoryFrame.BackgroundTransparency = 1
	categoryFrame.Parent = shopContainer

	local categoryLayout = Instance.new("UIListLayout")
	categoryLayout.FillDirection = Enum.FillDirection.Horizontal
	categoryLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	categoryLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	categoryLayout.Padding = UDim.new(0, 10)
	categoryLayout.Parent = categoryFrame

	local categories = { "Seeds", "Tools", "Decorations" }
	local currentCategory = "Seeds"
	local categoryButtons = {}

	for i, category in ipairs(categories) do
		local categoryButton = Instance.new("TextButton")
		categoryButton.Name = category .. "Tab"
		categoryButton.Size = UDim2.fromScale(0.25, 1)
		categoryButton.BackgroundColor3 = category == currentCategory and Color3.fromRGB(100, 150, 255)
			or Color3.fromRGB(60, 60, 80)
		categoryButton.BorderSizePixel = 0
		categoryButton.Text = category
		categoryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		categoryButton.TextScaled = true
		categoryButton.Font = Enum.Font.Gotham
		categoryButton.Parent = categoryFrame

		local tabCorner = Instance.new("UICorner")
		tabCorner.CornerRadius = UDim.new(0, 8)
		tabCorner.Parent = categoryButton

		categoryButtons[category] = categoryButton
	end

	-- Items scroll frame
	local itemsScroll = Instance.new("ScrollingFrame")
	itemsScroll.Name = "ItemsContainer"
	itemsScroll.Size = UDim2.fromScale(0.95, 0.75)
	itemsScroll.Position = UDim2.fromScale(0.025, 0.22)
	itemsScroll.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	itemsScroll.BorderSizePixel = 0
	itemsScroll.ScrollBarThickness = 8
	itemsScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
	itemsScroll.Parent = shopContainer

	local itemsCorner = Instance.new("UICorner")
	itemsCorner.CornerRadius = UDim.new(0, 15)
	itemsCorner.Parent = itemsScroll

	-- Grid layout for items
	local itemsLayout = Instance.new("UIGridLayout")
	itemsLayout.CellSize = UDim2.fromScale(0.3, 0.4)
	itemsLayout.CellPadding = UDim2.fromScale(0.02, 0.02)
	itemsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	itemsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	itemsLayout.Parent = itemsScroll

	-- Function to create item cards
	local function createItemCard(itemData)
		local itemCard = Instance.new("Frame")
		itemCard.Name = itemData.id
		itemCard.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
		itemCard.BorderSizePixel = 0

		local cardCorner = Instance.new("UICorner")
		cardCorner.CornerRadius = UDim.new(0, 12)
		cardCorner.Parent = itemCard

		-- Rarity border
		local rarityBorder = Instance.new("UIStroke")
		rarityBorder.Color = itemData.color
		rarityBorder.Thickness = 2
		rarityBorder.Parent = itemCard

		-- Item image
		local itemImage = Instance.new("ImageLabel")
		itemImage.Name = "ItemImage"
		itemImage.Size = UDim2.fromScale(0.8, 0.4)
		itemImage.Position = UDim2.fromScale(0.1, 0.05)
		itemImage.BackgroundColor3 = itemData.color
		itemImage.BackgroundTransparency = 0.8
		itemImage.BorderSizePixel = 0
		itemImage.Image = itemData.image
		itemImage.Parent = itemCard

		local imageCorner = Instance.new("UICorner")
		imageCorner.CornerRadius = UDim.new(0, 8)
		imageCorner.Parent = itemImage

		-- Item name
		local itemName = Instance.new("TextLabel")
		itemName.Name = "ItemName"
		itemName.Size = UDim2.fromScale(0.9, 0.15)
		itemName.Position = UDim2.fromScale(0.05, 0.48)
		itemName.BackgroundTransparency = 1
		itemName.Text = itemData.name
		itemName.TextColor3 = Color3.fromRGB(255, 255, 255)
		itemName.TextScaled = true
		itemName.Font = Enum.Font.GothamBold
		itemName.Parent = itemCard

		-- Item description
		local itemDesc = Instance.new("TextLabel")
		itemDesc.Name = "ItemDescription"
		itemDesc.Size = UDim2.fromScale(0.9, 0.2)
		itemDesc.Position = UDim2.fromScale(0.05, 0.63)
		itemDesc.BackgroundTransparency = 1
		itemDesc.Text = itemData.description
		itemDesc.TextColor3 = Color3.fromRGB(200, 200, 200)
		itemDesc.TextScaled = true
		itemDesc.Font = Enum.Font.Gotham
		itemDesc.TextWrapped = true
		itemDesc.Parent = itemCard

		-- Price and buy button
		local buyButton = Instance.new("TextButton")
		buyButton.Name = "BuyButton"
		buyButton.Size = UDim2.fromScale(0.8, 0.12)
		buyButton.Position = UDim2.fromScale(0.1, 0.85)
		buyButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
		buyButton.BorderSizePixel = 0
		buyButton.Text = "💰 " .. itemData.price .. " - BUY"
		buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		buyButton.TextScaled = true
		buyButton.Font = Enum.Font.GothamBold
		buyButton.Parent = itemCard

		local buyCorner = Instance.new("UICorner")
		buyCorner.CornerRadius = UDim.new(0, 6)
		buyCorner.Parent = buyButton

		-- Buy button functionality
		buyButton.MouseButton1Click:Connect(function()
			local playerData = GameManager.GetPlayerData(player)
			if playerData.money >= itemData.price then
				-- Purchase successful
				GameManager.RemoveMoney(player, itemData.price)
				GameManager.AddItem(player, itemData.id, 1)

				-- Update money display
				moneyLabel.Text = "💰 " .. GameManager.GetPlayerData(player).money

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
						{ BackgroundColor3 = Color3.fromRGB(100, 200, 100) }
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
						{ BackgroundColor3 = Color3.fromRGB(100, 200, 100) }
					)
					returnTween:Play()
				end)

				print("❌ Not enough money! Need " .. itemData.price .. " coins.")
			end
		end)

		-- Hover effects
		buyButton.MouseEnter:Connect(function()
			local hoverTween = TweenService:Create(
				buyButton,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad),
				{ Size = UDim2.fromScale(0.85, 0.13) }
			)
			hoverTween:Play()
		end)

		buyButton.MouseLeave:Connect(function()
			local leaveTween = TweenService:Create(
				buyButton,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad),
				{ Size = UDim2.fromScale(0.8, 0.12) }
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
				btn.BackgroundColor3 = cat == category and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(60, 60, 80)
			end

			currentCategory = category
			populateCategory(category)
		end)
	end

	-- Close button functionality
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

return ShopGUI
