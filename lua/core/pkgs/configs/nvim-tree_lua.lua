local kbd = dofile(with_config_lua_path('core', 'kbd', 'init.lua'))
local nvim_tree = require('nvim-tree')

nvim_tree.setup()

kbd.new('nvimtree', 'n', '<leader>`', ':NvimTreeToggle<CR>', {'noremap'}, 'Toggle nvim-tree'):enable()
