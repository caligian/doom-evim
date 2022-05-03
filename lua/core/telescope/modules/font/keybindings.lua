local TFS = require('core.telescope.modules.font')
local Kbd = require('core.kbd')

Kbd(false, false, 'n', false, '<leader>xf', TFS.switch_fonts, 'Switch to another font'):enable()
