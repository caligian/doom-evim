local class = require('classy')
local autocmd = require('core.au')
local buffer = class('doom-buffer')

buffer.status = Doom.buffer.status

function buffer.cleanup()
    for key, value in pairs(self.status) do
        if not value:exists() then
            self.status[key] = nil
        end
    end

    return self
end

function buffer:__init(name)
    if num_p(name) then
        oblige(vim.fn.bufname(name) ~= '', 'Invalid bufnr provided')
        name = vim.fn.bufname(name)
    elseif name:match('%%:?[a-z]?') then
        name = vim.fn.expand(name)
    end

    if Doom.buffer.status[self.name] then
        return Doom.buffer.status[self.name]
    end

    self.name = name
    self.index = vim.fn.bufadd(self.name)
    vim.fn.bufload(self.index)
    self.status[self] = self
end

function buffer:exists()
    return 1 == vim.fn.bufexists(self.index)
end

function buffer:is_visible(winnr)
    return -1 ~= vim.fn.bufwinnr(winnr or self.index)
end

function buffer:is_loaded()
    self.loaded = vim.fn.bufloaded(self.index) == 1
    return self.loaded
end

function buffer:setopts(opts)
    for key, value in pairs(options) do
        vim.api.nvim_buf_set_option(self.index, key, value)
    end
end

function buffer:setvars(vars)
    for key, value in pairs(vars) do
        vim.api.nvim_buf_set_var(self.index, key, value)
    end
end

function buffer:get_win()
    return vim.fn.bufwinnr(self.index)
end

function buffer:unlist()
    self:setopts({buflisted=false})
end

function buffer:__eq(buf)
    if class.of(buf) == buffer then
        return self.index == buf.index
    end
end

function buffer:__ne(buf)
    if class.of(buf) == buffer then
        return self.index ~= buf.index
    end
end

function buffer:get_line_count()
    return vim.api.nvim_buf_line_count(self.index)
end

function buffer.find_by_bufnr(bufnr, create)
    if vim.fn.bufexists(bufnr) == 0 then
        return false
    end

    local bufname = vim.fn.bufname(bufnr)

    if create and not Doom.buffer.status[bufname] then
        return buffer(bufname)
    end

    if Doom.buffer.status[bufname] then return Doom.buffer.status[bufname] end

    return false
end

function buffer.find_by_winnr(winnr, create)
    return buffer.find_by_bufnr(vim.fn.winbufnr(winnr), create)
end

function buffer.find_by_name(name, create)
    name = trim(name)

    if match(name, '^%%:?[a-z]?') then
        name = vim.fn.expand(name)
    end

    if vim.fn.bufexists(name) == 0 then return false end

    return buffer.find_by_bufnr(vim.fn.bufnr(name), create)
end


-- tparam opts table Options for vim.api.nvim_open_win
function buffer:to_win(opts)
    method = method or 'f'
    opts = opts or {}
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
    local winnr = vim.api.nvim_open_win(self.index, true, opts)

    return winnr
end

function buffer.focus(winnr)
    local id = vim.fn.win_getid(winnr)
    if id == 0 then
        return false
    end

    vim.fn.win_gotoid(name)
    return true
end

function buffer.hide(winnr)
    vim.api.nvim_win_close(winnr, true)
end

function buffer:exec(f, sched, timeout, tries, inc)
    local result = false
    local winnr = self:to_win()
    local tabnr = vim.fn.tabpagenr()

    result = wait(timeout, tries, inc, sched, f)

    local current_tabnr = vim.fn.tabpagenr()
    if tabnr ~= current_tabnr then
        vim.cmd(sprintf('normal %dgt', tabnr))
    end

    buffer.hide(winnr)

    return result, err
end

--[[
@table method
@field from_row number From row N. Default: 1
@field till_row number Till row N. Default: last row 
@field from_col number From col N. Default: 1
@field till_col number Till col N. Default: last column
--]]
function buffer:read(method, timeout, tries, inc)
    method = method or {}
    method.from_row = method.from_row or 1
    method.till_row = method.till_row or self:get_line_count()

    if not method.from_col or not method.till_col then
        return wait(timeout, tries, inc, vim.api.nvim_buf_get_lines, self.index, method.from_col, t.till_col, false)
    else 
        return wait(timeout, tries, inc, vim.api.nvim_buf_get_text, self.index, method.from_row, method.from_col, method.till_row, method.till_col, {})
    end
end

function buffer:read_line(n, from_col, till_col)
    return self:read({from_row=n, till_row=n+1, from_col=from_col, till_col=till_col})
end

function buffer:get_last_curpos()
end

function buffer:hook(event, f)
    oblige(self:exists(), 'Cannot set autocmds on buffer: %d', self.index)
    event = event or 'BufEnter'
    local pat = self.name .. '_' ..  self.index

    if not self.au then self.au = {} end
end

local b = buffer('abc')


