fx_version 'cerulean'
game 'gta5'
author 'Mirow'

shared_scripts {
    'config.lua'
}

client_scripts {
    '@NativeUILua_Reloaded/src/NativeUIReloaded.lua',
    'client.lua'
}

server_scripts {
    'server.lua',
    '@oxmysql/lib/MySQL.lua'
}