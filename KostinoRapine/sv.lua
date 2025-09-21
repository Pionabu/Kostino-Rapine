ESX = exports["es_extended"]:getSharedObject()

local cooldown = {}
local activeRobberies = {}

RegisterServerEvent("kostino:startRobbery")
AddEventHandler("kostino:startRobbery", function(name, coords)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    local now = os.time()
    if cooldown[src] and now - cooldown[src] < Config.RobberyCooldown then
        local remaining = Config.RobberyCooldown - (now - cooldown[src])
        TriggerClientEvent("esx:showNotification", src, "⏳ Devi aspettare " .. remaining .. "s prima di rapinare di nuovo.")
        return
    end

    cooldown[src] = now
    activeRobberies[src] = { name = name, started = now }

    TriggerClientEvent("kostino:startTimer", src)
    TriggerClientEvent("kostino:notifyFDO", -1, name)

    kostino_logDiscord("Rapina Iniziata", ("ID: %s | Nome: %s | Posizione: %s"):format(src, name, coords), 16711680)

    Wait(Config.RobberyTime * 1000)

    if activeRobberies[src] then
        if Config.InventoryType == "ox" then
            exports.ox_inventory:AddItem(src, Config.RewardItem, Config.RewardAmount)
        elseif Config.InventoryType == "qs" then
            exports['qs-inventory']:AddItem(src, Config.RewardItem, Config.RewardAmount)
        else
            xPlayer.addInventoryItem(Config.RewardItem, Config.RewardAmount)
        end

        TriggerClientEvent("kostino:notifyRobber", src, Config.RewardItem, Config.RewardAmount)
        TriggerClientEvent("kostino:notifyEnd", -1, name)

        kostino_logDiscord("Rapina Completata", ("ID: %s | Reward: %s x%s"):format(src, Config.RewardItem, Config.RewardAmount), 65280)
        activeRobberies[src] = nil
    end
end)

RegisterServerEvent("kostino:notifyFDOFuga")
AddEventHandler("kostino:notifyFDOFuga", function(name)
    local src = source
    TriggerClientEvent("kostino:notifyFDOFuga", -1, name)
    activeRobberies[src] = nil
    kostino_logDiscord("Rapina Annullata", ("ID: %s | Il sospetto è fuggito dal %s"):format(src, name), 16776960)
end)

function kostino_logDiscord(title, message, color)
    local embed = {
        {
            title = title,
            description = message,
            color = color,
            footer = { text = os.date("%d/%m/%Y %H:%M:%S") }
        }
    }

    PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({
        username = "Kostino Logs",
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end
