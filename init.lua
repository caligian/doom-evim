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
    vim.o.guifont="BitstreamVeraSansMono NF:h12"
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

    -- Change terminal colors
    vim.g.terminal_color_0 = "#ffffff"
    vim.g.terminal_color_1 = "#DDB6F2"
    vim.g.terminal_color_2 = "#ABE9B3"
    vim.g.terminal_color_3 = "#FAE3B0"
    vim.g.terminal_color_4 = "#96CDFB"
    vim.g.terminal_color_5 = "#F5C2E7"
    vim.g.terminal_color_6 = "#DDB6F2"
    vim.g.terminal_color_7 = "#D9E0EE"
    vim.g.terminal_color_8 = "#575268"
    vim.g.terminal_color_9 = "#E8A2AF"
    vim.g.terminal_color_10 = "#B5E8E0"
    vim.g.terminal_color_11 = "#F8BD96"
    vim.g.terminal_color_12 = "#89DCEB"
    vim.g.terminal_color_13 = "#C9CBFF"
    vim.g.terminal_color_14 = "#F5E0DC"
    vim.g.terminal_color_15 = "#C3BAC6"
end

init(vim)
