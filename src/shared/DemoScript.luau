--[[
	DemoScript - Comprehensive demonstration of all building and game systems
	
	🎮 HOW TO USE THIS SCRIPT:
	1. Copy this script into ServerScriptService in Roblox Studio
	2. Run the game
	3. Watch as it automatically creates a full demonstration world
	
	This script will create:
	- Various building types
	- Interactive objects
	- Beautiful environments
	- Complete game mechanics demonstration
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- Wait for packages to load
wait(2)

-- Import all modules
local BuildingGenerator = require(ReplicatedStorage.Shared.BuildingGenerator)
local InteractiveObjects = require(ReplicatedStorage.Shared.InteractiveObjects)
local EnvironmentGenerator = require(ReplicatedStorage.Shared.EnvironmentGenerator)

print("🎬 Starting Comprehensive Building Demo...")

-- Demo area positions
local DEMO_AREAS = {
	center = Vector3.new(0, 10, 0),
	residential = Vector3.new(100, 10, 0),
	commercial = Vector3.new(200, 10, 0),
	castle = Vector3.new(300, 10, 0),
	nature = Vector3.new(-100, 10, 0),
	interactive = Vector3.new(0, 10, 100),
	entertainment = Vector3.new(100, 10, 100),
}

-- Function to create informational signs
local function createSign(position, text, title)
	local sign = Instance.new("Part")
	sign.Name = "InfoSign"
	sign.Size = Vector3.new(8, 6, 1)
	sign.Position = position + Vector3.new(0, 3, 0)
	sign.Material = Enum.Material.Wood
	sign.Color = Color3.fromRGB(139, 69, 19)
	sign.Anchored = true
	sign.Parent = Workspace

	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.Parent = sign

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.fromScale(1, 0.3)
	titleLabel.Position = UDim2.fromScale(0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title or "INFO"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextScaled = true
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Parent = gui

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(1, 0.7)
	textLabel.Position = UDim2.fromScale(0, 0.3)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.Gotham
	textLabel.TextWrapped = true
	textLabel.Parent = gui

	return sign
end

-- 1. RESIDENTIAL AREA - Different house types
print("🏠 Creating Residential Area...")

local residentialHouses = {
	{ pos = DEMO_AREAS.residential + Vector3.new(-30, 0, -20), type = "House", style = "House" },
	{ pos = DEMO_AREAS.residential + Vector3.new(0, 0, -20), type = "House", style = "Modern" },
	{ pos = DEMO_AREAS.residential + Vector3.new(30, 0, -20), type = "House", style = "Castle" },
	{ pos = DEMO_AREAS.residential + Vector3.new(-15, 0, 20), type = "Tower", floors = 4, style = "Modern" },
	{ pos = DEMO_AREAS.residential + Vector3.new(15, 0, 20), type = "Tower", floors = 6, style = "Castle" },
}

for _, house in ipairs(residentialHouses) do
	if house.type == "House" then
		BuildingGenerator.CreateHouse(house.pos, house.style)
	elseif house.type == "Tower" then
		BuildingGenerator.CreateTower(house.pos, house.floors, house.style)
	end
end

createSign(
	DEMO_AREAS.residential + Vector3.new(0, 0, -40),
	"Welcome to Residential District!\n\nFeaturing different house styles:\n• Traditional Houses\n• Modern Houses\n• Castle-style Houses\n• Residential Towers",
	"🏠 RESIDENTIAL AREA"
)

-- 2. COMMERCIAL AREA - Skyscrapers and office buildings
print("🏢 Creating Commercial Area...")

for i = 1, 5 do
	local pos = DEMO_AREAS.commercial + Vector3.new((i - 3) * 30, 0, -20)
	local floors = math.random(8, 15)
	BuildingGenerator.CreateSkyscraper(pos, floors)
end

-- Add a shopping center
BuildingGenerator.CreateHouse(DEMO_AREAS.commercial + Vector3.new(0, 0, 20), "Modern")

createSign(
	DEMO_AREAS.commercial + Vector3.new(0, 0, -50),
	"Downtown Commercial District\n\nModern skyscrapers and\nbusiness buildings.\n\nEach building is randomly\ngenerated with different\nheights and window patterns.",
	"🏢 COMMERCIAL DISTRICT"
)

-- 3. CASTLE AREA - Medieval structures
print("🏰 Creating Castle Area...")

BuildingGenerator.CreateCastle(DEMO_AREAS.castle)

-- Add additional medieval structures
BuildingGenerator.CreateTower(DEMO_AREAS.castle + Vector3.new(-60, 0, 0), 8, "Castle")
BuildingGenerator.CreateTower(DEMO_AREAS.castle + Vector3.new(60, 0, 0), 8, "Castle")

createSign(
	DEMO_AREAS.castle + Vector3.new(0, 0, -80),
	"Medieval Castle Complex\n\nComplete with:\n• Main Keep\n• Corner Towers\n• Defensive Walls\n• Guard Towers\n\nFit for a king!",
	"🏰 CASTLE COMPLEX"
)

-- 4. NATURE AREA - Beautiful environment
print("🌲 Creating Nature Area...")

-- Create a mixed forest
EnvironmentGenerator.CreateForest(DEMO_AREAS.nature, 60, 25, "mixed")

-- Add a lake
EnvironmentGenerator.CreateWater(DEMO_AREAS.nature + Vector3.new(80, 0, 0), 25, 3)

-- Add mountains in the background
EnvironmentGenerator.CreateMountain(DEMO_AREAS.nature + Vector3.new(-80, 0, -80), 4, 120)

-- Create a beautiful garden
EnvironmentGenerator.CreateGarden(DEMO_AREAS.nature + Vector3.new(0, 0, 80), 25)

-- Add scattered natural elements
for _ = 1, 20 do
	local randomPos = DEMO_AREAS.nature + Vector3.new(math.random(-100, 100), 0, math.random(-60, 60))
	EnvironmentGenerator.CreateRock(randomPos, "boulder", math.random(50, 150) / 100)
end

createSign(
	DEMO_AREAS.nature + Vector3.new(0, 0, -80),
	"Natural Environment Showcase\n\n• Mixed Forest (Oak & Pine)\n• Crystal Clear Lake\n• Mountain Range\n• Flower Garden\n• Boulder Fields",
	"🌲 NATURE PRESERVE"
)

-- 5. INTERACTIVE AREA - All interactive objects
print("🎮 Creating Interactive Area...")

local interactivePos = DEMO_AREAS.interactive

-- Create various interactive objects in a grid
local objects = {
	{
		type = "Button",
		pos = Vector3.new(-30, 0, -20),
		text = "Money Button",
		callback = function(p)
			print(p.Name .. " got money!")
		end,
	},
	{
		type = "Button",
		pos = Vector3.new(-10, 0, -20),
		text = "XP Button",
		callback = function(p)
			print(p.Name .. " got XP!")
		end,
	},
	{
		type = "Button",
		pos = Vector3.new(10, 0, -20),
		text = "Items Button",
		callback = function(p)
			print(p.Name .. " got items!")
		end,
	},
	{
		type = "Button",
		pos = Vector3.new(30, 0, -20),
		text = "Level Up",
		callback = function(p)
			print(p.Name .. " leveled up!")
		end,
	},

	{ type = "Door", pos = Vector3.new(-30, 0, 0), doorType = "swing" },
	{ type = "Door", pos = Vector3.new(-10, 0, 0), doorType = "slide" },

	{ type = "Furniture", pos = Vector3.new(10, 0, 0), furnitureType = "table" },
	{ type = "Furniture", pos = Vector3.new(30, 0, 0), furnitureType = "chair" },
	{ type = "Furniture", pos = Vector3.new(50, 0, 0), furnitureType = "lamp" },

	{ type = "Elevator", pos = Vector3.new(-20, 0, 20), floors = 5 },
	{ type = "TreasureChest", pos = Vector3.new(0, 0, 20), rewards = { "Gold", "Gems", "Scroll" } },
	{ type = "TreasureChest", pos = Vector3.new(20, 0, 20), rewards = { "Silver", "Blueprint", "Key" } },
}

for _, obj in ipairs(objects) do
	local pos = interactivePos + obj.pos

	if obj.type == "Button" then
		InteractiveObjects.CreateButton(pos, Vector3.new(4, 1, 2), obj.text, obj.callback)
	elseif obj.type == "Door" then
		InteractiveObjects.CreateDoor(pos, obj.doorType)
	elseif obj.type == "Furniture" then
		InteractiveObjects.CreateFurniture(obj.furnitureType, pos)
	elseif obj.type == "Elevator" then
		InteractiveObjects.CreateElevator(pos, obj.floors)
	elseif obj.type == "TreasureChest" then
		InteractiveObjects.CreateTreasureChest(pos, obj.rewards)
	end
end

createSign(
	DEMO_AREAS.interactive + Vector3.new(0, 0, -40),
	"Interactive Objects Demo\n\n• Clickable Buttons\n• Animated Doors\n• Furniture Pieces\n• Working Elevator\n• Treasure Chests\n\nClick everything!",
	"🎮 INTERACTIVE ZONE"
)

-- 6. ENTERTAINMENT AREA - Fun structures
print("🎡 Creating Entertainment Area...")

local entertainmentPos = DEMO_AREAS.entertainment

-- Create a theme park-like area
BuildingGenerator.CreateTower(entertainmentPos + Vector3.new(-40, 0, 0), 12, "Modern") -- Observation tower
BuildingGenerator.CreateHouse(entertainmentPos + Vector3.new(0, 0, -30), "Modern") -- Visitor center
BuildingGenerator.CreateHouse(entertainmentPos + Vector3.new(40, 0, 0), "House") -- Gift shop

-- Add some entertainment structures
InteractiveObjects.CreateElevator(entertainmentPos + Vector3.new(-40, 0, -20), 8) -- Tower elevator
InteractiveObjects.CreateTreasureChest(entertainmentPos + Vector3.new(0, 0, 0), { "Tickets", "Prizes", "Souvenirs" })

-- Create paths connecting areas
print("🛤️ Creating Connecting Paths...")

EnvironmentGenerator.CreatePath(DEMO_AREAS.center, DEMO_AREAS.residential, 6, "stone")
EnvironmentGenerator.CreatePath(DEMO_AREAS.residential, DEMO_AREAS.commercial, 6, "stone")
EnvironmentGenerator.CreatePath(DEMO_AREAS.commercial, DEMO_AREAS.castle, 6, "stone")
EnvironmentGenerator.CreatePath(DEMO_AREAS.center, DEMO_AREAS.nature, 6, "dirt")
EnvironmentGenerator.CreatePath(DEMO_AREAS.center, DEMO_AREAS.interactive, 6, "brick")
EnvironmentGenerator.CreatePath(DEMO_AREAS.interactive, DEMO_AREAS.entertainment, 6, "brick")

-- Central hub with main information
print("📍 Creating Central Hub...")

-- Central information kiosk
BuildingGenerator.CreateTower(DEMO_AREAS.center, 3, "Modern")

createSign(
	DEMO_AREAS.center + Vector3.new(0, 0, -15),
	"🎮 BUILDING DEMO WORLD 🎮\n\nExplore different areas:\n⬆️ Interactive Zone\n➡️ Residential → Commercial → Castle\n⬅️ Nature Preserve\n\nUse WASD to move around!\nEach area showcases different\nbuilding and game systems.",
	"🏠 DEMO WORLD HUB"
)

-- Add some decorative elements around the hub
local flowerTypes = { "rose", "daisy", "sunflower" }
for i = 1, 8 do
	local angle = (i - 1) * (2 * math.pi / 8)
	local pos = DEMO_AREAS.center + Vector3.new(math.cos(angle) * 20, 0, math.sin(angle) * 20)
	local flowerType = flowerTypes[((i - 1) % 3) + 1]
	EnvironmentGenerator.CreateFlower(pos, flowerType)
end

-- Final setup message
print("✅ Demo World Creation Complete!")
print("🎮 Welcome to the Building Demo World!")
print("📍 Areas created:")
print("   🏠 Residential District - Different house styles")
print("   🏢 Commercial District - Modern skyscrapers")
print("   🏰 Castle Complex - Medieval fortress")
print("   🌲 Nature Preserve - Beautiful environment")
print("   🎮 Interactive Zone - Clickable objects")
print("   🎡 Entertainment Area - Fun structures")
print("")
print("🎯 Start exploring by walking around!")
print("🔗 All areas are connected by stone, dirt, or brick paths")
print("📚 Read the information signs in each area to learn more")
print("")
print("💡 Press H, T, S, C, I, E in the game to build more structures!")

-- Create a welcome message for players
wait(3)
local welcomeMessage = Instance.new("Message")
welcomeMessage.Text = "🎮 Welcome to the Building Demo World! Explore all areas and try the interactive objects!"
welcomeMessage.Parent = Workspace

game:GetService("Debris"):AddItem(welcomeMessage, 8)

-- Set up a guide for new players
spawn(function()
	while true do
		wait(60) -- Every minute

		local hint = Instance.new("Hint")
		hint.Text = "💡 Tip: Use your keyboard controls (H, T, S, C, I, E) to build new structures anywhere!"
		hint.Parent = Workspace

		game:GetService("Debris"):AddItem(hint, 10)
	end
end)
