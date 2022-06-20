local kbd = require('core.kbd')
local u = require('core.utils')
local au = require('core.au')

kbd('n', '<leader>fv', au.register(u.source_buffer, 'key'), {'noremap', 'nowait', 'silent'}, 'Source/compile current buffer'):enable()
