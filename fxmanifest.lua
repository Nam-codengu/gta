fx_version 'cerulean'
game 'gta5'

author 'Nam-codengu'
description 'Advanced Backpack Upgrade System with NUI Tabs for ox_inventory & EX'
version '1.0.0'

shared_scripts {
    'shared/config.lua',
    'shared/config_backpacks.lua'
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}
client_script 'client/main.lua'

ui_page 'web/build/index.html'
files {
    'web/build/index.html',
    'web/build/style.css',
    'web/build/app.js'
}