# NOTE: This repository does not show the full scripts (for protection reasons)

# Introduction
This repository showcases an M1 combat system coded with Luau in Roblox Studio.
Instead of relying entirely on the default client → server structure, I used modules for reusability and scalability. This allows not only players, but also NPCs, to use the same M1 system with minimal extra code.
In the background, I also use Module Loaders (which will not be shown in this repository).

# Explaining The Scripts
Parts of the code are already explained with comments inside the modules, but I’ll also explain the overall logic here.
(I highly recommend reading the scripts before reading this section.)
Also, the meleeData module stores combo data. This means I can easily create new combos with different damage values, stun durations, animations, etc. without hardcoding everything into the combat script.
To begin, initMainCombat is the core of the M1 system.

It handles:


+ Cooldown logic


+ Combo progression (punch1 -> finisher)


+ Effects


+ Damage handling


+ Hit detection


Before the main function, several variables are assigned as tables.
The reason for this is so every character has their own cooldowns and combo state (meaning Player A will not affect Player B’s cooldowns).
Now we can begin with the main function:
Punch(character: Model)
We pass in a character argument, which allows anything using the module (players, NPCs, etc.) to trigger an M1 attack.
Before anything else, we check multiple cooldowns:


+ Full combo reset cooldown (after the combo finishes)


+ Punch cooldown (to prevent spam)


+ Combo timeout reset (if the player waits too long between punches)


After that, we initialize the combo value.
If the character has no combo yet, it defaults to 1.
Next, we retrieve the full combo data from the meleeData module and index it using the character’s current combo step.
For example, if the combo number is 2, we retrieve the second move’s data from the combo table.
We then gather important references from the attacking character:


+ Character


+ Humanoid


+ Animator


+ HumanoidRootPart


To play animations, we retrieve the animation object stored in currentMoveData.
Because these are pre-existing Animation instances inside Studio, it is more optimized than creating them dynamically.
We then load the animation as an animation track and play it.
At this point, the script is only playing an animation, so we need actual hit detection.
Inside the animations, there are animation markers.
The script listens for the marker event, and once the animation reaches that marker, a function is triggered.
Inside that function, we:


1) Create the hitbox


2) Position it 3 studs in front of the attacking character


3) Detect targets inside the hitbox


To detect targets, we use:

workspace:GetPartsBoundInBox(hitbox.CFrame, hitbox.Size)

This is more reliable than using .Touched, although filtering is still necessary since the function continuously checks everything inside the hitbox bounds.
To prevent multiple hits on the same target, we store already-hit characters inside a table and skip them if detected again.
Once a valid target is found:


Damage is applied using the values stored in currentMoveData


The target’s movement speed is temporarily reduced to 1.5


task.delay() is used to restore their normal walk speed (16) shortly after


After the animation marker logic finishes, the combo step advances by 1.
Finally, we check whether the combo step exceeds the maximum combo length stored in the default combo data.
If it does, the combo resets back to 1.

In the mainCombatStart script, most of the heavy logic has already been handled by initMainCombat, so the script itself is fairly simple.
First, we require the initMainCombat module.
We also retrieve the eventsFolder because we need a signal from the client indicating that input was sent.
Roblox automatically passes the player as an argument when using RemoteEvents, which is useful because we need access to the player’s character.
Inside the Start() function, we listen for the remote event.
When the event fires, we call:
Punch(character)
with the player’s character passed into the function.

Finally, the modelAI script handles NPC combat behavior.
This script allows NPCs to utilize the same:
Punch(character)
function used by players.
First, we create a Start() function and use:
task.spawn(function()
to immediately run the AI loop asynchronously.
We then initialize:


nearestCharacter as nil


nearestDistance as the configured attackRange


Next, we iterate through all players in the game and calculate their distance from the NPC.
If a player is within range and closer than the current target, they become the new nearestCharacter.
Once a target exists, the NPC rotates toward them using Lerp() for smoother and simpler movement interpolation.
Finally, the NPC uses:
Punch(Model)
and waits for attackDelay before attacking again, preventing the AI from attacking unrealistically fast.
