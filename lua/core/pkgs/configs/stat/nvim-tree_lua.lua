local nvim_tree = require('nvim-tree')
local kbd = require('core.kbd')

nvim_tree.setup()
kbd(false, false, 'n', false, '<leader>`', ':NvimTreeToggle<CR>', 'Toggle nvim-tree'):enable()
