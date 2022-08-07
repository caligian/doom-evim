local nvim_tree = require('nvim-tree')

nvim_tree.setup()

kbd.new('nvimtree', 'n', '<leader>`', ':NvimTreeToggle<CR>', {'noremap'}, 'Toggle nvim-tree'):enable()
