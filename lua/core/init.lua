if not _G.Doom then _G.Doom = {} end

require('modules.utils').globalize()
globalize(require('modules.utils.table'))
globalize(require('modules.utils.string'))
globalize(require('modules.utils.function'))
globalize(require('modules.utils.nvim'))

add_global(require('path'), 'path')
add_global(require('path.fs'), 'fs')

require('core.exceptions')
require('core.globals')
require('core.log')
require('core.notify')
