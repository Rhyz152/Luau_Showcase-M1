# NOTE: This repository does not show the full scripts (for protection reasons)

# Introduction

This repository showcases an M1 system coded with Luau in Roblox Studio.
Instead of using the default client->server, I used modules for reusability + we can make not just the players, but also NPCs use the M1s.
In the background, I do have Module Loaders (which I will not be showing).

# Explaining The Modules

Parts of the code are already explained with comments in the modules but I'll explain them here (highly recommend you read the scripts before reading this).

**Also, the meleeData module is a module that has stored data about combos (so if I wanted, I could add new combos with different damage, stun and animations without hardcoding it)**

To begin, the initMainCombat is the **core** of our M1 script.
It handles: Cooldown logic, Combo loop (punch1 -> finisher), Effects, etc.
Before our main function, we assigned a few variables as tables.
The reason for this is that we want it so every character has their own cooldown (so Player A doesn't affect Player B's cooldown).
Now, we can begin writing the main function, Punch(character: Model).
We passed in a character argument (which would be sent in by whatever wants to do an M1).
Before anything, we check cooldowns for: Full combo reset (if the entire combo is finished), Between each punch (to prevent spam), and Combo reset (reset the combo if they were too slow to punch after the 1st).
Alright, now we have initialize our combo (so we set it to 1 if there was no combo before).
We then have to get the full combo data from our meleeData module and then we index the combo to where our combo is at the momemnt (so if our combo number was at 2, we'd look for the 2nd position in the full combo table).
Also, we get the data from the index we're on in the actual data (so if our currentMoveName was 3, we'd get the data from the meleeData about the 3rd position in the table).
Then we get the character, humanoid (and animator inside), and the humanoid root part of the character that is punching.
To play our animations, we get the animation data (which is an already existing Animation object inside of Studio so its more optimized) from our currentMoveData and we load it as an animation track.
Then we play the animation.
But this just plays an animation for now.
So, we have an animation marker inside of our animations and we check if our animation is at that marker and as soon as it reaches the animation marker, we connect a function.
In that function, we create the hitbox (used to track anything inside and applying danage) and set the CFrame to 3 studs in front of the character that is punching.
Now, we iterate through everything touching the hitbox using workspace:GetPartsBoundInBox(hitbox.CFrame, hitbox.Size).
This is better than using .Touched but we need to add filtering (because it is continously iterating through every part that is in bound of the hitbox).
So, we use a table that stores the already hit characters and doesn't apply damage to them.
Moving on, we take away the damage of how much damage data is set to the currentMoveData.
Additionally, we make the other character(s) really slow (1.5 walk speed) and we use a task.delay() to make their walking speed normal again (16).
After the animation marker function, we advance the combo step by 1 more for the character
Finally, we have a check to see if our combo step is higher than everything thats in the default combo data and then we set it back to 1.

In the mainCombatStart script, the logic is already done so not a lot of coding.
We require the initMainCombat module to use it + we also get an eventsFolder because we do need to get a signal that input was sent in from the client.
Roblox Studio automatically sends in the player as an argument when using remote events, useful because we need the player's character for our script.
In our Start() function, we listen for our remote event when it fires.
If our remote event fires, we use the Punch(character) function (sending in the player's character by defining it beforehand).

In the modelAI script, this is our script that our NPC in this showcase will do.
We're making the Model utilize the character argument in Punch(character).
First of all, we make a Start() function and using task.spawn(function() inside of it to immediately execute our actual function.
Secondly, we set the variables of 'nearestCharacter' to nil and 'nearestDistance' to the attackRange (shown in the script).
Now, we iterate over every player inside of the game and calculating whether they're in range of the Model.
Depending on how far they are, if they are close, they'd be the nearestCharacter + the target for the Model.
We then check if there is a nearestCharacter and we rotate the Model using Lerp() to keep it simple to the nearestCharacter's CFrame.
Finally, we use the Punch(Model) function and then make the task wait for attackDelay (so the Model isn't that quick).
