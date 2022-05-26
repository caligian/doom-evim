local utils = {}
utils.status = Doom.buffer.status

function utils.cleanup()
    for bufnr,_  in pairs(Doom.buffer.status) do
        if vim.fn.bufexists(bufnr) ~= 1 then
            Doom.buffer.status[bufnr] = nil
        end
    end
end

function utils.bufexists(bufnr)
    return 1 == vim.fn.bufexists(bufnr)
end

function utils.is_visible(bufnr)
    return -1 ~= vim.fn.bufwinid(buf)
end

function utils.is_loaded(bufnr)
    return vim.fn.bufloaded(bufnr) == 1
end

function utils.setopts(bufnr, opts)
    for key, value in pairs(options) do
        vim.api.nvim_buf_set_option(bufnr, key, value)
    end
end

function utils.setvars(bufnr, vars)
    for key, value in pairs(vars) do
        vim.api.nvim_buf_set_var(bufnr, key, value)
    end
end

function utils.unlist(bufnr)
    utils.setopts(bufnr, {buflisted=false})
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

function utils.get_line_count(bufnr)
    return vim.api.nvim_buf_line_count(bufnr)
end

function utils.find_by_bufnr(bufnr)
    if vim.fn.bufexists(bufnr) == 0 then return false end

    local bufnr = vim.fn.bufnr(bufnr)

    if Doom.utils.status[bufnr] then return Doom.utils.status[bufnr] end

    return false
end

function utils.find_by_winnr(winnr)
    return utils.find_by_bufnr(vim.fn.winbufnr(winnr), create)
end

function utils.find_by_winid(id)
    return utils.find_by_bufnr(vim.fn.winbufnr(vim.fn.win_id2win(id)))
end

function utils.find_by_bufname(expr)
    expr = trim(expr)

    if match(expr, '^%%:?[a-z]?') then
        expr = vim.fn.expand(expr)
    end

    local bufnr = vim.fn.bufnr(expr)
    if bufnr == -1 then return false end

    return utils.find_by_bufnr(bufnr)
end

-- tparam opts table Options for vim.api.nvim_open_win
function utils.get_floating_win(bufnr, opts)
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

    return vim.api.nvim_open_win(bufnr, true, opts)
end

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

function utils.exec(bufnr, f, sched, timeout, tries, inc)
    local result = false
    local id = utils.get_floating_win(bufnr)
    local tabnr = vim.fn.tabpagenr()

    timeout = timeout or 10
    tries = tries or 5
    inc = inc or 5
    sched = sched == nil or false
    result = wait(timeout, tries, inc, sched, f)
    local current_tabnr = vim.fn.tabpagenr()

    if tabnr ~= current_tabnr then
        vim.cmd(sprintf('normal %dgt', tabnr))
    end

    utils.hide_by_winid(id)

    return result, err
end

function utils.get_string(bufnr, pos)
    oblige(pos.start_row, 'Starting row number not provided')
    pos.end_row = pos.end_row or -1

    if not pos.start_col and not pos.end_col then
        return vim.api.nvim_buf_get_text(bufnr, pos.start_row, 0, pos.end_row, -1, {})
    end

    oblige(pos.start_col, 'Starting column number not provided')
    pos.end_col = pos.end_col or -1

    return vim.api.nvim_buf_get_text(bufnr, pos.start_row, pos.start_col, pos.end_row, pos.end_col, {})
end

function utils.write_string(bufnr, pos, s)
    oblige(pos.start_row, 'Starting row number not provided')
    oblige(pos.end_row, 'Ending row number not provided')
    oblige(pos.start_row <= pos.end_row, 'Starting row cannot be bigger than Ending row')
    if str_p(s) then s = split(s, "\n\r") end
    local count = utils.get_line_count(bufnr)
    pos.end_row = pos.end_row or count-1
    pos.end_row = pos.end_row >= count and count - 1 or pos.end_row
    pos.start_row = pos.start_row or count-1
    pos.start_row = pos.start_row >= count and count - 1 or pos.start_row

    if not pos.start_col and not pos.end_col then
        vim.api.nvim_buf_set_lines(bufnr, pos.start_row, pos.end_row, true, s)
        return
    end

    oblige(pos.start_col, 'No starting column provided')
    local a = first(utils.get_string(bufnr, {start_row=pos.start_row, end_row=pos.start_row}))
    local l = a and #a or 0
    local b = first(utils.get_string(bufnr, {start_row=pos.end_row, end_row=pos.end_row}))
    local m = b and #b or 0

    if l == m == 0 then
        pos.start_col = 0
        pos.end_col = 0
    elseif not pos.start_col and not pos.end_col then
        pos.start_col = l - 1
        pos.end_col = m - 1
    elseif pos.start_col or pos.end_col then
        if l == 0 then
            pos.start_col = 0
        elseif pos.start_col then
            if pos.start_col < 0 then
                if l - pos.start_col < 0 then
                    pos.start_col = 0
                else
                    pos.start_col = l - pos.start_col
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
                    pos.end_col = m - pos.end_col
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

function utils.getcurpos(bufnr)
    local winnr = vim.fn.win_id2win(utils.get_floating_win(bufnr))
    local bufnr, row, col, curswant = unpack(vim.fn.getcurpos(winnr))
    utils.focus_by_winnr(winnr)
    utils.hide_by_winnr(winnr)

    return {
        index = bufnr,
        row = row - 1,
        col = col - 1,
    }
end

function utils.getpos(bufnr, expr)
    local winnr = vim.fn.win_id2win(utils.get_floating_win(bufnr))
    local bufnr, row, col, off = unpack(vim.fn.getpos(expr))
    utils.hide_by_winnr(winnr)

    return {
        bufnr = bufnr,
        row = row - 1,
        col = col - 1,
    }
end

function utils.getvcurpos(bufnr)
    local from = utils.getpos(bufnr, "'<")
    local till = utils.getpos(bufnr, "'>")

    return {
        start_row = from.row - 1,
        end_row = till.row - 1,
        start_col = from.col - 1,
        end_col = till.col - 1,
    }
end

function utils.add_hook(bufnr, event, f, opts)
    oblige(utils.bufexists(bufnr), 'Invalid buffer provided: %d', bufnr)
    event = event or 'BufEnter'
    local name = self.name .. '_' ..  bufnr
    local au = augroup(name, 'Doom buffer augroup')
    au:add(event, sprintf('<buffer=%d>', bufnr), f, opts)

    return au
end
