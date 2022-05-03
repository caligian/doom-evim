local Class = require('classy')
local Path = require('path')
local Buf = require('core.buffers')
local Notify = require('core.doom-notify')
local Utils = require('core.doom-utils')
local JobException = require('core.async.exceptions')
local Job = Class('doom-async-job')

Job.status = {}

local job_opts_template = {
    -- Any jobstart() stuff +
    
    show = {
        method = 'echo|err|notify|float',
        
        -- If false then don't show. Default:true
        stdout = true,
        stderr = true,

        -- If method is notify
        title = 'message',
        args = 'other args',

        -- If method is float
        -- Any args acceptable by nvim_open_win()
    },
}

-- Same args as `jobstart() or termopen()`
-- Make a job object but don't start the job.
-- @param name string Name of the job
-- @param cmd string Command to run
-- @param opts table Contains all the options for jobstart() and current job
function Job:__init(name, cmd, opts)
    assert(name)
    assert(cmd)

    opts = opts or {}

    self.cmd = cmd
    self.name = name
    self._opts = opts
    self.running = false
    self.done = false
    self.exceptions = JobException(self)

    Job.status[self.name] = self
end

function Job:kill()
    if not self.done then
        vim.fn.chanclose(self.job_id)
        self.done = true
        Job.status[self.name] = nil
    end
end

function Job.killall()
    for key, value in pairs(Job.status) do
        if value.running then
            value:kill()
        end
    end
end

function Job:send(s)
    self.exceptions:assert(self.running, 'pending')

        if type(s) == 'table' then
            s = table.concat(s, "\n")
        end

        s = s .. "\n"

        vim.fn.chansend(self.job_id, s)
end

function Job:sanitize_opts(opts)
    opts = opts or self._opts
    local allowed = {
        clear_env = true,
        cwd = true,
        detach = true,
        env = true,
        height = true,
        on_exit = true,
        on_stderr = true,
        on_stdout = true,
        stdin = true,
        rpc = true,
        pty = true,
        stderr_buffered = true,
        stdout_buffered = true,
        width = true,
    }

    local new = {}
    for key, value in pairs(opts) do
        if allowed[key] then
            new[key] = value
        end
    end

    return new
end

-- Only works if terminal=true
function Job:focus(direction)
    local opts = self._opts or {}
    direction = direction or self._opts.direction or 'sp'

    if self._opts.terminal then
        self.terminal.buffer:focus(direction)
    end
end

function Job:show_output(opts)
    opts = opts or self._opts or {}
    opts.show = opts.show or {}
    opts.show.method = opts.show.method or 'sp'
    opts.show.stdout = not opts.show.stdout and type(opts.show.stdout) == 'boolean' and false or true
    opts.show.stderr = not opts.show.stderr and type(opts.show.stderr) == 'boolean' and false or true

    self:sync()

    local function _notify()
        local title = opts.show.title or string.format('doom job for command `%s` says', self.cmd)

        local args = opts.show.args or {}

        if opts.show.stdout and #self.stdout > 0 then
            Notify.info(title, self.stdout, args)
        end

        if opts.show.stderr and #self.stderr > 0 then
            Notify.info(title, self.stderr, args)
        end
    end

    local function _echo()
        if opts.show.stdout and #self.stdout > 0 then
            vim.api.nvim_echo({{table.concat(self.stdout, "\n")}}, false, {})
        end

        if opts.show.stderr and #self.stderr > 0 then
            vim.api.nvim_echo({{table.concat(self.stderr, "\n")}}, false, {})
        end
    end

    local function _err()
        if opts.show.stdout and #self.stdout > 0 then
            vim.api.nvim_err_writeln(table.concat(self.stdout, "\n"))
        end

        if opts.show.stderr and #self.stderr > 0 then
            vim.api.nvim_err_writeln(table.concat(self.stderr, "\n"))
        end
    end

    local function _split()
        local current_buf = Buf(vim.fn.expand('%'))

        if opts.show.stdout and self.stdout and #self.stdout > 0 then
            local buf = Buf('_async_command_stdout_' .. #(Utils.keys(current_buf.status)))

            current_buf:split(buf, opts.show.direction or 'sp', {
                on_open = function (buf_obj)
                    buf_obj.write:lines(self.stdout, {row={from=0}})
                    buf_obj:setopts {buflisted=false, buftype='nofile'}
                end,
            })
        end

        if opts.show.stderr and self.stderr and #self.stderr > 0 then
            local bufname = '_async_command_stdout_' .. #(Utils.keys(current_buf.status))
            current_buf:split(bufname, opts.show.direction or 'sp', {
                on_open = function (buf_obj)
                    buf_obj.write:lines(self.stderr, {row={from=0}})
                end,
                create = true,
            })

            current_buf:setopts {buftype='nofile'}
        end
    end

    local function _win()
        local floating_temp_buf = Buf()

        if #self.stdout > 0 and opts.show.stdout then
            floating_temp_buf.write:lines(self.stdout, {row={from=0}})
        end

        if #self.stderr > 0 and opts.show.stderr then
            floating_temp_buf.write:lines(self.stderr, {row={from=0}})
        end

        floating_temp_buf.float:show()
        floating_temp_buf:setopts {buftype='nofile', buflisted=false}
    end

    local method = opts.show.method
    if method:match('sp') then
        _split()
    elseif method:match('err') then
        _err()
    elseif method:match('win') or method:match('float') then
        _win()
    elseif method:match('echo') then
        _echo()
    elseif method:match('noti') then
        _notify()
    end
end

-- Works just like jobwait() but with incremental time delay
-- @param what string Stdout or Stderr? Waits until output is obtained. Default: stdout
-- @param wait number Milliseconds to wait for before reading output. This will be incremented at each failure to read by 0.1 Default: 150
-- @param n number Number of times to try to read output. Default: 100 (10 seconds)
function Job:sync(wait, n)
    self.exceptions:assert(self.running and not self.done, 'killed')

    wait = wait or 10
    n = n or 10

    while not self.done do
        vim.wait(wait)
        wait = wait + wait * 0.1
        n = n - 1
    end

    if not self.done then
        return false
    else
        return true
    end
end

function Job:open(opts)
    self.exceptions:assert(not self.done and not self.running, 'done')

    opts = opts or self._opts or {}

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

        for _, value in ipairs(Utils.toList(data)) do
            if #value > 0 then
                table.insert(self.stdout, value)
            end
        end
    end

    local function on_stderr(job_id, data, err)
        if not self.stderr then
            self.stderr = {}
        end

        for _, value in ipairs(Utils.toList(data)) do
            if #value > 0 then
                table.insert(self.stderr, value)
            end
        end
    end

    opts.on_stdout = not opts.on_stdout and type(opts.on_stdout) == 'boolean' and nil or on_stdout
    opts.on_stderr = not opts.on_stderr and type(opts.on_stderr) == 'boolean' and nil or on_stderr

    opts.env = opts.env or {
        HOME = os.getenv('HOME'),
        PATH = os.getenv('PATH'),
    }

    opts.cwd = opts.cwd or os.getenv('HOME')

    if opts.on_stderr and not opts.stderr_buffered then
        opts.stderr_buffered = true
    end

    if opts.on_stdout and not opts.stdout_buffered then
        opts.stdout_buffered = true
    end

    local job = false
    if not opts.terminal then
        job = vim.fn.jobstart(self.cmd, self:sanitize_opts(opts))
        self.job_id = job
        self.running = true
        self.done = false
    else
        self.terminal = {}
        self.terminal.buffer = Buf()
        self.buffer = self.terminal.buffer
        self.buffer:setopts({buflisted=false})

        do
            vim.cmd('tabnew')
            job = vim.fn.termopen(self.cmd, self:sanitize_opts(opts))
            self.terminal.buffer = Buf(vim.fn.expand('%'))
            self.job_id = job
            self.running = true
            self.done = false
            vim.cmd('q')
        end
    end
end

return Job
