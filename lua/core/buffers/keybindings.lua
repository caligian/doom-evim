local buffer = require('core.buffers')

kbd('n', '<leader>xx', function() buffer(false, true):split() end, false, 'Open a new scratch buffer in sp'):enable()
kbd('n', '<leader>xX', function() buffer(false, true):vsplit() end, false, 'Open a new scratch buffer in vsp'):enable()
kbd('n', '<leader>fv', buffer.source_buffer, {'noremap', 'nowait', 'silent'}, 'Source/compile current buffer'):enable()
