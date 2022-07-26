-- All the required modules
require('modules.utils')

-- Add some modules as globals
add_global(require('path'), 'path')
add_global(require('path.fs'), 'fs')
add_global(require('fun'), 'iter')
add_global(require('classy'), 'class')
add_global(class.multimethod, 'multimethod')
add_global(class.overload, 'overload')

-- Import globals
assoc(_G, {'Doom'}, require('core.globals'))

-- This is for convenience - global logger
add_global(require('core.exceptions'), 'ex')
require('core.log')

-- Load user overrides
-- Please note that you cannot avail much of the doom facilities while overriding so limit it to modifying _G.Doom
if path.exists(with_user_config_path('lua', 'user', 'init.lua')) then 
    require('user') 
end

-- Load doom packages
add_global(require('core.au'), 'au')
add_global(require('core.kbd'), 'kbd')
add_global(require('core.telescope'), 'telescope')
add_global(require('core.pkgs'), 'pkgs')
add_global(require('core.notify'), 'notify')
add_global(require('core.buffers'), 'buffer')

local lsp = require('core.lsp')
lsp.setup_nvim_cmp()
lsp.setup_servers()

-- Load extras from builtin modules
telescope.font_switcher = require('core.telescope.font_switcher')
require('core.telescope.font_switcher.keybindings')

-- Require keybindings
require('core.buffers.keybindings')
require('core.kbd.defaults')
require('core.repl.keybindings')

-- Require autocmds of modules
require('core.telescope.au')

-- Require formatter
require 'core.formatter.keybindings'

-- Successfuly load all the packages and their configurations (lazy or stat depending on its spec)
pkgs.load_plugins()

vim.cmd('colorscheme ' .. Doom.ui.theme)

-- Load post-initialization user config
if path.exists(with_user_config_path('lua', 'user', 'config.lua')) then require('user.config') end
