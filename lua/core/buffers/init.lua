local Class = require('classy')
local Kbd = require('core.doom-kbd')
local Au = require('core.doom-au')
local Utils = require('core.doom-utils')
local Doom = require('core.doom-globals')

local BufString = require('core.buffers.string')
local BufFloat = require('core.buffers.floating')
local BufWrite = require('core.buffers.writer')
local BufPrompt = require('core.buffers.prompt')


local Buffer = Class('doom-buffer')
Buffer.status = {}
Buffer.temporary = {}

function Buffer:is_visible()
    local winnr = vim.fn.bufwinnr(self.bufnr)

    if winnr ~= -1 then
        return winnr
    else
        return false
    end
end

function Buffer:setopts(options)
    for key, value in pairs(options) do
        vim.api.nvim_buf_set_option(self.bufnr, key, value)
    end
end

function Buffer:setvars(vars)
    for key, value in pairs(options) do
        vim.api.nvim_buf_set_var(self.bufnr, key, value)
    end
end

function Buffer:exists()
    if vim.fn.bufexists(self.bufnr) == 1 then
        return true
    else
        return false
    end
end

function Buffer:wipeout()
    vim.cmd('bwipeout ' .. self.bufname)
    self.deleted = true
end

function Buffer:count()
    return vim.api.nvim_buf_line_count(self.bufnr)
end

function Buffer:create()
    if vim.fn.bufexists(self.bufname) == 0 then
       vim.fn.bufadd(self.bufname)
    end

    self.bufnr = vim.fn.bufnr(self.bufname)
    Buffer.status[self.bufname] = self.bufnr
end

function Buffer:hook(event_name, f, schedule)
    event_name = event_name or 'BufEnter'

    if not schedule then
        Au.autocmd('Global', event_name, self.bufname, f)
    else
        Au.autocmd('Global', event_name, self.bufname, function ()
            f(self)
        end)
    end
end

-- opts as required by Kbd.new({...})
function Buffer:kbd(...)
    for _, opts in ipairs({...}) do
        opts.pattern = self.bufname
        opts.event = opts.event or 'BufEnter'
        Kbd.new(opts)
    end
end

function Buffer:load()
    if vim.fn.bufloaded == 0 then
        vim.fn.bufload(self.bufname)
    end
end

function Buffer:hide()
    local winnr = vim.fn.bufwinnr(self.bufnr)

    if winnr == 1 then
        vim.api.nvim_win_close(winnr, true)
    end
end

function Buffer:exec(f, schedule)
    local bufname = self.bufname

    vim.cmd('tabnew ' .. bufname)

    if schedule then
        vim.schedule(function ()
            f(self)
        end)
    else
        f(self)
    end

    vim.cmd('q')
end

function Buffer:getpos(expr)
    self:exec(function ()
        expr = vim.fn.getpos(expr)
    end)

    return expr
end

function Buffer:position(opts)
    opts = opts or {}

    local visual_cood = {
        row = {
            from = 0,
            till = false,
        },
        col = {
            from = 0,
            till = false
        }
    }

    local cood = {
        row = false,
        col = false,
    }

    if opts.visual then
        self:exec(function ()
            local from = vim.fn.getcurpos("'<")
            local till = vim.fn.getcurpos("'>")
            Utils.dump(from, till)

            cood.row.from = from[2] - 1
            cood.row.till = till[2] - 1
            cood.col.from = till[3] - 1
            cood.col.till = from[3] - 1
        end)
    else
        cood.row = vim.fn.getcurpos('.')[2] - 1
        cood.col = vim.fn.getcurpos('.')[3] - 1
    end

    return cood
end

-- Split this buffer and...
-- In order to do this, the buffer should be visible.
function Buffer:split(buf_obj_or_bufname, direction, opts)
    local winnr = self:is_visible()

    if winnr then
        vim.fn.win_gotoid(winnr)
        local buf_obj = nil
        direction = direction or 'sp'
        opts = opts or {}

        assert(buf_obj_or_bufname)

        if type(buf_obj_or_bufname) == 'string' then
            buf_obj = Buffer(buf_obj_or_bufname)
        elseif Class.is_a(buf_obj, Buffer) then
            buf_obj = buf_obj_or_bufname
        end

        if direction == 'sp' then
            if not opts.reverse then
                vim.cmd('sp | wincmd j | buffer ' .. buf_obj.bufname)
            else
                vim.cmd('sp | buffer ' .. buf_obj.bufname)
            end
        elseif direction == 'vsp' then
            if opts.reverse then
                vim.cmd('vsp | buffer ' .. buf_obj.bufname)
            else
                vim.cmd('vsp | wincmd l | buffer ' .. buf_obj.bufname)
            end
        elseif direction == 'tab' then
            vim.cmd('tabnew ' .. buf_obj.bufname)
        end

        if opts.hook then
            buf_obj:exec(opts.hook, opts.schedule or false)
        end

        return buf_obj
    end
end

function Buffer:__init(bufname, opts)
    opts = opts or {}
    bufname = bufname or string.format('_temp_buffer_%d', #Buffer.temporary + 1)
    self.bufname = bufname
    self:create()

    self.float = BufFloat(self)
    self.prompt = BufPrompt(self.float)

    self.write = BufWrite(self)
    self.string = BufString(self)
end

return Buffer
