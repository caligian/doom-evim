local kbd = require('core.kbd')

kbd(false, false, 'n', false, '<leader>gg', ':Git<CR>', 'Open Fugitive'):enable()
kbd(false, false, 'n', false, '<leader>gs', ':Git stage<CR>', 'Stage current file'):enable()
kbd(false, false, 'n', false, '<leader>gp', ':Git push<CR>', 'Push changes to remote'):enable()
kbd(false, false, 'n', false, '<leader>ga', ':Git add<CR>', 'Git init in dir'):enable()
kbd(false, false, 'n', false, '<leader>gc', ':Git commit<CR>', 'Commit changes'):enable()
kbd(false, false, 'n', false, '<leader>gP', ':Git pull<CR>', 'Pull changes'):enable()
