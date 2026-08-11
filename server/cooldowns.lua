-- Per-player, per-action rate limiting against Config.ActionCooldownMilliseconds.

Cooldowns = {}
local playerCooldowns = {}

function Cooldowns.Check(src, action)
    local now = GetGameTimer()
    local playerTable = playerCooldowns[src]
    if playerTable == nil then
        playerTable = {}
        playerCooldowns[src] = playerTable
    end

    local last = playerTable[action]
    if last ~= nil and (now - last) < Config.ActionCooldownMilliseconds then
        return false
    end

    playerTable[action] = now
    return true
end

function Cooldowns.Clear(src)
    playerCooldowns[src] = nil
end

AddEventHandler('playerDropped', function()
    Cooldowns.Clear(source)
end)
