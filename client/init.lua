local VehicleKeys = require 'client.interface'
local Hotwire = require 'client.modules.hotwire'
local Steal = require 'client.modules.steal'

function VehicleKeys:Init()
    if self.currentVehicle == 0 then
        if VehicleKeys.showTextUi then
            lib.hideTextUI()
            VehicleKeys.showTextUi = false
        end
        return
    end
    self.hasKey =  self.playerKeys[self.currentVehiclePlate] or self.playerTempKeys[self.currentVehiclePlate]
    if not self.hasKey and not self.showTextUi then
        lib.showTextUI('Hotwire Vehicle', {
            position = "left-center",
            icon = 'h',
        })
        self.showTextUi = true
        Hotwire:SetupHotwire()
    elseif self.hasKey and self.showTextUi then
        lib.hideTextUI()
        self.showTextUi = false
    end
end

if Shared.Ready then
    lib.onCache('vehicle', function(value)
        if IsThisModelABicycle(GetEntityModel(value)) then return end
        if value then
            VehicleKeys.currentVehicle = value
            VehicleKeys.isInDrivingSeat = GetPedInVehicleSeat(value, -1) == cache.ped
            VehicleKeys.currentVehiclePlate = GetVehicleNumberPlateText(value)
        else
            VehicleKeys.currentVehicle = 0
            VehicleKeys.isInDrivingSeat = false
            VehicleKeys.currentVehiclePlate = false
            VehicleKeys:Thread()
        end
        VehicleKeys:Init()
    end)

    lib.onCache('seat', function(value)
        if not value then return end
        if IsThisModelABicycle(GetEntityModel(value)) then return end
        VehicleKeys.isInDrivingSeat = value == -1
        VehicleKeys:Init()
    end)

    lib.onCache('weapon', function(value)
        if not value then return end
        VehicleKeys.currentWeapon = value
        if not Shared.steal.available then return end
        Steal:CarjackInit()
    end)
end

function VehicleKeys:Thread()
    CreateThread(function()
        while self.currentVehicle == 0 do
            local wait = 200
            if VehicleKeys.currentVehicle ~= 0 then wait = 500 end
            local entering = GetVehiclePedIsTryingToEnter(cache.ped)
            local driver = GetPedInVehicleSeat(entering, -1)
            if entering ~= 0 then
                wait = 500
                if not Shared.playerDraggable and IsPedAPlayer(driver) then
                    SetPedCanBeDraggedOut(driver, false)
                end
                if Shared.LockNPCVehicle then
                    TriggerServerEvent('mm_carkeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(entering), 2)
                    TaskSmartFleePed(driver, cache.ped, -1, -1, false, false)
                elseif driver ~= 0 and not IsPedAPlayer(driver) and IsEntityDead(driver) then
                    Steal:GrabKey(entering)
                end
            end
            Wait(wait)
        end
    end)
end

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() == resource then
        if VehicleKeys.showTextUi then
            lib.hideTextUI()
            VehicleKeys.showTextUi = false
        end
    end
end)