local job = require('core.async.vim-job')
local buffer = require('core.buffers')

local repl = class('doom-repl')
assoc(Doom, {'repl', 'status'}, {})
repl.status = Doom.repl.status

function repl.find(ft)
    ft = ft or vim.bo.filetype
    return assoc(repl.status, ft .. '-repl')
end

function repl.delall()
    for _, value in pairs(repl.status) do
        if value.running  then
            value:delete()
        end
    end
end

-- @param method string '.' send current line, '~.' till current line, '~' for whole buffer, 'v' for visual range
-- @param s string If s is given then method is ignored and s is simply chansend()
function repl:send(method)
    assert_type(method, 'string', 'boolean')

    local pos = {}
    method = method or '.'
    method = strip(method)
    local bufname = vim.fn.expand('%')

    if match(bufname, '^tmp\\.', '^term://') or not self.shell and not vim.bo.filetype == self.filetype  then 
        return 
    end

    if not self.running then
        self.job:start()
    end

    local buf = buffer.find_by_bufnr(vim.fn.bufnr()) or buffer.new('%')
    assoc(self, {'connected'}, {})
    self.connected[buf.index] = buf
    local curpos = buf:getcurpos()

    if method == '.' then
        if vim.v.count > 0 then
            pos = { start_row=curpos.row, end_row=curpos.row + vim.v.count, }
        else
            pos = { start_row=curpos.row, end_row=curpos.row, }
        end
    elseif method == '~.' then
        pos = { start_row=0, end_row=curpos.row }
    elseif method == '~' then
        pos = { start_row=0, end_row=-1 }
    elseif method == 'v' then
        pos = buf:getvcurpos()
    end

    local s = buf:read(pos)
    self.job:send(s)

    return s
end

function repl:__init(name, cmd, job_opts)
    self.job = job.new(name, cmd, job_opts)
    self.connected = {}
    return self
end

function repl.new(name, job_opts, ft, cmd)
    assert_type(name, 'boolean', 'string')
    assert_type(cmd, 'boolean', 'string')
    assert_type(job_opts, 'boolean', 'table')
    assert_type(ft, 'boolean', 'string')

    job_opts = job_opts or {}
    ft = ft or vim.bo.filetype
    cmd = cmd or assoc(Doom.langs, {ft, 'repl'})

    if job_opts.shell then
        cmd = Doom.langs.shell
        job_opts.shell = nil
        ft = false
        name = 'shell-repl'
    elseif not cmd then
        to_stderr('No REPL command found for: ' .. vim.bo.filetype)
        return false
    else
        name = ft .. '-repl'
    end

    job_opts.terminal = true
    job_opts.persistent = true
    job_opts.on_stdout = false
    job_opts.on_stderr = false

    local self = repl(name, cmd, job_opts)
    self.filetype = ft
    update(repl.status, name, self)

    return self
end

function repl:start()
    self.job:start()
end

function repl:kill(...)
    self.job:kill(...)
end

function repl:delete()
    self.job:delete()
end

function repl:show(...)
    self.job:show(...)
end


return repl
