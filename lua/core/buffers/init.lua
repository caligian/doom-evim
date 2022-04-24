local Class = require('classy')
local Kbd = require('core.doom-kbd')
local Au = require('core.doom-au')
local Utils = require('core.doom-utils')
local Doom = require('core.doom-globals')

local BufString = require('core.buffers.string')
local BufFloat = require('core.buffers.floating')

--local BufFloat = dofile('floating.lua')
local BufWrite = require('core.buffers.writer')
local BufPrompt = require('core.buffers.prompt')

local Buffer = Class('doom-buffer')
Buffer.status = {}
Buffer.temporary = {}
Buffer.floating = {}
Buffer.prompts = {}

function Buffer:exists()
    if vim.fn.bufexists(self.bufnr) == 1 then
        self.bufnr = vim.fn.bufnr(self.bufname)
        local info = vim.fn.getbufinfo(self.bufnr)

        if #info > 0 then
            info = info[1]
        end

        self.info = info

        Buffer.status[self.bufname] = self

        return true
    else
        return false
    end
end

function Buffer:is_visible()
    if self:exists() then
        local winnr = vim.fn.bufwinnr(self.bufnr)

        if winnr ~= -1 then
            self.winnr = winnr
            return winnr
        else
            self.winnr = false
            return false
        end
    end
end

function Buffer.cleanup(what)
    local function _cleanup_floating()
        for key, value in pairs(Buffer.floating) do
            if not value.buffer:exists() then
                Buffer.floating[key] = nil
                Buffer.status[key] = nil
            end
        end
    end

    local function _cleanup_temporary()
        for key, value in pairs(Buffer.temporary) do
            if not value.buffer:exists() then
                Buffer.temporary[key] = nil
                Buffer.status[key] = nil
            end
        end
    end
    
    local function _cleanup_prompts()
        for key, value in pairs(Buffer.prompts) do
            if not value.buffer:exists() then
                Buffer.prompts[key] = nil
                Buffer.status[key] = nil
            end
        end
    end

    if what:match('all') then
        _cleanup_floating()
        _cleanup_prompts()
        _cleanup_temporary()
    elseif what:match('prompt') then
        _cleanup_prompts()
    elseif what:match('float') then
        _cleanup_floating()
    elseif what:match('temp') then
        _cleanup_temporary()
    end
end

function Buffer:unlist()
    if self:exists() then
        self.listed = false
        vim.api.nvim_buf_set_option(self.bufnr, 'buflisted', false)
        return true
    end
end

function Buffer:setopts(options)
    if self:exists() then
        for key, value in pairs(options) do
            vim.api.nvim_buf_set_option(self.bufnr, key, value)
        end

        return true
    end
end

function Buffer:setvars(vars)
    if self:exists() then
        for key, value in pairs(options) do
            vim.api.nvim_buf_set_var(self.bufnr, key, value)
        end

        return true
    end
end

function Buffer:kill()
    if self:exists() then
        local visible_buffers = #(vim.fn.tabpagebuflist())

        if visible_buffers > 0 then
            vim.cmd('bwipeout ' .. self.bufname)
            Buffer.status[self.bufname] = nil
            return true
        else
            return false
        end
    end
end

function Buffer:count()
    if self:exists() then
        return vim.api.nvim_buf_line_count(self.bufnr)
    end
end

function Buffer:create()
    if vim.fn.bufexists(self.bufname) == 0 then
       vim.fn.bufadd(self.bufname)
    end

    self.bufnr = vim.fn.bufnr(self.bufname)
    Buffer.status[self.bufname] = self
    self:exists()
end

function Buffer:hook(event_name, f, schedule)
    if self:exists() then
        event_name = event_name or 'BufEnter'

        if not schedule then
            Au.autocmd('Global', event_name, self.bufname, f)
        else
            Au.autocmd('Global', event_name, self.bufname, function ()
                f(self)
            end)
        end

        return true
    end
end

-- opts as required by Kbd.new({...})
function Buffer:kbd(...)
    if self:exists() then
        for _, opts in ipairs({...}) do
            opts.pattern = self.bufname
            opts.event = opts.event or 'BufEnter'
            Kbd.new(opts)

            return true
        end
    end
end

function Buffer:load()
    if self:exists() then
        if vim.fn.bufloaded == 0 then
            vim.fn.bufload(self.bufname)

            return true
        end
    end
end

function Buffer:hide()
    if self:exists() then
        local winnr = vim.fn.bufwinnr(self.bufnr)

        if winnr == 1 then
            vim.api.nvim_win_close(winnr, true)
        end
    end
end

function Buffer:exec(f, schedule)
    if self:exists() then
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

        return true
    end
end

function Buffer:getpos(expr)
    if self:exists() then
        self:exec(function ()
            expr = vim.fn.getpos(expr)
        end)

        return expr
    end
end

function Buffer:position(opts)
    if self:exists() then
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
end

-- Split this buffer and...
-- In order to do this, the buffer should be visible.
function Buffer:split(buf_obj_or_bufname, direction, opts)
    if self:exists() then
        local winnr = self:is_visible()

        if winnr then
            vim.fn.win_gotoid(winnr)
            local buf_obj = nil
            direction = direction or 'sp'
            opts = opts or {}

            assert(buf_obj_or_bufname)


            if type(buf_obj_or_bufname) == 'string' then
                buf_obj = Buffer(buf_obj_or_bufname)
            elseif Class.is_a(buf_obj_or_bufname, Buffer) then
                buf_obj = buf_obj_or_bufname
            else
                buf_obj = Buffer()
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
            elseif direction:match('tab') then
                vim.cmd('tabnew ' .. buf_obj.bufname)
            elseif direction:match('float') then
                Utils.dump(opts)
                opts = opts or {}
                buf_obj.float:show(opts)
            end

            if opts.hook then
                buf_obj:exec(opts.hook, opts.schedule or false)
            end

            return buf_obj
        else
            return false
        end
    end
end

function Buffer.list()
    local n_buffers = vim.fn.bufnr('$')
    local buffers = {}

    for i = 1, n_buffers do
        local info = vim.fn.getbufinfo(i)
        local name = vim.fn.bufname(i)
        local bufnr = vim.fn.bufnr(i)

        if bufnr ~= -1 then
            if #info > 0 then
                info = info[1]
            end

            buffers[name] = info
            buffers[bufnr] = info
        end
    end

    return buffers
end

function Buffer:__init(bufname, opts)
    opts = opts or {}
    local is_temp_buffer = false

    if not bufname then
        bufname = string.format('_temp_buffer_%d', #Buffer.temporary + 1)
        is_temp_buffer = true
        self.scratch = true
    end

    self.bufname = bufname
    self:create()

    if self.bufname and self.bufname:match('^%%:..?') then
        self.bufname = vim.fn.expand(self.bufname)
    end

    self.float = BufFloat(self, opts)
    self.prompt = BufPrompt(self.float)

    self.write = BufWrite(self)
    self.string = BufString(self)

    if is_temp_buffer then
        self:setopts({buftype='nofile'})
    end
end

return Buffer
