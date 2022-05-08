local class = require('classy')
local iter = require('rocks.fun')
local tu = require('core.utils.table')
local tscope = require('core.telescope')
local floating = class('doom-buffer-floating')

function floating:__init(buf_obj, opts)
    self.buffer = buf_obj

    opts = opts or {}
    self._opts = opts

    opts.relative = opts.relative or 'editor'

    local current_height = vim.o.lines
    local current_width = vim.o.columns

    opts.width = opts.width or current_width
    opts.height = opts.height or current_height
    opts.height = math.ceil(opts.height/3)

    if opts.relative then
        opts.row = 0
        opts.col = opts.col or 1
    end

    opts.border = 'solid'
    opts.style = opts.style or 'minimal'

    if opts.options then
        self.buffer:setopts(opts.options)
    end

    if opts.vars then
        self.buffer:setvars(opts.vars)
    end

    opts.telescope = opts.telescope or true
    self._opts = opts
end

function floating:get_visible()
    local visible = {}

    for _, value in pairs(self.buffer.status) do
        if value:is_visible() then
            table.insert(visible, value)
        end
    end

    return visible
end

function floating:sanitize_opts(opts)
    opts = opts or self._opts
    local new = {}

    local required = {
        relative = true,
        row = true,
        col = true,
        width = true,
        height = true,
        bufpos = true,
        win = true,
        anchor = true,
        focusable = true,
        noautocmd = true
    }

    for key, value in pairs(opts) do
        if required[key] then
            new[key] = value
        end
    end

    return new
end

function floating:show(opts)
    self.buffer.exceptions:assert(self.buffer:exists(), 'invalid')
    opts = opts or self._opts

    if opts.options then
        self.buffer:setopts(opts.options)
    end

    if opts.vars then
        self.buffer:setvars(opts.vars)
    end

    opts = self:sanitize_opts()
    self.winnr = vim.api.nvim_open_win(self.buffer.bufnr, true, opts)
end

function floating:is_visible()
    self.winnr = self.buffer:is_visible()
    return self.winnr
end

function floating:hide()
    self.buffer.exceptions:assert(self.buffer:exists(), 'invalid')

    if self:is_visible() then
        vim.api.nvim_win_close(self.winnr, true)
        return true
    end
end

function floating:unfocus(opts)
    opts = opts or {}
    self.buffer.cleanup()
    local visible = self:get_visible()

    if opts.telescope then
        tscope.new {
            hook = function (selection, ...)
                selection = selection[1]
                local buffer = self.buffer.status[selection]
                opts = opts or buffer.floating:sanitize_opts(opts)
                buffer.floating:hide()
            end,

            getter = tu.nth('bufname', unpack(visible))
        }
    elseif opts.regex or type(opts) == 'string' then
        local regex = type(opts) == 'string' and opts or opts.regex
        iter.each(function (buffer)
            if not buffer:is_visible() and buffer.bufname:match(regex) then
                buffer.floating:hide()
            end
        end, visible)
    elseif opts.eq then
        iter.each(function (buffer)
            if not buffer:is_visible() and buffer.bufname == opts.eq then
                buffer.floating:hide()
            end
        end, visible)
    end
end

function floating:focus(opts)
    opts = opts or {}
    self.buffer.cleanup()
    local visible = self:get_visible()

    if opts.telescope then
        tscope.new {
            hook = function (selection, ...)
                selection = selection[1]
                local buffer = self.buffer.status[selection]
                opts = opts or buffer.floating:sanitize_opts(opts)
                buffer.floating:show()
            end,

            getter = tu.nth('bufname', unpack(visible))
        }
    elseif opts.regex or type(opts) == 'string' then
        local regex = type(opts) == 'string' and opts or opts.regex
        iter.each(function (buffer)
            if not buffer:is_visible() and buffer.bufname:match(regex) then
                buffer.floating:show()
            end
        end, visible)
    elseif opts.eq then
        iter.each(function (buffer)
            if not buffer:is_visible() and buffer.bufname == opts.eq then
                buffer.floating:show()
            end
        end, visible)
    end
end

return floating
