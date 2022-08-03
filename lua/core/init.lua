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
add_global(require('core.buffer'), 'buffer')
add_global(require('core.async.spawn'), 'spawn')
add_global(require('core.async.vim-job'), 'vim_job')
add_global(require('core.async.timer'), 'timer')
add_global(require('core.au.autocmd'), 'autocmd')

local lsp = require('core.lsp')
lsp.setup_nvim_cmp()
lsp.setup_servers()

-- Load extras from builtin modules
telescope.font_switcher = require('core.telescope.font_switcher')
require('core.telescope.font_switcher.keybindings')

-- Require keybindings
require('core.buffer.keybindings')
require('core.kbd.defaults')
require('core.repl.keybindings')

-- Require autocmds of modules
require('core.telescope.au')

-- Require formatter
require 'core.formatter.keybindings'

-- Template and snippets
require 'core.snippets'
require 'core.snippets.keybindings'
local templates = require 'core.templates'
require 'core.templates.keybindings'
templates.enable()

-- Successfuly load all the packages and their configurations (lazy or stat depending on its spec)
pkgs.load_plugins()

local a = au.new('StatuslineColorChanger', 'Change statusline colors automatically according to colorscheme.')
a:add('Colorscheme', '*', require('core.pkgs.configs.lualine_nvim').setup)
a:enable()

vim.cmd('colorscheme ' .. Doom.ui.theme)

-- Load post-initialization user config
if path.exists(with_user_config_path('lua', 'user', 'config.lua')) then require('user.config') end

vim.bo.filetype = 'lua'
