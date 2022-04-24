local Job = require('plenary.job')
local Path = require('path')
local Notification = require('core.doom-notify')
local Doom = require('core.doom-globals')
local BufUtils = require('doom-buffer-utils')
local Utils = require('doom-utils')
local Str = require('aniseed.string')

local Async = {
    history = {}
}

function Async.onStdout(err, data)
    if not Async._stdout then
        Async._stdout = {}
    end

    Async._err = err or 0

    if data then
        table.insert(Async._stdout, data)
    end
end

function Async.onStderr(err, data)
    if not Async._stderr then
        Async._stderr = {}
    end

    Async._err = err or 0

    if data then
        table.insert(Async._stderr, data)
    end
end

function Async.showOutput(_type, stdout, stderr, opts)
    stdout = Async._stdout and #Async._stdout > 0 and Async._stdout or stdout
    stderr = Async._stderr and #Async._stderr > 0 and Async._stderr or stderr
    opts = opts or {}
    local notify_args = opts.notifyArgs or {}
    local notify_title = opts.notifyTitle or ''
    local notify = opts.notify

    if type(stdout) == 'string' then
        stdout = Str.split(stdout, "[\n\r]+")
    end

    if type(stderr) == 'string' then
        stderr = Str.split(stderr, "[\n\r]+")
    end

    if _type == 'split' then
        if stdout then
            BufUtils.loadTemporaryBuffer(0, 'sp', {
                hook = function ()
                    BufUtils.setSubstring(0, stdout, {
                        insert = true
                    })
                end
            })

        end
        if stderr then
            BufUtils.loadTemporaryBuffer(0, 'sp', {
                hook = function ()
                    BufUtils.setSubstring(0, stderr, {
                        insert = true
                    })
                end
            })
        end
    elseif _type == 'stderr' then
        if stdout then
            vim.api.nvim_err_writeln(table.concat(stdout, "\n"))
        else
            vim.api.nvim_err_writeln(table.concat(stderr, "\n"))
        end
    elseif _type == 'notify' and notify then
        notify = string.format("%s\nError code: %d", notify, Async._err)

        local dnotify = require('core.doom-notify')

        dnotify.info(notify_title, notify, notify_args)

        if opts.notifyStdout then
            dnotify.info(notify_title, Async._stdout)
        end

        if opts.notifyStderr then
            dnotify.info(notify_title, Async._stderr)
        end
    elseif not _type then
        return {stdout, stderr}
    else
        return {stdout, stderr}
    end
    return {stdout, stderr}
end

function Async.spawn(opts)
    local stdoutHook = opts.onStdout or Async.onStdout
    local stderrHook = opts.onStderr or Async.onStderr
    local exitHook = opts.onExit

    assert(opts.cmd)
    local cmd = opts.cmd
    local args = opts.args or {}
    local cwd = opts.cwd or os.getenv('HOME')
    local split = not opts.split == false and not opts.split and true or true
    local stderr = opts.stderr or false
    local notify  = opts.notify or false
    local notifyTitle = opts.notifyTitle or ''
    local notifyArgs = opts.notifyArgs or {}

    if notify then
        exitHook = vim.schedule_wrap(function (...)
            if not opts.onExit then
                Async.showOutput('notify', nil, nil, {
                    notify = string.format("Command: %s\nMessage: %s", cmd, notify),
                    notifyArgs = notifyArgs,
                    notifyTitle = notifyTitle,
                })
            else
                Async.showOutput('notify', nil, nil, {
                    notify = string.format("Command: %s\nMessage: %s", cmd, notify),
                    notifyArgs = notifyArgs,
                    notifyTitle = notifyTitle,
                })
                exitHook(...)
            end
        end)
    elseif stderr then
        exitHook = vim.schedule_wrap(function ()
            if not opts.onExit then
                Async.showOutput('stderr')
            else
                local out = Async.showOutput('stderr')
                return exitHook(out)
            end
        end)
    elseif split then
        exitHook = vim.schedule_wrap(function ()
            if not opts.onExit then
                return Async.showOutput('split')
            else
                local out = Async.showOutput('split')
                exitHook(out)
            end
        end)
    else
        exitHook = vim.schedule_wrap(function ()
            if not exitHook then
                return Async.showOutput()
            else
                local out = Async.showOutput()
                return exitHook(out)
            end
        end)
    end

    local jobs_n = #(Utils.keys(Async.history))
    local job_name = opts.name or jobs_n + 1

    Job:new({
        command = cmd,
        args = args,
        cwd = cwd,
        on_stdout = stdoutHook,
        on_stderr = stderrHook,
        on_exit = exitHook,
    }):sync(opts.timeout or 100000)

    Async.history[job_name] = {
        stdout = Async._stdout,
        stderr = Async._stderr,
        cmd = cmd,
        args = args,
        stdoutHook = stdoutHook,
        stderrHook = stderrHook,
        exitHook = exitHook,
    }

    for key, value in pairs(opts) do
        if not Async.history[job_name][key] then
            Async.history[job_name][key] = value
        end
    end

    return Async.history[job_name]
end

return Async
