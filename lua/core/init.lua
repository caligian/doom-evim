require('modules.utils').globalize()
require('vimp').add_chord_cancellations('n', '<leader>')
require('vimp').add_chord_cancellations('n', '<localleader>')

globalize(require('modules.utils.table'))
globalize(require('modules.utils.string'))
globalize(require('modules.utils.function'))
globalize(require('modules.utils.nvim'))
globalize(require('modules.utils.param'))

if not _G.Doom then _G.Doom = require('core.globals') end

add_global(require('path'), 'path')
add_global(require('path.fs'), 'fs')

require('core.exceptions')
require('core.globals')
require('core.log')

-- How user configs are read:
-- ~/.vdoom.d/lua/user/init.lua      // For updating overrides for global settings
-- ~/.vdoom.d/lua/user/config.lua    // Post-initiliazation configuration
if path.exists(with_user_config_path('lua', 'user', 'init.lua')) then require('user') end

add_global(require('core.au'), 'au')
add_global(require('core.pkgs'), 'pkgs')
add_global(require('core.notify'), 'notify')
add_global(require('core.kbd'), 'kbd'); kbd.load_prefixes()
add_global(require('core.buffers'), 'buffer')
add_global(require('core.telescope'), 'telescope')

require('core.buffers.keybindings')

if path.exists(with_user_config_path('lua', 'user', 'init.lua')) then require('user') end
-- Require module keybindings

pkgs.load_all(Doom.pkgs.force_recompile == nil and true or Doom.pkgs.force_recompile)
