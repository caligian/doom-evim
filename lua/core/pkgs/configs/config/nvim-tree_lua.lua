local nvim_tree = require('nvim-tree')
local kbd = require('core.kbd')

nvim_tree.setup()
kbd(false, false, 'n', false, '<leader>`', 'NvimTreeToggle', 'Toggle nvim-tree'):enable()
