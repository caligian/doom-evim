local kbd = require('core.kbd')
local ab = require('core.async.buffer')

kbd.new('n', '<leader>fv', ab.source_buffer, {'noremap', 'nowait', 'silent'}, 'Source/compile current buffer'):enable()
