local path = require('path')
local kbd = require('core.kbd')

vim.g.vsnip_snippet_dir = with_user_config_path('snippets')
local expand = "vsnip#expandable()  ? '<Plug>(vsnip-expand)' : '<C-j>'"
local jump = "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'"
local prev = "vsnip#jumpable(1) ? '<Plug>(vsnip-jump-prev)'      : '<Tab>'"
local next = "vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)'      : '<Tab>'"
local si = {'s', 'i'}
local ni = {'s', 'i'}
local attribs = {noremap=false, 'expr'}

kbd(false, false, ni, attribs, '<C-j>', expand, 'Expand snippet under cursor'):enable()
kbd(false, false, si, attribs, '<C-l>', jump, 'Expand or jump to snippet under cursor'):enable()
kbd(false, false, 'i', attribs, '<Tab>', next, 'Jump to next field'):enable()
kbd(false, false, 'n', attribs, '<S-Tab>', prev, 'Jump to prev field'):enable()
