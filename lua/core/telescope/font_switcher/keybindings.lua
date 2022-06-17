local tfont = require('core.telescope.font_switcher')

if not kbd.find('n', '<leader>hf', 1) then
    kbd('n', tfont.keys, function() tfont():find() end, {'noremap'}, 'Switch to another font'):enable()
end


