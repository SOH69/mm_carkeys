local Bridge = {}

if Shared.Framework == "qb" then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Shared.Framework == "esx" then
    ESX = exports['es_extended']:getSharedObject()
end

function Bridge:GetPlayerCitizenId(id)
    if Shared.Framework == 'qb' then
        return QBCore.Functions.GetPlayer(id).PlayerData.citizenid
    elseif Shared.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(id)
        return xPlayer.getIdentifier()
    end
end

function Bridge:GetPlayer(id)
    if Shared.Framework == 'qb' then
        return QBCore.Functions.GetPlayer(id)
    elseif Shared.Framework == 'esx' then
        return ESX.GetPlayerFromId(id)
    end
end

function Bridge:GetPlayerJob(id)
    if Shared.Framework == 'qb' then
        local Player = QBCore.Functions.GetPlayer(id)
        return Player.PlayerData.job.name
    elseif Shared.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(id)
        return xPlayer.getJob().name
    end
end

function Bridge:AddItem(src, item, info)
    if Shared.Inventory == 'ox' then
        exports.ox_inventory:AddItem(src, item, 1, info)
    elseif Shared.Inventory == 'qb' then
        local Player = self:GetPlayer(src)
        Player.Functions.AddItem(item, 1, false, info)
        TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[item], "add")
    end
end

function Bridge:RemoveItem(src, item, slot)
    if Shared.Inventory == 'ox' then
        exports.ox_inventory:RemoveItem(src, item, 1, false, slot)
    elseif Shared.Inventory == 'qb' then
        local Player = self:GetPlayer(src)
        Player.Functions.RemoveItem(item, 1, slot)
        TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[item], "remove")
    end
end

function Bridge:GetPlayerItemsByName(src, item)
    if Shared.Inventory == 'ox' then
        return exports.ox_inventory:GetSlotsWithItem(src, item)
    elseif Shared.Inventory == 'qb' then
        local Player = self:GetPlayer(src)
        return Player.Functions.GetItemsByName(item)
    end
end

function Bridge:GetPlayerItemByName(src, item)
    if Shared.Inventory == 'ox' then
        return exports.ox_inventory:GetSlotWithItem(src, item)
    elseif Shared.Inventory == 'qb' then
        local Player = self:GetPlayer(src)
        return Player.Functions.GetItemByName(item)
    end
end

function Bridge:RemovePlayerKeyItem(src, info)
    local items = self:GetPlayerItemsByName(src, 'vehiclekey')
    for _, v in pairs(items) do
        if Shared.Inventory == 'ox' then
            if lib.table.matches(v.metadata, info) then
                exports.ox_inventory:RemoveItem(src, 'vehiclekey', 1, false, v.slot)
                return true
            end
        elseif Shared.Inventory == 'qb' then
            if lib.table.matches(v.info, info) then
                local Player = self:GetPlayer(src)
                Player.Functions.RemoveItem(src, 'vehiclekey', 1, v.slot)
                TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items["vehiclekey"], "remove")
                return true
            end
        end
    end
    return false
end

return Bridge