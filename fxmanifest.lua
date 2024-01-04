fx_version "cerulean"
game 'gta5'
use_experimental_fxv2_oal 'yes'

author "Master Mind"
version '1.0.2'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/shared.lua',
    'shared/init.lua'
}

client_scripts {
    '@ox_core/imports/client.lua', -- Can be commented in case not using ox_core to prevent warning on startup
    'bridge/framework/*.lua',
    'client/init.lua'
}

server_scripts {
    '@ox_core/imports/server.lua', -- Can be commented in case not using ox_core to prevent warning on startup
    'server/commands.lua',
    'server/server.lua'
}

files {
    'bridge/inventory/*.lua',
    'client/interface.lua',
    'client/modules/*.lua',
    'server/bridge.lua',
}

dependency 'ox_lib'