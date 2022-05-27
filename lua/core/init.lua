if not _G.Doom then _G.Doom = {} end

require('modules.utils').globalize()
require('modules.utils.table').globalize()
require('modules.utils.string').globalize()
require('modules.utils.function').globalize()
require('modules.utils.nvim').globalize()

add_global(require('classy'), 'class')
add_global(require('path'), 'path')
add_global(require('path.fs'), 'fs')

require('core.exceptions')
require('core.globals')
require('core.log')
