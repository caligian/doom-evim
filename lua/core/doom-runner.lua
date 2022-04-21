local Kbd = require("doom-kbd")
local Path = require("path")
local Async = require("doom-async")
local Utils = require("doom-utils")
local BufUtils = require("doom-buffer-utils")
local Runner = {}

-- Remove this line after testing
local Doom = dofile("doom-globals.lua")

function Runner.runAction(action, buffer, opts)
    assert(action)

    opts = opts or {}
    buffer = BufUtils.isValidBuffer(0)
    local fn = vim.call("bufname", buffer)
    fn = Path.abs(fn)
    local ft = opts.ft or vim.bo.filetype
    local cmd = opts.cmd
    local args = nil

    if not cmd then
        if Doom.langs[ft] and Doom.langs[ft][action] then
            cmd = Doom.langs[ft][action].cmd
        end
    end

    if not cmd then
        print(string.format('Cannot do action on current buffer: %s', action))
        return
    end

    if not args then
        if Doom.langs[ft] and Doom.langs[ft][action] and Doom.langs[ft][action].args then
            if type(Doom.langs[ft][action].args) ~= 'table' then
                args = {Doom.langs[ft][action].args}
            else
                args = Doom.langs[ft][action].args
            end

            table.insert(args, fn)
        else
            args = {fn}
        end
    end

    assert(cmd, "Require a command to execute")

    Async.spawn({
            cmd = cmd,
            args = args,
        })
end

function Runner.setup()
    Kbd.new({
        leader = 'l',
        keys = 'mb',
        help = 'Build buffer',
        exec = function ()
            Runner.runAction('build')
        end
    },
    {
        leader = 'l',
        keys = 'mt',
        help = 'Test buffer',
        exec = function ()
            Runner.runAction('test')
        end
    },
    {
        leader = 'l',
        keys = 'mc',
        help = 'Compile buffer',
        exec = function ()
            Runner.runAction('compile')
        end
    })
end

return Runner
