local ReplicatedStorage = game:GetService("ReplicatedStorage")
local meleeEventFolder = ReplicatedStorage.eventsFolder.meleeFolder
local meleeEvent: RemoteEvent = meleeEventFolder.meleeEvent
local initMainCombat = require(script.Parent.initMainCombat)

local mainCombatStart = {}

function mainCombatStart.Start()
    meleeEvent.OnServerEvent:Connect(function(player: Player)
        local character = player.Character or player.CharacterAdded:Wait()
        initMainCombat.Punch(character)
    end)
end

return mainCombatStart