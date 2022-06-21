local class = require('classy')
local path = require('path')
local buf = require('core.buffers')
local job = class('doom-async-job')

job.status = Doom.async.job.status

-- Same args as `jobstart() or termopen()`
-- Make a job object but don't start the job.
-- @param name string Name of the job
-- @param cmd string Command to run
-- @param opts table Contains all the options for jobstart() and current job
function job:__init(name, cmd, opts)
    assert(name)
    assert(cmd)

    opts = opts or {}

    self.id = -1
    self.cmd = cmd
    self.name = name
    self.opts = opts
    self.running = false
    self.opts = opts or {}

    self.status[self.name] = self
end

function job:repr()
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

function job:kill()
    if self.done then return false end
    self.done = true
    self.running = false

    pcall(function ()
        vim.fn.chanclose(self.id)

        if self.buffer then
            self.buffer:wipeout()
        end
    end)
end

function job:delete()
    self:kill()
    remove(Doom.async.job.status, self.name)
end

function job.killall()
    for key, value in pairs(job.status) do
        if value.running then
            value:kill()
        end
    end
end

function job.delall()
    for key, value in pairs(job.status) do
        if value.running then
            value:delete()
        end
    end
end

job.deleteall = job.delall
job.delete_all = job.deleteall

function job:send(s)
    if not self.running then return false end
    
    assert(s)
    assert_type(s, 'string', 'table')

    if table_p(s) then s = join(s, "\n") end
    s = s .. "\n"

    return vim.fn.chansend(self.id, s)
end

function job:sync(opts)
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

function job:open(opts)
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

    local job = false
    if not opts.terminal then
        job = vim.fn.jobstart(self.cmd, opts)
        self.id = job
        self.running = true
        self.done = false
    else
        self.persistent = opts.persistent == true
        local shell = opts.shell or Doom.langs.shell
        if shell == true then
            shell = Doom.langs.shell
        end

        opts.terminal = nil
        opts.persistent = nil
        opts.shell = nil
        self.terminal = true
        self.buffer = buf(self.name)

        if self.persistent then
            local _, temp_file = with_tempfile('w', function(fh)
                if str_p(self.cmd) then
                    self.cmd = split(self.cmd, "\n\r")
                end

                map(function(s) fh:write(s .. "\n") end, self.cmd)
            end, true)

            self.cmd = shell .. ' ' .. temp_file
        end

        self.buffer:exec(function()
            self.id = vim.fn.termopen(self.cmd, opts)
            self.running = true
            self.done = false
        end)
    end
end

job.start = job.open

return job
