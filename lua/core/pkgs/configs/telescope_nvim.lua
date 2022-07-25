local telescope = require('telescope')
local builtin = require('telescope.builtin')

local get_picker = function(picker_name)
    return function ()
        builtin[picker_name](ts.defaults.opts)
    end
end

telescope.setup(ts.defaults.opts)

-- File
kbd.new('ts_findfiles', 'n', '<leader>ff', get_picker('find_files'), false, 'Find git files'):enable()
kbd.new('ts_recentfiles', 'n', '<leader>fr', get_picker('oldfiles'), false, 'Recent files'):enable()

-- Commands
kbd.new('ts_commands', 'n', '<leader>;', get_picker('commands'), false, 'Show commands' ):enable()
kbd.new('ts_commandshistory', 'n', '<leader>:', get_picker('command_history'), false, 'Show commands' ):enable()

-- Marks and Registers
kbd.new('ts_marks', 'n', "<leader>'", get_picker('marks'), false, 'Show marks'):enable()
kbd.new('ts_registers', 'n', "<A-y>", get_picker('registers'), false, 'Show registers'):enable()

-- Qflist
kbd.new('ts_quickfix', 'n', "<leader>qq", get_picker('quickfix'), false, 'Show quickfix'):enable()
kbd.new('ts_quickfixhistory', 'n', "<leader>qf", get_picker('quickfixhistory'), false, 'Show quickfix history'):enable()

-- Search
kbd.new('ts_fzfgrep', 'n', '<leader>/', get_picker('current_buffer_fuzzy_find'), false, 'Fuzzy findin current buffer'):enable()
kbd.new('ts_grep', 'n', '<leader>?', get_picker('grep_string'), false, 'Grep string in cwd'):enable()

-- LSP
kbd.new('ts_lspreferences', 'n', '<leader>lr', get_picker('lsp_references'), false, 'Show references'):enable()
kbd.new('ts_lspdocumentsymbols', 'n', '<leader>ls', get_picker('lsp_document_symbols'), false, 'Show symbols in buffer'):enable()
kbd.new('ts_workspace_symbols', 'n', '<leader>lS', get_picker('lsp_workspace_symbols'), false, 'Show workspace symbols'):enable()
kbd.new('ts_lspdefinitions', 'n', '<leader>ld', get_picker('lsp_definitions'), false, 'Show definitions'):enable()
kbd.new('ts_typedefinitions', 'n', '<leader>lD', get_picker('lsp_type_definitions'), false, 'Show typedef'):enable()
kbd.new('ts_treesitter', 'n', '<leader>ll', get_picker('treesitter'), false, 'Show symbols (with treesitter)'):enable()

-- Git
kbd.new('ts_gitcommits', 'n', '<leader>gB', get_picker('builtin.git_commits'), false, 'Show commits'):enable()
kbd.new('ts_gitbranchcommits', 'n', '<leader>gC', get_picker('builtin.git_bcommits'), false, 'Show buffer commits'):enable()
kbd.new('ts_gitbranch', 'n', '<leader>gb', get_picker('builtin.git_branches'), false, 'Show branches'):enable()
kbd.new('ts_gitstatus', 'n', '<leader>g?', get_picker('builtin.git_status'), false, 'Show git status'):enable() 
kbd.new('ts_gitstash', 'n', '<leader>gS', get_picker('builtin.git_stash'), false, 'Show stashes'):enable()
kbd.new('ts_gitfiles', 'n', '<leader>gf', get_picker('git_files'), false, 'Find git files'):enable()

-- Buffer
kbd.new('ts_buffers', 'n', '<leader>bb', get_picker('buffers'), false, 'Show listed buffers'):enable()

-- Misc
kbd.new('ts_colorscheme', 'n', '<leader>ht', get_picker('colorscheme'), false, 'Change colorscheme'):enable()
kbd.new('ts_resume', 'n', '<C-space>', get_picker('resume'), false, 'Resume previous telescope'):enable()
kbd.new('ts_spellsuggest', 'n', 'z=', get_picker('spell_suggest'), false, 'Show spelling suggestions'):enable()
