local Kbd = require("doom-kbd")
local Path = require("path")
local Async = require("doom-async")
local Utils = require("doom-utils")
local BufUtils = require("doom-buffer-utils")
local Formatter = {}
local Doom = require("doom-globals")

function Formatter.formatBuffer(buffer, overwrite, opts)
    opts = opts or {}
    overwrite = overwrite or false
    buffer = BufUtils.isValidBuffer(0)
    local fn = vim.call("bufname", buffer)
    fn = Path.abs(fn)
    local ft = opts.ft or vim.bo.filetype
    local cmd = opts.cmd
    local args = nil

    if not cmd then
        if Doom.langs[ft] and Doom.langs[ft].format then
            cmd = Doom.langs[ft].format.cmd
        end
    end

    if not args then
        if Doom.langs[ft] and Doom.langs[ft].format and Doom.langs[ft].format.args then
            if type(Doom.langs[ft].format.args) ~= 'table' then
                args = {Doom.langs[ft].format.args}
            else
                args = Doom.langs[ft].format.args
            end

            table.insert(args, fn)
        else
            args = {fn}
        end
    end

    assert(cmd, "Require a command to execute")

    Async.spawn(
        {
            cmd = cmd,
            args = args,
            split = false,
        }
    )

    if overwrite or Doom.langs[ft].format.overwrite then
        local formatted = Async._stdout

        if formatted then
            formatted = table.concat(formatted, "\n")
            local fh = io.open(fn, "w")
            fh:write(formatted)
            fh:close()
        end
    end
end

function Formatter.setup()
    Kbd.new({
        leader = 'l',
        keys = 'mf',
        help = 'Format buffer',
        exec = Formatter.formatBuffer
    })
end

return Formatter
