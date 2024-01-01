local Bridge = require 'server.bridge'

lib.addCommand('givetempkeys', {
    help = 'Remove Temporary Keys',
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player\'s server id',
            optional = true,
        },
        {
            name = 'plate',
            type = 'string',
            help = 'Vehicle plate number',
            optional = true,
        }
    },
    restricted = 'group.admin'
}, function(source, args)
    local plate = args.plate
    if not plate then
        plate = lib.callback.await('mm_carkeys:client:getplate', source)
        if not plate then
            local ndata = {
                description = 'You are not in a vehicle',
                type = 'error'
            }
            TriggerClientEvent('ox_lib:notify', source, ndata)
            return
        end
    end
    GiveTempKeys(args.target or source, plate)
end)

lib.addCommand('removetempkeys', {
    help = 'Remove Temporary Keys',
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player\'s server id',
            optional = true,
        },
        {
            name = 'plate',
            type = 'string',
            help = 'Vehicle plate number',
            optional = true,
        }
    },
    restricted = 'group.admin'
}, function(source, args)
    local plate = args.plate
    if not plate then
        plate = lib.callback.await('mm_carkeys:client:getplate', source)
        if not plate then
            local ndata = {
                description = 'You are not in a vehicle',
                type = 'error'
            }
            TriggerClientEvent('ox_lib:notify', source, ndata)
            return
        end
    end
    RemoveTempKeys(args.target or source, plate)
end)

lib.addCommand('givekeys', {
    help = 'Give Permanent Keys',
    params = {},
}, function(source)
    local src = source
    local playerJob = Bridge:GetPlayerJob(src)
    if playerJob == "police" or playerJob == "cardealer" or IsPlayerAceAllowed(src, "admin") then
        TriggerClientEvent('mm_carkeys:client:givekeyitem', src)
        return
    end
    local ndata = {
		title = 'Failed',
    	description = 'Not Verified',
    	type = 'error'
	}
    TriggerClientEvent('ox_lib:notify', source, ndata)
end)

lib.addCommand('removekeys', {
    help = 'Remove Permanent Keys',
    params = {},
}, function(source)
    local src = source
    local playerJob = Bridge:GetPlayerJob(src)
    if playerJob == "police" or playerJob == "cardealer" or IsPlayerAceAllowed(src, "admin") then
        TriggerClientEvent('mm_carkeys:client:removekeyitem', src)
        return
    end
    local ndata = {
		title = 'Failed',
    	description = 'Not Verified',
    	type = 'error'
	}
    TriggerClientEvent('ox_lib:notify', source, ndata)
end)

lib.addCommand('stackkeys', {
    help = 'Stack Permanent Keys',
    params = {},
}, function(source)
    local src = source
    local keys = Bridge:GetPlayerItemsByName(src, 'vehiclekey')
    if not next(keys) then
        local ndata = {
            description = 'You don\'t have any keys',
            type = 'error'
        }
        TriggerClientEvent('ox_lib:notify', src, ndata)
        return
    end
    TriggerClientEvent('mm_carkeys:client:stackkeys', src)
end)

lib.addCommand('unstackkeys', {
    help = 'Unstack Permanent Keys',
    params = {},
}, function(source)
    local src = source
    local bag = Bridge:GetPlayerItemsByName(src, 'keybag')
    if not bag then
        local ndata = {
            description = 'You don\'t have a key bag',
            type = 'error'
        }
        TriggerClientEvent('ox_lib:notify', src, ndata)
        return
    end
    TriggerClientEvent('mm_carkeys:client:unstackkeys', src)
end)