-- Your config starts here.
vim.o.foldenable = false
vim.o.completeopt = "menu,menuone,noselect"
vim.o.mouse = "a"
vim.o.history = 1000
vim.o.ruler = true
vim.o.autochdir = true
vim.o.showcmd = true
vim.o.wildmode = "longest,list,full"
vim.o.wildmenu = true
vim.o.termguicolors = true
vim.o.laststatus = 2
vim.o.mousefocus = true
vim.o.shell = "/bin/bash --login"
vim.o.backspace = "indent,eol,start"
vim.o.number = true
vim.o.cursorline = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.foldmethod = "indent"
vim.o.guifont = 'Ubuntu Mono:h14'
vim.g.inccommand = 'split'
vim.g.session_autosave = false
vim.o.background = 'dark'
vim.g.session_autoload = false
vim.cmd [[ color bold-light ]]

-- leader key
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Important terminal keybinding
vim.cmd [[ tnoremap <Esc> <C-\><C-n> ]]

local path = require('path')
local config_dir = vim.fn.stdpath('config')
vim.o.backupdir = path(config_dir, 'temp', 'backups')
vim.o.directory = path(config_dir, 'temp', 'tmp')
vim.o.undodir = path(config_dir, 'temp', 'undo')

local home = os.getenv('HOME')
-- paths
package.path = package.path .. ';' .. home .. '/.local/share/nvim/luarocks/share/lua/5.1/?.lua'
package.path = package.path .. ';' .. home .. '/.local/share/nvim/luarocks/share/lua/5.1/?/init.lua'
package.path = package.path .. ';' .. home .. '/.local/share/nvim/luarocks/share/lua/5.1/?/?.lua'
package.path = package.path .. ';' .. home .. '/.vdoom.d/lua/?.lua'
package.path = package.path .. ';' .. home .. '/.vdoom.d/lua/?/?.lua'
package.path = package.path .. ';' .. home .. '/.vdoom.d/lua/?/init.lua'

-- cpaths
package.cpath = package.cpath .. ';' .. home .. '/.local/share/nvim/luarocks/share/lua/5.1/?.so'

-- Temp keybindings
local kbd = {
    'noremap <leader>ff :Telescope find_files',
    'noremap <leader>fr :Telescope oldfiles',
    'noremap <leader>fv :source %',
    'noremap <leader>fs :w %',
    'noremap <leader>fR :if &modifiable == 1 <bar> set nomodifiable nonumber <bar> else <bar> set modifiable <bar> endif',

    'noremap <leader>gf :Telescope git_files',
    'noremap <leader>gb :Telescope git_branches',
    'noremap <leader>gS :Telescope git_status',
    'noremap <leader>gs :Git stage %',
    'noremap <leader>gp :Git push',
    'noremap <leader>gg :Git',
    'noremap <leader>gi :Git init',
    'noremap <leader>gc :Git commit',
    'noremap <leader>ga :Git add %',

    'noremap <leader>bb :Telescope buffers',
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

    'noremap <leader><leader> :noh'
}

for _, kbd in ipairs(kbd) do vim.cmd(kbd .. '<CR>') end

-- Load doom
require('core')
