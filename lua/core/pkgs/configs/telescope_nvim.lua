local ivy_theme = require('telescope.themes').get_ivy({
    layout_config = {height=0.50}
})

local ts = require('telescope')
local builtin = require('telescope.builtin')
local get_picker = function(picker_name)
    return partial(builtin[picker_name], ivy_theme)
end

ts.setup(ivy_theme)

kbd('n', '<leader>ff', get_picker('find_files'), 'noremap', 'Find git files'):enable()
kbd('n', '<leader>gf', get_picker('git_files'), 'noremap', 'Find git files'):enable()
kbd('n', '<leader>gb', get_picker('git_branches'), 'noremap', 'Find git branches'):enable()
kbd('n', '<leader>gS', get_picker('git_status'), 'noremap', 'Show git status'):enable()
kbd('n', '<leader>bb', get_picker('buffers'), 'noremap', 'Show listed buffers'):enable()
kbd('n', '<leader>ht', get_picker('colorscheme'), 'noremap', 'Change colorscheme'):enable()
kbd('n', '<leader>fr', get_picker('oldfiles'), 'noremap', 'Recent files'):enable()


