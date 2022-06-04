local tfont = require('core.telescope.modules.font')
local kbd = require('core.kbd')

return to_callable(function(keys)
    keys = keys or '<leader>xf'

    local k = kbd('n', keys, tfont, {noremap=true}, 'Switch to another font')

    k:save()
    k:enable()

    return k
end)
