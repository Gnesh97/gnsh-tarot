-- Offset-based seating around the table, driven by Config.Seating. Purely
-- cosmetic — Config.FreezePlayersDuringReading defaults off, so RP emotes
-- and repositioning stay possible mid-reading unless a server opts in.

TarotSeating = {}

local seatedPed = nil
local chairEntity = nil

local function loadModel(model)
    local hash = type(model) == 'string' and GetHashKey(model) or model
    if not IsModelValid(hash) then return nil end

    RequestModel(hash)
    local start = GetGameTimer()
    while not HasModelLoaded(hash) do
        Wait(0)
        if (GetGameTimer() - start) > Config.ModelLoadTimeoutMs then
            return nil
        end
    end
    return hash
end

local function removeChair()
    if chairEntity ~= nil and DoesEntityExist(chairEntity) then
        DeleteEntity(chairEntity)
    end
    chairEntity = nil
end

local function spawnChair(tableEntity, offset, headingOffset)
    if type(Config.Seating.chairModel) ~= 'string' then return end

    local hash = loadModel(Config.Seating.chairModel)
    if hash == nil then
        print(('[tarot] chair spawn failed: model did not load (%s)'):format(tostring(Config.Seating.chairModel)))
        return
    end

    -- Chair-only nudge on top of the seat offset (table-local x/y/z) --
    -- tune via Config.Seating.chairPositionAdjust, independent of the ped.
    local nudge = Config.Seating.chairPositionAdjust or vector3(0.0, 0.0, 0.0)
    local coords = GetOffsetFromEntityInWorldCoords(tableEntity, offset.x + nudge.x, offset.y + nudge.y, offset.z + nudge.z)
    local heading = GetEntityHeading(tableEntity) + (headingOffset or 0.0) + 180.0

    local entity = CreateObject(hash, coords.x, coords.y, coords.z, true, true, false)
    SetModelAsNoLongerNeeded(hash)
    if entity == 0 or not DoesEntityExist(entity) then return end

    -- Ground-snapped, so it always ends up standing on the floor under the
    -- seat regardless of the offset's z.
    PlaceObjectOnGroundProperly(entity)
    SetEntityHeading(entity, heading)
    FreezeEntityPosition(entity, true)

    chairEntity = entity
end

local function seatAt(tableEntity, offset, headingOffset)
    local ped = PlayerPedId()
    local coords = GetOffsetFromEntityInWorldCoords(tableEntity, offset.x, offset.y, offset.z)
    local tableHeading = GetEntityHeading(tableEntity)

    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    -- Fine rotation knob for the ANIMATION only (chair keeps its own
    -- already-tuned heading in spawnChair) -- the seated pose doesn't quite
    -- face the same way as the chair's own facing, so this nudges just the
    -- character to line up. Restart and eyeball it.
    SetEntityHeading(ped, tableHeading + (headingOffset or 0.0) + (Config.Seating.seatRotationAdjust or 0.0))

    removeChair()
    spawnChair(tableEntity, offset, headingOffset)

    TarotAnimations.PlaySeated(ped, Config.Seating.animDict, Config.Seating.animName)
    seatedPed = ped

    if Config.FreezePlayersDuringReading then
        FreezeEntityPosition(ped, true)
    end
end

function TarotSeating.SitAsReader(tableEntity)
    if not Config.Seating.enabled then return end
    seatAt(tableEntity, Config.Seating.readerOffset, Config.Seating.readerHeadingOffset)
end

function TarotSeating.SitAsCustomer(tableEntity)
    if not Config.Seating.enabled then return end
    seatAt(tableEntity, Config.Seating.customerOffset, Config.Seating.customerHeadingOffset)
end

function TarotSeating.StandUp()
    removeChair()

    if seatedPed == nil then return end

    if Config.FreezePlayersDuringReading then
        FreezeEntityPosition(seatedPed, false)
    end
    TarotAnimations.Stop(seatedPed)
    seatedPed = nil
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    removeChair()
end)

RegisterNetEvent('tarot:client:sessionClosed', function()
    TarotSeating.StandUp()
end)

RegisterNetEvent('tarot:client:sessionCompleted', function()
    TarotSeating.StandUp()
end)
