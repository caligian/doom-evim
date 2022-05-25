%%cal Class = require('classy')
local Au = require('core.au')
local BufString = require('core.buffers.string')
local BufFloat = require('core.buffers.floating')
local BufWrite = require('core.buffers.writer')
local BufPrompt = require('core.buffers.prompt')
local BufExceptions = require('core.buffers.exceptions')
local utils = require('modules.utils')

local Buffer = Class('doom-buffer')
Buffer.status = Doom.buffer.status
Buffer.temp_path = Doom.buffer.temp_path

function Buffer:exists()
    if vim.fn.bufexists(self.bufnr) == 1 then
        self.bufnr = vim.fn.bufnr(self.bufname)
        self.status[self.bufname] = self
        return self.bufnr
    else
        return false
    end
end

function Buffer:is_visible()
    self.exceptions:assert(self:exists(), 'invalid')

    local winnr = vim.fn.bufwinnr(self.bufnr)

    if winnr ~= -1 then
        self.winnr = winnr
        return winnr
    else
        self.winnr = false
        return false
    end
end

function Buffer:focus(direction)
    self.exceptions:assert(self:exists(), 'invalid')

    direction = direction or 'sp'

    if self:is_visible() then
        vim.fn.win_gotoid(self.winnr)
    elseif direction:match('^sp') then
        vim.cmd('sp | wincmd j | buffer ' .. self.bufname)
    elseif direction:match('^vsp') then
        vim.cmd('vsp | wincmd l | buffer ' .. self.bufname)
    elseif direction:match('tab') then
        vim.cmd('tabnew ' .. self.bufname)
    elseif direction:match('float') then
        self.float:show()
    end

    return self
end

function Buffer:winsaveview()
    self.exceptions:assert(self:exists(), 'invalid')
    self.exceptions:assert(self:is_visible(), 'invisible')

    self.winview = vim.fn.winsaveview()

    return self.winview
end

function Buffer:winrestview()
    self.exceptions:assert(self:exists(), 'invalid')
    self.exceptions:assert(self:is_visible(), 'invisible')

    vim.fn.winrestview(self.winview)

    return self
end

function Buffer.cleanup()
    for key, value in pairs(self.status) do
        if not value:exists() then
            self.status[key] = nil
        end
    end

    return self
end

function Buffer:unlist()
    self.exceptions:assert(self:exists(), 'invalid')

    self.listed = false
    vim.api.nvim_buf_set_option(self.bufnr, 'buflisted', false)

    return self
end

function Buffer:setopts(options)
    self.exceptions:assert(self:exists(), 'invalid')

    for key, value in pairs(options) do
        vim.api.nvim_buf_set_option(self.bufnr, key, value)
    end

    return self
end

function Buffer:setvars(vars)
    self.exceptions:assert(self:exists(), 'invalid')

    for key, value in pairs(vars) do
        vim.api.nvim_buf_set_var(self.bufnr, key, value)
    end

    return self
end

function Buffer:kill()
    self.exceptions:assert(self:exists(), 'invalid')

    if not self:is_visible() then
        vim.cmd('bwipeout! ' .. self.bufname)
        self.killed = true
        self.status[self.bufname] = nil
    end
end

function Buffer:count()
    self.exceptions:assert(self:exists(), 'invalid')

    return vim.api.nvim_buf_line_count(self.bufnr)
end

function Buffer:__eq(buf_obj)
    return self.bufnr == buf_obj.bufnr
end

function Buffer:create()
    if vim.fn.bufexists(self.bufname) == 0 then
       vim.fn.bufadd(self.bufname)
    end

    self.bufnr = vim.fn.bufnr(self.bufname)
    self.bufname = vim.fn.bufname(self.bufnr)
    self.status[self.bufname] = self

    return self
end

function Buffer:hook(event_name, f, schedule)
    self.exceptions:assert(self:exists(), 'invalid')
    event_name = event_name or 'BufEnter'
    self.au = au(self.path)

    if not schedule then
        Au.autocmd('Global', event_name, self.bufname, f)
    else
        Au.autocmd('Global', event_name, self.bufname, function ()
            f(self)
        end)
    end

    return self
end

function Buffer:load()
    self.exceptions:assert(self:exists(), 'invalid')

    if vim.fn.bufloaded == 0 then
        vim.fn.bufload(self.bufname)
        return self
    end
end

function Buffer:hide()
    self.exceptions:assert(self:exists(), 'invalid')

    local tabpage_buflist_n = #(vim.fn.tabpagebuflist(vim.fn.tabpagenr()))

    if self:is_visible() and tabpage_buflist_n > 1 then
        vim.fn.win_gotoid(self.winnr)
        vim.cmd('q')

        return self
    end
end

-- If sync is provided then only wait for output
function Buffer:exec(f, opts)
    self.exceptions:assert(self:exists(), 'invalid')

    opts = opts or {}
    opts.sync = opts.sync or {}
    opts.sync.try = opts.sync.try or 10
    opts.sync.wait = opts.sync.wait or 1
    opts.sync.inc = opts.sync.inc or 0.6

    local out = false
    local err

    local function _sync()
        local try_n = opts.sync.try or 10
        local wait = opts.sync.wait or 10
        local inc = opts.sync.inc or 0.5

        while not out and try_n >= 0 do
            vim.wait(wait)
            wait = wait + wait * inc
            try_n = try_n - 1
        end

        if not out and try_n == 0 then
            self.exceptions:timeout()
        end
    end

    local function _f()
        if self:is_visible() then
            local current_winnr = vim.fn.winnr()

            vim.fn.win_gotoid(self.winnr)

            if opts.schedule then
                vim.schedule(function ()
                    out = f(self)
                end)
            else
                out = f(self)
            end

            vim.fn.win_gotoid(current_winnr)
        else
            self.floating:show()

            if opts.schedule then
                vim.schedule(function ()
                    out = f(self)
                end)
            else
                out = f(self)
            end

            self.floating:hide()
        end
    end

    opts.protected = opts.protected == nil and false or true

    if opts.protected then
        local _ 

        _, err = pcall(function ()
            _f()

            if opts.output then
                sync()
            end
        end)
    else
        _f()
    end

    if err then
        return err
    else
        return out
    end
end

function Buffer:getpos(expr)
    self.exceptions:assert(self:exists(), 'invalid')

    self:exec(function ()
        expr = vim.fn.getpos(expr)
    end)
end

function Buffer:position(opts)
    self.exceptions:assert(self:exists(), 'invalid')

    opts = opts or {}

    local cood = {row={}, col={}}

    if opts.visual then
        local from = vim.api.nvim_buf_get_mark(self.bufnr, "<")
        local till = vim.api.nvim_buf_get_mark(self.bufnr, ">")

        cood.row.from = from[1] - 1
        cood.row.till = till[1] - 1

        cood.col.from = from[2]
        cood.col.till = till[2]
    else
        self:exec(function ()
            cood.col = vim.fn.col('.') - 1
            cood.row = vim.fn.line('.') - 1
        end)
    end

    return cood
end

-- Split this buffer and...
-- In order to do this, the buffer should be visible.
function Buffer:split(buf_obj_or_bufname, direction, opts)
    self.exceptions:assert(self:exists(), 'invalid')
    self.exceptions:assert(self:is_visible(), 'invisible')

    vim.fn.win_gotoid(self.winnr)
    local buf_obj = nil
    direction = direction or 'sp'
    opts = opts or {}

    if type(buf_obj_or_bufname) == 'string' then
        buf_obj = Buffer(buf_obj_or_bufname)
    elseif Class.is_a(buf_obj_or_bufname, Buffer) then
        buf_obj = buf_obj_or_bufname
    else
        buf_obj = Buffer()
    end

    if direction:match('^sp') then
        if not opts.reverse then
            vim.cmd('sp | wincmd j | buffer ' .. buf_obj.bufname)
        else
            vim.cmd('sp | buffer ' .. buf_obj.bufname)
        end
    elseif direction:match('vsp') then
        if opts.reverse then
            vim.cmd('vsp | buffer ' .. buf_obj.bufname)
        else
            vim.cmd('vsp | wincmd l | buffer ' .. buf_obj.bufname)
        end
    elseif direction:match('tab') then
        vim.cmd('tabnew ' .. buf_obj.bufname)
    elseif direction:match('float') then
        opts = opts or {}
        buf_obj.float:show(opts)
    end

    local out = nil
    if opts.on_open then
        out = buf_obj:exec(opts.on_open, {
            protected=opts.protected,
            schedule=opts.scheduled,
            stdout=opts.stdout})
    end

    return buf_obj, out
end

function Buffer.list()
    local n_buffers = vim.fn.bufnr('$')
    local buffers = {}

    for i = 1, n_buffers do
        local bufnr = vim.fn.bufnr(i)

        if bufnr ~= -1 then
            local bufname = vim.fn.bufname(bufnr)

            if not Buffer.status[bufname] then
                buffers[bufname] = Buffer(bufname)
-- code            else
                buffers[bufname] = Buffer.status[bufname]
            end
        end
    end

    return buffers
end

-- Always save the name of the calling buffer.
function Buffer:__init(bufname, opts)
    opts = opts or {}

    if not bufname then
        self.bufname = string.format('_temp_buffer_%d', #Buffer.status + 1)
        self.scratch = true
    elseif bufname:match('^%%?:?..?') then
        self.bufname = vim.fn.expand(bufname)
    end

    self:create()

    self.float = BufFloat(self, opts)
    self.prompt = BufPrompt(self.float)

    self.write = BufWrite(self)
    self.string = BufString(self)

    self.exceptions = BufExceptions(self)

    if self.scratch then
        self:setopts({buftype='nofile', buflisted=true})
    end
end

return Buffer
