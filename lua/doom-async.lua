local Job = require('plenary.job')
local BufUtils = require('doom-buffer-utils')
local Utils = require('doom-utils')
local Async = {}

function Async.onStdout(err, data)
    if not Async._stdout then
        Async._stdout = {}
    end

    if data then
        table.insert(Async._stdout, data)
    end
end

function Async.onStderr(err, data)
    if not Async._stderr then
        Async._stderr = {}
    end

    if data then
        table.insert(Async._stderr, data)
    end
end

function Async.showOutput(...)
    if Async._stdout and #Async._stdout then
        BufUtils.loadTemporaryBuffer(0, 'sp', {
            hook = function ()
                BufUtils.setSubstring(0, Async._stdout, {
                    insert = true
                })
            end
        })
    end

    if Async._stderr and #Async._stderr > 0 then
        BufUtils.loadTemporaryBuffer(0, 'sp', {
            hook = function ()
                BufUtils.setSubstring(0, Async._stderr, {
                    insert = true
                })
            end
        })
    end
end

function Async.spawn(opts)
    local stdoutHook = opts.onStdout or Async.onStdout
    local stderrHook = opts.onStderr or Async.onStderr
    local exitHook = opts.onExit or Async.showOutput
    exitHook = vim.schedule_wrap(exitHook)

    assert(opts.cmd)
    local cmd = opts.cmd
    local args = opts.args or {}
    local cwd = opts.cwd or os.getenv('HOME')

    Job:new({
        command = cmd,
        args = args,
        cwd = cwd,
        on_stdout = stdoutHook,
        on_stderr = stderrHook,
        on_exit = exitHook,
    }):sync()
end

return Async
