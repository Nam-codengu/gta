fx_version 'cerulean'
game 'gta5'

author 'Nam-codengu'
description 'Backpack Upgrade System with NUI Tabs (Upgrade, Transfer, Recycle, Ranking) for ox_inventory'
version '1.0.0'

shared_script 'shared/config_backpacks.lua'
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