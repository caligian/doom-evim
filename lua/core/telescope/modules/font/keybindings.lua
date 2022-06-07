local tfont = require('core.telescope.modules.font')
local kbd = require('core.kbd')

kbd('n', '<leader>hf', tfont, {noremap=true}, 'Switch to another font'):enable()
