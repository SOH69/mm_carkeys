if Shared.Framework == 'ox' then
    local KeyManagement = require 'client.modules.keys'
    local VehicleKeys = require 'client.interface'

    local function setupData()
        VehicleKeys.currentVehicle = cache.vehicle and cache.vehicle or 0
        if cache.vehicle then
            VehicleKeys.isInDrivingSeat = GetPedInVehicleSeat(cache.vehicle, -1) == cache.ped
            VehicleKeys.currentVehiclePlate = GetVehicleNumberPlateText(cache.vehicle)
        end
    end

    RegisterNetEvent('ox:playerLoaded', function()
        KeyManagement:SetVehicleKeys()
        VehicleKeys:Thread()
        VehicleKeys:Init()
    end)

    AddEventHandler('onResourceStart', function(resource)
        if GetCurrentResourceName() == resource and player then
            setupData()
            KeyManagement:SetVehicleKeys()
            VehicleKeys:Thread()
            VehicleKeys:Init()
        end
    end)

    AddEventHandler('ox_inventory:updateInventory', function()
        KeyManagement:SetVehicleKeys()
        VehicleKeys:Init()
    end)

    exports.ox_inventory:displayMetadata({platestxt = 'Vehicle Plates'})
end