fx_version "cerulean"
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/shared.lua',
    'shared/init.lua'
}

client_scripts {
    'bridge/framework/*.lua',
    'client/init.lua'
}

server_scripts {
    'server/commands.lua',
    'server/server.lua'
}

files {
    'bridge/inventory/*.lua',
    'client/interface.lua',
    'client/modules/*.lua',
    'server/bridge.lua',
}