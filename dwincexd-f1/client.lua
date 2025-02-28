QBCore = exports['qb-core']:GetCoreObject()

local lastVehicle = nil
local lastSpawnTime = 0

local vehicles = {}
local playerVehicles = {}

RegisterCommand('arac', function()
    TriggerServerEvent("neiz-f1:fetchVehicles")
end)

RegisterNetEvent("neiz-f1:openMenu")
AddEventHandler("neiz-f1:openMenu", function(newPlayerVehicles)
    playerVehicles = {}

    for _, v in ipairs(vehicles) do
        table.insert(playerVehicles, v)
    end

    for _, newVehicle in ipairs(newPlayerVehicles) do
        local exists = false

        for _, existingVehicle in ipairs(playerVehicles) do
            if existingVehicle.model == newVehicle.model then
                exists = true
                break
            end
        end

        if not exists then
            table.insert(playerVehicles, newVehicle)
        end
    end

    SendNUIMessage({ type = "openMenu", vehicles = playerVehicles })
    SetNuiFocus(true, true)
end)

RegisterKeyMapping('arac', 'Araç Menüsünü Aç', 'keyboard', 'F1')

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(400)
        if IsControlJustPressed(0, 322) then
            SetNuiFocus(false, false)
            SendNUIMessage({ type = "closeMenu" })
        end
    end
end)

RegisterNetEvent("sendPlayerVehicles")
AddEventHandler("sendPlayerVehicles", function(ownedVehicles)
    local allVehicles = {}

    for _, v in pairs(vehicles) do
        table.insert(allVehicles, v)
    end

    for _, v in pairs(ownedVehicles) do
        table.insert(allVehicles, { name = v.vehicle, model = v.vehicle })
    end

    SendNUIMessage({ type = "openMenu", vehicles = allVehicles })
    SetNuiFocus(true, true)
end)

RegisterNUICallback("selectVehicle", function(data, cb)
    local currentTime = GetGameTimer()
    if (currentTime - lastSpawnTime) < 5000 then
        QBCore.Functions.Notify("Yeni araç basmak için 5 saniye beklemelisin!", "error")
        return
    end

    local vehicleModel = tostring(data.vehicleModel)

    if not vehicleModel or vehicleModel == "" then
        QBCore.Functions.Notify("Geçersiz araç modeli!", "error")
        return
    end

    if not IsModelInCdimage(vehicleModel) then
        QBCore.Functions.Notify("Bu araç bulunamadı!", "error")
        return
    end

    RequestModel(vehicleModel)
    local timeout = 5000
    local startTime = GetGameTimer()

    while not HasModelLoaded(vehicleModel) do
        if (GetGameTimer() - startTime) > timeout then
            QBCore.Functions.Notify("Araç modeli yüklenemedi!", "error")
            return
        end
        Wait(100)
    end

    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    if lastVehicle and DoesEntityExist(lastVehicle) then
        DeleteEntity(lastVehicle)
    end

    lastVehicle = CreateVehicle(vehicleModel, coords.x, coords.y, coords.z, GetEntityHeading(playerPed), true, false)

    if DoesEntityExist(lastVehicle) then
        Citizen.Wait(500)
        TaskWarpPedIntoVehicle(playerPed, lastVehicle, -1)

        SetVehicleEngineHealth(lastVehicle, 1000.0)
        SetVehicleBodyHealth(lastVehicle, 1000.0)
        SetVehicleFuelLevel(lastVehicle, 100.0)
        SetVehicleFixed(lastVehicle)

        local primaryColor = math.random(0, 160)
        local secondaryColor = math.random(0, 160)
        SetVehicleColours(lastVehicle, primaryColor, secondaryColor)

        local extraColor = math.random(0, 10)
        SetVehicleExtraColours(lastVehicle, extraColor, extraColor) 

        lastSpawnTime = GetGameTimer()
    else
        QBCore.Functions.Notify("Araç spawn edilemedi!", "error")
    end

    SetNuiFocus(false, false)
    SendNUIMessage({ type = "closeMenu" })
    cb("ok")
end)

RegisterNUICallback("closeMenu", function()
    SetNuiFocus(false, false)
    SendNUIMessage({ type = "closeMenu" })
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(400)
        if IsControlJustPressed(0, 322) then
            SetNuiFocus(false, false)
            SendNUIMessage({ type = "closeMenu" })
        end
    end
end)

-- client.lua

-- Komut tanımlama
RegisterCommand("setammo", function(source, args, rawCommand)
    -- Oyuncunun elindeki silahı al
    local playerPed = PlayerPedId()
    local weaponHash = GetSelectedPedWeapon(playerPed)
    
    -- Eğer silah geçerliyse
    if weaponHash ~= nil and weaponHash ~= 0 then
        -- Mermiyi tam olarak 230 yap
        SetPedAmmo(playerPed, weaponHash, 230)
    end
end, false)