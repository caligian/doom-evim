local keybindings = {}
local kbd = require('core.kbd')
local attribs = {'noremap', 'silent', 'nowait'}

keybindings.tabs = {
    {'n', '<leader>tt', ":tabnew <CR>", attribs, 'Open a new tab'};
    {'n', '<leader>tk', ":tabclose <CR>", attribs, 'Close tab'};
    {'n', '<leader>tn', ":tabnext <CR>", attribs, 'Next tab'};
    {'n', '<leader>tp', ":tabprev <CR>", attribs, 'Previous tab'};
}

keybindings.quit = {
    {'n', '<leader>qq', ":qa! <CR>", attribs, 'Quit unconditionally'};
    {'n', '<leader>qw', ":xa! <CR>", attribs, 'Save buffers and quit'};
}

keybindings.misc = {
    {'n', '<leader><leader>', ":noh <CR>", attribs, 'Disable highlighting'};
}

keybindings.terminal = {
    {'n', '<localleader>t', ":tabnew term://bash <CR>", attribs, 'Open bash in terminal in new tab'};
    {'n', '<localleader>S', ":split term://bash <CR>", attribs, 'Open bash in terminal in split'};
    {'n', '<localleader>V', ":vsplit term://bash <CR>", attribs, 'Open bash in terminal in vsplit'};
}
keybindings.files = {
    {'n', '<leader>fv', ':luafile %<CR>', attribs, 'Save and source lua buffer'};
    {'n', '<leader>fV', ":source %<CR>", attribs, 'Source current buffer'};
    {'n', '<leader>fs', ":w %<CR>", attribs, 'Save current buffer'};
}

keybindings.buffers = {
    {'n', '<leader>bR', ":if &modifiable == 1 <bar> set nomodifiable <bar> else <bar> set modifiable <bar> endif <CR>", attribs, 'Make current buffer readonly'};
    {'n', '<leader>bk', ":hide <CR>", attribs, 'Hide current window'};
    {'n', '<leader>bq', ":bwipeout <CR>", attribs, 'Wipeout current buffer'};
    {'n', '<leader>bn', ":bnext <CR>", attribs, 'Go to next buffer'};
    {'n', '<leader>bn', ":bprev <CR>", attribs, 'Go to previous buffer'};
    {'n', '<leader>br', ":e % <CR>", attribs, 'Reload current buffer'};
}

function keybindings.set(overrides)
    if not overrides then
        local overrides_p = with_user_config_path('lua', 'user', 'kbd', 'defaults.lua')
        if path.exists(overrides_p) then
            overrides = require('user.kbd.defaults')
            assert_t(overrides)
        end
    end

    if overrides then
        each(function(group)
            local specs = overrides[group]
            assoc(keybindings, group, {})
            each(partial(push, keybindings[group]), specs)
        end, keys(overrides))
    end

    for k, v in pairs(keybindings) do
        if table_p(v) then
            each(function(_k) kbd(unpack(_k)):enable() end, v)
        end
    end
end

keybindings.set()
