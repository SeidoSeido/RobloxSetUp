--[[
	KillBlock - Server script that kills players when they touch the KillBlock
	Place this script in ServerScriptService or as a child of the KillBlock part
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Wait for the KillBlock to exist in workspace
local killBlock = Workspace:WaitForChild("KillBlock")

-- Function to kill a player
local function killPlayer(player)
	local character = player.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.Health = 0
			print("💀 " .. player.Name .. " was killed by the KillBlock!")
		end
	end
end

-- Connect the touched event
killBlock.Touched:Connect(function(hit)
	-- Check if the thing that touched is part of a player's character
	local character = hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid then
		-- Get the player from the character
		local player = Players:GetPlayerFromCharacter(character)
		if player then
			-- Kill the player
			killPlayer(player)
		end
	end
end)

print("🔴 KillBlock script loaded - players will be killed on touch!")
