local uv = vim.loop
local stdin, stdout = uv.new_pipe(false), uv.new_pipe(false)
local handle, pid
local results = {}
local class = require('classy')
local async = class('doom-luv-spawn')
local path = require('path')

function async:__init(cmd, opts)
    self.cmd = cmd
    merge(self, opts)
end

function async.new(cmd, opts)
    opts = opts or {}
    local args = false
    local env, cwd
    local stdin, on_stdin
    local stdout, on_stdout
    local stderr, on_stderr

    assert(cmd)

    if table_p(cmd) then
        args = slice(copy(cmd), 2, -1)
        cmd = first(cmd)
    elseif not opts.args then
        args = {}
    else
        args = opts.args
    end

    if str_p(cwd) then
        assert(path.exists(cwd), 'Invalid cwd: ' .. cwd)
    else
        cwd = vim.fn.fnamemodify(vim.fn.expand('%:p'), ':h')
    end

    local _env
    if str_p(opts.env) then
        _env = os.getenv(opts.env)
        assert(_env, 'Invalid env var provided: ' .. opts.env)
    end

    env = {os.getenv('PATH'), _env}

    if opts.stderr then
        assert_callable(opts.on_stderr)
        on_stderr = opts.on_stderr
    end
    
    if opts.stdout then
        assert_callable(opts.on_stdout)
        on_stdout = opts.on_stdout
    end

    if opts.stdin then
        assert_callable(opts.on_stdin)
        on_stdin = opts.on_stdin
    end

    assert_t(opts.stdio)
    assert_callable(opts.on_exit)

    local self_opts = {
        env = env;
        cwd = cwd;
        stdio = opts.stdio or {uv.new_pipe(false), uv.new_pipe(false), uv.new_pipe(false)};
        detached = opts.detached;
        args = args;
        uid = opts.uid;
        gid = opts.gid;
        verbatim = opts.verbatim;
        hide = opts.hide;
        on_stdout = on_stdout;
        on_stderr = on_stderr;
        on_stdin = on_stdin;
        on_exit = opts.on_exit;
        stdout_output = {err={}, data={}};
        stderr_output = {err={}, data={}};
        capture_stdout = opts.stdout ~= nil;
        capture_stderr = opts.stderr ~= nil;
        accepts_stdin = opts.stdin ~= nil;
    }

    return async(cmd, self_opts)
end

function async:start()
    local in_pipe, out_pipe, err_pipe
    in_pipe, out_pipe, err_pipe = unpack(self.stdio)

    if self.capture_stdout then
        if not self.on_stdout then
            self.on_stdout = function (err, data)
                if data then push(self.stdout_output.data, data) end
                if err then push(self.stdout_output.err, err) end
            end
        end

    end

    if self.capture_stderr then
        if not self.on_stderr then
            self.on_stderr = function (err, data)
                if data then push(self.stderr_output.data, data) end
                if err then push(self.stderr_output.err, err) end
            end
        end
    end

    if not self.on_exit then
        self.on_exit = function (code, signal)
            self.code = code
            self.signal = signal

            if not self.handle:is_closing() then
                self.handle:close()
            end

            if out_pipe then
                out_pipe:read_stop() 
                if not out_pipe:is_closing() then
                    out_pipe:close()
                end
            end

            if err_pipe then
                err_pipe:read_stop()
                if not err_pipe:is_closing() then
                    err_pipe:close()
                end
            end

            if in_pipe then
                uv.shutdown(in_pipe)
                if not err_pipe:is_closing() then
                    err_pipe:close()
                end
            end
        end
    end

    self.handle = uv.spawn(self.cmd, self, self.on_exit)

    if self.capture_stdout then
        out_pipe:read_start(vim.schedule_wrap(self.on_stdout))
    end

    if self.capture_stderr then
        err_pipe:read_start(vim.schedule_wrap(self.on_stderr))
    end
end

function async:write(s)
    assert_type(s, 'string', 'table')
    assert(self.accepts_stdin, 'Job does not accept stdin')

    uv.write(self.stdio[1], s)
end

function async:sync_read(opts)
    opts = opts or {}
    opts.inc = opts.inc or 0.1
    opts.timeout = opts.timeout or 1
    opts.tries = opts.tries or 1000

    local function wait(what)
        assert_s(what)

        local n = 0
        local timeout = opts.timeout
        local check = self[what]

        while #check.data == 0 and n < opts.tries do
            vim.wait(timeout)
            timeout = timeout + opts.inc
            n = n + 1
        end
    end

    if self.capture_stdout then wait('stdout_output') end
    if self.capture_stderr then wait('stderr_output') end
end


return async
