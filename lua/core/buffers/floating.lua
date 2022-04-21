local Class = require('classy')
local Notify = require('core.doom-notify')
local Utils = require('core.doom-utils')
local Tscope = require('core.doom-telescope')
local Floating = Class('doom-buffer-floating')
Floating.status = {}

function Floating:__init(buf_obj, opts)
    opts = opts or {}
    for key, value in pairs(opts) do
        self[key] = value
    end

    self.buffer = buf_obj

    Floating.status[self.buffer.bufname] = self

    self._opts = opts
end

function Floating.sanitize_opts(opts)
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
    opts = opts or self._opts
    opts.relative = opts.relative or 'win'

    local current_height = vim.o.lines
    local current_width = vim.o.columns

    opts.width = opts.width or current_width
    opts.height = opts.height or current_height

    opts.width = opts.width
    opts.height = math.ceil(opts.height/3)
    
    if opts.relative then
        opts.row = opts.row or vim.o.lines - 1
        opts.col = opts.col or 1
   end

    opts.border = 'single'
    opts.style = opts.style or 'minimal'

    local sanitized_opts = Floating.sanitize_opts(opts)
    self.winnr = vim.api.nvim_open_win(self.buffer.bufnr, true, sanitized_opts)
end

function Floating:hide()
    local win = Floating.status[self.buffer.bufname]

    if win.winnr then
        vim.api.nvim_win_close(win.winnr, true)
    end
end

function Floating:is_visible()
    if self.winnr then
        return true
    else
        return false
    end
end

-- Only works if the window is actually visible
function Floating:exec(f, schedule)
    if self.winnr then
        if schedule then
            vim.schedule(function ()
                f(self)
            end)
        else
            f(self)
        end
    end
end

function Floating:hook(event_name, f, schedule)
    if not self._opts.noautocmd then
        self.buffer:hook(event_name, f, schedule)
    else
        local s = string.format('No autocmds can be applied to %s. Check options.', self.buffer.bufname)
        Notify.warn('doom-buffer-floating says', s, {})
    end
end

function Floating.unfocus(opts)
    opts = opts or {}

    if opts.telescope then
        Tscope.new {
            hook = function (selection)
                selection = selection[1]

                if vim.fn.bufexists(selection) == 1 then
                    local floating_buffer = Floating.status[selection]
                    floating_buffer:hide()
                else
                    local floating_buffer = Floating.status[selection]
                    floating_buffer.buffer:wipeout()
                    Floating.status[selection] = nil
                    Buffer.status[selection] = nil
                end
            end,

            getter = Utils.keys(Floating.status)
        }
    end
end

function Floating.focus(opts)
    opts = opts or {}

    if opts.telescope then
        Tscope.new {
            hook = function (selection, ...)
                selection = selection[1]

                if vim.fn.bufexists(selection) == 1 then
                    local floating_buffer = Floating.status[selection]
                    floating_buffer:show(opts or floating_buffer._opts)
                else
                    local floating_buffer = Floating.status[selection]
                    floating_buffer.buffer:wipeout()
                    Floating.status[selection] = nil
                    Buffer.status[selection] = nil
                end
            end,

            getter = Utils.keys(Floating.status)
        }
    end
end

return Floating
