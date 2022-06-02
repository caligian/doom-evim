local class = require('classy')
local path = require('path')
local augroup = require('core.au')

local exception = require('core.buffers.exception')
local buffer = class('doom-buffer-utils')

-- This is the same as buffer class in init.lua
-- But this is a functional interface.
-- However all the functionalities are not available. 

-- Class methods
function buffer.exists(bufnr)
    return 1 == vim.fn.bufexists(bufnr)
end

function buffer.visible_p(bufnr)
    return 1 == vim.fn.bufwinid(bufnr)
end

buffer.is_visible = buffer.visible_p

function buffer.hide_by_winid(id)
    vim.api.nvim_win_close(id, true)
end

function buffer.hide_by_winnr(winnr)
    buffer.hide_by_winid(vim.fn.win_getid(winnr))
end

function buffer.focus_by_winid(id)
    return 0 ~= vim.fn.win_gotoid(id)
end

function buffer.focus_by_winnr(winnr)
    return 0 ~= vim.fn.win_gotoid(vim.fn.win_getid(winnr))
end

function buffer.is_loaded(bufnr)
    return vim.fn.bufloaded(bufnr) == 1
end

buffer.loaded_p = buffer.is_loaded

function buffer.load(bufnr)
    vim.fn.bufload(vim.fn.bufname(bufnr))
end

function buffer.setopts(bufnr, options)
    for key, value in pairs(options) do
        vim.api.nvim_buf_set_option(bufnr, key, value)
    end
end

function buffer.setvars(bufnr, vars)
    for key, value in pairs(vars) do
        vim.api.nvim_buf_set_var(bufnr, key, value)
    end
end

function buffer.getvars(bufnr, vars)
    local t = {}

    for i, o in ipairs(vars) do
        t[o] = vim.api.nvim_buf_get_var(bufnr, o)
    end

    return t
end

function buffer.getopts(bufnr, options)
    local t = {}

    for i, o in ipairs(options) do
        t[o] = vim.api.nvim_buf_get_option(bufnr, o)
    end

    return t
end


function buffer.unlist(bufnr)
    buffer.setopts(bufnr, {buflisted=false})
end

function buffer.not_equals(buf1, buf2)
    if class.of(buf1) == class.of(buf2) then
        return buf1.index == buf2.index
    else
        local s = 'bufnr should be a number'
        assert(num_p(buf1), s)
        assert(num_p(buf2), s)
        
        s = 'Buffer does not exist'
        assert(buffer.exists(buf1), s)
        assert(buffer.exists(buf2), s)

        return buf1 ~= buf2
    end
end

function buffer.equals(buf1, buf2)
    if class.of(buf1) == class.of(buf2) then
        return buf1.index == buf2.index
    else
        local s = 'bufnr should be a number'
        assert(num_p(buf1), s)
        assert(num_p(buf2), s)
        
        s = 'Buffer does not exist'
        assert(buffer.exists(buf1), s)
        assert(buffer.exists(buf2), s)

        return buf1 == buf2
    end
end

-- @tparam opts table Options for vim.api.nvim_open_win
-- @return winid number
function buffer.to_win(bufnr, opts)
    assert(buffer.exists(bufnr), exception.BUFNR_NOT_EXISTS)

    opts = opts or {}
    opts.relative = opts.relative or 'win'
    local current_height = vim.o.lines
    local current_width = math.ceil(vim.o.columns/2) 
    opts.width = opts.width or current_width
    opts.height = opts.height or current_height

    if opts.relative then
        opts.row = 0
        opts.col = opts.col or -1
    end

    opts.border = 'solid'
    opts.style = opts.style or 'minimal'

    return vim.api.nvim_open_win(bufnr, true, opts)
end

function buffer.exec(bufnr, f, sched, timeout, tries, inc)
    assert(bufnr.exists(bufnr), exception.BUFNR_NOT_EXISTS)

    local result = false
    local id = buffer.to_win(bufnr)
    local tabnr = vim.fn.tabpagenr()

    timeout = timeout or 10
    tries = tries or 5
    inc = inc or 5
    sched = sched == nil and false
    result = wait(timeout, tries, inc, sched, f)
    local current_tabnr = vim.fn.tabpagenr()

    if tabnr ~= current_tabnr then
        vim.cmd(sprintf('normal %dgt', tabnr))
    end

    buffer.hide_by_winid(id)

    return result
end

function buffer.read(bufnr, pos, concat)
    assert(bufnr.exists(bufnr), exception.BUFNR_NOT_EXISTS)

    pos = pos or {}
    pos.start_row = pos.start_row or 0
    pos.end_row = pos.end_row or -1

    if not pos.start_col and not pos.end_col then
        return vim.api.nvim_buf_get_text(bufnr, pos.start_row, 0, pos.end_row, -1, {})
    end

    pos.start_col = pos.start_col or 0
    pos.end_col = pos.end_col or -1

    local t = vim.api.nvim_buf_get_text(bufnr, pos.start_row, pos.start_col, pos.end_row, pos.end_col, {})

    if concat then 
        return join(t, "\n") 
    else
        return t
    end
end

function buffer.write(bufnr, pos, s)
    assert(bufnr.exists(bufnr), exception.BUFNR_NOT_EXISTS)

    pos = pos or {}
    pos.start_row = pos.start_row or 0

    if str_p(s) then s = split(s, "\n\r") end

    local count = buffer.get_line_count(bufnr)
    pos.end_row = pos.end_row or count
    pos.end_row = pos.end_row > count and count or pos.end_row
    pos.start_row = pos.start_row > count and count or pos.start_row

    if not pos.start_col and not pos.end_col then
        vim.api.nvim_buf_set_lines(bufnr, pos.start_row, pos.end_row, true, s)
        return
    end

    local a = first(buffer.read(bufnr, {start_row=pos.start_row, end_row=pos.start_row}, false))
    local l = a and #a or 0
    local b = first(buffer.read(bufnr, {start_row=pos.end_row, end_row=pos.end_row}, false))
    local m = b and #b or 0

    if l == m == 0 then
        return {a}
    elseif pos.start_col or pos.end_col then
        if l == 0 then
            pos.start_col = 0
        elseif pos.start_col then
            if pos.start_col < 0 then
                if l - pos.start_col < 0 then
                    pos.start_col = 0
                else
                    pos.start_col = l + pos.start_col + 1
                end
            elseif pos.start_col > l then
                pos.start_col = l
            end
        else
            pos.start_col = l
        end

        if m == 0 then
            pos.end_col = 0
        elseif pos.end_col then
            if pos.end_col < 0 then
                if m - pos.end_col < 0 then
                    pos.end_col = 0
                else
                    pos.end_col = m + pos.end_col + 1
                end
            elseif pos.end_col > m then
                pos.end_col = m
            end
        else
            pos.end_col = m
        end
    end

    return vim.api.nvim_buf_set_text(bufnr, pos.start_row, pos.start_col, pos.end_row, pos.end_col, s)
end

function buffer.write_line(bufnr, pos, s)
    assert(bufnr.exists(bufnr), exception.BUFNR_NOT_EXISTS)
    assert(pos.start_row, 'No start row provided')

    pos.end_row = pos.start_row

    buffer.write(bufnr, pos, s)
end

function buffer.insert(bufnr, pos, s)
    pos.end_row = pos.start_row
    pos.end_col = pos.start_col
    buffer.write(bufnr, pos, s)
end

function buffer.insert_line(bufnr, start_row, s)
    buffer.insert(bufnr, {start_row=start_row, start_col=-1}, s)
end

function buffer.put(bufnr, s, prepend, _type, _follow)
    local bufnr = bufnr
    prepend = prepend and 'P' or 'p'
    _type = not _type and 'c' or _type
    _follow = _follow == nil and true or _follow

    if str_p(s) then
        s = split(s, "\n\r")
    end

    sched = sched == nil and false
    timeout = timeout or 10
    tries = tries or 5
    inc = inc or 5
    local f = partial(vim.api.nvim_put, s, _type, prepend, _follow), 

    buffer.exec(bufnr, f, sched, timeout, tries, inc)
end

function buffer.getcurpos(bufnr)
    assert(buffer.exists(bufnr), exception.BUFNR_NOT_EXISTS)

    local row, col, curswant
    local id = buffer.to_win(bufnr)
    bufnr, row, col, curswant = unpack(vim.fn.getcurpos(winnr))
    buffer.hide_by_winid(id)

    return {
        curswant = curswant,
        winid = id,
        row = row - 1,
        col = col - 1,
    }
end

function buffer.getpos(bufnr, expr)
    assert(buffer.exists(bufnr), exception.BUFNR_NOT_EXISTS)

    expr = expr or '.'
    local id = buffer.to_win(bufnr)
    local bufnr, row, col, off = unpack(vim.fn.getpos(expr))
    buffer.hide_by_winid(id)

    return {
        winid = id,
        row = row-1,
        col = col-1,
        curswant = off,
    }
end

function buffer.getvcurpos(bufnr)
    assert(buffer.exists(bufnr), exception.BUFNR_NOT_EXISTS)

    local from = buffer.getpos("'<", bufnr)
    local till = buffer.getpos("'>", bufnr)

    return {
        id = from.winid,
        start_row = from.row,
        end_row = till.row,
        start_col = from.col,
        end_col = till.col,
    }
end

function buffer.add_hook(bufnr, event, f, opts)
    assert(buffer.exists(bufnr), exception.BUFNR_NOT_EXISTS)

    event = event or 'BufEnter'
    local name = 'doom_buffer_' ..  bufnr
    local au = augroup(name, 'Doom buffer augroup for ' .. bufnr)
    au:add(event, sprintf('<buffer=%d>', bufnr), f, opts)

    return au
end

function buffer.to_win_prompt(bufnr, hook, doc, comment, win_opts)
    assert(buffer.exists(bufnr), exception.BUFNR_NOT_EXISTS)
    assert(doc, 'No documentation for callback given')
    assert(hook, 'No callback provided.')

    local text = buffer.read(bufnr, pos)
    comment = comment or '#'
    buffer.write(bufnr, {}, map(function(s) return comment .. ' ' .. s end, text))

    buffer.set_keymap('n', 'gs', function() 
        hook(filter(function(s) 
            if match(s, '^' .. comment) then
                return true
            end
            return false
        end, buffer.read({})))
    end, 'buffer', doc, 'BufEnter', sprintf('<buffer=%d>', bufnr))

    buffer.to_win(bufnr, fin_opts)
end

function buffer.split(bufnr, reverse)
    oblige(buffer.exists(bufnr), 'Buffer [%d] cannot be displayed as it is nonexistent', bufnr)

    reverse = reverse == nil and false

    if reverse then
        vim.cmd(sprintf(':split | b %d', bufnr))
    else
        vim.cmd(sprintf(':split | wincmd j | b %d', bufnr))
    end
end

function buffer.vsplit(bufnr, reverse)
    oblige(buffer.exists(bufnr), 'Buffer [%d] cannot be displayed as it is nonexistent', bufnr)

    reverse = reverse == nil and false

    if reverse then
        vim.cmd(sprintf(':vsplit | b %d', bufnr))
    else
        vim.cmd(sprintf(':vsplit | wincmd l | b %d', bufnr))
    end
end

function buffer.tabnew(bufnr)
    oblige(buffer.exists(bufnr), 'Buffer [%d] cannot be displayed as it is nonexistent', bufnr)

    vim.cmd(sprintf(':tabnew | b %d', bufnr))
end

return buffer
