--[[
	InteractiveObjects - System for creating interactive elements like doors, buttons, furniture
	Features: Clickable objects, animations, sound effects, and state management
]]

local InteractiveObjects = {}
local TweenService = game:GetService("TweenService")

-- Storage for interactive objects
local interactiveObjects = {}

-- Create a clickable button
function InteractiveObjects.CreateButton(position, size, text, onClickCallback)
	local button = Instance.new("Part")
	button.Name = "InteractiveButton"
	button.Size = size or Vector3.new(4, 1, 2)
	button.Position = position
	button.Material = Enum.Material.Neon
	button.Color = Color3.fromRGB(0, 255, 0)
	button.Anchored = true
	button.Parent = workspace

	-- Add text label
	local surfaceGui = Instance.new("SurfaceGui")
	surfaceGui.Face = Enum.NormalId.Top
	surfaceGui.Parent = button

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text or "BUTTON"
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.GothamBold
	textLabel.Parent = surfaceGui

	-- Add click detector
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 50
	clickDetector.Parent = button

	-- Button animation and callback
	clickDetector.MouseClick:Connect(function(player)
		-- Visual feedback
		local originalColor = button.Color
		button.Color = Color3.fromRGB(255, 0, 0)

		local tween = TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Bounce), { Size = size * 0.9 })
		tween:Play()

		tween.Completed:Connect(function()
			local returnTween = TweenService:Create(
				button,
				TweenInfo.new(0.1, Enum.EasingStyle.Bounce),
				{ Size = size, Color = originalColor }
			)
			returnTween:Play()
		end)

		-- Execute callback
		if onClickCallback then
			onClickCallback(player, button)
		end
	end)

	return button
end

-- Create an animated door
function InteractiveObjects.CreateDoor(position, doorType)
	doorType = doorType or "swing" -- "swing" or "slide"

	local doorModel = Instance.new("Model")
	doorModel.Name = "InteractiveDoor"
	doorModel.Parent = workspace

	-- Door frame
	local frame = Instance.new("Part")
	frame.Name = "DoorFrame"
	frame.Size = Vector3.new(6, 10, 1)
	frame.Position = position
	frame.Material = Enum.Material.Wood
	frame.Color = Color3.fromRGB(101, 67, 33)
	frame.Anchored = true
	frame.Parent = doorModel

	-- Door panel
	local door = Instance.new("Part")
	door.Name = "DoorPanel"
	door.Size = Vector3.new(5, 9, 0.2)
	door.Position = position + Vector3.new(0, 0, -0.4)
	door.Material = Enum.Material.Wood
	door.Color = Color3.fromRGB(139, 69, 19)
	door.Parent = doorModel

	-- Door handle
	local handle = Instance.new("Part")
	handle.Name = "DoorHandle"
	handle.Size = Vector3.new(0.3, 0.3, 0.8)
	handle.Position = position + Vector3.new(2, 0, -0.5)
	handle.Material = Enum.Material.Metal
	handle.Color = Color3.fromRGB(255, 215, 0)
	handle.Shape = Enum.PartType.Ball
	handle.Parent = doorModel

	-- Weld handle to door
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = door
	weld.Part1 = handle
	weld.Parent = door

	-- Door state
	local isOpen = false

	-- Click detector
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 20
	clickDetector.Parent = handle

	-- Door animation
	clickDetector.MouseClick:Connect(function(player)
		if doorType == "swing" then
			local targetCFrame
			if not isOpen then
				-- Open door (rotate 90 degrees)
				targetCFrame = door.CFrame * CFrame.Angles(0, math.rad(90), 0)
			else
				-- Close door
				targetCFrame = CFrame.new(position + Vector3.new(0, 0, -0.4))
			end

			local tween = TweenService:Create(
				door,
				TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ CFrame = targetCFrame }
			)
			tween:Play()
		elseif doorType == "slide" then
			local targetPosition
			if not isOpen then
				-- Slide door up
				targetPosition = position + Vector3.new(0, 10, -0.4)
			else
				-- Slide door down
				targetPosition = position + Vector3.new(0, 0, -0.4)
			end

			local tween = TweenService:Create(
				door,
				TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Position = targetPosition }
			)
			tween:Play()
		end

		isOpen = not isOpen
		print(player.Name .. " " .. (isOpen and "opened" or "closed") .. " the door")
	end)

	-- Store door reference
	door.Anchored = true
	interactiveObjects[doorModel] = { type = "door", isOpen = isOpen }

	return doorModel
end

-- Create furniture pieces
function InteractiveObjects.CreateFurniture(furnitureType, position)
	local furniture = Instance.new("Model")
	furniture.Name = furnitureType
	furniture.Parent = workspace

	if furnitureType == "chair" then
		-- Chair seat
		local seat = Instance.new("Part")
		seat.Name = "ChairSeat"
		seat.Size = Vector3.new(4, 1, 4)
		seat.Position = position + Vector3.new(0, 2, 0)
		seat.Material = Enum.Material.Wood
		seat.Color = Color3.fromRGB(139, 69, 19)
		seat.Anchored = true
		seat.Parent = furniture

		-- Chair back
		local back = Instance.new("Part")
		back.Name = "ChairBack"
		back.Size = Vector3.new(4, 6, 0.5)
		back.Position = position + Vector3.new(0, 4.5, 1.75)
		back.Material = Enum.Material.Wood
		back.Color = Color3.fromRGB(139, 69, 19)
		back.Anchored = true
		back.Parent = furniture

		-- Chair legs
		for i = 1, 4 do
			local leg = Instance.new("Part")
			leg.Name = "ChairLeg" .. i
			leg.Size = Vector3.new(0.5, 4, 0.5)
			leg.Position = position + Vector3.new((i <= 2) and -1.5 or 1.5, 1, (i % 2 == 1) and -1.5 or 1.5)
			leg.Material = Enum.Material.Wood
			leg.Color = Color3.fromRGB(101, 67, 33)
			leg.Anchored = true
			leg.Parent = furniture
		end
	elseif furnitureType == "table" then
		-- Table top
		local top = Instance.new("Part")
		top.Name = "TableTop"
		top.Size = Vector3.new(8, 0.5, 6)
		top.Position = position + Vector3.new(0, 4, 0)
		top.Material = Enum.Material.Wood
		top.Color = Color3.fromRGB(139, 69, 19)
		top.Anchored = true
		top.Parent = furniture

		-- Table legs
		for i = 1, 4 do
			local leg = Instance.new("Part")
			leg.Name = "TableLeg" .. i
			leg.Size = Vector3.new(0.8, 8, 0.8)
			leg.Position = position + Vector3.new((i <= 2) and -3.5 or 3.5, 2, (i % 2 == 1) and -2.5 or 2.5)
			leg.Material = Enum.Material.Wood
			leg.Color = Color3.fromRGB(101, 67, 33)
			leg.Anchored = true
			leg.Parent = furniture
		end
	elseif furnitureType == "lamp" then
		-- Lamp base
		local base = Instance.new("Part")
		base.Name = "LampBase"
		base.Size = Vector3.new(2, 1, 2)
		base.Position = position + Vector3.new(0, 0.5, 0)
		base.Material = Enum.Material.Metal
		base.Color = Color3.fromRGB(105, 105, 105)
		base.Anchored = true
		base.Parent = furniture

		-- Lamp pole
		local pole = Instance.new("Part")
		pole.Name = "LampPole"
		pole.Size = Vector3.new(0.3, 8, 0.3)
		pole.Position = position + Vector3.new(0, 5, 0)
		pole.Material = Enum.Material.Metal
		pole.Color = Color3.fromRGB(105, 105, 105)
		pole.Anchored = true
		pole.Parent = furniture

		-- Lamp shade
		local shade = Instance.new("Part")
		shade.Name = "LampShade"
		shade.Size = Vector3.new(4, 3, 4)
		shade.Position = position + Vector3.new(0, 10, 0)
		shade.Material = Enum.Material.Fabric
		shade.Color = Color3.fromRGB(255, 255, 200)
		shade.Shape = Enum.PartType.Cylinder
		shade.Anchored = true
		shade.Parent = furniture

		-- Light source
		local light = Instance.new("PointLight")
		light.Brightness = 2
		light.Color = Color3.fromRGB(255, 255, 200)
		light.Range = 20
		light.Parent = shade

		-- Click to toggle light
		local clickDetector = Instance.new("ClickDetector")
		clickDetector.MaxActivationDistance = 15
		clickDetector.Parent = shade

		clickDetector.MouseClick:Connect(function(player)
			light.Enabled = not light.Enabled
			shade.Material = light.Enabled and Enum.Material.Neon or Enum.Material.Fabric
			print(player.Name .. " turned the lamp " .. (light.Enabled and "on" or "off"))
		end)
	end

	return furniture
end

-- Create an elevator
function InteractiveObjects.CreateElevator(position, floors)
	floors = floors or 3
	local elevator = Instance.new("Model")
	elevator.Name = "Elevator"
	elevator.Parent = workspace

	-- Elevator shaft
	local shaft = Instance.new("Part")
	shaft.Name = "ElevatorShaft"
	shaft.Size = Vector3.new(8, floors * 15, 8)
	shaft.Position = position + Vector3.new(0, floors * 7.5, 0)
	shaft.Material = Enum.Material.Metal
	shaft.Color = Color3.fromRGB(105, 105, 105)
	shaft.Anchored = true
	shaft.Transparency = 0.8
	shaft.Parent = elevator

	-- Elevator car
	local car = Instance.new("Part")
	car.Name = "ElevatorCar"
	car.Size = Vector3.new(6, 1, 6)
	car.Position = position + Vector3.new(0, 1, 0)
	car.Material = Enum.Material.Metal
	car.Color = Color3.fromRGB(200, 200, 200)
	car.Anchored = true
	car.Parent = elevator

	-- Current floor
	local currentFloor = 1

	-- Create floor buttons
	for floor = 1, floors do
		local button = InteractiveObjects.CreateButton(
			position + Vector3.new(5, floor * 15 - 13, 0),
			Vector3.new(2, 1, 1),
			"Floor " .. floor,
			function(player)
				if currentFloor ~= floor then
					print(player.Name .. " called elevator to floor " .. floor)

					local targetY = position.Y + (floor - 1) * 15 + 1
					local tween = TweenService:Create(
						car,
						TweenInfo.new(math.abs(floor - currentFloor) * 2, Enum.EasingStyle.Quad),
						{ Position = Vector3.new(car.Position.X, targetY, car.Position.Z) }
					)

					tween:Play()
					currentFloor = floor
				end
			end
		)
		button.Parent = elevator
	end

	return elevator
end

-- Create a treasure chest
function InteractiveObjects.CreateTreasureChest(position, rewards)
	rewards = rewards or { "Gold Coin", "Magic Gem", "Ancient Scroll" }

	local chest = Instance.new("Model")
	chest.Name = "TreasureChest"
	chest.Parent = workspace

	-- Chest base
	local base = Instance.new("Part")
	base.Name = "ChestBase"
	base.Size = Vector3.new(4, 2, 3)
	base.Position = position
	base.Material = Enum.Material.Wood
	base.Color = Color3.fromRGB(101, 67, 33)
	base.Anchored = true
	base.Parent = chest

	-- Chest lid
	local lid = Instance.new("Part")
	lid.Name = "ChestLid"
	lid.Size = Vector3.new(4, 0.5, 3)
	lid.Position = position + Vector3.new(0, 1.25, 0)
	lid.Material = Enum.Material.Wood
	lid.Color = Color3.fromRGB(101, 67, 33)
	lid.Anchored = true
	lid.Parent = chest

	-- Gold trim
	local trim = Instance.new("Part")
	trim.Name = "ChestTrim"
	trim.Size = Vector3.new(4.2, 0.2, 3.2)
	trim.Position = position + Vector3.new(0, 1.1, 0)
	trim.Material = Enum.Material.Metal
	trim.Color = Color3.fromRGB(255, 215, 0)
	trim.Anchored = true
	trim.Parent = chest

	-- Lock
	local lock = Instance.new("Part")
	lock.Name = "ChestLock"
	lock.Size = Vector3.new(0.8, 0.8, 0.2)
	lock.Position = position + Vector3.new(0, 0.5, 1.6)
	lock.Material = Enum.Material.Metal
	lock.Color = Color3.fromRGB(105, 105, 105)
	lock.Anchored = true
	lock.Parent = chest

	-- Chest state
	local isOpen = false
	local hasBeenOpened = false

	-- Click detector
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 10
	clickDetector.Parent = base

	clickDetector.MouseClick:Connect(function(player)
		if not isOpen then
			-- Open chest
			local openTween = TweenService:Create(
				lid,
				TweenInfo.new(1, Enum.EasingStyle.Quad),
				{ CFrame = lid.CFrame * CFrame.Angles(math.rad(-90), 0, 0) }
			)
			openTween:Play()

			-- Create golden glow
			local glow = Instance.new("PointLight")
			glow.Color = Color3.fromRGB(255, 215, 0)
			glow.Brightness = 3
			glow.Range = 15
			glow.Parent = base

			if not hasBeenOpened then
				-- Spawn rewards
				for i, reward in ipairs(rewards) do
					local rewardPart = Instance.new("Part")
					rewardPart.Name = reward
					rewardPart.Size = Vector3.new(1, 1, 1)
					rewardPart.Position = position + Vector3.new(math.random(-1, 1), 3 + i, math.random(-1, 1))
					rewardPart.Material = Enum.Material.Neon
					rewardPart.Color = Color3.fromRGB(255, 215, 0)
					rewardPart.Shape = Enum.PartType.Ball
					rewardPart.Parent = workspace

					-- Add floating animation
					local float = TweenService:Create(
						rewardPart,
						TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
						{ Position = rewardPart.Position + Vector3.new(0, 2, 0) }
					)
					float:Play()
				end

				hasBeenOpened = true
				print(player.Name .. " discovered treasure: " .. table.concat(rewards, ", "))
			end

			isOpen = true
		else
			-- Close chest
			local closeTween = TweenService:Create(
				lid,
				TweenInfo.new(1, Enum.EasingStyle.Quad),
				{ CFrame = CFrame.new(position + Vector3.new(0, 1.25, 0)) }
			)
			closeTween:Play()

			-- Remove glow
			local glow = base:FindFirstChild("PointLight")
			if glow then
				glow:Destroy()
			end

			isOpen = false
		end
	end)

	return chest
end

return InteractiveObjects
