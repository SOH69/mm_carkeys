local Utils = {}
local VehicleKeys = require 'client.interface'

function Utils:IsBlacklistedWeapon()
    if VehicleKeys.currentWeapon then
        for _, v in pairs(Shared.BlackListedWeapon) do
            if VehicleKeys.currentWeapon == joaat(v) then
                return true
            end
        end
    end
    return false
end

function Utils:GetPedsInVehicle(vehicle)
    if not vehicle then return end
    local otherPeds = {}
    for seat=-1,GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) - 2 do
        local pedInSeat = GetPedInVehicleSeat(vehicle, seat)
        if not IsPedAPlayer(pedInSeat) and pedInSeat ~= 0 then
            otherPeds[#otherPeds+1] = pedInSeat
        end
    end
    return otherPeds
end

function Utils:RemoveSpecialCharacter(txt)
    if not txt then return 'undefined' end
    return txt:gsub("%W", "")
end

return Utils