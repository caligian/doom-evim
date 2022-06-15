local snippet_dir = with_user_config_path('snippets')
if not path.exists(snippet_dir) then fs.mkdir(snippet_dir) end
vim.g.vsnip_snippet_dir = snippet_dir
vim.g.vsnip_snippet_dirs = {snippet_dir, with_config_path('snippets')}

local _expand = "vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<C-j>'"
local _jump = "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'"
local _prev = "vsnip#jumpable(1) ? '<Plug>(vsnip-jump-prev)' : '<Tab>'"
local _next = "vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<Tab>'"
local attribs = {'expr'}
    
kbd('i', '<C-j>', _expand, attribs, 'Expand snippet under cursor'):enable()
kbd('s', '<C-j>', _expand, attribs, 'Expand snippet under cursor'):enable()

kbd('s', '<C-l>', _jump, attribs, 'Expand or jump to snippet under cursor'):enable()
kbd('i', '<C-l>', _jump, attribs, 'Expand or jump to snippet under cursor'):enable()

kbd('i', '<Tab>', _next, attribs, 'Jump to next field'):enable()
kbd('s', '<Tab>', _next, attribs, 'Jump to next field'):enable()

kbd('i', '<S-Tab>', _prev, attribs, 'Jump to prev field'):enable()
kbd('s', '<S-Tab>', _prev, attribs, 'Jump to prev field'):enable()
