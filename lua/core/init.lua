-- Basic keybindings in case of initialization failures
local basic_keys = {
    'noremap <leader>fv :source %',
    'noremap <leader>fs :w %',
    'noremap <leader>fR :if &modifiable == 1 <bar> set nomodifiable nonumber <bar> else <bar> set modifiable <bar> endif',

    'noremap <leader>bk :hide',
    'noremap <leader>bq :bwipeout',
    'noremap <leader>bn :bnext',
    'noremap <leader>br :e %',

    'noremap <leader>tt :tabnew',
    'noremap <leader>tk :tabclose',
    'noremap <leader>tn :tabnext',
    'noremap <leader>tp :tabprev',

    'noremap <localleader>,t :tabnew term://bash',
    'noremap <localleader>,S :split term://bash',
    'noremap <localleader>,V :vsplit term://bash',

    'noremap <leader>qq :qa!',
    'noremap <leader>qw :xa!',

    'noremap <leader><leader> :noh';
}

for _, basic_keys in ipairs(basic_keys) do vim.cmd(basic_keys .. '<CR>') end

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
add_global(require('core.pkgs'), 'pkgs')
add_global(require('core.notify'), 'notify')
add_global(require('core.kbd'), 'kbd')
add_global(require('core.buffers'), 'buffer')
add_global(require('core.telescope'), 'telescope')
kbd.load_prefixes()

-- Successfuly load all the packages and their configurations (lazy or stat depending on its spec)
pkgs.load_plugins()

-- Require keybindings
require('core.buffers.keybindings')

-- Load post-initialization user config
if path.exists(with_user_config_path('lua', 'user', 'config.lua')) then require('user.config') end
