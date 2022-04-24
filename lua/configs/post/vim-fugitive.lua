local Kbd = require('core.doom-kbd')

Kbd.new({
    leader = 'l',
    keys = 'gg',
    exec = ":Git<CR>",
    help = 'Open Fugitive',
},
{
    leader = 'l',
    keys = 'ga',
    exec = ':Git add %<CR>',
    help = 'Add and stage current file',
},
{
    leader = 'l',
    keys = 'gc',
    exec = ':Git commit %<CR>',
    help = 'Commit changes',
},
{
    leader = 'l',
    keys = 'gi',
    exec = ':Git init<CR>',
    help = 'Initialize git in cwd',
},
{
    leader = 'l',
    keys = 'gp',
    exec = ':Git push<CR>',
    help = 'Push commits',
},
{
    leader = 'l',
    keys = 'gm',
    exec = ':Git merge<CR>',
    help = 'Merge from remote',
})
