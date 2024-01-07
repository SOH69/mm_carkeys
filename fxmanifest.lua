fx_version "cerulean"
game 'gta5'
use_experimental_fxv2_oal 'yes'

author "Master Mind"
version '1.0.3'

lua54 'yes'

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

dependency 'ox_lib'