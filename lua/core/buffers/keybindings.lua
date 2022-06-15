local buffer = require('core.buffers')

kbd('n', '<leader>xx', function() buffer(false, true):split() end, {'noremap'}, 'Open a new scratch buffer'):enable()
kbd('n', '<leader>xX', function() buffer(false, true):vsplit() end, {'noremap'}, 'Open a new scratch buffer'):enable()
