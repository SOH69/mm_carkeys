local VehicleKeys = require 'client.interface'
local Utils = require 'client.modules.utils'

local Steal = {
    isCarjacking = false,
    isRobbingKeys = false
}

function Steal:MakePedFlee(target, vehicle)
    local occupants = Utils:GetPedsInVehicle(vehicle)
    for p=1, #occupants do
        local ped = occupants and occupants[p] or 0
        CreateThread(function()
            if ped ~= target then
                TaskLeaveVehicle(ped, vehicle, 256)
                TaskReactAndFleePed(ped, cache.ped)
                PlayPain(ped, 6, 0)
            end
        end)
    end
end

function Steal:CheckStealStatus(target)
    CreateThread(function()
        while self.isCarjacking do
            SetVehicleUndriveable(vehicle, true)
            TaskSetBlockingOfNonTemporaryEvents(target, true)
            local distance = #(GetEntityCoords(cache.ped) - GetEntityCoords(target))
            if IsPedDeadOrDying(target, false) or distance > 7.5 then
                SetVehicleUndriveable(vehicle, false)
                if lib.progressActive() then
                    lib.cancelProgress()
                end
                break
            end
            Wait(10)
        end
    end)
end

function Steal:CarjackVehicle(target)
    if self.isCarjacking then return end
    self.isCarjacking = true
    lib.requestAnimDict('missminuteman_1ig_2')
    local stealTime = math.random(Shared.steal.minTime, Shared.steal.maxTime)
    local vehicle = GetVehiclePedIsUsing(target)
    SetVehicleCanBeUsedByFleeingPeds(vehicle, false)
    TaskLeaveVehicle(target, vehicle, 256)
    self:MakePedFlee(target, vehicle)
    CreateThread(function()
        Wait(350)
        self:CheckStealStatus(target)
        TaskTurnPedToFaceEntity(target, cache.ped, 3.0)
        TaskPlayAnim(target, "missminuteman_1ig_2", "handsup_base", 8.0, -8.0, -1, 49, 0, false, false, false)
    end)
    if lib.progressBar({
        label = Shared.steal.label,
        duration = stealTime,
        position = 'bottom',
        allowCuffed = false,
        useWhileDead = false,
        canCancel = true
    }) then
        local carjackChance = Shared.steal.chance[GetWeapontypeGroup(cache.weapon)] or 0.5
        self.isCarjacking = false
        TaskSetBlockingOfNonTemporaryEvents(target, false)
        ClearPedTasks(target)
        Wait(1000)
        TaskReactAndFleePed(target, cache.ped)
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        if math.random() <= carjackChance then
            lib.notify({
                title = 'Failed',
                description = 'Cannot retrive the keys!',
                type = 'error'
            })
            TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
            self:CarjackInit()
            return
        end
        lib.requestAnimDict('mp_common')
        TaskPlayAnim(target, "mp_common", "givetake1_a", 8.0, -8, -1, 12, 1, false, false, false)
        TriggerServerEvent('vehiclekeys:server:AcquireTempVehicleKeys', GetVehicleNumberPlateText(vehicle))
    else
        self.isCarjacking = false
        TaskReactAndFleePed(target, cache.ped)
        TaskSetBlockingOfNonTemporaryEvents(target, false)
        ClearPedTasks(target)
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        self:CarjackInit()
    end
    SetVehicleUndriveable(vehicle, false)
end

function Steal:GrabKey(vehicle)
    if self.isRobbingKeys then return end
    self.isRobbingKeys = true
    local robTime = math.random(Shared.grab.minTime, Shared.grab.maxTime)
    if lib.progressBar({
        label = Shared.grab.label,
        duration = robTime,
        position = 'bottom',
        allowCuffed = false,
        useWhileDead = false,
        canCancel = true
    }) then
        TriggerServerEvent('mm_carkeys:server:AcquireTempVehicleKeys', GetVehicleNumberPlateText(vehicle))
    else
        lib.notify({
            title = 'Failed',
            description = 'Failed to find keys!',
            type = 'error'
        })
    end
    self.isRobbingKeys = false
end

function Steal:CarjackInit()
    CreateThread(function()
        while VehicleKeys.currentWeapon do
            local aiming, target = GetEntityPlayerIsFreeAimingAt(cache.playerId)
            if aiming and (target ~= nil and target ~= 0) then
                if DoesEntityExist(target) and IsPedInAnyVehicle(target, false) and not IsEntityDead(target) and not IsPedAPlayer(target) then
                    local targetveh = GetVehiclePedIsIn(target, false)
                    if GetPedInVehicleSeat(targetveh, -1) == target and not Utils:IsBlacklistedWeapon() then
                        local pos = GetEntityCoords(cache.ped, true)
                        local targetpos = GetEntityCoords(target, true)
                        if #(pos - targetpos) < 5.0 then
                            self:CarjackVehicle(target)
                        end
                    end
                end
            end
            Wait(200)
        end
    end)
end

return Steal