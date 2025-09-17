fx_version 'cerulean'
game 'gta5'

author 'Nam-codengu'
description 'Advanced Item Upgrade System (Transfer, Recycle, Ranking, Effects) for ox_inventory & EX'
version '1.0.0'

shared_script 'shared/config.lua'
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}
client_script 'client/main.lua'

ui_page 'nui/index.html'
files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js',
    'nui/sfx/*.mp3'
}