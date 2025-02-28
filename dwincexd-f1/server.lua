QBCore = exports['qb-core']:GetCoreObject()

local vehicles = {
    { name = "manuelarac1", model = "panto" },
    { name = "manuelarac1", model = "tolraid" }
}

RegisterNetEvent("neiz-f1:fetchVehicles")
AddEventHandler("neiz-f1:fetchVehicles", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid

    local playerVehicles = vehicles

    exports.oxmysql:execute("SELECT vehicle FROM player_vehicles WHERE citizenid = ?", {citizenid}, function(results)
        for _, v in ipairs(results) do
            table.insert(playerVehicles, { name = v.vehicle, model = v.vehicle })
        end
        TriggerClientEvent("neiz-f1:openMenu", src, playerVehicles)
    end)
end)