require('core.globals')

-- Your config starts here.
vim.o.foldenable = false
vim.o.completeopt = "menu,menuone,noselect"
vim.o.mouse="a"
vim.o.history = 1000
vim.o.ruler = true
vim.o.autochdir = true
vim.o.showcmd = true
vim.o.wildmode="longest,list,full"
vim.o.wildmenu = true
vim.o.termguicolors = true
vim.o.laststatus = 2
vim.o.mousefocus = true
vim.o.shell="/bin/bash"
vim.o.backspace="indent,eol,start"
vim.o.number = true
vim.o.numberwidth = 5
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.foldmethod = "syntax"
vim.o.guifont="UbuntuMono NF:h14"
vim.o.backupdir = string.format("%s/%s", vim.fn.stdpath("config"), "backup")
vim.o.directory = string.format("%s/%s", vim.fn.stdpath("config"), "tmp")
vim.o.undodir = string.format("%s/%s", vim.fn.stdpath("config"), "undo")
vim.g.session_autosave = false
vim.g.session_autoload = false

-- leader key
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Important terminal keybinding
vim.cmd [[ tnoremap <Esc> <C-\><C-n> ]]
vim.cmd [[ set inccommand=split ]]

-- Load impatient
require 'impatient'

-- Adding fennel searchers
-- Add all user configurations to package path
local fennel = require 'fennel'
debug.traceback = fennel.traceback
table.insert(package.loaders or package.searchers, fennel.searcher)

-- Change fennel-compiled results directory
vim.cmd [[ let g:aniseed#env = {'input': stdpath('config') . '/fnl/', 'output': stdpath('config') . '/compiled/'} ]]

local home = os.getenv('HOME')
package.path = string.format('%s;%s/compiled/?.lua', package.path, vim.fn.stdpath('config'))
package.path = string.format('%s;%s/.vdoom.d/compiled/?.lua', package.path, home)
package.path = string.format('%s;%s/.vdoom.d/lua/?.lua', package.path, home)
package.path = string.format('%s;%s/.vdoom.d/?.lua', package.path, home)

-- Add luarock support
package.path = string.format('%s;%s/.luarocks/share/lua/5.1/?.lua;%s/.luarocks/share/lua/5.1/?/init.lua', package.path, home, home)
package.cpath = string.format('%s;%s/.luarocks/lib/lua/5.1/?.so', package.cpath, home)

-- Open log quickly
vim.cmd [[ noremap <leader>fl :e ~/.local/share/nvim/doom-evim.log<CR> ]]

