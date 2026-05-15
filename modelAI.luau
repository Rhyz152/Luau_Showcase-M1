--This module is for the Model's AI

local Players = game:GetService("Players")

local initMainCombat = require(script.Parent.Parent.Melee.initMainCombat)

local punchCharacter = {}

local attackRange = 12
local attackDelay = 0.45

local npcCharacter = workspace:WaitForChild("Model")
local humanoidRootPart =
	npcCharacter:WaitForChild("HumanoidRootPart")

function punchCharacter.Start()
	task.spawn(function()
		--While the npc 'lives'
		while npcCharacter.Parent do
			local nearestCharacter = nil
			local nearestDistance = attackRange

			--Checks for every player in the game (and if they're in range)
			for _, player in ipairs(Players:GetPlayers()) do
				local character = player.Character
				if not character then
					continue
				end

				local humanoid =
					character:FindFirstChildWhichIsA("Humanoid")

				local rootPart =
					character:FindFirstChild("HumanoidRootPart")

				--Checks if the player isn't dead
				if not humanoid or not rootPart or humanoid.Health <= 0 then
					continue
				end

                --Calculate the distance from the player's HumanoidRootPart to the npcs
				local distance =
					(rootPart.Position - humanoidRootPart.Position).Magnitude
				
				--[[
				Checks if the distance is less than the nearest distance (attack range)
				If it is, it sets the nearestDistance to the distance and the nearestCharacter to the character in the range\
				Essentially, this targets the nearestCharacter]]
				if distance < nearestDistance then
					nearestDistance = distance
					nearestCharacter = character
				end
			end

			--If there is a targeted character then we do something
			if nearestCharacter then
				local targetRoot =
					nearestCharacter:FindFirstChild("HumanoidRootPart")

				--Rotates the npc to the targeted characters position
				if targetRoot then
					local targetPosition = Vector3.new(
						targetRoot.Position.X,
						humanoidRootPart.Position.Y,
						targetRoot.Position.Z
					)

					--transitioning
					humanoidRootPart.CFrame =
						humanoidRootPart.CFrame:Lerp(
							CFrame.lookAt(
								humanoidRootPart.Position,
								targetPosition
							),
							0.2
						)
				end

				--punch
				initMainCombat.Punch(npcCharacter)
			end

			task.wait(attackDelay)
		end
	end)
end

return punchCharacter
