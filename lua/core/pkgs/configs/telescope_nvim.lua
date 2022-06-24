local telescope = require('telescope')
local builtin = require('telescope.builtin')

local get_picker = function(picker_name)
    return function ()
        builtin[picker_name](ts.defaults.opts)
    end
end

telescope.setup(ts.defaults.opts)

-- File
kbd.new('n', '<leader>ff', get_picker('find_files'), false, 'Find git files'):enable()
kbd.new('n', '<leader>fr', get_picker('oldfiles'), false, 'Recent files'):enable()

-- Commands
kbd.new('n', '<leader>;', get_picker('commands'), false, 'Show commands' ):enable()
kbd.new('n', '<leader>:', get_picker('command_history'), false, 'Show commands' ):enable()

-- Marks and Registers
kbd.new('n', "<leader>'", get_picker('marks'), false, 'Show marks'):enable()
kbd.new('n', "<A-y>", get_picker('registers'), false, 'Show registers'):enable()

-- Qflist
kbd.new('n', "<leader>qq", get_picker('quickfix'), false, 'Show quickfix'):enable()
kbd.new('n', "<leader>qf", get_picker('quickfixhistory'), false, 'Show quickfix history'):enable()

-- Search
kbd.new('n', '<leader>/', get_picker('current_buffer_fuzzy_find'), false, 'Fuzzy findin current buffer'):enable()
kbd.new('n', '<leader>?', get_picker('grep_string'), false, 'Grep string in cwd'):enable()

-- LSP
kbd.new('n', '<leader>lr', get_picker('lsp_references'), false, 'Show references'):enable()
kbd.new('n', '<leader>ls', get_picker('lsp_document_symbols'), false, 'Show symbols in buffer'):enable()
kbd.new('n', '<leader>lS', get_picker('lsp_workspace_symbols'), false, 'Show workspace symbols'):enable()
kbd.new('n', '<leader>ld', get_picker('lsp_definitions'), false, 'Show definitions'):enable()
kbd.new('n', '<leader>lD', get_picker('lsp_type_definitions'), false, 'Show typedef'):enable()
kbd.new('n', '<leader>ll', get_picker('treesitter'), false, 'Show symbols (with treesitter)'):enable()

-- Git
kbd.new('n', '<leader>gB', get_picker('builtin.git_commits'), false, 'Show commits'):enable()
kbd.new('n', '<leader>gC', get_picker('builtin.git_bcommits'), false, 'Show buffer commits'):enable()
kbd.new('n', '<leader>gb', get_picker('builtin.git_branches'), false, 'Show branches'):enable()
kbd.new('n', '<leader>g?', get_picker('builtin.git_status'), false, 'Show git status'):enable() 
kbd.new('n', '<leader>gS', get_picker('builtin.git_stash'), false, 'Show stashes'):enable()
kbd.new('n', '<leader>gf', get_picker('git_files'), false, 'Find git files'):enable()

-- Buffer
kbd.new('n', '<leader>bb', get_picker('buffers'), false, 'Show listed buffers'):enable()

-- Misc
kbd.new('n', '<leader>ht', get_picker('colorscheme'), false, 'Change colorscheme'):enable()
kbd.new('n', '<C-space>', get_picker('resume'), false, 'Resume previous telescope'):enable()
kbd.new('n', 'z=', get_picker('spell_suggest'), false, 'Show spelling suggestions'):enable()
