local kbd = require('core.kbd')

kbd(false, false, 'n', false, '<leader>qf', '<Plug>(qf_qf_toggle)', 'Toggle qflist'):enable()

vim.g.qf_mapping_ack_style = 1
