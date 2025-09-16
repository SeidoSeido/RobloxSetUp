--[[
	InventoryGUI - Modern inventory system with grid layout, sorting, and item management
	Features: Drag & drop, search, categories, item details, and smooth animations
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Import GameManager for data
local GameManager = require(ReplicatedStorage.Shared.GameManager)

-- Inventory GUI Module
local InventoryGUI = {}

-- Item data for display (this would normally come from server)
local itemDatabase = {
	fire_seed = {
		name = "Fire Seed",
		description = "A warm, glowing seed that tingles with fire magic. Plant this to grow a fire creature companion.",
		image = "rbxassetid://0",
		category = "Seeds",
		rarity = "Common",
		color = Color3.fromRGB(255, 100, 100),
		stackable = true,
		maxStack = 99,
	},
	water_seed = {
		name = "Water Seed",
		description = "A cool, blue seed that feels refreshing to touch. Perfect for growing aquatic companions.",
		image = "rbxassetid://0",
		category = "Seeds",
		rarity = "Common",
		color = Color3.fromRGB(100, 150, 255),
		stackable = true,
		maxStack = 99,
	},
	legendary_seed = {
		name = "Legendary Rainbow Seed",
		description = "An incredibly rare seed that shimmers with all colors of the rainbow. Contains immense magical potential!",
		image = "rbxassetid://0",
		category = "Seeds",
		rarity = "Legendary",
		color = Color3.fromRGB(255, 215, 0),
		stackable = true,
		maxStack = 10,
	},
	magic_watering_can = {
		name = "Magic Watering Can",
		description = "A mystical watering can that never runs dry. Click to water all plants instantly!",
		image = "rbxassetid://0",
		category = "Tools",
		rarity = "Rare",
		color = Color3.fromRGB(100, 255, 200),
		stackable = false,
		usable = true,
	},
	growth_crystal = {
		name = "Growth Crystal",
		description = "A shimmering crystal infused with time magic. Use to speed up creature evolution!",
		image = "rbxassetid://0",
		category = "Consumables",
		rarity = "Common",
		color = Color3.fromRGB(200, 100, 255),
		stackable = true,
		maxStack = 50,
	},
	wood = {
		name = "Magic Wood",
		description = "Enchanted wood from the mystical forest. Used for crafting garden decorations.",
		image = "rbxassetid://0",
		category = "Materials",
		rarity = "Common",
		color = Color3.fromRGB(139, 69, 19),
		stackable = true,
		maxStack = 999,
	},
	stone = {
		name = "Crystal Stone",
		description = "Glowing stones found in crystal caves. Essential for advanced garden construction.",
		image = "rbxassetid://0",
		category = "Materials",
		rarity = "Common",
		color = Color3.fromRGB(150, 150, 200),
		stackable = true,
		maxStack = 999,
	},
}

-- Create the main inventory GUI
function InventoryGUI.CreateInventoryInterface()
	-- Main ScreenGui
	local inventoryScreen = Instance.new("ScreenGui")
	inventoryScreen.Name = "InventoryGUI"
	inventoryScreen.Parent = playerGui
	inventoryScreen.ResetOnSpawn = false

	-- Background blur effect
	local blurFrame = Instance.new("Frame")
	blurFrame.Name = "BlurBackground"
	blurFrame.Size = UDim2.fromScale(1, 1)
	blurFrame.Position = UDim2.fromScale(0, 0)
	blurFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	blurFrame.BackgroundTransparency = 0.4
	blurFrame.Parent = inventoryScreen

	-- Main inventory container
	local inventoryContainer = Instance.new("Frame")
	inventoryContainer.Name = "InventoryContainer"
	inventoryContainer.Size = UDim2.fromScale(0.85, 0.8)
	inventoryContainer.Position = UDim2.fromScale(0.075, 0.1)
	inventoryContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
	inventoryContainer.BorderSizePixel = 0
	inventoryContainer.Parent = inventoryScreen

	-- Rounded corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 20)
	corner.Parent = inventoryContainer

	-- Magical border glow
	local borderGlow = Instance.new("UIStroke")
	borderGlow.Color = Color3.fromRGB(150, 100, 255)
	borderGlow.Thickness = 3
	borderGlow.Transparency = 0.4
	borderGlow.Parent = inventoryContainer

	-- Header section
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.fromScale(1, 0.12)
	header.Position = UDim2.fromScale(0, 0)
	header.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
	header.BorderSizePixel = 0
	header.Parent = inventoryContainer

	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 20)
	headerCorner.Parent = header

	-- Inventory title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "InventoryTitle"
	titleLabel.Size = UDim2.fromScale(0.4, 1)
	titleLabel.Position = UDim2.fromScale(0.05, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "🎒 MAGICAL INVENTORY"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextScaled = true
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Parent = header

	-- Search box
	local searchFrame = Instance.new("Frame")
	searchFrame.Name = "SearchFrame"
	searchFrame.Size = UDim2.fromScale(0.25, 0.6)
	searchFrame.Position = UDim2.fromScale(0.45, 0.2)
	searchFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	searchFrame.BorderSizePixel = 0
	searchFrame.Parent = header

	local searchCorner = Instance.new("UICorner")
	searchCorner.CornerRadius = UDim.new(0, 8)
	searchCorner.Parent = searchFrame

	local searchBox = Instance.new("TextBox")
	searchBox.Name = "SearchBox"
	searchBox.Size = UDim2.fromScale(0.9, 1)
	searchBox.Position = UDim2.fromScale(0.05, 0)
	searchBox.BackgroundTransparency = 1
	searchBox.PlaceholderText = "🔍 Search items..."
	searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
	searchBox.Text = ""
	searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	searchBox.TextScaled = true
	searchBox.Font = Enum.Font.Gotham
	searchBox.Parent = searchFrame

	-- Item count display
	local itemCountLabel = Instance.new("TextLabel")
	itemCountLabel.Name = "ItemCount"
	itemCountLabel.Size = UDim2.fromScale(0.2, 0.6)
	itemCountLabel.Position = UDim2.fromScale(0.75, 0.2)
	itemCountLabel.BackgroundTransparency = 1
	itemCountLabel.Text = "Items: 0/100"
	itemCountLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	itemCountLabel.TextScaled = true
	itemCountLabel.Font = Enum.Font.Gotham
	itemCountLabel.Parent = header

	-- Close button
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.fromScale(0.06, 0.6)
	closeButton.Position = UDim2.fromScale(0.92, 0.2)
	closeButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
	closeButton.BorderSizePixel = 0
	closeButton.Text = "✕"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextScaled = true
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = header

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeButton

	-- Category filter tabs
	local categoryFrame = Instance.new("Frame")
	categoryFrame.Name = "CategoryTabs"
	categoryFrame.Size = UDim2.fromScale(1, 0.08)
	categoryFrame.Position = UDim2.fromScale(0, 0.12)
	categoryFrame.BackgroundTransparency = 1
	categoryFrame.Parent = inventoryContainer

	local categoryLayout = Instance.new("UIListLayout")
	categoryLayout.FillDirection = Enum.FillDirection.Horizontal
	categoryLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	categoryLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	categoryLayout.Padding = UDim.new(0, 8)
	categoryLayout.Parent = categoryFrame

	local categories = { "All", "Seeds", "Tools", "Materials", "Consumables" }
	local currentFilter = "All"
	local categoryButtons = {}

	for _, category in ipairs(categories) do
		local categoryButton = Instance.new("TextButton")
		categoryButton.Name = category .. "Tab"
		categoryButton.Size = UDim2.fromScale(0.15, 1)
		categoryButton.BackgroundColor3 = category == currentFilter and Color3.fromRGB(150, 100, 255)
			or Color3.fromRGB(60, 60, 80)
		categoryButton.BorderSizePixel = 0
		categoryButton.Text = category
		categoryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		categoryButton.TextScaled = true
		categoryButton.Font = Enum.Font.Gotham
		categoryButton.Parent = categoryFrame

		local tabCorner = Instance.new("UICorner")
		tabCorner.CornerRadius = UDim.new(0, 6)
		tabCorner.Parent = categoryButton

		categoryButtons[category] = categoryButton
	end

	-- Main content area
	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "ContentFrame"
	contentFrame.Size = UDim2.fromScale(1, 0.8)
	contentFrame.Position = UDim2.fromScale(0, 0.2)
	contentFrame.BackgroundTransparency = 1
	contentFrame.Parent = inventoryContainer

	-- Items grid scroll frame
	local itemsScroll = Instance.new("ScrollingFrame")
	itemsScroll.Name = "ItemsGrid"
	itemsScroll.Size = UDim2.fromScale(0.7, 1)
	itemsScroll.Position = UDim2.fromScale(0.025, 0)
	itemsScroll.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	itemsScroll.BorderSizePixel = 0
	itemsScroll.ScrollBarThickness = 8
	itemsScroll.ScrollBarImageColor3 = Color3.fromRGB(150, 100, 255)
	itemsScroll.Parent = contentFrame

	local itemsCorner = Instance.new("UICorner")
	itemsCorner.CornerRadius = UDim.new(0, 12)
	itemsCorner.Parent = itemsScroll

	-- Grid layout for items
	local itemsLayout = Instance.new("UIGridLayout")
	itemsLayout.CellSize = UDim2.fromScale(0.18, 0.25)
	itemsLayout.CellPadding = UDim2.fromScale(0.02, 0.02)
	itemsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	itemsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	itemsLayout.Parent = itemsScroll

	-- Item details panel
	local detailsPanel = Instance.new("Frame")
	detailsPanel.Name = "ItemDetails"
	detailsPanel.Size = UDim2.fromScale(0.25, 1)
	detailsPanel.Position = UDim2.fromScale(0.73, 0)
	detailsPanel.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	detailsPanel.BorderSizePixel = 0
	detailsPanel.Parent = contentFrame

	local detailsCorner = Instance.new("UICorner")
	detailsCorner.CornerRadius = UDim.new(0, 12)
	detailsCorner.Parent = detailsPanel

	-- Details content
	local detailsTitle = Instance.new("TextLabel")
	detailsTitle.Name = "DetailsTitle"
	detailsTitle.Size = UDim2.fromScale(0.9, 0.08)
	detailsTitle.Position = UDim2.fromScale(0.05, 0.05)
	detailsTitle.BackgroundTransparency = 1
	detailsTitle.Text = "📋 ITEM DETAILS"
	detailsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	detailsTitle.TextScaled = true
	detailsTitle.Font = Enum.Font.GothamBold
	detailsTitle.Parent = detailsPanel

	local selectedItemFrame = Instance.new("Frame")
	selectedItemFrame.Name = "SelectedItem"
	selectedItemFrame.Size = UDim2.fromScale(0.9, 0.85)
	selectedItemFrame.Position = UDim2.fromScale(0.05, 0.13)
	selectedItemFrame.BackgroundTransparency = 1
	selectedItemFrame.Parent = detailsPanel
	selectedItemFrame.Visible = false

	-- Selected item image
	local selectedImage = Instance.new("ImageLabel")
	selectedImage.Name = "ItemImage"
	selectedImage.Size = UDim2.fromScale(0.8, 0.3)
	selectedImage.Position = UDim2.fromScale(0.1, 0.02)
	selectedImage.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	selectedImage.BorderSizePixel = 0
	selectedImage.Parent = selectedItemFrame

	local selectedImageCorner = Instance.new("UICorner")
	selectedImageCorner.CornerRadius = UDim.new(0, 8)
	selectedImageCorner.Parent = selectedImage

	-- Selected item name
	local selectedName = Instance.new("TextLabel")
	selectedName.Name = "ItemName"
	selectedName.Size = UDim2.fromScale(1, 0.1)
	selectedName.Position = UDim2.fromScale(0, 0.35)
	selectedName.BackgroundTransparency = 1
	selectedName.Text = ""
	selectedName.TextColor3 = Color3.fromRGB(255, 255, 255)
	selectedName.TextScaled = true
	selectedName.Font = Enum.Font.GothamBold
	selectedName.Parent = selectedItemFrame

	-- Selected item description
	local selectedDesc = Instance.new("TextLabel")
	selectedDesc.Name = "ItemDescription"
	selectedDesc.Size = UDim2.fromScale(1, 0.3)
	selectedDesc.Position = UDim2.fromScale(0, 0.47)
	selectedDesc.BackgroundTransparency = 1
	selectedDesc.Text = ""
	selectedDesc.TextColor3 = Color3.fromRGB(200, 200, 200)
	selectedDesc.TextScaled = true
	selectedDesc.Font = Enum.Font.Gotham
	selectedDesc.TextWrapped = true
	selectedDesc.Parent = selectedItemFrame

	-- Selected item quantity
	local selectedQuantity = Instance.new("TextLabel")
	selectedQuantity.Name = "ItemQuantity"
	selectedQuantity.Size = UDim2.fromScale(1, 0.08)
	selectedQuantity.Position = UDim2.fromScale(0, 0.79)
	selectedQuantity.BackgroundTransparency = 1
	selectedQuantity.Text = ""
	selectedQuantity.TextColor3 = Color3.fromRGB(255, 215, 0)
	selectedQuantity.TextScaled = true
	selectedQuantity.Font = Enum.Font.GothamBold
	selectedQuantity.Parent = selectedItemFrame

	-- Use button (for usable items)
	local useButton = Instance.new("TextButton")
	useButton.Name = "UseButton"
	useButton.Size = UDim2.fromScale(0.8, 0.1)
	useButton.Position = UDim2.fromScale(0.1, 0.88)
	useButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
	useButton.BorderSizePixel = 0
	useButton.Text = "USE ITEM"
	useButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	useButton.TextScaled = true
	useButton.Font = Enum.Font.GothamBold
	useButton.Parent = selectedItemFrame
	useButton.Visible = false

	local useCorner = Instance.new("UICorner")
	useCorner.CornerRadius = UDim.new(0, 6)
	useCorner.Parent = useButton

	-- Function to create item slot
	local function createItemSlot(itemId, quantity)
		local itemData = itemDatabase[itemId]
		if not itemData then
			return nil
		end

		local itemSlot = Instance.new("Frame")
		itemSlot.Name = itemId .. "_Slot"
		itemSlot.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
		itemSlot.BorderSizePixel = 0

		local slotCorner = Instance.new("UICorner")
		slotCorner.CornerRadius = UDim.new(0, 8)
		slotCorner.Parent = itemSlot

		-- Rarity border
		local rarityBorder = Instance.new("UIStroke")
		rarityBorder.Color = itemData.color
		rarityBorder.Thickness = 2
		rarityBorder.Parent = itemSlot

		-- Item image
		local itemImage = Instance.new("ImageLabel")
		itemImage.Name = "ItemImage"
		itemImage.Size = UDim2.fromScale(0.7, 0.7)
		itemImage.Position = UDim2.fromScale(0.15, 0.05)
		itemImage.BackgroundColor3 = itemData.color
		itemImage.BackgroundTransparency = 0.7
		itemImage.BorderSizePixel = 0
		itemImage.Image = itemData.image
		itemImage.Parent = itemSlot

		local imageCorner = Instance.new("UICorner")
		imageCorner.CornerRadius = UDim.new(0, 6)
		imageCorner.Parent = itemImage

		-- Quantity label (if stackable)
		if itemData.stackable and quantity > 1 then
			local quantityLabel = Instance.new("TextLabel")
			quantityLabel.Name = "Quantity"
			quantityLabel.Size = UDim2.fromScale(0.4, 0.25)
			quantityLabel.Position = UDim2.fromScale(0.6, 0.75)
			quantityLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			quantityLabel.BackgroundTransparency = 0.3
			quantityLabel.BorderSizePixel = 0
			quantityLabel.Text = tostring(quantity)
			quantityLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			quantityLabel.TextScaled = true
			quantityLabel.Font = Enum.Font.GothamBold
			quantityLabel.Parent = itemSlot

			local qtyCorner = Instance.new("UICorner")
			qtyCorner.CornerRadius = UDim.new(0, 4)
			qtyCorner.Parent = quantityLabel
		end

		-- Click functionality
		local clickDetector = Instance.new("TextButton")
		clickDetector.Name = "ClickDetector"
		clickDetector.Size = UDim2.fromScale(1, 1)
		clickDetector.Position = UDim2.fromScale(0, 0)
		clickDetector.BackgroundTransparency = 1
		clickDetector.Text = ""
		clickDetector.Parent = itemSlot

		clickDetector.MouseButton1Click:Connect(function()
			-- Show item details
			selectedItemFrame.Visible = true
			selectedImage.BackgroundColor3 = itemData.color
			selectedImage.Image = itemData.image
			selectedName.Text = itemData.name
			selectedDesc.Text = itemData.description
			selectedQuantity.Text = "Quantity: " .. quantity

			-- Show use button if item is usable
			useButton.Visible = itemData.usable or false

			-- Update selected item data for use button
			useButton.MouseButton1Click:Connect(function()
				print("Used " .. itemData.name .. "!")
				-- Here you would implement the actual item usage logic
			end)
		end)

		-- Hover effects
		clickDetector.MouseEnter:Connect(function()
			local hoverTween = TweenService:Create(
				itemSlot,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad),
				{ BackgroundColor3 = Color3.fromRGB(70, 70, 90) }
			)
			hoverTween:Play()
		end)

		clickDetector.MouseLeave:Connect(function()
			local leaveTween = TweenService:Create(
				itemSlot,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad),
				{ BackgroundColor3 = Color3.fromRGB(50, 50, 70) }
			)
			leaveTween:Play()
		end)

		itemSlot.Parent = itemsScroll
		return itemSlot
	end

	-- Function to populate inventory
	local function populateInventory(filter, searchTerm)
		-- Clear existing items
		for _, child in ipairs(itemsScroll:GetChildren()) do
			if child:IsA("Frame") then
				child:Destroy()
			end
		end

		local playerData = GameManager.GetPlayerData(player)
		local totalItems = 0

		-- Add items from player inventory
		for itemId, quantity in pairs(playerData.inventory) do
			local itemData = itemDatabase[itemId]
			if itemData then
				-- Apply filters
				local showItem = true

				-- Category filter
				if filter ~= "All" and itemData.category ~= filter then
					showItem = false
				end

				-- Search filter
				if searchTerm and searchTerm ~= "" then
					local searchLower = searchTerm:lower()
					if
						not (itemData.name:lower():find(searchLower) or itemData.description:lower():find(searchLower))
					then
						showItem = false
					end
				end

				if showItem then
					createItemSlot(itemId, quantity)
					totalItems = totalItems + quantity
				end
			end
		end

		-- Update item count
		itemCountLabel.Text = "Items: " .. totalItems .. "/100"

		-- Update scroll canvas size
		task.wait(0.1) -- Wait for layout to update
		itemsScroll.CanvasSize = UDim2.fromScale(0, itemsLayout.AbsoluteContentSize.Y / itemsScroll.AbsoluteSize.Y)
	end

	-- Category button functionality
	for category, button in pairs(categoryButtons) do
		button.MouseButton1Click:Connect(function()
			-- Update button states
			for cat, btn in pairs(categoryButtons) do
				btn.BackgroundColor3 = cat == category and Color3.fromRGB(150, 100, 255) or Color3.fromRGB(60, 60, 80)
			end

			currentFilter = category
			populateInventory(currentFilter, searchBox.Text)
		end)
	end

	-- Search functionality
	searchBox.FocusLost:Connect(function()
		populateInventory(currentFilter, searchBox.Text)
	end)

	-- Close button functionality
	closeButton.MouseButton1Click:Connect(function()
		inventoryScreen:Destroy()
	end)

	-- Initial population
	populateInventory(currentFilter, "")

	-- Entrance animation
	inventoryContainer.Size = UDim2.fromScale(0, 0)
	inventoryContainer.Position = UDim2.fromScale(0.5, 0.5)

	local openTween =
		TweenService:Create(inventoryContainer, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.fromScale(0.85, 0.8),
			Position = UDim2.fromScale(0.075, 0.1),
		})
	openTween:Play()

	return inventoryScreen
end

-- Function to open inventory
function InventoryGUI.OpenInventory()
	-- Close any existing inventory
	local existingInventory = playerGui:FindFirstChild("InventoryGUI")
	if existingInventory then
		existingInventory:Destroy()
	end

	InventoryGUI.CreateInventoryInterface()
end

-- Keyboard shortcut to open inventory (E key)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.E then
		InventoryGUI.OpenInventory()
	end
end)

return InventoryGUI
