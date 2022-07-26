local uv = vim.loop
local sig  = require('core.async.signals')
local job = {}
local m = {}

assoc(Doom.async, {'luv_job'}, {status={}})
job.status = Doom.async.luv_job.status

function m:close(code, signal)
    self.exit_code = code
    self.exit_signal = signal

    local in_pipe, out_pipe, err_pipe = unpack(self.stdio)

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

    self.done = true
    self.running = false
end

function job.new(name, cmd, opts)
    claim.string(name)

    opts = opts or {}
    local existing_job = assoc(Doom.async.luv_job, name)
    if existing_job then
        if not existing_job.done and not opts.force then
            return existing_job
        end
    end

    local args = false
    local env, cwd
    local stdin, on_stdin
    local stdout, on_stdout
    local stderr, on_stderr

    assert(cmd)
    claim(cmd, 'string', 'table')

    if table_p(cmd) then
        args = slice(cmd, 2, -1)
        cmd = first(cmd)
    elseif not opts.args then
        args = {}
    else
        args = opts.args
    end

    args = to_list(args)

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
        if callable(opts.stderr)  then
            on_stderr = opts.on_stderr
        end
    end
    
    if opts.stdout then
        if callable(opts.stdout)  then
            on_stdout = opts.on_stdout
        end
    end

    if opts.stdin then
        if callable(opts.stdin)  then
            on_stdin = opts.on_stdin
        end
    end

    claim.opt_table(opts.stdio)
    claim.opt_callable(opts.on_exit)
    claim.opt_table(opts.signals)

    local self_opts = {
        name = name;
        -- This is causing the bug of ENOENT No file such file or directory
        -- env = env;
        cmd = cmd;
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
        running = false;
        done = false;
        on_stdin = on_stdin;
        on_exit = opts.on_exit;
        stdout_output = {err={}, data={}};
        stderr_output = {err={}, data={}};
        capture_stdout = opts.stdout ~= nil;
        capture_stderr = opts.stderr ~= nil;
        accepts_stdin = opts.stdin ~= nil;
        signals = opts.signals or {};
        opts = opts;
    }

    local self = module.new('libuv-job', {vars=self_opts}, m)
    update(Doom.async.luv_job, name, self)

    return self
end

function m:restart(force)
    if not self.done and not force then
        return false
    end

    inspect(s)
    self.exit_code = nil
    self.exit_signal = nil
    local prev = self.opts.force
    self.opts.force = true
    local s = self.new(self.name, self.cmd, self.opts)
    s.force = prev

    return s
end

function m:kill()
    uv.process_kill(self.handle, 'SIGHUP') 
end

function m:start()
    if self.done then
        error(sprintf("Job %s is already done", self.name))
    end

    if self.running then
        return self
    end

    local in_pipe, out_pipe, err_pipe
    in_pipe, out_pipe, err_pipe = unpack(self.stdio)

    inspect(self.capturing_stdout)
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

    local on_exit
    if not self.on_exit then
        on_exit = partial(self.close, self)
    else
        on_exit = function (code, signal)
            self:close()
            self.on_exit(code, signal)
        end
    end

    local success, err = uv.spawn(self.cmd, self, on_exit)
    assert(success, err)
    self.handle = success
    self.on_exit = on_exit

    if self.capture_stdout then
        out_pipe:read_start(vim.schedule_wrap(self.on_stdout))
    end

    if self.capture_stderr then
        err_pipe:read_start(vim.schedule_wrap(self.on_stderr))
    end

    self.running = true
end

function m:write(s)
    claim(s, 'string', 'table')
    assert(self.accepts_stdin, 'Job does not accept stdin')

    uv.write(self.stdio[1], s)
end

function m:sync(opts)
    opts = opts or {}
    opts.inc = opts.inc or 1
    opts.timeout = opts.timeout or 1000
    opts.tries = opts.tries or 10

    wait(function ()
        if #self.stdout_output.data > 0 then
            return true
        else
            return false
        end
    end, false, opts)

    local status = {}
    if #self.stderr_output.data > 0 then
        status.stderr = self.stderr_output.data
    end

    if #self.stdout_output.data > 0 then
        status.stdout = self.stdout_output.data
    end

    return status
end

return job
