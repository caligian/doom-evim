local keybindings = {}
local kbd = require('core.kbd')
local attribs = {'noremap', 'silent', 'nowait'}

keybindings.tabs = {
    {'tabnew', 'n', '<leader>tt', ":tabnew <CR>", attribs, 'Open a new tab'};
    {'tabclose', 'n', '<leader>tk', ":tabclose <CR>", attribs, 'Close tab'};
    {'tabnext', 'n', '<leader>tn', ":tabnext <CR>", attribs, 'Next tab'};
    {'tabprev', 'n', '<leader>tp', ":tabprev <CR>", attribs, 'Previous tab'};
}

keybindings.misc = {
    {'clipboardpaste', 'v', '<leader>xy', '"+y', {'silent', 'nowait'}, 'Paste from clipboard'};
    {'clipboardcopy', 'v', '<leader>xp', '"+p', {'silent', 'nowait'}, 'Copy from clipboard'};
    {'nohighlight', 'n', '<leader><leader>', ":noh <CR>", attribs, 'Disable highlighting'};
    {'source%', 'n', '<leader>fv', function (bufnr, opts)
        opts = opts or {}
        bufnr = bufnr or vim.fn.bufnr()
        claim.number(bufnr)
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
            -- out = wait(vcmd, {':luafile ' .. fullpath, true}, {sched=true, timeout=1, tries=10, inc=2}) 
            out = vcmd(':luafile %s', fullpath)
        elseif is_nvim_buffer == 'vim' then
            out = vcmd(':source %s', fullpath) 
        end

        if out then
            echo("------\n" .. out)
        end
    end, attribs, 'Source buffer';
    }
}

keybindings.files = {
    {'savebuffer', 'n', '<leader>fs', ':w<CR>', attribs, 'Save file'};
}

keybindings.buffers = {
    {'readonlybuffer', 'n', '<leader>bR', ":if &modifiable == 1 <bar> set nomodifiable <bar> else <bar> set modifiable <bar> endif <CR>", attribs, 'Make current buffer readonly'};
    {'hidebuffer', 'n', '<leader>bk', ":hide <CR>", attribs, 'Hide current window'};
    {'wipeoutbuffer', 'n', '<leader>bq', ":bwipeout <CR>", attribs, 'Wipeout current buffer'};
    {'nextbuffer', 'n', '<leader>bn', ":bnext <CR>", attribs, 'Go to next buffer'};
    {'prevbuffer', 'n', '<leader>bn', ":bprev <CR>", attribs, 'Go to previous buffer'};
    {'reloadbuffer', 'n', '<leader>br', ":e % <CR>", attribs, 'Reload current buffer'};
}

update(Doom.kbd, 'defaults', keybindings)
Doom.kbd.loaded = false

if not Doom.kbd.loaded then
    if not overrides then
        local overrides_p = with_user_config_path('lua', 'user', 'kbd', 'defaults.lua')
        if path.exists(overrides_p) then
            overrides = require('user.kbd.defaults')
            claim.table(overrides)
        end
    end

    if overrides then
        each(keys(overrides), function(group)
            local specs = overrides[group]
            assoc(keybindings, group, {})
            each(partial(push, keybindings[group]), specs)
        end)
    end

    for k, v in pairs(keybindings) do
        if table_p(v) then
            each(v, function(_k) kbd.new(unpack(_k)):enable() end)
        end
    end

    Doom.kbd.loaded = true
end
