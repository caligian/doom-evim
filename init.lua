local function init(vim)
    vim.o.completeopt = "menu,menuone,noselect"
    vim.o.mouse="a"
    vim.o.history = 1000
    vim.o.ruler = true
    vim.o.autochdir = true
    vim.o.showcmd = true
    vim.o.wildmode="longest,list,full"
    vim.o.wildmenu = true
    vim.o.laststatus = 2
    vim.o.mousefocus = true
    vim.o.shell="/bin/bash"
    vim.o.backspace="indent,eol,start"
    vim.o.number = true
    vim.o.cursorline = true
    vim.o.numberwidth = 5
    vim.o.tabstop = 4
    vim.o.shiftwidth = 4
    vim.o.expandtab = true
    vim.o.foldmethod = "syntax"
    vim.o.guifont="RobotoMono NF:h12"
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

    -- Adding fennel searchers
    -- Add all user configurations to package path
    debug.traceback = require("fennel").traceback

    -- Change fennel-compiled results directory
    vim.cmd [[ let g:aniseed#env = v:true ]]

    local home = os.getenv('HOME')
    package.path = string.format('%s;%s/.vdoom.d/compiled/?.lua', package.path, home)
    package.path = string.format('%s;%s/.vdoom.d/lua/?.lua', package.path, home)
    package.path = string.format('%s;%s/.vdoom.d/?.lua', package.path, home)
end

init(vim)
