--[[ ===================================================== ]]--
--[[        QBCore 3 in 1 AI EMS Script by MaDHouSe        ]]--
--[[ ===================================================== ]]--

fx_version 'cerulean'
games { 'gta5' }

author 'MaDHouSe'
description 'MH Anti Hankers.'
version '1.0.0'

shared_scripts {
    'config.lua',
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/update.lua',
}

dependencies {
    'oxmysql',
    'qb-core',
}

lua54 'yes'
