-- Server-side guard helpers. Called: fxmanifest server_scripts (after bridges,
-- before cooldowns/deck/tables/sessions/cleanup/main). No dup exists. Schema:
-- consumers pass raw event payloads; this validates shape/type/whitelist only,
-- never trusts client-declared identity beyond `source`. User: continue plan.

Security = {}

function Security.ValidateSource(src)
    if type(src) ~= 'number' or src <= 0 then return false end
    return GetPlayerName(src) ~= nil
end

function Security.ValidateCoords(coords)
    local coordsType = type(coords)
    if coordsType ~= 'table' and coordsType ~= 'vector3' then return false end
    if not Utils.IsFiniteNumber(coords.x)
        or not Utils.IsFiniteNumber(coords.y)
        or not Utils.IsFiniteNumber(coords.z) then
        return false
    end

    return math.abs(coords.x) <= 100000.0
        and math.abs(coords.y) <= 100000.0
        and math.abs(coords.z) <= 100000.0
end

function Security.ValidateHeading(heading)
    return Utils.IsFiniteNumber(heading) and heading >= 0.0 and heading <= 360.0
end

function Security.WithinPlayerDistance(src, coords, maxDistance)
    if not Security.ValidateCoords(coords) then return false end
    local ped = GetPlayerPed(src)
    if ped == 0 or not DoesEntityExist(ped) then return false end
    return Utils.DistanceBetween(GetEntityCoords(ped), coords) <= maxDistance
end

function Security.WithinEntityDistance(src, entity, maxDistance)
    if entity == 0 or not DoesEntityExist(entity) then return false end
    local ped = GetPlayerPed(src)
    if ped == 0 or not DoesEntityExist(ped) then return false end
    return Utils.DistanceBetween(GetEntityCoords(ped), GetEntityCoords(entity)) <= maxDistance
end

function Security.IsNetworkEntityOwnedBy(entity, src)
    if entity == 0 or not DoesEntityExist(entity) then return false end
    local owner = NetworkGetEntityOwner(entity)
    return owner == src
end

-- Validates a payload table against a schema of {field = 'string'|'number'|'boolean'}.
-- Rejects unknown fields, wrong types, and strings over maxStringLen.
function Security.ValidatePayload(payload, schema, maxStringLen)
    maxStringLen = maxStringLen or 64
    if type(payload) ~= 'table' then return false end

    for key in pairs(payload) do
        if schema[key] == nil then return false end
    end

    for field, expectedType in pairs(schema) do
        local value = payload[field]
        if expectedType == 'optional_string' then
            if value ~= nil and (type(value) ~= 'string' or #value > maxStringLen) then
                return false
            end
        elseif expectedType == 'string' then
            if type(value) ~= 'string' or #value == 0 or #value > maxStringLen then
                return false
            end
        elseif expectedType == 'number' then
            if type(value) ~= 'number' then return false end
        elseif expectedType == 'boolean' then
            if type(value) ~= 'boolean' then return false end
        end
    end

    return true
end

function Security.SamePlayerBucket(srcA, srcB)
    return GetPlayerRoutingBucket(srcA) == GetPlayerRoutingBucket(srcB)
end

function Security.WithinDistance(srcA, srcB, maxDistance)
    local pedA = GetPlayerPed(srcA)
    local pedB = GetPlayerPed(srcB)
    if pedA == 0 or pedB == 0 then return false end

    local coordsA = GetEntityCoords(pedA)
    local coordsB = GetEntityCoords(pedB)
    return Utils.DistanceBetween(coordsA, coordsB) <= maxDistance
end

function Security.IsSessionReader(session, src)
    return session ~= nil and session.readerSource == src
end

function Security.IsSessionCustomer(session, src)
    return session ~= nil and session.customerSource == src
end

function Security.Reject(reason, src, context)
    if Config.Debug then
        Utils.Debug(('reject src=%s reason=%s context=%s'):format(tostring(src), tostring(reason), tostring(context)))
    end
    return false
end
