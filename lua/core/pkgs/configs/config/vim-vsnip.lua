local Path = require('path')
local Kbd = require('core.doom-kbd')

vim.g.vsnip_snippet_dir = Path(vim.fn.stdpath('data'), 'doom-snippets')

Kbd.new({
    keys = '<C-j>',
    noremap = false,
    exec = "vsnip#expandable()  ? '<Plug>(vsnip-expand)' : '<C-j>'",
    attribs = 'expr',
    help = 'Expand snippet',
},
{
    keys = '<C-j>',
    noremap = false,
    mode = 'i',
    exec = 'vsnip#expandable() ? "<Plug>(vsnip-expand)" : "<C-j>"'
},
{
    keys = "<C-l>",
    mode = "s",
    attribs = "expr",
    noremap = false,
    help = "Expand or jump snippet",
    exec = "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'"
},

{
    keys = "<C-l>",
    mode = "i",
    noremap = false,
    attribs = "expr",
    help = "Expand or jump snippet",
    exec = "vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'"
},
{
    keys = "<S-Tab>",
    noremap = false,
    attribs = "expr",
    modes = "i",
    help = "Snippet jump to next field",
    exec = "vsnip#jumpable(1) ? '<Plug>(vsnip-jump-prev)'      : '<Tab>'"
},
{
    keys = "<S-Tab>",
    attribs = "expr",
    noremap = false,
    modes = "i",
    help = "Snippet jump to prev field",
    exec = "vsnip#jumpable(1) ? '<Plug>(vsnip-jump-prev)'      : '<Tab>'"
},
{
    keys = "<Tab>",
    noremap = false,
    attribs = "expr",
    modes = "s",
    help = "Snippet jump to next field",
    exec = "vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'"
},
{
    keys = "<Tab>",
    attribs = "expr",
    noremap = false,
    modes = "i",
    help = "Snippet jump to next field",
    exec = "vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'"
})
