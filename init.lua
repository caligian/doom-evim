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

local home = os.getenv('HOME')

-- Add luarock support
package.path = string.format('%s;%s/.luarocks/share/lua/5.1/?.lua;%s/.luarocks/share/lua/5.1/?/init.lua', package.path, home, home)
package.cpath = string.format('%s;%s/.luarocks/lib/lua/5.1/?.so', package.cpath, home)

-- Open log quickly
vim.cmd [[ noremap <leader>fl :e ~/.local/share/nvim/doom-evim.log<CR> ]]

-- In case nvim config is fucked up
if not _G.gkbd then 
    _G.gkbd = function (mode, lhs, rhs, noremap, opts)
        opts = opts or {}
        noremap = noremap == nil and true or noremap
        if noremap then opts.noremap = true end
        vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
    end
end

gkbd('n', '<leader>ff', ':Telescope find_files<CR>')
gkbd('n', '<leader>fr', ':Telescope oldfiles<CR>')
gkbd('n', '<leader>fs', ':w<CR>')
gkbd('n', '<leader>fv', ':w <bar> luafile %<CR>')
gkbd('n', '<leader>qq', ':qa!')
