local ReplicatedStorage = game:GetService("ReplicatedStorage")
local meleeEventFolder = ReplicatedStorage.eventsFolder.meleeFolder
local meleeEvent: RemoteEvent = meleeEventFolder.meleeEvent
local initMainCombat = require(script.Parent.initMainCombat)

local mainCombatStart = {}

--My module loader detects the 'Start()' function to actually execute modules (basically, the module loader starts any module that has the Start() function)
function mainCombatStart.Start()
    meleeEvent.OnServerEvent:Connect(function(player: Player)
        local character = player.Character or player.CharacterAdded:Wait()
        initMainCombat.Punch(character)
    end)
end

return mainCombatStart
