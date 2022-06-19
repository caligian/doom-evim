local job = require('core.async')
local buffer = require('core.buffers')
local repl = {}

function repl:__init(ft, cmd, job_opts)
    assert(name)
    assert_s(name)

    assert(cmd)
    assert_s(cmd)

    job_opts = job_opts or {}
    assert_t(job_opts)

    job_opts.terminal = true
    job_opts.persistent = true
    job_opts.on_stdout = false
    job_opts.on_stderr = false

    local ft = ft or vim.bo.filetype
    assert_s(ft)

    local cmd = assoc(Doom.langs, {ft, 'repl'})
    assert(cmd, 'No command found for filetype: ' .. vim.bo.filetype)
    
    local name = ft .. '-repl'
    local j = job(name, cmd, job_opts)

    self.job = j
    self.cmd = cmd
    self.name = name
end

function repl:open(opts)
    self.job:open(opts)
    self.buffer = self.job.buffer
end

-- @param method string '.' send current line, '~.' till current line, '~' for whole buffer, 'v' for visual range
-- @param s string If s is given then method is ignored and s is simply chansend()
function repl:send(method, s, no_ft_check)
    assert(method)
    assert_s(method)
    assert_type(s, 'string', 'table')

    if s then
        self.job:send(s)
        return
    end

    if not no_ft_check and vim.bo.filetype ~= self.filetype then return false end

    local current_buffer = false
    local bufnr = vim.fn.bufnr()
    if not self.buffers[bufnr] then
        current_buffer = buffer(bufnr)
    else
        current_buffer = self.buffers[bufnr]
    end

    if not current_buffer:is_visible() then return false end

    local pos = {}
    method = method or '.'
    method = strip(method)
    local curpos = current_buffer:getcurpos()

    if method == '.' then
        if vim.v.count > 0 then
            pos = { start_row=curpos.row, end_row=curpos.row + vim.v.count, }
        else
            pos = { start_row=curpos.row, end_row=curpos.start_row, }
        end
    elseif method == '~.' then
        pos = { start_row=0, end_row=curpos.row }
    elseif method == '~' then
        pos = { start_row=0, end_row=-1 }
    elseif method == 'v' then
        pos = current_buffer:getvcurpos()
    end

    local s = current_buffer:read(pos)

    self.job:send(s)
end



return repl
