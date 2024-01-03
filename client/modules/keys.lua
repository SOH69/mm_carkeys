local VehicleKeys = require 'client.interface'
local InventoryBridge = require 'bridge.inventory.client'

local KeyManagement = {
    getItemInfo = Shared.Inventory == 'qb' and function(item) return item.info end or function(item) return item.metadata end
}

function KeyManagement:SetVehicleKeys()
    VehicleKeys.playerKeys = {}
    local PlayerItems = InventoryBridge:GetPlayerItems()
    for _, item in pairs(PlayerItems) do
        local itemInfo = self.getItemInfo(item)
        if itemInfo and item.name == "vehiclekey" then
            VehicleKeys.playerKeys[itemInfo.plate] = true
        elseif itemInfo and item.name == "keybag" then
            for _,v in pairs(itemInfo.plates) do
                VehicleKeys.playerKeys[v.plate] = true
            end
        end
    end
end

function KeyManagement:GetKeys()
    lib.callback('mm_carkeys:server:getvehiclekeys', false, function(keysList)
        VehicleKeys.playerTempKeys = keysList
    end)
end

function KeyManagement:ToggleVehicleLock(vehicle)
    lib.requestAnimDict("anim@mp_player_intmenu@key_fob@")
    TaskPlayAnim(cache.ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3.0, 3.0, -1, 49, 0, false, false, false)
    TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 5, "lock", 0.3)
    NetworkRequestControlOfEntity(vehicle)
    local vehLockStatus = GetVehicleDoorLockStatus(vehicle)
    if vehLockStatus == 1 then
        TriggerServerEvent('mm_carkeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(vehicle), 2)
        lib.notify({
            description = 'Locked Vehicle',
            type = 'error'
        })
    else
        TriggerServerEvent('mm_carkeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(vehicle), 1)
        lib.notify({
            description = 'Unlocked Vehicle',
            type = 'success'
        })
    end
    SetVehicleLights(vehicle, 2)
    Wait(250)
    SetVehicleLights(vehicle, 1)
    Wait(200)
    SetVehicleLights(vehicle, 0)
    Wait(300)
    ClearPedTasks(cache.ped)
end

RegisterCommand('togglelocks', function()
    if VehicleKeys.currentVehicle == 0 then
        local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 3.0, false)
        local plate = GetVehicleNumberPlateText(vehicle)
        if VehicleKeys.playerKeys[plate] then
            KeyManagement:ToggleVehicleLock(vehicle)
        end
        return
    end
    if VehicleKeys.playerKeys[VehicleKeys.currentVehiclePlate] then
        KeyManagement:ToggleVehicleLock(VehicleKeys.currentVehicle)
    end
end, false)

RegisterKeyMapping('togglelocks', 'LOCK Vehicle', 'keyboard', 'L')

RegisterCommand('engine', function()
    if VehicleKeys.currentVehicle then
        local EngineOn = GetIsVehicleEngineRunning(VehicleKeys.currentVehicle)
        if EngineOn then
            SetVehicleEngineOn(VehicleKeys.currentVehicle, false, false, true)
            local plate = VehicleKeys.currentVehiclePlate or false
            if plate and not VehicleKeys.playerKeys[plate] and VehicleKeys.playerTempKeys[plate] then
                VehicleKeys.playerTempKeys[plate] = nil
                VehicleKeys:Init()
            end
            return
        end
        if VehicleKeys.playerKeys[VehicleKeys.currentVehiclePlate] then
            SetVehicleEngineOn(VehicleKeys.currentVehicle, true, true, true)
            return
        end
    end
end, false)

RegisterKeyMapping('engine', "Toggle Engine", 'keyboard', 'G')

lib.callback.register('mm_carkeys:client:getplate', function()
    if VehicleKeys.currentVehicle == 0 then return false end
    return VehicleKeys.currentVehiclePlate
end)

lib.callback.register('mm_carkeys:client:havekey', function(type, plate)
    if type == 'temp' then
        return VehicleKeys.playerTempKeys[plate] ~= nil
    elseif type == 'perma' then
        return VehicleKeys.playerKeys[plate] ~= nil
    end
end)

RegisterNetEvent('mm_carkeys:client:addtempkeys', function(plate)
    VehicleKeys.playerTempKeys[plate] = true
    if VehicleKeys.currentVehicle and cache.vehicle then
        local vehicleplate = GetVehicleNumberPlateText(cache.vehicle)
        if VehicleKeys.currentVehiclePlate == vehicleplate then
            VehicleKeys.hasKey = true
            SetVehicleEngineOn(VehicleKeys.currentVehicle, true, false, true)
            if VehicleKeys.showTextUi then
                lib.hideTextUI()
                VehicleKeys.showTextUi = false
            end
        end
    end
end)

RegisterNetEvent('mm_carkeys:client:removetempkeys', function(plate)
    VehicleKeys.playerTempKeys[plate] = nil
    if VehicleKeys.currentVehicle and cache.vehicle then
        local vehicleplate = GetVehicleNumberPlateText(cache.vehicle)
        if VehicleKeys.currentVehiclePlate == vehicleplate then
            VehicleKeys.hasKey = false
            SetVehicleEngineOn(VehicleKeys.currentVehicle, false, false, true)
            if not VehicleKeys.showTextUi then
                lib.showTextUI('Hotwire Vehicle', {
                    position = "left-center",
                    icon = 'h',
                })
                VehicleKeys.showTextUi = true
            end
        end
    end
end)

RegisterNetEvent('mm_carkeys:client:setplayerkey', function(plate, netId)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not plate or not netId then
        return lib.notify({
            description = 'No Vehicle Data Found',
            type = 'error'
        })
    end
    local model = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
    TriggerServerEvent('mm_carkeys:server:acquirevehiclekeys', plate, model)
end)

RegisterNetEvent('mm_carkeys:client:removeplayerkey', function(plate)
    if not plate then
        return lib.notify({
            description = 'No Vehicle Plate Found',
            type = 'error'
        })
    end
    TriggerServerEvent('mm_carkeys:server:removevehiclekeys', plate)
end)

RegisterNetEvent('mm_carkeys:client:givekeyitem', function()
    if VehicleKeys.currentVehicle == 0 then
        return lib.notify({
            description = 'You are not inside any vehicle',
            type = 'error'
        })
    end
    local model = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(VehicleKeys.currentVehicle)))
    if lib.progressBar({
        label = 'Making Vehicle Keys...',
        duration = 5000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        }
    }) then
        TriggerServerEvent('mm_carkeys:server:acquirevehiclekeys', VehicleKeys.currentVehiclePlate, model)
    else
        lib.notify({
            description = 'Action cancelled',
            type = 'error'
        })
    end
end)

RegisterNetEvent('mm_carkeys:client:removekeyitem', function()
    if VehicleKeys.currentVehicle == 0 then
        return lib.notify({
            description = 'You are not inside any vehicle',
            type = 'error'
        })
    end
    TriggerServerEvent('mm_carkeys:server:removevehiclekeys', VehicleKeys.currentVehiclePlate)
end)

RegisterNetEvent('mm_carkeys:client:stackkeys', function()
    if lib.progressBar({
        label = 'Stacking Keys...',
        duration = 5000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        anim = {
            dict = 'anim@amb@business@weed@weed_inspecting_high_dry@',
            clip = 'weed_inspecting_high_base_inspector'
        },
        disable = {
            car = true,
            move = true,
            combat = true
        }
    }) then
        TriggerServerEvent('mm_carkeys:server:stackkeys')
    else
        lib.notify({
            description = 'Action cancelled',
            type = 'error'
        })
    end
end)

RegisterNetEvent('mm_carkeys:client:unstackkeys', function()
    if lib.progressBar({
        label = 'Unstacking Keys...',
        duration = 5000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        anim = {
            dict = 'anim@amb@business@weed@weed_inspecting_high_dry@',
            clip = 'weed_inspecting_high_base_inspector'
        },
        disable = {
            car = true,
            move = true,
            combat = true
        }
    }) then
        TriggerServerEvent('mm_carkeys:server:unstackkeys')
    else
        lib.notify({
            description = 'Action cancelled',
            type = 'error'
        })
    end
end)

return KeyManagement