local class = require('classy')
local path = require('path')
local augroup = require('core.au')
local buffer = class('doom-buffer')

buffer.status = Doom.buffer.status

function buffer:__init(name)
    if str_p(name) then name = trim(name) end

    if num_p(name) then
        oblige(vim.fn.bufname(name) ~= '', 'Invalid bufnr provided')
        name = vim.fn.bufname(name)
    elseif name:match('%%:?[a-z]?') then
        name = vim.fn.expand(name)
    end

    local index = vim.fn.bufadd(name)
    self.index = index
    self.name = name
    vim.fn.bufload(self.index)
end

function buffer.exists(bufnr)
    return 1 == vim.fn.bufexists(bufnr)
end

function buffer.is_visible(bufnr)
    return -1 ~= vim.fn.bufwinid(buf)
end

function buffer.is_loaded(bufnr)
    return vim.fn.bufloaded(bufnr) == 1
end

function buffer.setopts(bufnr, opts)
    for key, value in pairs(options) do
        vim.api.nvim_buf_set_option(bufnr, key, value)
    end
end

function buffer.setvars(bufnr, vars)
    for key, value in pairs(vars) do
        vim.api.nvim_buf_set_var(bufnr, key, value)
    end
end

function buffer.unlist(bufnr)
    buffer.setopts(bufnr, {buflisted=false})
end

function buffer.equals(buf1, buf2)
    if class.of(buf1) == class.of(buf2) then
        return buf1.index == buf2.index
    end
end

function buffer.not_equals(buf1, buf2)
    if class.of(buf) == class.of(buf) then
        return buf1.index ~= buf2.index
    end
end

function buffer.get_line_count(bufnr)
    return vim.api.nvim_buf_line_count(bufnr)
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
    local winid = vim.fn.win_getid(winnr)
    return winid
end
--[[
@table method
@field start_row number From row N. Default: 1
@field end_row number Till row N. Default: last row 
@field start_col number From col N. Default: 1
@field end_col number Till col N. Default: last column
--]]
function buffer:read(method, timeout, tries, inc)
    method = method or {}
    method.start_row = method.start_row or 1
    method.end_row = method.end_row or self:get_line_count()
    timeout = timeout == nil and 10
    tries = tries == nil and 20
    inc = inc == nil and 5


    if not method.start_col and not method.end_col then
        return wait(timeout, tries, inc, true, vim.api.nvim_buf_get_lines, self.index, method.start_row, method.end_row, false)
    else 
        method.start_col = method.start_col or 1
        oblige(method.end_col, 'Till which column?')

        if method.end_row - method.start_row == 1 then
            method.end_row = method.end_row -1
        end

        return wait(timeout, tries, inc, true, vim.api.nvim_buf_get_text, self.index, method.start_row, method.start_col, method.end_row, method.end_col, {})
    end
end

function buffer:read_line(n, start_col, end_col)
    return first(self:read({start_row=n, end_row=n+1,start_col=start_col, end_col=end_col}))
end

-- [n, m, n, -1] yields a single full line
local function _getstr(bufnr, t)
    oblige(t.start_row, 'Starting row number not provided')
    t.end_row = t.end_row or -1

    if not t.start_col and not t.end_col then
        return vim.api.nvim_buf_get_text(bufnr, t.start_row, 0, t.end_row, -1, {})
    end

    oblige(t.start_col, 'Starting column number not provided')
    t.end_col = t.end_col or -1

    return vim.api.nvim_buf_get_text(bufnr, t.start_row, t.start_col, t.end_row, t.end_col, {})
end

local function _writestr(bufnr, t)
end

function buffer:write(pos, s)
    inspect(pos)
    assert(table_p(pos))
    assert(pos.start_row)

    if str_p(s) then s = split(s, "\n\r") end

    local last_line = self:get_line_count() - 1
    if pos.start_row == '$' then pos.start_row = last_line end
    pos.end_row = pos.end_row or last_line
    if pos.end_row >= last_line then pos.end_row = last_line end
    if pos.start_row > pos.end_row then pos.start_row = pos.end_row end

    if not pos.start_col and not pos.end_col then
        vim.api.nvim_buf_set_lines(self.index, pos.start_row, pos.end_row, false, s)
    else
        assert(pos.start_col)
        pos.end_row = pos.end_row - 1
        local end_row_s = self:read_line(pos.end_row)
        local n = #end_row_s
        pos.end_col = pos.end_col or n
        if pos.end_col >= n then pos.end_col = n end
        vim.api.nvim_buf_set_text(self.index, pos.start_row, pos.start_col, pos.end_row, pos.end_col, s)
    end
end

function buffer:write_line(row, start_col, end_col, s)
    self:write({
        start_row=row,
        end_row=row+1,
        start_col=start_col,
        end_col=end_col,
    }, s)
end

function buffer:insert(row, col, s)
    self:write({
        start_row = row,
        end_row = row+1,
        start_col = col,
        end_col = col,
    }, s)
end

function buffer:insert_line(row, s)
    self:write({
        start_row = row,
        end_row = row,
        start_col = 0,
        end_col = 0
    }, s)
end

function buffer:getcurpos()
    local winnr = vim.fn.win_id2win(self:to_win())
    local bufnr, row, col, curswant = unpack(vim.fn.getcurpos(winnr))
    self.hide(winnr)

    return {
        index = vim.fn.bufnr(bufnr),
        row = row - 1,
        col = col - 1,
    }
end

function buffer:getpos(expr)
    local winnr = vim.fn.win_id2win(self:to_win())
    local bufnr, row, col, off = unpack(vim.fn.getpos(expr))
    self.hide(winnr)

    return {
        bufnr = bufnr,
        row = row - 1,
        col = col - 1,
    }
end

function buffer:getvcurpos()
    local from = self:getpos("'<")
    local till = self:getpos("'>")

    return {
        start_row = from.row - 1,
        end_row = till.row - 1,
        start_col = from.col - 1,
        end_col = till.col - 1,
    }
end

function buffer:add_hook(event, f, opts)
    oblige(self:exists(), 'Cannot set autocmds on buffer: %d', self.index)
    event = event or 'BufEnter'

    if not self.au then
        local name = self.name .. '_' ..  self.index
        self.au = augroup(name, 'Doom buffer augroup')
    end

    self.au:add(event, sprintf('<buffer=%d>', self.index), f, opts)
end

-- local b = buffer('abcdefgh')
-- b:write_line('$', 1, 1, {'hello world12'})
