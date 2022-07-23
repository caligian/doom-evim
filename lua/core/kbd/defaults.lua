local keybindings = {}
local kbd = require('core.kbd')
local attribs = false

keybindings.tabs = {
    {'n', '<leader>tt', ":tabnew <CR>", attribs, 'Open a new tab'};
    {'n', '<leader>tk', ":tabclose <CR>", attribs, 'Close tab'};
    {'n', '<leader>tn', ":tabnext <CR>", attribs, 'Next tab'};
    {'n', '<leader>tp', ":tabprev <CR>", attribs, 'Previous tab'};
}

keybindings.misc = {
    {'n', '<leader><leader>', ":noh <CR>", attribs, 'Disable highlighting'};
    {'n', '<leader>fv', function (bufnr, opts)
        opts = opts or {}
        bufnr = bufnr or vim.fn.bufnr()
        assert_n(bufnr)
        assert(vim.fn.bufnr(bufnr) ~= -1, 'Invalid bufnr provided')

        vim.cmd(':buffer ' .. bufnr)

        local ft = vim.bo.filetype
        local cmd = assoc(Doom.langs, {ft, 'compile'})
        if not cmd then return false end
        local fullpath = vim.fn.expand('%:p')
        local is_nvim_buffer = match(fullpath, vim.fn.stdpath('config') .. '.+(lua|vim)$')
        local out = false

        if not is_nvim_buffer then
            out = vim.fn.system(cmd .. ' ' .. fullpath)
        elseif is_nvim_buffer == 'lua' then
            out = wait(vcmd, {':luafile ' .. fullpath, true}, {sched=true, timeout=1, tries=10, inc=2}) 
        elseif is_nvim_buffer == 'vim' then
            out = vcmd(':source %s', fullpath) 
        end

        if out then
            echo(out)
        end
    end, attribs, 'Source buffer';
    }
}

keybindings.files = {
    {'n', '<leader>fs', ':w<CR>', attribs, 'Save file'};
}

keybindings.buffers = {
    {'n', '<leader>bR', ":if &modifiable == 1 <bar> set nomodifiable <bar> else <bar> set modifiable <bar> endif <CR>", attribs, 'Make current buffer readonly'};
    {'n', '<leader>bk', ":hide <CR>", attribs, 'Hide current window'};
    {'n', '<leader>bq', ":bwipeout <CR>", attribs, 'Wipeout current buffer'};
    {'n', '<leader>bn', ":bnext <CR>", attribs, 'Go to next buffer'};
    {'n', '<leader>bn', ":bprev <CR>", attribs, 'Go to previous buffer'};
    {'n', '<leader>br', ":e % <CR>", attribs, 'Reload current buffer'};
}

update(Doom.kbd, 'defaults', keybindings)

if not Doom.kbd.loaded then
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
            each(function(_k) kbd.new(unpack(_k)):enable() end, v)
        end
    end

    Doom.kbd.loaded = true
end
