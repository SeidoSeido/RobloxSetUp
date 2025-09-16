--[[
	BuildingGenerator - A comprehensive system for generating buildings procedurally
	Features: Houses, towers, castles, modern buildings, and more
]]

local BuildingGenerator = {}

-- Materials and colors for different building types
local BuildingMaterials = {
	House = {
		Wall = { Material = Enum.Material.Brick, Color = Color3.fromRGB(139, 69, 19) },
		Roof = { Material = Enum.Material.Slate, Color = Color3.fromRGB(105, 105, 105) },
		Door = { Material = Enum.Material.Wood, Color = Color3.fromRGB(101, 67, 33) },
		Window = { Material = Enum.Material.Glass, Color = Color3.fromRGB(173, 216, 230) },
	},
	Modern = {
		Wall = { Material = Enum.Material.SmoothPlastic, Color = Color3.fromRGB(220, 220, 220) },
		Roof = { Material = Enum.Material.Metal, Color = Color3.fromRGB(70, 70, 70) },
		Door = { Material = Enum.Material.Metal, Color = Color3.fromRGB(50, 50, 50) },
		Window = { Material = Enum.Material.ForceField, Color = Color3.fromRGB(0, 150, 255) },
	},
	Castle = {
		Wall = { Material = Enum.Material.Cobblestone, Color = Color3.fromRGB(128, 128, 128) },
		Roof = { Material = Enum.Material.Slate, Color = Color3.fromRGB(47, 79, 79) },
		Door = { Material = Enum.Material.Wood, Color = Color3.fromRGB(139, 69, 19) },
		Window = { Material = Enum.Material.Glass, Color = Color3.fromRGB(255, 215, 0) },
	},
}

-- Create a basic part with specified properties
local function createPart(name, size, position, material, color, parent)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Material = material
	part.Color = color
	part.Anchored = true
	part.Parent = parent or workspace
	return part
end

-- Create a window with frame
local function createWindow(position, size, materials, parent)
	local windowFrame = createPart("WindowFrame", size, position, materials.Wall.Material, materials.Wall.Color, parent)

	local glass = createPart(
		"Glass",
		Vector3.new(size.X * 0.8, size.Y * 0.8, 0.1),
		position,
		materials.Window.Material,
		materials.Window.Color,
		parent
	)

	return { frame = windowFrame, glass = glass }
end

-- Create a door with frame
local function createDoor(position, materials, parent)
	local doorFrame =
		createPart("DoorFrame", Vector3.new(4, 8, 1), position, materials.Wall.Material, materials.Wall.Color, parent)

	local door =
		createPart("Door", Vector3.new(3.5, 7.5, 0.2), position, materials.Door.Material, materials.Door.Color, parent)

	-- Add door handle
	local handle = createPart(
		"DoorHandle",
		Vector3.new(0.2, 0.2, 0.5),
		position + Vector3.new(1.5, 0, 0.3),
		Enum.Material.Metal,
		Color3.fromRGB(255, 215, 0),
		parent
	)

	return { frame = doorFrame, door = door, handle = handle }
end

-- Generate a simple house
function BuildingGenerator.CreateHouse(position, buildingType)
	buildingType = buildingType or "House"
	local materials = BuildingMaterials[buildingType]

	local house = Instance.new("Model")
	house.Name = buildingType .. "House"
	house.Parent = workspace

	-- House dimensions
	local width, height, depth = 20, 12, 16

	-- Create foundation
	createPart(
		"Foundation",
		Vector3.new(width + 2, 1, depth + 2),
		position + Vector3.new(0, -0.5, 0),
		Enum.Material.Concrete,
		Color3.fromRGB(105, 105, 105),
		house
	)

	-- Create walls
	local wallThickness = 1

	-- Front wall (with door)
	createPart(
		"FrontWall1",
		Vector3.new(8, height, wallThickness),
		position + Vector3.new(-6, height / 2, depth / 2),
		materials.Wall.Material,
		materials.Wall.Color,
		house
	)

	createPart(
		"FrontWall2",
		Vector3.new(8, height, wallThickness),
		position + Vector3.new(6, height / 2, depth / 2),
		materials.Wall.Material,
		materials.Wall.Color,
		house
	)

	-- Back wall (with windows)
	createPart(
		"BackWall",
		Vector3.new(width, height, wallThickness),
		position + Vector3.new(0, height / 2, -depth / 2),
		materials.Wall.Material,
		materials.Wall.Color,
		house
	)

	-- Side walls
	createPart(
		"LeftWall",
		Vector3.new(wallThickness, height, depth),
		position + Vector3.new(-width / 2, height / 2, 0),
		materials.Wall.Material,
		materials.Wall.Color,
		house
	)

	createPart(
		"RightWall",
		Vector3.new(wallThickness, height, depth),
		position + Vector3.new(width / 2, height / 2, 0),
		materials.Wall.Material,
		materials.Wall.Color,
		house
	)

	-- Create roof
	createPart(
		"Roof",
		Vector3.new(width + 4, 2, depth + 4),
		position + Vector3.new(0, height + 1, 0),
		materials.Roof.Material,
		materials.Roof.Color,
		house
	)

	-- Add door
	createDoor(position + Vector3.new(0, 4, depth / 2), materials, house)

	-- Add windows
	createWindow(position + Vector3.new(-6, 6, -depth / 2), Vector3.new(3, 3, 0.5), materials, house)
	createWindow(position + Vector3.new(6, 6, -depth / 2), Vector3.new(3, 3, 0.5), materials, house)
	createWindow(position + Vector3.new(-width / 2, 6, 0), Vector3.new(0.5, 3, 3), materials, house)
	createWindow(position + Vector3.new(width / 2, 6, 0), Vector3.new(0.5, 3, 3), materials, house)

	return house
end

-- Generate a tower
function BuildingGenerator.CreateTower(position, floors, buildingType)
	floors = floors or 5
	buildingType = buildingType or "Castle"
	local materials = BuildingMaterials[buildingType]

	local tower = Instance.new("Model")
	tower.Name = buildingType .. "Tower"
	tower.Parent = workspace

	local radius = 8
	local floorHeight = 6

	for floor = 1, floors do
		local floorY = position.Y + (floor - 1) * floorHeight + floorHeight / 2

		-- Create floor platform
		createPart(
			"Floor" .. floor,
			Vector3.new(radius * 2, 1, radius * 2),
			Vector3.new(position.X, floorY - floorHeight / 2 + 0.5, position.Z),
			Enum.Material.Wood,
			Color3.fromRGB(139, 69, 19),
			tower
		)

		-- Create circular walls
		local segments = 8
		for i = 1, segments do
			local angle = (i - 1) * (2 * math.pi / segments)
			local x = position.X + radius * math.cos(angle)
			local z = position.Z + radius * math.sin(angle)

			local wall = createPart(
				"Wall" .. floor .. "_" .. i,
				Vector3.new(3, floorHeight - 1, 1),
				Vector3.new(x, floorY, z),
				materials.Wall.Material,
				materials.Wall.Color,
				tower
			)
			wall.CFrame = CFrame.lookAt(Vector3.new(x, floorY, z), position)

			-- Add windows on upper floors
			if floor > 1 and i % 2 == 0 then
				local windowPos = Vector3.new(x, floorY, z) + (position - Vector3.new(x, floorY, z)).Unit * -0.5
				createWindow(windowPos, Vector3.new(0.5, 2, 2), materials, tower)
			end
		end
	end

	-- Create roof
	local roofHeight = 4
	createPart(
		"Roof",
		Vector3.new(radius * 2 + 2, roofHeight, radius * 2 + 2),
		Vector3.new(position.X, position.Y + floors * floorHeight + roofHeight / 2, position.Z),
		materials.Roof.Material,
		materials.Roof.Color,
		tower
	)

	-- Add door on ground floor
	createDoor(Vector3.new(position.X + radius, position.Y + floorHeight / 2, position.Z), materials, tower)

	return tower
end

-- Generate a modern skyscraper
function BuildingGenerator.CreateSkyscraper(position, floors)
	floors = floors or 10
	local materials = BuildingMaterials.Modern

	local building = Instance.new("Model")
	building.Name = "Skyscraper"
	building.Parent = workspace

	local width, depth = 20, 15
	local floorHeight = 4

	for floor = 1, floors do
		local floorY = position.Y + (floor - 1) * floorHeight + floorHeight / 2

		-- Create floor
		createPart(
			"Floor" .. floor,
			Vector3.new(width, 0.5, depth),
			Vector3.new(position.X, floorY - floorHeight / 2 + 0.25, position.Z),
			Enum.Material.Metal,
			Color3.fromRGB(200, 200, 200),
			building
		)

		-- Create walls with windows
		local wallPositions = {
			{ Vector3.new(position.X, floorY, position.Z + depth / 2), Vector3.new(width, floorHeight, 1) }, -- Front
			{ Vector3.new(position.X, floorY, position.Z - depth / 2), Vector3.new(width, floorHeight, 1) }, -- Back
			{ Vector3.new(position.X + width / 2, floorY, position.Z), Vector3.new(1, floorHeight, depth) }, -- Right
			{ Vector3.new(position.X - width / 2, floorY, position.Z), Vector3.new(1, floorHeight, depth) }, -- Left
		}

		for i, wallData in ipairs(wallPositions) do
			createPart(
				"Wall" .. floor .. "_" .. i,
				wallData[2],
				wallData[1],
				materials.Wall.Material,
				materials.Wall.Color,
				building
			)

			-- Add windows
			local windowCount = math.floor(wallData[2].X > wallData[2].Z and wallData[2].X / 4 or wallData[2].Z / 4)
			for w = 1, windowCount do
				local windowOffset = (w - windowCount / 2 - 0.5) * 4
				local windowPos = wallData[1]
					+ (
						wallData[2].X > wallData[2].Z and Vector3.new(windowOffset, 0, 0)
						or Vector3.new(0, 0, windowOffset)
					)
				createWindow(windowPos, Vector3.new(2, 2, 0.5), materials, building)
			end
		end
	end

	-- Add entrance
	createDoor(Vector3.new(position.X, position.Y + floorHeight / 2, position.Z + depth / 2), materials, building)

	return building
end

-- Generate a castle complex
function BuildingGenerator.CreateCastle(position)
	local materials = BuildingMaterials.Castle

	local castle = Instance.new("Model")
	castle.Name = "Castle"
	castle.Parent = workspace

	-- Main keep (central tower)
	local keep = BuildingGenerator.CreateTower(position, 6, "Castle")
	keep.Parent = castle

	-- Corner towers
	local corners = {
		Vector3.new(position.X + 30, position.Y, position.Z + 30),
		Vector3.new(position.X - 30, position.Y, position.Z + 30),
		Vector3.new(position.X + 30, position.Y, position.Z - 30),
		Vector3.new(position.X - 30, position.Y, position.Z - 30),
	}

	for _, cornerPos in ipairs(corners) do
		local tower = BuildingGenerator.CreateTower(cornerPos, 4, "Castle")
		tower.Parent = castle
	end

	-- Castle walls
	local wallHeight = 15
	local wallThickness = 2

	-- Create perimeter walls
	local wallSegments = {
		{
			Vector3.new(position.X, position.Y + wallHeight / 2, position.Z + 30),
			Vector3.new(60, wallHeight, wallThickness),
		},
		{
			Vector3.new(position.X, position.Y + wallHeight / 2, position.Z - 30),
			Vector3.new(60, wallHeight, wallThickness),
		},
		{
			Vector3.new(position.X + 30, position.Y + wallHeight / 2, position.Z),
			Vector3.new(wallThickness, wallHeight, 60),
		},
		{
			Vector3.new(position.X - 30, position.Y + wallHeight / 2, position.Z),
			Vector3.new(wallThickness, wallHeight, 60),
		},
	}

	for i, wallData in ipairs(wallSegments) do
		createPart("CastleWall" .. i, wallData[2], wallData[1], materials.Wall.Material, materials.Wall.Color, castle)
	end

	-- Add main gate
	createDoor(Vector3.new(position.X, position.Y + 8, position.Z + 30), materials, castle)

	return castle
end

return BuildingGenerator
