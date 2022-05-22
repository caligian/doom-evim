local Kbd = require('core.doom-kbd')

Kbd.new({
    leader = 'l',
    keys = 'bq',
    exec = ':Bdelete<CR>',
    help = 'Delete current buffer',
})
