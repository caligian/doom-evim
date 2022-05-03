local Class = require('classy')
local Notify = require('core.doom-notify')
local Utils = require('core.doom-utils')
local Tscope = require('core.doom-telescope')
local Floating = Class('doom-buffer-floating')

function Floating:__init(buf_obj, opts)
    self.buffer = buf_obj
    self.buffer.floating[self.buffer.bufname] = self

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

function Floating:sanitize_opts(opts)
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

function Floating:show(opts)
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

function Floating:is_visible()
    self.winnr = self.buffer:is_visible()
    return self.winnr
end

function Floating:hide()
    self.buffer.exceptions:assert(self.buffer:exists(), 'invalid')

    if self:is_visible() then
        vim.api.nvim_win_close(self.winnr, true)
        return true
    end
end

-- Only works if the window is actually visible
function Floating:exec(f, opts)
    self.buffer.exceptions:assert(self.buffer:exists() and self:is_visible())
    return slef.buffer:exec(f, opts)
end

function Floating:hook(event_name, f, schedule)
    self.buffer.exceptions:assert(self.buffer:exists(), 'invalid')

    if not self._opts.noautocmd then
        self.buffer:hook(event_name, f, schedule)
        return true
    else
        error({buffer=self.buffer, no_autocmd=true, reason='No autocmd can be applied to buffer'})
    end
end

function Floating:unfocus(opts)
    opts = opts or self._opts or {}
    local floating_buffers = {}

    self.buffer.cleanup('floating')

    if opts.telescope then
        if #floating_buffers > 0 then
            Tscope.new {
                hook = function (selection)
                    selection = selection[1]
                    local floating_buffer = self.buffer.floating[selection]
                    opts = opts or floating_buffer:sanitize_opts()
                    floating_buffer:hide(opts)
                end,

                getter = floating_buffers
            }

            return true
        end
    elseif opts.regex or type(opts) == 'string' then
        local regex = type(opts) == 'string' and opts or opts

        for key, value in pairs(self.buffer.floating) do
            if key:match(regex) then
                value:show()
            end
        end
    elseif opts.eq then
        for key, value in pairs(self.buffer.floating) do
            if key == opts.eq then
                value:show()
            end
        end
    end
end

function Floating:focus(opts)
    opts = opts or {}

    self.buffer.cleanup('floating')
    self:hide()

    if opts.telescope then
        Tscope.new {
            hook = function (selection, ...)
                selection = selection[1]
                local floating_buffer = self.buffer.floating[selection]
                opts = opts or floating_buffer:sanitize_opts()
                floating_buffer:show(opts)
            end,

            getter = Utils.keys(self.buffer.floating)
        }
    elseif opts.regex or type(opts) == 'string' then
        local regex = type(opts) == 'string' and opts or opts.regex

        for key, value in pairs(self.buffer.floating) do
            if key:match(regex) then
                value:show()
            end
        end
    elseif opts.eq then
        for key, value in pairs(self.buffer.floating) do
            if key == opts.eq then
                value:show()
            end
        end
    end
end

return Floating
