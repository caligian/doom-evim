local Path = require('path')

local bannerPath = Path(vim.fn.stdpath('config'), 'misc', 'punisher-logo.txt')
local fh = io.open(bannerPath, 'r')
local banner = fh:read()
fh:close()

vim.g.dashboard_custom_footer = {string.format(' %d packages loaded.', #Doom.packages)}
vim.g.dashboard_custom_header = banner
vim.g.indentline_filetypeexclude = {'dashboard'}
vim.g.dashboard_default_executive = 'telescope'
vim.g.dashboard_custom_section = {
    a = {
        description = {'  load previous session               SPC s l'},
        command = 'lua require("persistence").load({last = true})'
    },
    b = {
        description = {'  Recently opened files               SPC f r'},
        command = 'lua require("telescope.builtin").oldfiles(require("telescope.themes").get_ivy())'
    },
    c =  {
        description = {"  Change colorscheme                  SPC h t"},
        command =  "lua require('telescope.builtin').colorscheme(require('telescope.themes').get_ivy())"
    },
    d =  {
        description = {"  Split window with terminal          COM t s"},
        command =  "lua require('core.doom-repl').split"
    },
    e =  {
        description = {"  Find file                           SPC f f"},
        command = "lua require('telescope.builtin').find_files(require('telescope.themes').get_ivy())"
    },
    f =  {
        description = {"  Open system configuration           SPC f p"},
        command =  "e ~/.config/nvim"
    },
    g =  {
        description = {"  Open private configuration          SPC f p"},
        command =  "e ~/.vdoom.d/"
    }
}
