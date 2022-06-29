local kbd = require('core.kbd')
local a = require('core.async')
local misc = {}
a.misc = misc

function misc.source_buffer(bufnr, opts)
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
        to_stderr(out)
    end
end

kbd.new('n', '<leader>fv', misc.source_buffer, {'noremap', 'nowait', 'silent'}, 'Source/compile current buffer'):enable()

return misc
