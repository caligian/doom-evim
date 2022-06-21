local vimp = require('vimp')
local job = require('core.async')
local u = class('doom-utils')

function u.source_buffer(ft, cmd)
    ft = ft or vim.bo.filetype
    cmd = assoc(Doom.langs, {ft, 'compile'})
    if not cmd then return false end
    local fullpath = vim.fn.expand('%:p')
    local is_nvim_buffer = match(fullpath, 'nvim.*(lua|vim)$')

    if not is_nvim_buffer then
        local out = system(cmd .. ' ' .. vim.fn.expand('%:p'))
        local b = buffer()
        
        b:write({start_row=0, end_row=0}, out)
        b:split()

        return b
    elseif is_nvim_buffer == 'lua' then
        vim.cmd(':luafile ' .. vim.fn.expand('%:p')) 
    elseif is_nvim_buffer == 'vim' then
        vim.cmd(':source ' .. vim.fn.expand('%:p')) 
    end

    return out
end

return u
