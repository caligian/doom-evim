local Kbd = require('core.doom-kbd')

Kbd.new({
    keys = '<leader>qf',
    noremap = false,
    help = 'Toggle qflist',
    exec = '<Plug>(qf_qf_toggle)'
})

vim.g.qf_mapping_ack_style = 1
