local snippet_dir = with_user_config_path('snippets')

if not path.exists(snippet_dir) then
    fs.mkdir(snippet_dir)
end

vim.g.vsnip_snippet_dir = snippet_dir

local _expand = "vsnip#expandable()  ? '<Plug>(vsnip-expand)' : '<C-j>'"
local _jump = "vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'"
local _prev = "vsnip#jumpable(1) ? '<Plug>(vsnip-jump-prev)'      : '<Tab>'"
local _next = "vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)'      : '<Tab>'"
local attribs = {'noremap', 'expr'}

kbd.new('i', '<C-j>', _expand, attribs, 'Expand snippet under cursor'):enable()
kbd.new('n', '<C-j>', _expand, attribs, 'Expand snippet under cursor'):enable()

kbd.new('s', '<C-l>', _jump, attribs, 'Expand or jump to snippet under cursor'):enable()
kbd.new('i', '<C-l>', _jump, attribs, 'Expand or jump to snippet under cursor'):enable()

kbd.new('i', '<Tab>', _next, attribs, 'Jump to next field'):enable()
kbd.new('n', '<Tab>', _next, attribs, 'Jump to next field'):enable()

kbd.new('i', '<S-Tab>', _prev, attribs, 'Jump to prev field'):enable()
kbd.new('n', '<S-Tab>', _prev, attribs, 'Jump to prev field'):enable()
