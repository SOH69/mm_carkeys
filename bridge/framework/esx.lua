if Shared.Framework == 'esx' then
    local KeyManagement = require 'client.modules.keys'
    local VehicleKeys = require 'client.interface'

    local ESX = exports['es_extended']:getSharedObject()

    local function setupData()
        VehicleKeys.currentVehicle = cache.vehicle and cache.vehicle or 0
        if cache.vehicle then
            VehicleKeys.isInDrivingSeat = GetPedInVehicleSeat(cache.vehicle, -1) == cache.ped
            VehicleKeys.currentVehiclePlate = GetVehicleNumberPlateText(cache.vehicle)
        end
    end

    RegisterNetEvent('esx:playerLoaded', function()
        KeyManagement:SetVehicleKeys()
        VehicleKeys:Thread()
        VehicleKeys:Init()
    end)

    AddEventHandler('onResourceStart', function(resource)
        if GetCurrentResourceName() == resource and ESX.IsPlayerLoaded() then
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