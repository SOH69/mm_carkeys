local VehicleKeys = require 'client.interface'

local LockPick = {
    lockpicking = false,
}

function LockPick:Minigame()
    return lib.skillCheck('easy')
end

function LockPick:BreakLockPick(isAdvanced)
    local chance = math.random()
    local canBreak = isAdvanced and chance <= Shared.lockpick.advancedBreakChance or chance <= Shared.lockpick.breakChance
    if canBreak then
        TriggerServerEvent('mm_carkeys:server:removelockpick', isAdvanced and 'advancedlockpick' or 'lockpick')
    end
end

function LockPick:LockPickDoor(isAdvanced)
    local playerPos = GetEntityCoords(cache.ped)
    local vehicle = lib.getClosestVehicle(playerPos, 3.0, false)
    if not vehicle or GetVehicleDoorLockStatus(vehicle) == 1 then return end
    if self.lockpicking then return end
    self.lockpicking = true
    lib.requestAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
    TaskPlayAnim(cache.ped, 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 'machinic_loop_mechandplayer', 3.0, 3.0, -1, 49, 0, false, false, false)
    local result = self:Minigame()
    TriggerServerEvent('hud:server:GainStress', Shared.lockpick.stressIncrease)
    self:BreakLockPick(isAdvanced)
    self.lockpicking = false
    StopAnimTask(cache.ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
    if result then
        TriggerServerEvent('mm_carkeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(vehicle), 1)
        SetVehicleLights(vehicle, 2)
        Wait(250)
        SetVehicleLights(vehicle, 1)
        Wait(200)
        SetVehicleLights(vehicle, 0)
        return
    end
    SetVehicleAlarm(vehicle, true)
    SetVehicleAlarmTimeLeft(vehicle, 60000)
    lib.notify({
        title = 'Failed',
        description = 'Failed to lockpick the door!',
        type = 'error'
    })
end

function LockPick:LockPickEngine(isAdvanced)
    if VehicleKeys.currentVehicle == 0 or GetIsVehicleEngineRunning(VehicleKeys.currentVehicle) then return end
    if self.lockpicking then return end
    self.lockpicking = true
    lib.requestAnimDict("anim@amb@clubhouse@tutorial@bkr_tut_ig3@")
    TaskPlayAnim(cache.ped, 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 'machinic_loop_mechandplayer', 3.0, 3.0, -1, 49, 0, false, false, false)
    local result = self:Minigame()
    TriggerServerEvent('hud:server:GainStress', Shared.lockpick.stressIncrease)
    self:BreakLockPick(isAdvanced)
    self.lockpicking = false
    StopAnimTask(cache.ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
    if result then
        TriggerServerEvent('mm_carkeys:server:acquiretempvehiclekeys', VehicleKeys.currentVehiclePlate)
        SetVehicleEngineOn(VehicleKeys.currentVehicle, true, true, true)
        VehicleKeys.isEngineRunning = true
        return
    end
    SetVehicleAlarm(VehicleKeys.currentVehicle, true)
    SetVehicleAlarmTimeLeft(VehicleKeys.currentVehicle, 60000)
    lib.notify({
        title = 'Failed',
        description = 'Failed to lockpick the ignition!',
        type = 'error'
    })
end

return LockPick