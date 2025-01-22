fx_version 'cerulean'
games { 'gta5' }

author 'Yarn'
description 'Console'
version '1.0.0'

ox_lib 'locale'

shared_scripts {
	'@ox_lib/init.lua',
	'imports.lua',
}

server_script 'server.lua'
client_scripts {
    '@qbx_core/modules/lib.lua',
    'client.lua',
}


ui_page "web/index.html"

files({
	"web/*",
})

lua54 'yes'
use_experimental_fxv2_oal 'yes'

dependencies {		-- All required dependencies
    'bl_ui',  		-- Hacking UI
    'fd_laptop',  	-- Laptop UI
    'ox_inventory', -- Inventory
}