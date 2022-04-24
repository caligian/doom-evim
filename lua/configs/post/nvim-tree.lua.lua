local NvimTree = require('nvim-tree')
local Kbd = require('core.doom-kbd')

NvimTree.setup()

Kbd.new({
    keys = '<leader>`',
    exec = ':NvimTreeToggle<CR>',
    help = 'Nvim tree toggle'
})

