-- All the required modules
require('modules.utils').globalize()

globalize(require('modules.utils.table'))
globalize(require('modules.utils.string'))
globalize(require('modules.utils.function'))
globalize(require('modules.utils.nvim'))
globalize(require('modules.utils.param'))

-- Import globals
assoc(_G, {'Doom'}, require('core.globals'))

-- Add some modules as globals
add_global(require('path'), 'path')
add_global(require('path.fs'), 'fs')
add_global(require('classy'), 'class')
add_global(require('fun'), 'iter')

-- This is for convenience - global logger
require('core.exceptions')
require('core.log')

-- Load user overrides
-- Please note that you cannot avail much of the doom facilities while overriding so limit it to modifying _G.Doom
if path.exists(with_user_config_path('lua', 'user', 'init.lua')) then 
    require('user') 
end

-- Load doom packages
add_global(require('core.au'), 'au')
add_global(require('core.kbd'), 'kbd')
add_global(require('core.telescope'), 'ts')
add_global(require('core.pkgs'), 'pkgs')
add_global(require('core.notify'), 'notify')
add_global(require('core.buffers'), 'buffer')

-- Load extras from builtin modules
ts.font_switcher = require('core.telescope.font_switcher')
kbd.load_prefixes()

-- Require keybindings
require('core.buffers.keybindings')
local default_keybindings = require('core.kbd.defaults')
default_keybindings.set()

-- Successfuly load all the packages and their configurations (lazy or stat depending on its spec)
pkgs.load_plugins()

-- Load post-initialization user config
if path.exists(with_user_config_path('lua', 'user', 'config.lua')) then require('user.config') end
