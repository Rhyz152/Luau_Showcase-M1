local initMainCombat = {}
--Note: we are using character instead of player because we want npcs to also use it (reusability)

--Tables for per-character
local lastPunch = {} --When was the last time the character punched
local comboStep = {} --Where is the character at in their combo (Example: are they in punch1?)
local finisherPunch = {} --Is the character on the last punch (which is the finisher punch so we can add cd at the end of the combo)?

local commboResetTime = meleeVariables.comboResetTime --Used modules, this would be 2
local punchCooldown = meleeVariables.punchCooldown --Used modules, this would be 0.65

--The order of the defaultCombo (because its a table of data and not )
local defaultComboOrder = {
	"punch1",
	"punch2",
	"punch3",
	"finisher"
}

function initMainCombat.Punch(character: Model)
    --Precise timing
	local now = os.clock() 

    -- cooldown after full combo
    if finisherPunch[character] and (now - finisherPunch[character]) < 5 then
	    return
    end

	-- cooldown between each punch
	if lastPunch[character] and (now - lastPunch[character]) < punchCooldown then
		return
	end

	-- reset combo if too slow between hits
	if lastPunch[character] and (now - lastPunch[character]) > commboResetTime then
		comboStep[character] = 1
	end
	
	--Sets the time of the last punch to the current time
	lastPunch[character] = now
	
	--set the comboStep
	if not comboStep[character] then
		comboStep[character] = 1
	end

	--The data inside the deafultCombo
	local defaultCombo = meleeData["defaultCommbo"]

	--Whatever the name (punch1, punch2, etc) the player is on
	local currentMoveName = defaultComboOrder[comboStep[character]]
	--The data of the punch (damage data, stun data, and animation data in this case)
	local currentMoveData = defaultCombo[currentMoveName]

	-- character
	local humanoid = character:WaitForChild("Humanoid")
	local animator = humanoid:WaitForChild("Animator")
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

	-- animation
	local animation: Animation = currentMoveData["animation"]
	local punchTrack: AnimationTrack = animator:LoadAnimation(animation)
	punchTrack:Play()

     --If the animation is at the point where the animation is punching (using animation markers)
	punchTrack:GetMarkerReachedSignal("Hit"):Connect(function()
		--Play the swoosh sound cause of wind
		clonedSwooshSFX:Play()

		--hitbox
		local hitbox = Instance.new("Part")
		hitbox.Name = "Default Combo Hitbox"
		hitbox.Transparency = 0.5
		hitbox.CanCollide = false
		hitbox.Anchored = true
		hitbox.Size = Vector3.new(5, 5, 5)
		hitbox.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -3)
		hitbox.Parent = workspace

		--Filtering
		local alreadyHit = {}
        
		--Applying damage
		for _, part in pairs(workspace:GetPartBoundsInBox(hitbox.CFrame, hitbox.Size)) do
			local otherCharacter = part:FindFirstAncestorOfClass("Model")
			if not otherCharacter or alreadyHit[otherCharacter] or otherCharacter == character then continue end
			--Set the other character to already damaged
			alreadyHit[otherCharacter] = true

			local otherHumanoid: Humanoid = otherCharacter:FindFirstChildWhichIsA("Humanoid")
			if not otherHumanoid then continue end

			--[[
			Take the amount of damage data (punch1 damage, punch2 damage, etc) from the other humanoid's health
			Then, set the walk speed to 1.5 (because they're now 'stunned')
			]]
			otherHumanoid:TakeDamage(currentMoveData.damage)
			otherHumanoid.WalkSpeed = 1.5

      --hit VFX
		  local clonedHitVFXPart: Part = meleeHitVFXPart:Clone()
		  clonedHitVFXPart.CanCollide = false
		  clonedHitVFXPart.Name = "Cloned Hit VFX Part"
		  clonedHitVFXPart.Anchored = true
		  clonedHitVFXPart.CFrame = hitbox.CFrame
		  clonedHitVFXPart.Parent = workspace
			
		  local attachment0 = clonedHitVFXPart:FindFirstChild("Attachment0")
		  if not attachment0 then
			      warn("[Init Main Combat]: Attachment0 in clonedHitVFXPart wasn't found!")
			      continue
		  end

		  local hitVFX: ParticleEmitter = attachment0:FindFirstChild("vfx0")
		  if not hitVFX then
				warn("[Init Main Combat]: vfx0 wasn't found in attachment0")
				continue
			end

			--[[
			Using task.defer() so it doesn't affect the rest of the script
			We need to enable then emit then disable the vfx for this particle]]
			task.defer(function()
				hitVFX:Clear()
				task.wait()
				hitVFX.Enabled = true
				task.wait()
				hitVFX:Emit(20)
				task.wait()
				hitVFX.Enabled = false
			end)

      --cleanup the cloned part
			game:GetService("Debris"):AddItem(clonedHitVFXPart, 2)

			--play the hit sound (because we hit something)
			clonedHitSFX:Play()

			--Delay for the amount of time that is defined from the data inside of the current move then set the other humanoid's walk speed to default (16)
			task.delay(currentMoveData.stun, function()
				if otherHumanoid then
					otherHumanoid.WalkSpeed = 16
				end
			end)
		end

    
		--cleanup 2
    game:GetService("Debris"):AddItem(clonedSwooshSFX, 0.5)
		game:GetService("Debris"):AddItem(clonedHitSFX, 0.5)
		game:GetService("Debris"):AddItem(hitbox, 0.5)
	end)

	-- advance combo after attack
	comboStep[character] += 1
	if comboStep[character] > #defaultComboOrder then
		finisherPunch[character] = now --Finally on the finisher punch, so we set the time when the character punched to now
		comboStep[character] = 1
	end
end
