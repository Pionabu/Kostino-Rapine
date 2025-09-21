local ESX = nil
local isRobbing = false
local robberyTimer = 0
local currentRobberyName = nil

CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Wait(10)
    end
end)

CreateThread(function()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

        for _, loc in pairs(Config.RobberyLocations) do
            DrawMarker(1, loc.coords.x, loc.coords.y, loc.coords.z - 1.0, --triggera qui il tuo gridsystem
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                1.0, 1.0, 1.0, 255, 0, 0, 150,
                false, true, 2, nil, nil, false)

            if #(coords - loc.coords) < 1.5 and not isRobbing then
                ESX.ShowHelpNotification("Premi E per iniziare la rapina")

                if IsControlJustReleased(0, 38) then
                    if IsPedArmed(playerPed, 4) then
                        TriggerServerEvent("kostino:startRobbery", loc.name, loc.coords)
                        currentRobberyName = loc.name
                    else
                        ESX.ShowNotification("Non hai un'arma equipaggiata!")
                    end
                end
            end
        end
    end
end)

RegisterNetEvent("kostino:startTimer")
AddEventHandler("kostino:startTimer", function()
    isRobbing = true
    robberyTimer = Config.RobberyTime
    local playerPed = PlayerPedId()
    local startCoords = GetEntityCoords(playerPed)

    CreateThread(function()
        while robberyTimer > 0 do
            Wait(1000)
            robberyTimer = robberyTimer - 1

            local currentCoords = GetEntityCoords(playerPed)
            if #(currentCoords - startCoords) > 15.0 then
                ESX.ShowNotification("❌ Sei fuggito! La rapina è stata annullata.")
                TriggerServerEvent("kostino:notifyFDOFuga", currentRobberyName)
                isRobbing = false
                robberyTimer = 0
                return
            end
        end
        isRobbing = false
    end)
end)

CreateThread(function()
    while true do
        Wait(0)
        if isRobbing then
            DrawAdvancedText(0.97, 0.9, 0.005, 0.0028, 0.6, string.upper("RAPINA IN CORSO"), 0, 255, 0, 255, 4, 2)
            DrawAdvancedText(0.97, 0.94, 0.005, 0.0028, 0.85, robberyTimer .. "s", 255, 255, 255, 255, 4, 2)
        end
    end
end)

function DrawAdvancedText(x, y, w, h, sc, text, r, g, b, a, font, justify)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(sc, sc)
    SetTextColour(r, g, b, a)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - 0.1, y - 0.02)
end

RegisterNetEvent("kostino:notifyFDO")
AddEventHandler("kostino:notifyFDO", function(name)
    ESX.ShowNotification("📢 Centrale: rapina in corso al " .. name)
end)

RegisterNetEvent("kostino:notifyEnd")
AddEventHandler("kostino:notifyEnd", function(name)
    ESX.ShowNotification("✅ La rapina al " .. name .. " è terminata.")
end)

RegisterNetEvent("kostino:notifyRobber")
AddEventHandler("kostino:notifyRobber", function(item, amount)
    ESX.ShowNotification("Hai ricevuto " .. amount .. "x " .. item .. " per la rapina completata.")
end)

RegisterNetEvent("kostino:notifyFDOFuga")
AddEventHandler("kostino:notifyFDOFuga", function(name)
    ESX.ShowNotification("📢 Centrale: il sospetto è fuggito dal " .. name)
end)
