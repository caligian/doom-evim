local class = require('classy')
local path = require('path')
local buf = require('core.buffers')
local job = {}
local m = {}

job.status = Doom.async.job.status

-- Same args as `jobstart() or termopen()`
-- Make a job object but don't start the job.
-- @param name string Name of the job
-- @param cmd string Command to run
-- @param opts table Contains all the options for jobstart() and current job
function job.new(name, cmd, opts)
    claim.string(name)
    claim.string(cmd)
    claim.table(opts)

    local existing_job = get(job.status, name)

    if existing_job then
        if opts.force and existing_job.running then
            existing_job:kill()
        elseif existing_job.running then
            return existing_job
        end
    end

    opts.force = nil
    local self = module.new('vim-job', {
        vars = {
            id = -1;
            running = false;
            name = name;
            cmd = cmd;
            opts = opts;
        }
    }, m)
    update(job.status, self.name, self)

    return self
end

function m:repr()
    print(sprintf([[
%10s: %s
%10s: %s
%10s: %s
%10s: %s
%10s: %s
%10s: %s]], 
    'Name', self.name, 
    'Command', self.cmd,
    'Status', self.running and 'RUNNING' or 'NOT STARTED',
    'Done', self.done and 'DONE' or 'NOT DONE',
    'Channel', tostring(self.id),
    'Options', dump(self.opts or {})))
end

function m:kill()
    if not self.running then return false end
    self.buffer:delete()
    self.running = false
    self.done = true
    self.buffer = nil
    vim.fn.jobstop(self.id)
end

function m:show(direction)
    if not self.buffer:exists() then
        to_stderr('REPL was killed by user: ' .. self.cmd)
    else
        if self.running then
            self.buffer:split(direction)
        else
            to_stderr('Job has already been stopped for ' .. self.cmd)
        end
    end
end

function job.killall()
    for key, value in pairs(job.status) do
        if value.running then
            value:kill()
        end
    end
end

function m:send(s)
    if not self.running then return false end
    
    claim(s, 'table', 'string')

    if table_p(s) then s = join(s, "\n") end
    s = s .. "\n"

    return vim.fn.chansend(self.id, s)
end

function m:sync(opts)
    if not self.running then return false end

    assert(self.persistent ~= true, 'Cannot wait for output from a persistent terminal session')
    local opts = opts or {}

    opts.wait = opts.wait or 2
    opts.tries = opts.tries or 10
    opts.inc = opts.inc or 10
    opts.sched = opts.sched == nil and true

    return wait(function()
        if self.done then
            return true
        else
            return false
        end
    end, opts)
end

function m:wait()
    if not self.running then return false end
    return vim.fn.jobwait(self.id)
end

function m:open(opts)
    if self.running then return end

    opts = opts or self.opts or {}

    if not opts.on_exit then
        opts.on_exit = function (...)
            self.done = true
            self.running = false
        end
    end

    local function on_stdout(job_id, data, err)
        if not self.stdout then
            self.stdout = {}
        end

        for _, value in ipairs(to_list(data)) do
            if #value > 0 then
                table.insert(self.stdout, value)
            end
        end
    end

    local function on_stderr(job_id, data, err)
        if not self.stderr then
            self.stderr = {}
        end

        for _, value in ipairs(to_list(data)) do
            if #value > 0 then
                table.insert(self.stderr, value)
            end
        end
    end

    opts.on_stdout = opts.on_stdout == nil and false or on_stdout
    opts.on_stderr = opts.on_stderr == nil and false or on_stderr

    opts.env = opts.env or {
        HOME = os.getenv('HOME'),
        PATH = os.getenv('PATH'),
    }

    opts.cwd = opts.cwd or os.getenv('HOME')

    if opts.on_stderr and opts.stderr_buffered == nil then
        opts.stderr_buffered = true
    end

    if opts.on_stdout and opts.stdout_buffered == nil then
        opts.stdout_buffered = true
    end

    self.opts = opts

    local job = false
    if not opts.terminal then
        job = vim.fn.jobstart(self.cmd, opts)
        self.id = job
        self.running = true
        self.done = false
        self.pid = vim.fn.jobpid(self.id)
    else
        self.persistent = opts.persistent == true
        if opts.shell then self.cmd = Doom.langs.shell end
        opts.terminal = nil
        opts.persistent = nil
        opts.shell = nil
        self.terminal = true

        -- Sadly termopen() acts up after a kill signal is sent
        vcmd('tabnew term://' .. self.cmd)

        self.buffer = buf.new(vim.fn.bufnr())
        self.buffer:setopts {buflisted=false}
        self.id = vim.b.terminal_job_id
        self.pid = vim.fn.terminal_job_pid
        self.running = true
        self.done = false

        vcmd('tabclose')
    end
end

m.start = m.open

return job
