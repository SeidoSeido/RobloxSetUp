--[[
	RagDollBlock - Server script that makes players ragdoll dramatically when they touch it
	Features: Funny death animation, temporary ragdoll physics, automatic recovery
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

-- Wait for the RagDollBlock to exist in workspace
local ragDollBlock = Workspace:WaitForChild("RagDollBlock")

-- Ragdoll settings
local RAGDOLL_DURATION = 3 -- 3 seconds of ragdoll
local RECOVERY_TIME = 1 -- 1 second recovery animation
local ragdolledPlayers = {}

-- Function to create ragdoll effect
local function ragdollPlayer(player)
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChild("Humanoid")
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if not humanoid or not humanoidRootPart then
		return
	end

	-- Check if player is already ragdolled
	local userId = player.UserId
	if ragdolledPlayers[userId] then
		return
	end

	print("💀 " .. player.Name .. " has been DRAMATICALLY DEFEATED by the RagDoll Block!")

	-- Mark player as ragdolled
	ragdolledPlayers[userId] = true

	-- Disable player control
	humanoid.PlatformStand = true

	-- Add dramatic death sound effect (optional - you can remove if no sound)
	local deathSound = Instance.new("Sound")
	deathSound.SoundId = "rbxasset://sounds/impact_water.mp3" -- Silly death sound
	deathSound.Volume = 0.5
	deathSound.Parent = humanoidRootPart
	deathSound:Play()
	Debris:AddItem(deathSound, 2)

	-- Create funny death message above player
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(200, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.Parent = humanoidRootPart

	local deathText = Instance.new("TextLabel")
	deathText.Size = UDim2.fromScale(1, 1)
	deathText.BackgroundTransparency = 1
	deathText.Text = "💀 DRAMATICALLY DECEASED 💀"
	deathText.TextColor3 = Color3.fromRGB(255, 0, 0)
	deathText.TextScaled = true
	deathText.Font = Enum.Font.ArimoBold
	deathText.Parent = billboard

	-- Animate the death text
	local textTween = TweenService:Create(
		deathText,
		TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
		{ TextTransparency = 0 }
	)
	textTween:Play()

	-- Create proper R15/R16 ragdoll physics
	local ragdollJoints = {}
	local originalCanCollide = {}

	-- Enable collision on all body parts so they don't phase through ground
	for _, part in pairs(character:GetChildren()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			-- Store original CanCollide state
			originalCanCollide[part] = part.CanCollide
			-- Enable collision for ragdoll physics
			part.CanCollide = true
		end
	end

	-- Store original collision states for restoration
	character:SetAttribute("OriginalCanCollide", originalCanCollide)

	-- Disable all Motor6D joints and replace with BallSocketConstraints for realistic limb physics
	for _, joint in pairs(character:GetDescendants()) do
		if joint:IsA("Motor6D") then
			-- Store original joint info for restoration
			local jointInfo = {
				joint = joint,
				part0 = joint.Part0,
				part1 = joint.Part1,
				c0 = joint.C0,
				c1 = joint.C1,
			}
			table.insert(ragdollJoints, jointInfo)

			-- Create attachments if they don't exist
			local attachment0 = joint.Part0:FindFirstChild(joint.Name .. "RigAttachment")
				or joint.Part0:FindFirstChild(joint.Name .. "Attachment")
			local attachment1 = joint.Part1:FindFirstChild(joint.Name .. "RigAttachment")
				or joint.Part1:FindFirstChild(joint.Name .. "Attachment")

			if not attachment0 then
				attachment0 = Instance.new("Attachment")
				attachment0.Name = joint.Name .. "Attachment0"
				attachment0.CFrame = joint.C0
				attachment0.Parent = joint.Part0
			end

			if not attachment1 then
				attachment1 = Instance.new("Attachment")
				attachment1.Name = joint.Name .. "Attachment1"
				attachment1.CFrame = joint.C1
				attachment1.Parent = joint.Part1
			end

			-- Create BallSocketConstraint for realistic joint physics
			local ballSocket = Instance.new("BallSocketConstraint")
			ballSocket.Name = joint.Name .. "RagdollJoint"
			ballSocket.Attachment0 = attachment0
			ballSocket.Attachment1 = attachment1
			ballSocket.LimitsEnabled = true
			ballSocket.UpperAngle = 45 -- Limit extreme bending
			ballSocket.Parent = joint.Part0

			-- Disable the original joint
			joint.Enabled = false
		end
	end

	-- Store ragdoll joints for cleanup
	character:SetAttribute("RagdollJoints", ragdollJoints)

	-- Add initial impulse for dramatic effect
	local initialForce = Instance.new("BodyVelocity")
	initialForce.MaxForce = Vector3.new(4000, 4000, 4000)
	initialForce.Velocity = Vector3.new(math.random(-15, 15), math.random(10, 20), math.random(-15, 15))
	initialForce.Parent = humanoidRootPart

	-- Remove initial force after short time to let physics take over
	Debris:AddItem(initialForce, 0.3)

	-- Recovery after ragdoll duration
	task.wait(RAGDOLL_DURATION)

	-- Start recovery process
	if character and character.Parent and humanoid then
		print("✨ " .. player.Name .. " is dramatically recovering...")

		-- Change death message to recovery
		if deathText then
			deathText.Text = "✨ MIRACULOUS RECOVERY! ✨"
			deathText.TextColor3 = Color3.fromRGB(0, 255, 0)

			local recoveryTween = TweenService:Create(
				deathText,
				TweenInfo.new(RECOVERY_TIME, Enum.EasingStyle.Elastic),
				{ TextTransparency = 1 }
			)
			recoveryTween:Play()
		end

		-- Add recovery effect
		local recoverySound = Instance.new("Sound")
		recoverySound.SoundId = "rbxasset://sounds/electronicpingshort.wav" -- Recovery sound
		recoverySound.Volume = 0.3
		recoverySound.Parent = humanoidRootPart
		recoverySound:Play()
		Debris:AddItem(recoverySound, 2)

		-- Gradually restore player control
		task.wait(RECOVERY_TIME)

		-- Re-enable player control
		humanoid.PlatformStand = false

		-- Restore original joints and remove ragdoll constraints
		local storedJoints = character:GetAttribute("RagdollJoints")
		if storedJoints then
			-- Remove all ragdoll constraints
			for _, constraint in pairs(character:GetDescendants()) do
				if constraint:IsA("BallSocketConstraint") and constraint.Name:match("RagdollJoint") then
					constraint:Destroy()
				end
			end

			-- Re-enable original Motor6D joints
			for _, joint in pairs(character:GetDescendants()) do
				if joint:IsA("Motor6D") then
					joint.Enabled = true
				end
			end

			-- Clear the ragdoll joints attribute
			character:SetAttribute("RagdollJoints", nil)
		end

		-- Restore original CanCollide states
		local storedCanCollide = character:GetAttribute("OriginalCanCollide")
		if storedCanCollide then
			for part, originalState in pairs(storedCanCollide) do
				if part and part.Parent then
					part.CanCollide = originalState
				end
			end
			-- Clear the stored collision states
			character:SetAttribute("OriginalCanCollide", nil)
		end

		-- Clean up death message
		if billboard then
			billboard:Destroy()
		end

		-- Remove from ragdolled players
		ragdolledPlayers[userId] = nil

		print("🎉 " .. player.Name .. " has fully recovered and is ready for more mischief!")
	else
		-- Character was destroyed during ragdoll, clean up
		ragdolledPlayers[userId] = nil
	end
end

-- Connect the touched event
ragDollBlock.Touched:Connect(function(hit)
	-- Check if the thing that touched is part of a player's character
	local character = hit.Parent
	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid then
		-- Get the player from the character
		local player = Players:GetPlayerFromCharacter(character)
		if player then
			-- Start ragdoll effect in a separate thread to avoid blocking
			task.spawn(function()
				ragdollPlayer(player)
			end)
		end
	end
end)

-- Clean up when players leave
Players.PlayerRemoving:Connect(function(player)
	ragdolledPlayers[player.UserId] = nil
end)

print("🤸 RagDollBlock script loaded - touch for DRAMATIC RAGDOLL ACTION!")
print("⏱️ Ragdoll duration: " .. RAGDOLL_DURATION .. " seconds")
print("✨ Recovery time: " .. RECOVERY_TIME .. " second")
