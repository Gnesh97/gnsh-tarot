-- Shared animation dictionary loader used by client/seating.lua.

TarotAnimations = {}

function TarotAnimations.PlaySeated(ped, dict, anim)
    RequestAnimDict(dict)
    local start = GetGameTimer()
    while not HasAnimDictLoaded(dict) do
        Wait(0)
        if (GetGameTimer() - start) > 3000 then return end
    end

    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
end

function TarotAnimations.Stop(ped)
    ClearPedTasks(ped)
end
