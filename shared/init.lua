Shared.Ready = true -- dont Touch this

if GetResourceState('qb-core') == 'started' then -- change your core script
    Shared.Framework = 'qb' -- dont touch this
elseif GetResourceState('qbx_core') == 'started' then -- change your core script
    Shared.Framework = 'qbx' -- dont touch this
elseif GetResourceState('es_extended') == 'started' then -- change your core script
    Shared.Framework = 'esx' -- dont touch this
elseif GetResourceState('ox_core') == 'started' then -- change your core script
    Shared.Framework = 'ox' -- dont touch this
else
    Shared.Framework = false
    Shared.Ready = false
    warn('No Core Script found')
end

if GetResourceState('ox_inventory') == 'started' then -- change your inventory script
    Shared.Inventory = 'ox' -- dont touch this
elseif GetResourceState('mm_inventory') == 'started' then -- change your inventory script
    Shared.Inventory = 'qb' -- dont touch this
elseif GetResourceState('ps-inventory') == 'started' then -- change your inventory script
    Shared.Inventory = 'qb' -- dont touch this
elseif GetResourceState('qb-inventory') == 'started' then -- change your inventory script
    Shared.Inventory = 'qb' -- dont touch this
elseif GetResourceState('qs-inventory') == 'started' then -- change your inventory script
    Shared.Inventory = 'qb' -- dont touch this
else
    Shared.Inventory = false
    Shared.Ready = false
    warn('No Inventory found')
end