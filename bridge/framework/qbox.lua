if Shared.Framework == 'qbx' then
    local KeyManagement = require 'client.modules.keys'
    local VehicleKeys = require 'client.interface'
    local Utils = require 'client.modules.utils'

    local function setupData()
        VehicleKeys.currentVehicle = cache.vehicle and cache.vehicle or 0
        if cache.vehicle then
            VehicleKeys.isInDrivingSeat = GetPedInVehicleSeat(value, -1) == cache.ped
            local plate = GetVehicleNumberPlateText(value)
            VehicleKeys.currentVehiclePlate = Utils:RemoveSpecialCharacter(plate)
        end
    end

    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        KeyManagement:SetVehicleKeys()
        VehicleKeys:Thread()
        VehicleKeys:Init()
        KeyManagement:GetKeys()
    end)

    AddEventHandler('onResourceStart', function(resource)
        if GetCurrentResourceName() == resource and LocalPlayer.state.isLoggedIn then
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