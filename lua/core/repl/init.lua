local class = require('classy')
local job = require('core.async')
local buffer = require('core.buffers')
local repl = class('doom-repl', job)

-- opts as required by job
function repl:__init(name, job_opts)
    job_opts = job_opts or {}
    job_opts.terminal = true
    job_opts.persistent = true
    job_opts.on_stdout = false
    job_opts.on_stderr = false
    job_opts.on_exit = false

    self.filetype = job_opts.ft or vim.bo.filetype
    local cmd = job_opts.cmd
    if not cmd then 
        cmd = assoc(Doom.langs, {self.filetype, 'repl'}) 
    end

    oblige(cmd ~= '' or cmd ~= false, 'Need a command to start an repl')

    job.__init(self, name, cmd, job_opts)

    return self
end

-- @param method string '.' send current line, '~.' till current line, '~' for whole buffer, 'v' for visual range
-- @param s string If s is given then method is ignored and s is simply chansend()
function repl:send(method, s, no_ft_check)
    assoc(self, 'connected_buffers', {})

    if s then return job.send(self, s) end
    if not no_ft_check and vim.bo.filetype ~= self.filetype then return false end

    local current_buffer = false
    local bufnr = vim.fn.bufnr()
    if not self.connected_buffers[bufnr] then
        current_buffer = buffer(bufnr)
    else
        current_buffer = self.connected_buffers[bufnr]
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
    job.send(self, s)
end

return repl
