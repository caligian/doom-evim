local Class = require('classy')
local Path = require('path')
local Buf = require('core.buffers')
local Notify = require('core.doom-notify')
local Utils = require('core.doom-utils')
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
    self.pending = true

    Job.status[self.name] = self
end

function Job:close()

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

function Job:show_output(opts)
    self:sync()

    vim.schedule(function ()
        opts = opts or self._opts or {}
        opts.show = opts.show or {}
        opts.show.method = opts.show.method or 'split'
        opts.show.stdout = not opts.show.stdout and type(opts.show.stdout) == 'boolean' and false or true
        opts.show.stderr = not opts.show.stderr and type(opts.show.stderr) == 'boolean' and false or true

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
                local bufname = '_async_command_stdout_' .. #(Utils.keys(current_buf.status))
                current_buf:split(bufname, opts.show.direction or 'sp', {
                    hook = function (buf_obj)
                        buf_obj.write:lines(self.stdout)
                    end,
                    create = true,
                })
            end

            if opts.show.stderr and self.stderr and #self.stderr > 0 then
                local bufname = '_async_command_stdout_' .. #(Utils.keys(current_buf.status))
                current_buf:split(bufname, opts.show.direction or 'sp', {
                    hook = function (buf_obj)
                        buf_obj.write:lines(self.stderr)
                    end,
                    create = true,
                })
            end
        end

        local function _win()
            local floating_temp_buf = Buf.temp()

            if #self.stdout > 0 and self.show.stdout then
                floating_temp_buf.write:lines(self.stdout)
            end

            if #self.stderr > 0 and self.show.stderr then
                floating_temp_buf.write:lines(self.stderr)
            end

            floating_temp_buf:show()
        end

        local method = opts.show.method
        if method == 'split' then
            _split()
        elseif method == 'err' then
            _err()
        elseif method == 'win' then
            _win()
        elseif method == 'echo' then
            _echo()
        elseif method == 'notify' then
            _notify()
        end
    end)
end

-- Works just like jobwait() but with incremental time delay
-- @param what string Stdout or Stderr? Waits until output is obtained. Default: stdout
-- @param wait number Milliseconds to wait for before reading output. This will be incremented at each failure to read by 0.1 Default: 150
-- @param n number Number of times to try to read output. Default: 100 (10 seconds)
function Job:sync(what, wait, n)
    assert(self.running, 'Job has not been started.')

    what = what or 'stdout'
    wait = wait or 100
    n = n or 100

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
    opts = opts or self._opts or {}

    if not opts.on_exit then
        opts.on_exit = function (...)
            self.done = true
            self.running = false
        end
    end

    opts.on_stdout = opts.on_stdout or function (job_id, data, err)
        if not self.stdout then
            self.stdout = {}
        end

        for _, value in ipairs(Utils.toList(data)) do
            if #value > 0 then
                table.insert(self.stdout, value)
            end
        end
    end

    opts.on_stderr = opts.on_stderr or function (job_id, data, err)
        if not self.stderr then
            self.stderr = {}
        end

        for _, value in ipairs(Utils.toList(data)) do
            if #value > 0 then
                table.insert(self.stderr, value)
            end
        end
    end

    opts.env = opts.env or {
        HOME = os.getenv('HOME'),
        PATH = os.getenv('PATH'),
    }

    opts.cwd = opts.cwd or os.getenv('HOME')

    if not opts.stderr_buffered then
        opts.stderr_buffered = true
    end

    if not opts.stdout_buffered then
        opts.stdout_buffered = true
    end

    if not opts.terminal then
        local job = vim.fn.jobstart(self.cmd, self:sanitize_opts(opts))
        self.job_id = job
        self.pending = false
        self.running = true
        self.pid = vim.fn.jobpid(self.job_id)
    else
        local this_buffer = Buf(vim.fn.expand('%'))

        this_buffer:split('_terminal_buffer', opts.direction or 'tab', {
            hook = function ()
                local job = vim.fn.termopen(self.cmd, self:sanitize_opts(opts))
                self.job_id = job
                self.terminal = true
                self.running = true
                self.pending = false
            end,

            create = true,
        })
    end
end

return Job
