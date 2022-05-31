local class = require('classy')
local kbd = require('core.kbd')
local path = require('path')
local augroup = require('core.au')
local utils = class('doom-buffer-utils')

-- This is the same as buffer class in init.lua
-- But this is a functional interface.
-- However all the functionalities are not available. 

-- Class methods
function utils.hide_by_winid(id)
    vim.api.nvim_win_close(id, true)
end

function utils.hide_by_winnr(winnr)
    utils.hide_by_winid(vim.fn.win_getid(winnr))
end

function utils.focus_by_winid(id)
    return 0 ~= vim.fn.win_gotoid(id)
end

function utils.focus_by_winnr(winnr)
    return 0 ~= vim.fn.win_gotoid(vim.fn.win_getid(winnr))
end

function utils.bufexists(bufnr)
    return 1 == vim.fn.bufexists(bufnr)
end

function utils.is_visible(bufnr)
    return -1 ~= vim.fn.bufwinid(bufnr)
end

function utils.is_loaded(bufnr)
    return vim.fn.bufloaded(bufnr) == 1
end

function utils.load(bufnr)
    vim.fn.bufload(vim.fn.bufname(bufnr))
end

function utils.setopts(bufnr, options)
    for key, value in pairs(options) do
        vim.api.nvim_buf_set_option(bufnr, key, value)
    end
end

function utils.setvars(bufnr, vars)
    for key, value in pairs(vars) do
        vim.api.nvim_buf_set_var(bufnr, key, value)
    end
end

function utils.getvars(bufnr, vars)
    local t = {}

    for i, o in ipairs(vars) do
        t[o] = vim.api.nvim_buf_get_var(bufnr, o)
    end

    return t
end

function utils.getopts(options)
    local t = {}

    for i, o in ipairs(options) do
        t[o] = vim.api.nvim_buf_get_option(bufnr, o)
    end

    return t
end


function utils.unlist(bufnr)
    utils.setopts({buflisted=false}, bufnr)
end

function utils.equals(buf1, buf2)
    if class.of(buf1) == class.of(buf2) then
        return buf1.index == buf2.index
    else
        return buf1 == buf2
    end
end

function utils.not_equals(buf1, buf2)
    if class.of(buf1) == class.of(buf2) then
        return buf1.index ~= buf2.index
    else
        return buf1 == buf2
    end
end

-- @tparam opts table Options for vim.api.nvim_open_win
-- @return winid number
function utils.to_win(bufnr, opts)
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

function utils.exec(bufnr, f, sched, timeout, tries, inc)
    local result = false
    local id = utils.to_win(bufnr)
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

    utils.hide_by_winid(id)

    return result
end

function utils.read(bufnr, pos, concat)
    pos = pos or {}
    pos.start_row = pos.start_row or 0
    pos.end_row = pos.end_row or -1

    if not pos.start_col and not pos.end_col then
        return vim.api.nvim_buf_get_text(bufnr, pos.start_row, 0, pos.end_row, -1, {})
    end

    oblige(pos.start_col, 'Starting column number not provided')
    pos.end_col = pos.end_col or -1

    local t = vim.api.nvim_buf_get_text(bufnr, pos.start_row, pos.start_col, pos.end_row, pos.end_col, {})
    if concat then return join(t, "\n") end
    return t
end

function utils.write(bufnr, pos, s)
    pos = pos or {}
    pos.start_row = pos.start_row or 0

    if str_p(s) then s = split(s, "\n\r") end

    local count = utils.get_line_count(bufnr)
    pos.end_row = pos.end_row or count
    pos.end_row = pos.end_row > count and count or pos.end_row
    pos.start_row = pos.start_row > count and count or pos.start_row

    if not pos.start_col and not pos.end_col then
        vim.api.nvim_buf_set_lines(bufnr, pos.start_row, pos.end_row, true, s)
        return
    end

    oblige(pos.start_col, 'No starting column provided')
    local a = first(utils.read(bufnr, {start_row=pos.start_row, end_row=pos.start_row}, false))
    local l = a and #a or 0
    local b = first(utils.read(bufnr, {start_row=pos.end_row, end_row=pos.end_row}, false))
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
    vim.api.nvim_buf_set_text(bufnr, pos.start_row, pos.start_col, pos.end_row, pos.end_col, s)
end

function utils.write_line(bufnr, pos, s)
    oblige(pos.start_row)
    pos.end_row = pos.start_row
    utils.write(bufnr, pos, s)
end

function utils.insert(bufnr, pos, s)
    pos.end_row = pos.start_row
    pos.end_col = pos.start_col
    utils.write(bufnr, pos, s)
end

function utils.insert_line(bufnr, start_row, s)
    utils.insert(bufnr, {start_row=start_row, start_col=-1}, s)
end

function utils.put(bufnr, s, prepend, _type, _follow)
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

    utils.exec(bufnr, f, sched, timeout, tries, inc)
end

function utils.getcurpos(bufnr)
    local row, col, curswant
    local id = utils.to_win(bufnr)
    bufnr, row, col, curswant = unpack(vim.fn.getcurpos(winnr))
    utils.hide_by_winid(id)

    return {
        curswant = curswant,
        winid = id,
        row = row - 1,
        col = col - 1,
    }
end

function utils.getpos(bufnr, expr)
    expr = expr or '.'
    local id = utils.to_win(bufnr)
    local bufnr, row, col, off = unpack(vim.fn.getpos(expr))
    utils.hide_by_winid(id)

    return {
        winid = id,
        row = row-1,
        col = col-1,
        curswant = off,
    }
end

function utils.getvcurpos(bufnr)
    local from = utils.getpos("'<", bufnr)
    local till = utils.getpos("'>", bufnr)

    return {
        id = from.winid,
        start_row = from.row,
        end_row = till.row,
        start_col = from.col,
        end_col = till.col,
    }
end

function utils.add_hook(bufnr, event, f, opts)
    oblige(utils.bufexists(bufnr), 'Invalid utils provided: %d', bufnr)
    event = event or 'BufEnter'

    local name = 'doom_utils_' ..  bufnr
    local au = augroup(name, 'Doom utils augroup for ' .. bufnr)
    au:add(event, sprintf('<utils=%d>', bufnr), f, opts)

    return au
end

function utils.to_win_prompt(bufnr, hook, doc, comment, win_opts)
    oblige(doc, 'No documentation for callback given')
    oblige(hook, 'No callback provided.')

    local text = utils.read(bufnr, pos)
    comment = comment or '#'
    utils.write(bufnr, {}, map(function(s) return comment .. ' ' .. s end, text))

    utils.set_keymap('n', 'gs', function() 
        hook(filter(function(s) 
            if match(s, '^' .. comment) then
                return true
            end
            return false
        end, utils.read({})))
    end, 'utils', doc, 'BufEnter', sprintf('<utils=%d>', bufnr))

    utils.to_win(bufnr, fin_opts)
end

function utils.split(bufnr, reverse)
    oblige(utils.bufexists(bufnr), 'Buffer [%d] cannot be displayed as it is nonexistent', bufnr)

    reverse = reverse == nil and false

    if reverse then
        vim.cmd(sprintf(':split | b %d', bufnr))
    else
        vim.cmd(sprintf(':split | wincmd j | b %d', bufnr))
    end
end

function utils.vsplit(bufnr, reverse)
    oblige(utils.bufexists(bufnr), 'Buffer [%d] cannot be displayed as it is nonexistent', bufnr)

    reverse = reverse == nil and false

    if reverse then
        vim.cmd(sprintf(':vsplit | b %d', bufnr))
    else
        vim.cmd(sprintf(':vsplit | wincmd l | b %d', bufnr))
    end
end

function utils.tabnew(bufnr)
    oblige(utils.bufexists(bufnr), 'Buffer [%d] cannot be displayed as it is nonexistent', bufnr)

    vim.cmd(sprintf(':tabnew | b %d', bufnr))
end

return utils
