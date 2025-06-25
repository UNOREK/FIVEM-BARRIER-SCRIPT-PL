local barieraActive = false
local barieraStart = nil
local barieraDir = nil

RegisterCommand("startbariera", function(source)
    local _source = source
    TriggerClientEvent("bariera:getPlayerCoords", _source)
    print("Startbariera command od gracza ID: " .. tostring(_source))
end)

RegisterCommand("stopbariera", function(source)
    barieraActive = false
    barieraStart = nil
    barieraDir = nil
    TriggerClientEvent("bariera:stop", -1)

    TriggerClientEvent("chat:addMessage", -1, {
        color = {255, 50, 50},
        multiline = false,
        args = {"^1SYSTEM", "Bariera została wyłączona."}
    })

    print("Stopbariera command od gracza ID: " .. tostring(source))
end)

RegisterNetEvent("bariera:setStart")
AddEventHandler("bariera:setStart", function(pos, dir)
    barieraActive = true
    barieraStart = pos
    barieraDir = dir
    TriggerClientEvent("bariera:start", -1, barieraStart, barieraDir)

    TriggerClientEvent("chat:addMessage", -1, {
        color = {180, 0, 255},
        multiline = false,
        args = {"^6SYSTEM", "Bariera została aktywowana."}
    })

    print("Bariera globalnie ustawiona")
end)
