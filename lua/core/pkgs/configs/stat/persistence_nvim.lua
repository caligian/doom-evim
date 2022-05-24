local persistence = require('persistence')
local kbd = require('core.kbd')

persistence.setup {
    dir = with_data_path('sessions')
}

kbd(false, false, 'n', false, '<leader>sl', "lua require('persistence').load({last=true})<cr>", 'Load session'):enable()
kbd(false, false, 'n', false, '<leader>ss', "lua require('persistence').save()<cr>", 'Save current session'):enable()
