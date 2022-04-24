local Kbd = require('core.doom-kbd')

Kbd.new({
    keys = '<C-t>',
    help = 'Open tagbar',
    exec = ':TagbarToggle<CR>'
})
