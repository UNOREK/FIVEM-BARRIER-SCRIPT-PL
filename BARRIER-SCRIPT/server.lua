local barieraActive = false
local barieraStart = nil
local barieraDir = nil

RegisterCommand("startbariera", function(source)
    local _source = source
    -- Wyślij event do klienta, który wywołał komendę, aby podał pozycję i kierunek
    TriggerClientEvent("bariera:getPlayerCoords", _source)
    print("Startbariera command od gracza ID: " .. tostring(_source))
end)

RegisterCommand("stopbariera", function(source)
    barieraActive = false
    barieraStart = nil
    barieraDir = nil
    TriggerClientEvent("bariera:stop", -1)
    TriggerClientEvent("chat:addMessage", -1, { args = { "^1Bariera została wyłączona!" } })
    print("Stopbariera command od gracza ID: " .. tostring(source))
end)

-- Event odbierający pozycję i kierunek od klienta wywołującego startbariera
RegisterNetEvent("bariera:setStart")
AddEventHandler("bariera:setStart", function(pos, dir)
    barieraActive = true
    barieraStart = pos
    barieraDir = dir
    TriggerClientEvent("bariera:start", -1, barieraStart, barieraDir)
    TriggerClientEvent("chat:addMessage", -1, { args = { "^6Bariera została uruchomiona globalnie!" } })
    print("Bariera globalnie ustawiona")
end)
