local Class = require('classy')
local Job = require('core.async.job')
local Buf = require('core.buffers')
local REPL = Class('doom-repl')

REPL.status = Doom.repl.status

function REPL:open(opts)
    opts = opts or self._opts or {}
    local ft = opts.ft or self.filetype
    local cmd = opts.cmd or self.cmd
    opts = opts or self._opts

    if not REPL.status[ft] then
        self.job = Job(ft .. '-repl' , cmd, opts)
        self.job:open()
        self.buffer = self.job.terminal.buffer

        if not REPL.status[ft] then
            REPL.status[ft] = {}
        end

        REPL.status[ft] = self

        return self
    else
        return false
    end
end

-- opts as required by job
function REPL:__init(opts)
    opts = opts or {}
    self._opts = opts

    ft = opts.ft or vim.bo.filetype

    local cmd = ''
    if opts.debug then
        cmd = opts.debug or get(Doom.langs, {ft, 'debug'})
        cmd = cmd .. ' ' .. vim.fn.expand('%:p')
    else
        cmd = opts.cmd or get(Doom.langs, {ft, 'repl'})
    end

    oblige(cmd ~= '', 'Need a command to start an REPL')

    opts = opts or {}
    opts.direction = opts.direction or 'float'
    opts.terminal = true
    opts.on_stdout = false
    opts.on_stderr = false
    opts.on_exit = false

    self._opts = opts
    self.cmd = cmd
    self.filetype = vim.bo.filetype
end

-- @param method string How to send a string? 'line' for a single line of assoc buffer. 'till-point' to send everything till-point. 'visual' for strings in visual range. 'count' to send the next N strings where N is defined by v:count
-- @param s string If s is given then method is ignored and s is simply chansend()
function REPL:send(s, opts)
    opts = opts or {}
    local ft = opts.ft or self.filetype or vim.bo.filetype
    local method = opts.method or 'line'

    if opts.ft:match('^%%$') then
        opts.ft = vim.bo.filetype
    end

    local current_buf = Buf('%')
    local cood = current_buf:position()

    if s then
        self.job:send(s)
    elseif method:match('line') then
        self.job:send(current_buf.string:current_line())
    elseif method:match('till.point') then
        self.job:send(current_buf.string:lines {
            row = {from=0, till=cood.row}
        })
    elseif method:match('count') then
        if vim.v.count > 0 then
            local from = current_buf:position().row
            local till = from + vim.v.count

            self.job:send(current_buf.string:lines {
                row = {from=from, till=till},
                nl = true,
            })
        end
    elseif method:match('visual') then
        self.job:send(current_buf.string:visual_range {nl=true})
    end
end

function REPL:focus(direction)
    direction =  direction or self._opts.direction
    self.buffer:focus(direction)
end

function REPL:kill()
    self.job:kill()
end

function REPL.killall()
    for ft, repl in pairs(REPL.status) do
        if repl.job.running then
            repl:kill()
            REPL.status[ft] = nil
        end
    end
end

function REPL.force_killall()
    local all_buffers = Buf.list()

    for key, value in pairs(all_buffers) do
        if key:match('term') then
            pcall(value, value.kill, value)
        end
    end
end

local repl = REPL()
repl:open()

return REPL
