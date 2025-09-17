--[[
	Custom Mouse Cursor - Changes the default cursor to a simple dot
	Features: Simple dot cursor for clean, minimalist UI
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Create custom cursor
local function createCustomCursor()
	local playerGui = player:WaitForChild("PlayerGui")

	-- Create ScreenGui for cursor
	local cursorGui = Instance.new("ScreenGui")
	cursorGui.Name = "CustomCursor"
	cursorGui.DisplayOrder = 1000 -- High priority to be on top
	cursorGui.IgnoreGuiInset = true
	cursorGui.Parent = playerGui

	-- Create the dot cursor
	local cursorDot = Instance.new("Frame")
	cursorDot.Name = "CursorDot"
	cursorDot.Size = UDim2.fromOffset(8, 8) -- 8x8 pixel dot
	cursorDot.Position = UDim2.fromOffset(0, 0)
	cursorDot.BackgroundColor3 = Color3.new(1, 1, 1) -- White dot
	cursorDot.BorderSizePixel = 0
	cursorDot.Parent = cursorGui

	-- Make it circular
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0) -- Fully rounded = circle
	corner.Parent = cursorDot

	return cursorGui, cursorDot
end

-- Update cursor position
local function updateCursorPosition(cursorDot)
	local mousePosition = UserInputService:GetMouseLocation()
	-- Offset by half the dot size to center it on mouse position
	cursorDot.Position = UDim2.fromOffset(mousePosition.X - 4, mousePosition.Y - 4)
end

-- Initialize custom cursor
local function initCustomCursor()
	-- Hide default cursor
	mouse.Icon = "rbxasset://textures/Blank.png"

	-- Create custom cursor
	local cursorGui, cursorDot = createCustomCursor()

	-- Update cursor position on mouse movement
	local connection = UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			updateCursorPosition(cursorDot)
		end
	end)

	-- Set initial position
	updateCursorPosition(cursorDot)

	print("Custom dot cursor loaded!")

	-- Clean up if player leaves
	Players.PlayerRemoving:Connect(function(leavingPlayer)
		if leavingPlayer == player then
			connection:Disconnect()
			if cursorGui then
				cursorGui:Destroy()
			end
		end
	end)
end

-- Wait for player to fully load then initialize
player.CharacterAdded:Connect(function()
	task.wait(1) -- Wait a moment for everything to load
	initCustomCursor()
end)

-- Initialize immediately if character already exists
if player.Character then
	task.wait(1)
	initCustomCursor()
end
