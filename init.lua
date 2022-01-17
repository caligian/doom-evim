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
    vim.o.numberwidth = 4
    vim.o.tabstop = 4
    vim.o.shiftwidth = 4
    vim.o.expandtab = true
    vim.o.foldmethod = "syntax"
    vim.o.guifont="FiraCode NF:h12"
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
    -- This will load init.fnl
    vim.cmd [[ let g:aniseed#env = v:true ]]

    -- Add all user configurations to package path
    debug.traceback = require("fennel").traceback

    -- Load user lua files
    package.path = package.path .. ";" .. string.format("%s/.vdoom.d/?.lua", os.getenv("HOME"))

    package.path = package.path .. ";" .. string.format("%s/.vdoom.d/lua/?.lua", os.getenv("HOME"))

    -- Load user compiled fennel-to-lua files
    package.path = package.path .. ";" .. string.format("%s/.vdoom.d/compiled/?.lua", os.getenv("HOME"))

    -- Vim repl plugin
    vim.cmd "source ~/.config/nvim/vim/repl.vim"
end

init(vim)
