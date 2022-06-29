local buffer = require('core.buffers')

kbd.new('n', '<leader>xxs', function() buffer.new(false, true):split('s', {force_resize=true}) end, false, 'Open a new scratch buffer in sp'):enable()
kbd.new('n', '<leader>xxv', function() buffer.new(false, true):vsplit({force_resize=true}) end, false, 'Open a new scratch buffer in vsp'):enable()
kbd.new('n', '<leader>xxf', function() buffer.new(false, true):to_win() end, false, 'Open a new scratch buffer in floating win'):enable()
kbd.new('n', '<leader>xxt', function() buffer.new(false, true):tabnew({force_resize=true}) end, false, 'Open a new scratch buffer in a new tab'):enable()
