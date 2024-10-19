local jailedPlayers = {}

RegisterCommand("jail", function(source, args)
    local playerId = tonumber(args[1])
    local minutes = tonumber(args[2])

    if not playerId or not minutes then
        TriggerClientEvent("chat:addMessage", source, { args = { "SYSTEM", "Usage: /jail [playerID] [minutes]" } })
        return
    end

    local targetPlayer = GetPlayerFromId(playerId)
    if targetPlayer then
        TriggerClientEvent("jailPlayer", targetPlayer, minutes)
        jailedPlayers[playerId] = os.time() + (minutes * 60) -- Temps de jail en secondes

        TriggerClientEvent("chat:addMessage", source, { args = { "SYSTEM", "Player " .. playerId .. " has been jailed for " .. minutes .. " minutes." } })
    else
        TriggerClientEvent("chat:addMessage", source, { args = { "SYSTEM", "Player not found." } })
    end
end)

RegisterCommand("unjail", function(source, args)
    local playerId = tonumber(args[1])

    if not playerId then
        TriggerClientEvent("chat:addMessage", source, { args = { "SYSTEM", "Usage: /unjail [playerID]" } })
        return
    end

    local targetPlayer = GetPlayerFromId(playerId)
    if targetPlayer then
        if jailedPlayers[playerId] then
            jailedPlayers[playerId] = nil
            TriggerClientEvent("unjailPlayer", targetPlayer)
            TriggerClientEvent("chat:addMessage", source, { args = { "SYSTEM", "Player " .. playerId .. " has been unjailed." } })
        else
            TriggerClientEvent("chat:addMessage", source, { args = { "SYSTEM", "Player is not jailed." } })
        end
    else
        TriggerClientEvent("chat:addMessage", source, { args = { "SYSTEM", "Player not found." } })
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Vérifie chaque seconde
        for playerId, releaseTime in pairs(jailedPlayers) do
            if os.time() >= releaseTime then
                local targetPlayer = GetPlayerFromId(playerId)
                if targetPlayer then
                    TriggerClientEvent("unjailPlayer", targetPlayer)
                end
                jailedPlayers[playerId] = nil
            end
        end
    end
end)

-- Fonction pour obtenir un joueur par ID
function GetPlayerFromId(playerId)
    for _, player in ipairs(GetPlayers()) do
        if tonumber(player) == playerId then
            return player
        end
    end
    return nil
end
