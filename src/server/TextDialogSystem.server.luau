--[[
	Text Dialog System Server - Handles mysterious story dialog triggers
	Features: Touch detection for non-collidable parts, sequential dialog progression
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create RemoteEvent for dialog communication
local dialogRemoteEvent = Instance.new("RemoteEvent")
dialogRemoteEvent.Name = "TextDialogEvent"
dialogRemoteEvent.Parent = ReplicatedStorage

-- Dialog data with mysterious messages
local DIALOG_DATA = {
	{
		partName = "TextDialogPartOne",
		message = "Strange.. you walk a path not meant for you.",
		dialogId = 1,
	},
	{
		partName = "TextDialogPartTwo",
		message = "You are not meant to be here.",
		dialogId = 2,
	},
	{
		partName = "TextDialogPartThree",
		message = "You were never meant to be here… not yet.",
		dialogId = 3,
	},
}

-- Track which players have seen which dialogs
local playerDialogProgress = {}

-- Function to setup a dialog part
local function setupDialogPart(dialogInfo)
	local part = Workspace:FindFirstChild(dialogInfo.partName)

	if not part then
		warn("⚠️ Dialog part not found: " .. dialogInfo.partName)
		return false
	end

	-- Ensure part is non-collidable
	part.CanCollide = false
	part.Transparency = 0.8 -- Slightly visible for debugging

	print("👻 Setting up dialog part: " .. dialogInfo.partName)

	-- Connect touch event
	part.Touched:Connect(function(hit)
		print("👻 Touch detected on " .. dialogInfo.partName .. " by: " .. hit.Name)
		local character = hit.Parent
		local humanoid = character:FindFirstChild("Humanoid")

		if humanoid then
			local player = Players:GetPlayerFromCharacter(character)
			if player then
				print("👤 Player identified: " .. player.Name)
				-- Initialize player progress if not exists
				if not playerDialogProgress[player.UserId] then
					playerDialogProgress[player.UserId] = {}
					print("🆕 Initialized dialog progress for " .. player.Name)
				end

				-- Check if player has already seen this dialog
				if playerDialogProgress[player.UserId][dialogInfo.dialogId] then
					print("🔒 " .. player.Name .. " already saw dialog " .. dialogInfo.dialogId)
					return -- Already seen, don't show again
				end

				print("👤 " .. player.Name .. " triggered dialog: " .. dialogInfo.dialogId)

				-- Mark as seen
				playerDialogProgress[player.UserId][dialogInfo.dialogId] = true

				-- Send dialog to client
				dialogRemoteEvent:FireClient(player, {
					action = "showDialog",
					message = dialogInfo.message,
					dialogId = dialogInfo.dialogId,
				})

				print("📜 Sent dialog " .. dialogInfo.dialogId .. " to " .. player.Name)
			else
				print("⚠️ No player found for character: " .. character.Name)
			end
		else
			print("⚠️ No humanoid found in: " .. tostring(character))
		end
	end)

	return true
end

-- Setup all dialog parts
local successCount = 0
for _, dialogInfo in ipairs(DIALOG_DATA) do
	if setupDialogPart(dialogInfo) then
		successCount = successCount + 1
	end
end

if successCount > 0 then
	print("✅ Text Dialog System initialized!")
	print("👻 Active dialog parts: " .. successCount .. "/" .. #DIALOG_DATA)
	print("📜 Dialog messages loaded")
	print("🎭 One-time activation per player")
else
	warn("❌ Failed to setup any dialog parts - check part names")
end

print("👻 Text Dialog System Server loaded!")
