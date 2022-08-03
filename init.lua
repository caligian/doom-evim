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
vim.o.shell = "/bin/bash"
vim.o.backspace = "indent,eol,start"
vim.o.number = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.foldmethod = "indent"
vim.g.inccommand = 'split'
vim.g.session_autosave = false
vim.o.background = 'dark'
vim.g.session_autoload = false
vim.g.guifont = 'Liberation Mono:h16'

vim.cmd [[set ttimeout
set ttimeoutlen=1
set listchars=tab:>-,trail:~,extends:>,precedes:<,space:.
set ttyfast
let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_SR = "\<Esc>]50;CursorShape=2\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"]]

-- leader key
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Important terminal keybinding
vim.cmd [[ tnoremap <Esc> <C-\><C-n> ]]

local path = require('path')
local data_dir = vim.fn.stdpath('data')
vim.o.backupdir = path(data_dir, 'temp', 'backups')
vim.o.directory = path(data_dir, 'temp', 'tmp')
vim.o.undodir = path(data_dir, 'temp', 'undo')

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

if vim.fn.exists('g:fvim_loaded') then
    cmds = {
        FVimCursorSmoothMove = 'v:true',
        FVimCursorSmoothBlink = 'v:true',
        FVimAntiAlias = 'v:true',
        FVimFontHintLevel = 'full',
        FVimFontSubPixel = 'v:true',
        FVimFontAutoSnap = 'v:true',
        FVimFontNormalWeight = '100',
        FVimCursorSmoothMove = 'v:true',
        FVimCursorSmoothMove = 'v:true',
        FVimCursorSmoothMove = 'v:true',
    }

    for key, value in ipairs(cmds) do
        vim.cmd(k .. ' ' .. v)
    end
end

-- Load doom
require('core')
