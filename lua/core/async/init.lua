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

    self.status[self.name] = self
end

function job:kill()
    if self.done then return false end
    vim.fn.chanclose(self.id)
    self.done = true
    self.running = false
end

function job.killall()
    for key, value in pairs(job.status) do
        if value.running then
            value:kill()
        end
    end
end

function job:send(s)
    if not self.running then return false end

    if type(s) == 'table' then s = join(s, "\n") end
    s = s .. "\n"

    return vim.fn.chansend(self.id, s)
end

function job:sync(timeout, tries, inc, sched)
    if not self.running then return false end
    assert(self.persistent ~= true, 'Cannot wait for output from a persistent terminal session')

    wait = wait or 2
    tries = tries or 10
    inc = inc or 10
    sched = sched == nil and true

    return wait(timeout, tries, inc, sched, function()
        if self.done then
            return true
        else
            return false
        end
    end)
end

function job:open(opts)
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
        local shell = opts.shell or 'bash'

        opts.terminal = nil
        opts.persistent = nil
        opts.shell = nil
        self.terminal = true
        self.buffer = buf(self.name)

        if self.persistent then
            local _, temp_file = with_open(false, 'w', function(fh)
                if str_p(self.cmd) then
                    self.cmd = split(self.cmd, "\n\r")
                end

                map(function(s) fh:write(s .. "\n") end, self.cmd)
            end)

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
