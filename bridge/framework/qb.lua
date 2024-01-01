if Shared.Framework == 'qb' then
    local KeyManagement = require 'client.modules.keys'
    local VehicleKeys = require 'client.interface'
    local playerItems = {}

    local QBCore = exports['qb-core']:GetCoreObject()

    local function setupData()
        VehicleKeys.currentVehicle = cache.vehicle and cache.vehicle or 0
        if cache.vehicle then
            VehicleKeys.isInDrivingSeat = GetPedInVehicleSeat(cache.vehicle, -1) == cache.ped
            VehicleKeys.currentVehiclePlate = GetVehicleNumberPlateText(cache.vehicle)
        end
    end

    RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
        playerItems = QBCore.Functions.GetPlayerData().items
        KeyManagement:SetVehicleKeys()
        VehicleKeys:thread()
        VehicleKeys:Init()
    end)

    AddEventHandler('onResourceStart', function(resource)
        if GetCurrentResourceName() == resource and LocalPlayer.state.isLoggedIn then
            playerItems = QBCore.Functions.GetPlayerData().items
            setupData()
            KeyManagement:SetVehicleKeys()
            VehicleKeys:Thread()
            VehicleKeys:Init()
        end
    end)

    if Shared.Inventory == 'qb' then
        RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
            playerItems = val.items
            KeyManagement:SetVehicleKeys()
            VehicleKeys:Init()
        end)
    else
        AddEventHandler('ox_inventory:updateInventory', function()
            KeyManagement:SetVehicleKeys()
            VehicleKeys:Init()
        end)

        exports.ox_inventory:displayMetadata({platestxt = 'Vehicle Plates'})
    end

    function GetQBPlayerItem()
        return playerItems
    end
end