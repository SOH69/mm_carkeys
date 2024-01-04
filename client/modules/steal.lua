local VehicleKeys = require 'client.interface'
local Utils = require 'client.modules.utils'

local Steal = {
    isCarjacking = false,
    canCarjack = true,
    isRobbingKeys = false
}

function Steal:ToggleCooldown()
    CreateThread(function()
        Wait(5000)
        self.canCarjack = true
        self:CarjackInit()
    end)
end

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
        SetVehicleUndriveable(vehicle, true)
        while self.isCarjacking do
            TaskSetBlockingOfNonTemporaryEvents(target, true)
            local distance = #(GetEntityCoords(cache.ped) - GetEntityCoords(target))
            if IsPedDeadOrDying(target, false) or distance > 7.5 then
                SetVehicleUndriveable(vehicle, false)
                if lib.progressActive() then
                    lib.cancelProgress()
                end
                break
            end
            Wait(25)
        end
    end)
end

function Steal:CarjackVehicle(target)
    if self.isCarjacking or not self.canCarjack then return end
    self.isCarjacking = true
    self.canCarjack = false
    local vehicle = GetVehiclePedIsUsing(target)
    local carjackChance = Shared.steal.chance[tostring(GetWeapontypeGroup(cache.weapon))] or 0.5
    local chance = math.random()
    if chance > carjackChance then
        TriggerServerEvent('mm_carkeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(vehicle), 2)
        TaskReactAndFleePed(target, cache.ped)
        self.isCarjacking = false
        self:ToggleCooldown()
        return
    end
    lib.requestAnimDict('missminuteman_1ig_2')
    local stealTime = math.random(Shared.steal.minTime, Shared.steal.maxTime)
    TaskLeaveVehicle(target, vehicle, 256)
    self:MakePedFlee(target, vehicle)
    CreateThread(function()
        Wait(350)
        self:CheckStealStatus(target)
        TaskTurnPedToFaceEntity(target, cache.ped, -1)
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
        self.isCarjacking = false
        StopAnimTask(target, "missminuteman_1ig_2", "handsup_base", 1.0)
        lib.requestAnimDict('mp_common')
        TaskPlayAnim(cache.ped, "mp_common", "givetake1_b", 8.0, -8, -1, 12, 1, false, false, false)
        TaskPlayAnim(target, "mp_common", "givetake1_b", 8.0, -8, -1, 12, 1, false, false, false)
        local targetPos = GetEntityCoords(target)
        TaskSmartFleePed(target, cache.ped, 50, -1, false, false)
        TriggerServerEvent('hud:server:GainStress', Shared.steal.stressIncrease)
        TriggerServerEvent('mm_carkeys:server:setVehLockState', NetworkGetNetworkIdFromEntity(vehicle), 1)

        local plate = GetVehicleNumberPlateText(vehicle)
        local modelName = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
        if Shared.steal.getKey then
            TriggerServerEvent('mm_carkeys:server:acquirevehiclekeys', plate, modelName)
        else
            TriggerServerEvent('mm_carkeys:server:acquiretempvehiclekeys', plate)
        end
        
        
    else
        StopAnimTask(target, "missminuteman_1ig_2", "handsup_base", 1.0)
        self.isCarjacking = false
        local targetPos = GetEntityCoords(target)
        TaskWanderInArea(target, targetPos.x, targetPos.y, targetPos.z, 5.0, 5.0, 5.0)
        TriggerServerEvent('hud:server:GainStress', Shared.steal.stressIncrease)
    end
    self:ToggleCooldown()
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
        TriggerServerEvent('mm_carkeys:server:acquiretempvehiclekeys', GetVehicleNumberPlateText(vehicle))
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
        while VehicleKeys.currentWeapon and VehicleKeys.currentVehicle == 0 do
            local aiming, target = GetEntityPlayerIsFreeAimingAt(cache.playerId)
            if aiming and (target ~= nil and target ~= 0) then
                if DoesEntityExist(target) and IsPedInAnyVehicle(target, false) and not IsEntityDead(target) and not IsPedAPlayer(target) then
                    local targetveh = GetVehiclePedIsIn(target, false)
                    if GetPedInVehicleSeat(targetveh, -1) == target and not Utils:IsBlacklistedWeapon() then
                        local pos = GetEntityCoords(cache.ped, true)
                        local targetpos = GetEntityCoords(target, true)
                        if #(pos - targetpos) < 5.0 then
                            self:CarjackVehicle(target)
                            break
                        end
                    end
                end
            end
            Wait(200)
        end
    end)
end

return Steal