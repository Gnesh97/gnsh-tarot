Utils = {}

local sessionCounter = 0

-- Generates ids like tarot_<serverTimeSeconds>_<incrementingCounter> so they
-- are unique per-resource-lifetime and match SessionIdPattern from constants.lua.
function Utils.GenerateId(prefix)
    sessionCounter = sessionCounter + 1
    return ('%s_%d_%d'):format(prefix or 'tarot', os.time(), sessionCounter)
end

function Utils.IsValidSessionId(id)
    if type(id) ~= 'string' then return false end
    if #id > MaxSessionIdLength then return false end
    return id:match(SessionIdPattern) ~= nil
end

function Utils.IsValidTableId(id)
    if type(id) ~= 'string' then return false end
    if #id > MaxTableIdLength then return false end
    return id:match(TableIdPattern) ~= nil
end

function Utils.SafeNumber(value, min, max)
    local num = tonumber(value)
    if num == nil or num ~= num or math.abs(num) == math.huge then return nil end
    if min ~= nil and num < min then return nil end
    if max ~= nil and num > max then return nil end
    return num
end

function Utils.IsFiniteNumber(value)
    return type(value) == 'number' and value == value and math.abs(value) ~= math.huge
end

function Utils.DistanceBetween(coordsA, coordsB)
    if coordsA == nil or coordsB == nil then return math.huge end
    local dx = coordsA.x - coordsB.x
    local dy = coordsA.y - coordsB.y
    local dz = coordsA.z - coordsB.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function Utils.Debug(...)
    if not Config.Debug then return end
    local args = { ... }
    local parts = {}
    for i = 1, #args do
        parts[i] = tostring(args[i])
    end
    print(('^5[tarot debug]^7 %s'):format(table.concat(parts, ' ')))
end
