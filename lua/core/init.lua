if not _G.Doom then _G.Doom = {} end

require('modules.utils').globalize()
require('vimp').add_chord_cancellations('n', '<leader>')
require('vimp').add_chord_cancellations('n', '<localleader>')

globalize(require('modules.utils.table'))
globalize(require('modules.utils.string'))
globalize(require('modules.utils.function'))
globalize(require('modules.utils.nvim'))
globalize(require('modules.utils.param'))

add_global(require('path'), 'path')
add_global(require('path.fs'), 'fs')

require('core.exceptions')
require('core.globals')
require('core.log')

add_global(require('core.au'), 'au')
add_global(require('core.notify'), 'notify')
add_global(require('core.kbd'), 'kbd'); kbd.load_prefixes()
add_global(require('core.pkgs'), 'pkgs')

if path.exists(with_user_config_path('lua', 'user', 'init.lua')) then
    require('user')
end

pkgs.load_all(Doom.pkgs.force_recompile)


