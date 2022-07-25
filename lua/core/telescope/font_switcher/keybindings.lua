local tfont = require('core.telescope.font_switcher')

kbd.new('ts_fontswitcher', 'n', tfont.keys or '<leader>hf', function ()
    tfont.new():find()
end, false, 'Switch to another font'):enable()
