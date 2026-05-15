# NOTE: This reprository does not show the full scripts (for protection reasons)

# Introduction

This reprository showcases an M1 system coded with Luau in Roblox Studio.
Instead of using the default client->server, I used modules for reusability + we can make not just the players, but also NPCs use the M1s.
In the background, I do have Module Loaders (which I will not be showing).

# Explaining The Modules

Parts of the code are already explained with comments in the modules but I'll explain them here (highly recommend you read the scripts before reading this).

**Also, the meleeData module is a module that has stored data about combos (so if I wanted, I could add new combos with different damage, stun and animations without hardcoding it)**

To begin, the initMainCombat is the core of our M1 script.
It handles: Cooldown logic, Combo loop (punch1 -> finisher), Effects, etc.
Before our main function, we assigned a few variables as tables.
The reason for this is that we want it so every character has their own cooldown (so Player A doesn't affect Player B's cooldown).
Now, we can begin writing the main function, Punch(character: Model).
We passed in a character argument (which would be sent in by whatever wants to do an M1).
Before anything, we check cooldowns for: Full combo reset (if the entire combo is finished), Between each punch (to prevent spam), and Combo reset (reset the combo if they were too slow to punch after the 1st).
Alright, now we have initialize our combo (so we set it to 1 if there was no combo before).
We then have to get the full combo data from our meleeData module and then we index the combo to where our combo is at the momemnt (so if our combo number was at 2, we'd look for the 2nd position in the full combo table).
Also, we get the data from the index we're on in the actual data (so if our currentMoveName was 3, we'd get the data from the meleeData about the 3rd position in the table).
