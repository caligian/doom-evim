local persistence = require('persistence')
local kbd = require('core.kbd')

persistence.setup {
    dir = with_data_path('sessions')
}

kbd.new('persistenceload', 'n', '<leader>sl', "lua require('persistence').load({last=true})", 'noremap', 'Load session'):enable()
kbd.new('persistencesave', 'n', '<leader>ss', "lua require('persistence').save()<CR>", 'noremap', 'Save  current session'):enable()
