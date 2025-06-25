local barieraActive = false
local barieraStart = nil
local barieraDir = nil
local barieraWidth = 15.0
local barieraLength = 50000.0

local checkpoint = nil
local checkpointCount = 0
local vehicleModel = "shinobi"
local initialCheckpointSet = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 26) then
            checkpoint = GetEntityCoords(PlayerPedId())
            checkpointCount = checkpointCount + 1
            initialCheckpointSet = false

            SendNUIMessage({
                type = "checkpoint",
                id = checkpointCount,
                x = checkpoint.x,
                y = checkpoint.y,
                z = checkpoint.z
            })

            TriggerEvent("chat:addMessage", {
                color = {255, 100, 0},
                multiline = false,
                args = {"^4SYSTEM", "Checkpoint #" .. checkpointCount .. " ustawiony."}
            })
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 206) and checkpoint then
            local ped = PlayerPedId()
            SetEntityCoords(ped, checkpoint.x, checkpoint.y, checkpoint.z)

            local hash = GetHashKey(vehicleModel)
            RequestModel(hash)
            while not HasModelLoaded(hash) do
                Citizen.Wait(100)
            end

            local veh = CreateVehicle(hash, checkpoint.x, checkpoint.y, checkpoint.z, GetEntityHeading(ped), true, false)
            SetPedIntoVehicle(ped, veh, -1)
            SetModelAsNoLongerNeeded(hash)

            SendNUIMessage({
                type = "checkpoint",
                id = checkpointCount,
                x = checkpoint.x,
                y = checkpoint.y,
                z = checkpoint.z
            })
        end
    end
end)

RegisterCommand("checkreset", function()
    checkpoint = nil
    checkpointCount = 0
    initialCheckpointSet = false
    TriggerEvent("chat:addMessage", {
        color = {255, 0, 0},
        multiline = false,
        args = {"^1SYSTEM", "Checkpoint zresetowany. Licznik wyzerowany."}
    })
end)

RegisterNetEvent("bariera:start")
AddEventHandler("bariera:start", function(startPos, direction)
    barieraActive = true
    barieraStart = startPos
    barieraDir = direction
end)

RegisterNetEvent("bariera:stop")
AddEventHandler("bariera:stop", function()
    barieraActive = false
    barieraStart = nil
    barieraDir = nil
end)

RegisterNetEvent("bariera:getPlayerCoords")
AddEventHandler("bariera:getPlayerCoords", function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local dir = GetEntityForwardVector(ped)

    if not initialCheckpointSet then
        checkpoint = pos
        initialCheckpointSet = true
    end

    TriggerServerEvent("bariera:setStart", pos, dir)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if barieraActive and barieraStart and barieraDir and checkpoint then
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)

            local dx = pos.x - barieraStart.x
            local dy = pos.y - barieraStart.y
            local dotForward = dx * barieraDir.x + dy * barieraDir.y
            local dotSide = dx * -barieraDir.y + dy * barieraDir.x

            if dotForward < -barieraLength / 2 or dotForward > barieraLength / 2 or math.abs(dotSide) > barieraWidth / 2 then
                SetEntityCoords(ped, checkpoint.x, checkpoint.y, checkpoint.z)

                local hash = GetHashKey(vehicleModel)
                RequestModel(hash)
                while not HasModelLoaded(hash) do
                    Citizen.Wait(100)
                end

                local veh = CreateVehicle(hash, checkpoint.x, checkpoint.y, checkpoint.z, GetEntityHeading(ped), true, false)
                SetPedIntoVehicle(ped, veh, -1)
                SetModelAsNoLongerNeeded(hash)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if barieraActive and barieraStart and barieraDir then
            local pedPos = GetEntityCoords(PlayerPedId())

            local segmentSpacing = 0.5
            local renderRange = 50.0
            local halfLength = barieraLength / 2
            local halfWidth = barieraWidth / 2
            local perp = vector3(-barieraDir.y, barieraDir.x, 0.0)

            local dx = pedPos.x - barieraStart.x
            local dy = pedPos.y - barieraStart.y
            local playerPosAlongBariera = dx * barieraDir.x + dy * barieraDir.y

            for i = playerPosAlongBariera - renderRange, playerPosAlongBariera + renderRange, segmentSpacing do
                if i >= -halfLength and i <= halfLength then
                    local center = barieraStart + barieraDir * i
                    local leftPos = center + perp * halfWidth
                    local rightPos = center - perp * halfWidth

                    DrawLine(leftPos.x, leftPos.y, -100.0, leftPos.x, leftPos.y, 8000.0, 255, 0, 255, 150)
                    DrawLine(rightPos.x, rightPos.y, -100.0, rightPos.x, rightPos.y, 8000.0, 255, 0, 255, 150)
                end
            end
        end
    end
end)
