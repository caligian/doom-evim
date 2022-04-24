local Persistence = require('persistence')
local Path = require('path')
local Kbd = require('core.doom-kbd')

Persistence.setup {
    dir = Path(vim.fn.stdpath('data'), 'sessions'),
}

Kbd.new({
    keys =  "<leader>sl",
    exec =  "lua =  require('persistence').load()<cr>",
    help =  "load session"
},
{
    keys =  "<leader>sl",
    exec =  "lua =  require('persistence').load({last=true})<cr>",
    help =  "load last session"
},
{
    keys =  "<leader>ss",
    exec =  "lua =  require('persistence').save()<cr>",
    help =  "save current session"
})
