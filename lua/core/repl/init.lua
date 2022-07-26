local job = require('core.async.vim-job')
local buffer = require('core.buffers')

local repl = {}
assoc(Doom, {'repl', 'status'}, {})
repl.status = Doom.repl.status
local m = {}

function repl.find(ft)
    ft = ft or vim.bo.filetype
    return assoc(repl.status, ft .. '-repl')
end

function repl.killall()
    for _, value in pairs(repl.status) do
        if value.running  then
            value:kill()
        end
    end
end

-- @param method string '.' send current line, '~.' till current line, '~' for whole buffer, 'v' for visual range
-- @param s string If s is given then method is ignored and s is simply chansend()
function m:send(method)
    claim(method, 'string', 'boolean')

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

function repl.new(name, job_opts, ft, cmd)
    claim(name, 'boolean', 'string')
    claim(cmd, 'boolean', 'string')
    claim(job_opts, 'boolean', 'table')
    claim(ft, 'boolean', 'string')

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

    local self = module.new('repl', {
        vars = {
            filetype = ft;
            job_opts = job_opts;
            name = name;
            cmd = cmd;
            job = job.new(name, cmd, job_opts);
            connected = {};
        }
    }, m)

    update(repl.status, name, self)
    return self
end

function m:start()
    self.job:start()
end

function m:kill(...)
    self.job:kill(...)
end

function m:delete()
    self.job:delete()
end

function m:show(...)
    self.job:show(...)
end

--local r = repl.new('lua-repl')
--r:start()
--r:show('s')
--r:send('.')

return repl
