local job = require('core.async')
local buffer = require('core.buffers')

local repl = class('doom-repl', job)
assoc(Doom, {'repl', 'status'}, {})
repl.status = Doom.repl.status

function repl.find_job(ft)
    ft = ft or vim.bo.filetype
    return assoc(repl.status, ft .. '-repl')
end

function repl:__init(name, job_opts, ft, cmd)
    assert_type(name, 'boolean', 'string')
    assert_type(cmd, 'boolean', 'string')
    assert_type(job_opts, 'boolean', 'table')
    assert_type(ft, 'boolean', 'string')

    job_opts = job_opts or {}
    ft = ft or vim.bo.filetype
    cmd = cmd or assoc(Doom.langs, {ft, 'repl'})

    if not cmd and job_opts.shell then
        if str_p(job_opts.shell) then
            cmd = job_opts.shell 
        else
            cmd = Doom.langs.shell
        end

        self.shell = cmd
        ft = false
    end

    assert(cmd, 'No command found for filetype: ' .. vim.bo.filetype)

    if ft then
        name = ft .. '-repl'
    else
        name = 'shell-repl'
    end

    local existing_job = assoc(Doom.async.job.status, name)

    if existing_job and job_opts.force then
        local j = existing_job
        j:delete()
    elseif existing_job then
        if existing_job.running then
            merge(self, existing_job)
            return self
        else
            existing_job:delete()
        end
    end

    job_opts.terminal = true
    job_opts.persistent = true
    job_opts.on_stdout = false
    job_opts.on_stderr = false

    self.filetype = ft
    self.connected_buffers = {}
    self.status[name] = self

    job.__init(self, name, cmd, job_opts)
end

-- @param method string '.' send current line, '~.' till current line, '~' for whole buffer, 'v' for visual range
-- @param s string If s is given then method is ignored and s is simply chansend()
function repl:send_from_buffer(method)
    assert_type(method, 'string', 'boolean')

    local pos = {}
    method = method or '.'
    method = strip(method)
    local bufname = vim.fn.expand('%')

    if match(bufname, '^tmp\\.', '^term://') or not self.shell and not vim.bo.filetype == self.filetype  then 
        return 
    end

    local buf = buffer.find_by_bufnr(vim.fn.bufnr()) or buffer('%')

    self.connected_buffers[buf.index] = buf
    local curpos = buf:getcurpos()

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
        pos = buf:getvcurpos()
    end

    local s = buf:read(pos)
    self:send(s)
end

function repl.killall()
    for _, value in pairs(repl.status) do
        value:delete()
    end
end

return repl
