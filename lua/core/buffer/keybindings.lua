local buffer = require('core.buffer')
local kbd = require 'core.kbd'

kbd.new('splitscratch', 'n', '<leader>xxs', function() buffer.new(false, true):split('s', {force_resize=true}) end, false, 'Open a new scratch buffer in sp'):enable()
kbd.new('vsplitscratch', 'n', '<leader>xxv', function() buffer.new(false, true):vsplit({force_resize=true}) end, false, 'Open a new scratch buffer in vsp'):enable()
kbd.new('floatscratch', 'n', '<leader>xxf', function() buffer.new(false, true):to_win() end, false, 'Open a new scratch buffer in floating win'):enable()
kbd.new('tabscratch', 'n', '<leader>xxt', function() buffer.new(false, true):tabnew({force_resize=true}) end, false, 'Open a new scratch buffer in a new tab'):enable()
