--[[
	EnvironmentGenerator - Creates natural environments, landscapes, and decorations
	Features: Trees, rocks, flowers, paths, water bodies, and terrain generation
]]

local EnvironmentGenerator = {}

-- Create a tree with configurable size and type
function EnvironmentGenerator.CreateTree(position, treeType, scale)
	treeType = treeType or "oak"
	scale = scale or 1

	local tree = Instance.new("Model")
	tree.Name = treeType:gsub("^%l", string.upper) .. "Tree"
	tree.Parent = workspace

	-- Tree trunk
	local trunk = Instance.new("Part")
	trunk.Name = "Trunk"
	trunk.Shape = Enum.PartType.Cylinder
	trunk.Size = Vector3.new(2 * scale, 8 * scale, 2 * scale)
	trunk.Position = position + Vector3.new(0, 4 * scale, 0)
	trunk.Material = Enum.Material.Wood
	trunk.Color = Color3.fromRGB(101, 67, 33)
	trunk.Anchored = true
	trunk.Parent = tree

	-- Tree leaves/foliage
	local foliage = Instance.new("Part")
	foliage.Name = "Foliage"
	foliage.Shape = Enum.PartType.Ball

	if treeType == "oak" then
		foliage.Size = Vector3.new(12 * scale, 10 * scale, 12 * scale)
		foliage.Position = position + Vector3.new(0, 12 * scale, 0)
		foliage.Color = Color3.fromRGB(34, 139, 34)
	elseif treeType == "pine" then
		foliage.Shape = Enum.PartType.Block
		foliage.Size = Vector3.new(6 * scale, 12 * scale, 6 * scale)
		foliage.Position = position + Vector3.new(0, 14 * scale, 0)
		foliage.Color = Color3.fromRGB(0, 100, 0)
	elseif treeType == "palm" then
		foliage.Size = Vector3.new(8 * scale, 4 * scale, 8 * scale)
		foliage.Position = position + Vector3.new(0, 10 * scale, 0)
		foliage.Color = Color3.fromRGB(124, 252, 0)
	end

	foliage.Material = Enum.Material.Grass
	foliage.Anchored = true
	foliage.Parent = tree

	-- Add branches for oak trees
	if treeType == "oak" then
		for i = 1, 4 do
			local branch = Instance.new("Part")
			branch.Name = "Branch" .. i
			branch.Shape = Enum.PartType.Cylinder
			branch.Size = Vector3.new(1 * scale, 4 * scale, 1 * scale)

			local angle = (i - 1) * (math.pi / 2)
			local branchOffset = Vector3.new(math.cos(angle) * 3 * scale, 2 * scale, math.sin(angle) * 3 * scale)

			branch.Position = position + Vector3.new(0, 8 * scale, 0) + branchOffset
			branch.CFrame = CFrame.lookAt(branch.Position, branch.Position + branchOffset)
			branch.Material = Enum.Material.Wood
			branch.Color = Color3.fromRGB(101, 67, 33)
			branch.Anchored = true
			branch.Parent = tree
		end
	end

	return tree
end

-- Create a rock formation
function EnvironmentGenerator.CreateRock(position, rockType, scale)
	rockType = rockType or "boulder"
	scale = scale or 1

	local rock = Instance.new("Part")
	rock.Name = rockType:gsub("^%l", string.upper)
	rock.Material = Enum.Material.Rock
	rock.Color = Color3.fromRGB(105, 105, 105)
	rock.Anchored = true
	rock.Parent = workspace

	if rockType == "boulder" then
		rock.Shape = Enum.PartType.Ball
		rock.Size = Vector3.new(6 * scale, 4 * scale, 5 * scale)
	elseif rockType == "cliff" then
		rock.Shape = Enum.PartType.Block
		rock.Size = Vector3.new(20 * scale, 15 * scale, 8 * scale)
	elseif rockType == "pebble" then
		rock.Shape = Enum.PartType.Ball
		rock.Size = Vector3.new(1 * scale, 0.8 * scale, 1 * scale)
	end

	rock.Position = position + Vector3.new(0, rock.Size.Y / 2, 0)

	-- Add some randomness to rotation
	rock.CFrame = rock.CFrame
		* CFrame.Angles(math.rad(math.random(-15, 15)), math.rad(math.random(0, 360)), math.rad(math.random(-15, 15)))

	return rock
end

-- Create flowers and grass
function EnvironmentGenerator.CreateFlower(position, flowerType)
	flowerType = flowerType or "daisy"

	local flower = Instance.new("Model")
	flower.Name = flowerType:gsub("^%l", string.upper)
	flower.Parent = workspace

	-- Flower stem
	local stem = Instance.new("Part")
	stem.Name = "Stem"
	stem.Shape = Enum.PartType.Cylinder
	stem.Size = Vector3.new(0.1, 2, 0.1)
	stem.Position = position + Vector3.new(0, 1, 0)
	stem.Material = Enum.Material.Grass
	stem.Color = Color3.fromRGB(34, 139, 34)
	stem.Anchored = true
	stem.Parent = flower

	-- Flower petals
	local petals = Instance.new("Part")
	petals.Name = "Petals"
	petals.Shape = Enum.PartType.Ball
	petals.Size = Vector3.new(1, 0.5, 1)
	petals.Position = position + Vector3.new(0, 2.25, 0)
	petals.Material = Enum.Material.Neon
	petals.Anchored = true
	petals.Parent = flower

	if flowerType == "daisy" then
		petals.Color = Color3.fromRGB(255, 255, 255)
	elseif flowerType == "rose" then
		petals.Color = Color3.fromRGB(255, 0, 0)
	elseif flowerType == "sunflower" then
		petals.Color = Color3.fromRGB(255, 255, 0)
		petals.Size = Vector3.new(2, 0.5, 2)
	elseif flowerType == "lavender" then
		petals.Color = Color3.fromRGB(147, 112, 219)
	end

	-- Flower center
	local center = Instance.new("Part")
	center.Name = "Center"
	center.Shape = Enum.PartType.Ball
	center.Size = Vector3.new(0.3, 0.3, 0.3)
	center.Position = petals.Position
	center.Material = Enum.Material.Neon
	center.Color = Color3.fromRGB(255, 255, 0)
	center.Anchored = true
	center.Parent = flower

	return flower
end

-- Create a water body
function EnvironmentGenerator.CreateWater(centerPosition, radius, depth)
	radius = radius or 20
	depth = depth or 3

	local water = Instance.new("Part")
	water.Name = "Water"
	water.Size = Vector3.new(radius * 2, depth, radius * 2)
	water.Position = centerPosition - Vector3.new(0, depth / 2, 0)
	water.Material = Enum.Material.Water
	water.Color = Color3.fromRGB(0, 162, 255)
	water.Transparency = 0.3
	water.Anchored = true
	water.CanCollide = false
	water.Parent = workspace

	-- Add some ripple effect with multiple transparent parts
	for i = 1, 3 do
		local ripple = Instance.new("Part")
		ripple.Name = "Ripple" .. i
		ripple.Size = Vector3.new((radius + i * 2) * 2, 0.1, (radius + i * 2) * 2)
		ripple.Position = centerPosition + Vector3.new(0, 0.1 * i, 0)
		ripple.Material = Enum.Material.ForceField
		ripple.Color = Color3.fromRGB(0, 162, 255)
		ripple.Transparency = 0.7 + (i * 0.1)
		ripple.Anchored = true
		ripple.CanCollide = false
		ripple.Parent = workspace
	end

	return water
end

-- Create a path between two points
function EnvironmentGenerator.CreatePath(startPos, endPos, width, pathType)
	width = width or 4
	pathType = pathType or "stone"

	local path = Instance.new("Model")
	path.Name = pathType:gsub("^%l", string.upper) .. "Path"
	path.Parent = workspace

	local distance = (endPos - startPos).Magnitude
	local segments = math.ceil(distance / 4)

	for i = 1, segments do
		local progress = (i - 1) / (segments - 1)
		local segmentPos = startPos:Lerp(endPos, progress)

		local segment = Instance.new("Part")
		segment.Name = "PathSegment" .. i
		segment.Size = Vector3.new(width, 0.2, 4)
		segment.Position = segmentPos + Vector3.new(0, 0.1, 0)
		segment.Anchored = true
		segment.Parent = path

		if pathType == "stone" then
			segment.Material = Enum.Material.Cobblestone
			segment.Color = Color3.fromRGB(105, 105, 105)
		elseif pathType == "dirt" then
			segment.Material = Enum.Material.Ground
			segment.Color = Color3.fromRGB(139, 69, 19)
		elseif pathType == "brick" then
			segment.Material = Enum.Material.Brick
			segment.Color = Color3.fromRGB(178, 34, 34)
		end

		-- Orient segment towards the path direction
		if i < segments then
			local nextPos = startPos:Lerp(endPos, i / (segments - 1))
			segment.CFrame = CFrame.lookAt(segmentPos, nextPos)
		end
	end

	return path
end

-- Generate a forest area
function EnvironmentGenerator.CreateForest(centerPosition, radius, treeCount, forestType)
	radius = radius or 50
	treeCount = treeCount or 20
	forestType = forestType or "mixed"

	local forest = Instance.new("Model")
	forest.Name = forestType:gsub("^%l", string.upper) .. "Forest"
	forest.Parent = workspace

	local treeTypes = { "oak", "pine" }
	if forestType == "tropical" then
		treeTypes = { "palm", "oak" }
	elseif forestType == "pine" then
		treeTypes = { "pine" }
	elseif forestType == "oak" then
		treeTypes = { "oak" }
	end

	for _ = 1, treeCount do
		-- Random position within radius
		local angle = math.random() * 2 * math.pi
		local distance = math.random() * radius
		local treePos = centerPosition + Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)

		-- Random tree type and scale
		local treeType = treeTypes[math.random(1, #treeTypes)]
		local scale = math.random(80, 120) / 100

		local tree = EnvironmentGenerator.CreateTree(treePos, treeType, scale)
		tree.Parent = forest

		-- Add some undergrowth
		if math.random() < 0.3 then
			local flowerTypes = { "daisy", "lavender" }
			local flowerType = flowerTypes[math.random(1, #flowerTypes)]
			local flowerPos = treePos + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5))
			local flower = EnvironmentGenerator.CreateFlower(flowerPos, flowerType)
			flower.Parent = forest
		end

		-- Add rocks occasionally
		if math.random() < 0.2 then
			local rockPos = treePos + Vector3.new(math.random(-8, 8), 0, math.random(-8, 8))
			local rock = EnvironmentGenerator.CreateRock(rockPos, "boulder", math.random(50, 100) / 100)
			rock.Parent = forest
		end
	end

	return forest
end

-- Create a mountain range
function EnvironmentGenerator.CreateMountain(position, peakCount, height)
	peakCount = peakCount or 3
	height = height or 100

	local mountain = Instance.new("Model")
	mountain.Name = "Mountain"
	mountain.Parent = workspace

	for i = 1, peakCount do
		local peak = Instance.new("Part")
		peak.Name = "Peak" .. i
		peak.Shape = Enum.PartType.Block

		local peakHeight = height * (0.7 + math.random() * 0.3)
		local peakWidth = 30 + math.random() * 20

		peak.Size = Vector3.new(peakWidth, peakHeight, peakWidth)
		peak.Position = position + Vector3.new((i - (peakCount + 1) / 2) * 25, peakHeight / 2, math.random(-10, 10))
		peak.Material = Enum.Material.Rock
		peak.Color = Color3.fromRGB(105, 105, 105)
		peak.Anchored = true
		peak.Parent = mountain

		-- Add snow cap for tall peaks
		if peakHeight > 80 then
			local snowCap = Instance.new("Part")
			snowCap.Name = "SnowCap" .. i
			snowCap.Shape = Enum.PartType.Block
			snowCap.Size = Vector3.new(peakWidth * 0.8, 10, peakWidth * 0.8)
			snowCap.Position = peak.Position + Vector3.new(0, peakHeight / 2 - 5, 0)
			snowCap.Material = Enum.Material.Snow
			snowCap.Color = Color3.fromRGB(255, 255, 255)
			snowCap.Anchored = true
			snowCap.Parent = mountain
		end
	end

	return mountain
end

-- Create a garden area
function EnvironmentGenerator.CreateGarden(centerPosition, radius)
	radius = radius or 15

	local garden = Instance.new("Model")
	garden.Name = "Garden"
	garden.Parent = workspace

	-- Create flower beds in a pattern
	local flowerTypes = { "rose", "daisy", "sunflower", "lavender" }
	local bedCount = 4

	for bed = 1, bedCount do
		local bedAngle = (bed - 1) * (2 * math.pi / bedCount)
		local bedCenter = centerPosition
			+ Vector3.new(math.cos(bedAngle) * radius * 0.6, 0, math.sin(bedAngle) * radius * 0.6)

		-- Create flower bed border
		local border = Instance.new("Part")
		border.Name = "FlowerBed" .. bed
		border.Size = Vector3.new(8, 0.5, 8)
		border.Position = bedCenter + Vector3.new(0, 0.25, 0)
		border.Material = Enum.Material.Wood
		border.Color = Color3.fromRGB(101, 67, 33)
		border.Anchored = true
		border.Parent = garden

		-- Fill with flowers
		local flowerType = flowerTypes[bed]
		for _ = 1, 12 do
			local flowerPos = bedCenter + Vector3.new(math.random(-3, 3), 0.5, math.random(-3, 3))
			local flower = EnvironmentGenerator.CreateFlower(flowerPos, flowerType)
			flower.Parent = garden
		end
	end

	-- Add central fountain
	local fountain = Instance.new("Part")
	fountain.Name = "Fountain"
	fountain.Shape = Enum.PartType.Cylinder
	fountain.Size = Vector3.new(2, 6, 6)
	fountain.Position = centerPosition + Vector3.new(0, 3, 0)
	fountain.Material = Enum.Material.Marble
	fountain.Color = Color3.fromRGB(255, 255, 255)
	fountain.Anchored = true
	fountain.Parent = garden

	-- Add water to fountain
	local fountainWater = Instance.new("Part")
	fountainWater.Name = "FountainWater"
	fountainWater.Shape = Enum.PartType.Cylinder
	fountainWater.Size = Vector3.new(1.8, 5, 5)
	fountainWater.Position = centerPosition + Vector3.new(0, 2.5, 0)
	fountainWater.Material = Enum.Material.Water
	fountainWater.Color = Color3.fromRGB(0, 162, 255)
	fountainWater.Transparency = 0.3
	fountainWater.Anchored = true
	fountainWater.CanCollide = false
	fountainWater.Parent = garden

	-- Create garden paths
	for i = 1, bedCount do
		local pathAngle = (i - 1) * (2 * math.pi / bedCount)
		local pathEnd = centerPosition + Vector3.new(math.cos(pathAngle) * radius, 0, math.sin(pathAngle) * radius)

		local path = EnvironmentGenerator.CreatePath(centerPosition, pathEnd, 2, "stone")
		path.Parent = garden
	end

	return garden
end

return EnvironmentGenerator
