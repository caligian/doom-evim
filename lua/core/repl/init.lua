local Class = require('classy')
local Utils = require('core.doom-utils')
local Job = require('core.async.job')
local Buf = require('core.buffers')
local REPL = Class('doom-repl')

REPL.status = {}

REPL.repls = {}

REPL.ft_repl =  {
    lua = 'lua5.1',
    ruby = 'irb',
    python = 'python3',
    javascript = 'node',
    sh = 'bash',
}

REPL.ft_debugger = {
    python = 'python3 -m pdb',
    sh = 'bash -x',
}

-- opts as required by job
function REPL:__init(name, opts)
    assert(name)

    opts = opts or {}
    self._opts = opts

    local ft = opts.ft or vim.bo.filetype
    local cmd = false

    if opts.debugger then
        cmd = opts.cmd or REPL.ft_debugger[ft]
        cmd = cmd .. ' ' .. vim.fn.expand('%:p')
    else
        cmd = opts.cmd or REPL.ft_repl[ft]
    end

    assert(cmd, 'Need a command to start an REPL')

    opts = opts or {}
    opts.direction = opts.direction or 'float'
    opts.terminal = true
    opts.on_stdout = false
    opts.on_stderr = false
    opts.on_exit = false

    self.job = Job(name, cmd, opts)
    assert(self.job:open(), 'Could not start job: ' .. self.job.name)

    if not REPL.status[ft] then
        REPL.status[ft] = {}
    end

    REPL.status[ft][cmd] = self
end

local repl = REPL('lua-repl')
Utils.dump(repl.status)

-- @param method string How to send a string? 'line' for a single line of assoc buffer. 'till-point' to send everything till-point. 'visual' for strings in visual range. 'count' to send the next N strings where N is defined by v:count
-- @param s string If s is given then method is ignored and s is simply chansend()
function REPL:send(method, s)
    method = method or 'line'
    local buf = self.job.terminal.buffer

    if buf:exists() and not self.job.done then
        if s then
            self.job:send(s)
        elseif method:match('line') then
            self.job:send(buf.string:current_line())
        elseif method:match('till-point') then
            self.job:send(buf.string:lines {
                row = {from=0, till=buf:position().row}
            })
        elseif method:match('count') then
            if vim.v.count > 0 then
                local from = buf:position().row
                local till = from + vim.v.count
                self.job:send(buf.string:lines {
                    row = {from=from, till=till},
                    nl = true,
                })
            end
        elseif method:match('visual') then
            self.job:send(buf.string:visual_range {nl=true})
        end
    end
end
