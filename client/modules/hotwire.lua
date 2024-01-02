local VehicleKeys = require 'client.interface'

local Hotwire = {
    isHotwiring = false
}

function Hotwire:HotwireHandler()
    if self.isHotwiring then return end
    self.isHotwiring = true
    local hotwireTime = math.random(Shared.hotwire.minTime, Shared.hotwire.maxTime)
    local success = false
    SetVehicleAlarm(VehicleKeys.currentVehicle, true)
    SetVehicleAlarmTimeLeft(VehicleKeys.currentVehicle, hotwireTime)
    lib.hideTextUI()
    VehicleKeys.showTextUi = false
    if lib.progressBar({
        label = Shared.hotwire.label,
        duration = hotwireTime,
        position = 'bottom',
        allowCuffed = false,
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
            clip = 'machinic_loop_mechandplayer'
        }
    }) then
        TriggerServerEvent('hud:server:GainStress', Shared.hotwire.stressIncrease)
        if (math.random() <= Shared.hotwire.chance) then
            TriggerServerEvent('mm_carkeys:server:acquiretempvehiclekeys', VehicleKeys.currentVehiclePlate)
            SetVehicleEngineOn(VehicleKeys.currentVehicle, true, false, true)
            success = true
            return
        end
        lib.notify({
            title = 'Failed',
            description = 'Aah it seems too hard!',
            type = 'error'
        })
    else
        lib.notify({
            title = 'Failed',
            description = 'Cancelled hotwiring!',
            type = 'error'
        })
    end
    if VehicleKeys.currentVehicle and VehicleKeys.isInDrivingSeat and not success and not VehicleKeys.showTextUi then
        lib.showTextUI('Hotwire Vehicle', {
            position = "left-center",
            icon = 'h',
        })
        VehicleKeys.showTextUi = true
    end
    self.isHotwiring = false
end

function Hotwire:SetupHotwire()
    CreateThread(function()
        while VehicleKeys.currentVehicle ~= 0 and not VehicleKeys.hasKey do
            SetVehicleEngineOn(VehicleKeys.currentVehicle, false, false, true)
            if IsControlJustPressed(0, 74) then
                self:HotwireHandler()
            end
            Wait(5)
        end
    end)
end

return Hotwire