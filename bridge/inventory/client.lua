local InventoryBridge = {}

function InventoryBridge:GetPlayerItems()
    if Shared.Inventory == 'qb' then
        return GetQBPlayerItem()
    elseif Shared.Inventory == 'ox' then
        return exports.ox_inventory:GetPlayerItems()
    end
end

return InventoryBridge