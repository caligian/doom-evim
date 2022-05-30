local class = require('classy')
local kbd = require('core.kbd')
local path = require('path')
local augroup = require('core.au')
local buffer = class('doom-buffer')

buffer.status = Doom.buffer.status

-- Class methods
function buffer.find_by_bufnr()
    local bufnr = self.index
    if vim.fn.bufexists(bufnr) == 0 then return false end
    local bufnr = vim.fn.bufnr(bufnr)
    if Doom.buffer.status[bufnr] then return Doom.buffer.status[bufnr] end
    return false
end

function buffer.find_by_winnr(winnr)
    return buffer.find_by_bufnr(vim.fn.winbufnr(winnr), create)
end

function buffer.find_by_winid(id)
    return buffer.find_by_bufnr(vim.fn.winbufnr(vim.fn.win_id2win(id)))
end

function buffer.find_by_bufname(expr)
    expr = trim(expr)

    if match(expr, '^%%:?[a-z]?') then
        expr = vim.fn.expand(expr)
    end

    local bufnr = vim.fn.bufnr(expr)
    if bufnr == -1 then return false end

    return buffer.find_by_bufnr(bufnr)
end

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

function buffer.cleanup()
    for bufnr,_  in pairs(Doom.buffer.status) do
        if vim.fn.bufexists(bufnr) ~= 1 then
            Doom.buffer.status[bufnr] = nil
        end
    end
end

-- Instance methods
function buffer:__init(name)
    local bufnr
    local is_temp

    if not name then
        name = sprintf('doom-buffer-%d', #(keys(Doom.buffer.status)))
        bufnr = vim.fn.bufadd(name)
        is_temp = true
    else
        if str_p(name) then name = trim(name) end

        if num_p(name) then
            oblige(vim.fn.bufname(name) ~= '', 'Invalid bufnr provided')
            name = vim.fn.bufname(name)
        elseif name:match('%%:?[a-z]?') then
            name = vim.fn.expand(name)
        end
        bufnr = vim.fn.bufadd(name)
    end

    self.index = bufnr
    self.name = name
    if is_temp then
        self:setopts({buftype='nofile', noswapfile=true, buflisted=false})
    end

    if self.status[bufnr] then
        return self.status[bufnr]
    else
        self.status[bufnr] = self
        self.status[self.name] = self
        return self
    end
end

function buffer:bufexists()
    return 1 == vim.fn.bufexists(self.index)
end

function buffer:is_visible()
    return -1 ~= vim.fn.bufwinid(self.index)
end

function buffer:is_loaded()
    return vim.fn.bufloaded(self.index) == 1
end

function buffer:load()
    local bufnr = self.name
    vim.fn.bufload(self.name)
end

function buffer:setopts(options)
    local bufnr = self.index
    for key, value in pairs(options) do
        vim.api.nvim_buf_set_option(bufnr, key, value)
    end
end

function buffer:setvars(vars)
    local bufnr = self.index
    for key, value in pairs(vars) do
        vim.api.nvim_buf_set_var(bufnr, key, value)
    end
end

function buffer:unlist(bufnr)
    self:setopts({buflisted=false}, bufnr)
end

function buffer:equals(buf2)
    local buf1 = self
    if class.of(buf1) == class.of(buf2) then
        return buf1.index == buf2.index
    else
        return buf1 == buf2
    end
end

function buffer:not_equals(buf2)
    local buf1 = self
    if class.of(buf1) == class.of(buf2) then
        return buf1.index ~= buf2.index
    else
        return buf1 == buf2
    end
end

function buffer:get_line_count()
    return vim.api.nvim_buf_line_count(self.index)
end

-- @tparam opts table Options for vim.api.nvim_open_win
-- @return winid number
function buffer:to_win(opts)
    local bufnr = bufnr or self.index
    method = method or 'f'
    opts = opts or {}
    opts.relative = opts.relative or 'editor'
    local current_height = vim.o.lines / 2
    local current_width = vim.o.columns 
    opts.width = opts.width or current_width
    opts.height = opts.height or current_height

    if opts.relative then
        opts.row = 0
        opts.col = opts.col or 0
    end

    opts.border = 'solid'
    opts.style = opts.style or 'minimal'

    return vim.api.nvim_open_win(bufnr, true, opts)
end

function buffer:exec(f, sched, timeout, tries, inc)
    local bufnr = bufnr or self.index
    local result = false
    local id = self:to_win({})
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

function buffer:read(pos, concat)
    pos = pos or {}
    local bufnr = self.index
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

function buffer:write(pos, s)
    pos = pos or {}
    pos.start_row = pos.start_row or 0
    local bufnr = self.index

    if str_p(s) then s = split(s, "\n\r") end

    local count = self:get_line_count(bufnr)
    pos.end_row = pos.end_row or count
    pos.end_row = pos.end_row > count and count or pos.end_row
    pos.start_row = pos.start_row > count and count or pos.start_row

    if not pos.start_col and not pos.end_col then
        vim.api.nvim_buf_set_lines(bufnr, pos.start_row, pos.end_row, true, s)
        return
    end

    oblige(pos.start_col, 'No starting column provided')
    local a = first(self:read({start_row=pos.start_row, end_row=pos.start_row}, false, bufnr))
    local l = a and #a or 0
    local b = first(self:read({start_row=pos.end_row, end_row=pos.end_row}, false, bufnr))
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

function buffer:write_line(pos, s)
    oblige(pos.start_row)
    pos.end_row = pos.start_row
    self:write(pos, s)
end

function buffer:insert(pos, s)
    prepend = prepend == nil and false
    pos.end_row = pos.start_row
    pos.end_col = pos.start_col
    self:write(pos, s)
end

function buffer:insert_line(start_row, s)
    self:insert({start_row=start_row, start_col=-1}, s)
end

function buffer:put(s, prepend, _type, _follow)
    local bufnr = self.index
    prepend = prepend and 'p' or 'P'
    _type = not _type and 'c' or _type
    _follow = not _follow and true or _follow

    if str_p(s) then
        s = split(s, "\n\r")
    end

    sched = sched == nil and false
    timeout = timeout or 10
    tries = tries or 5
    inc = inc or 5

    self:exec(
    partial(vim.api.nvim_put, s, _type, prepend, _follow), 
    sched,
    timeout, tries, inc,
    bufnr)
end

function buffer:getcurpos()
    local bufnr = self.index
    local row, col, curswant
    local id = buffer.get_floating_win(bufnr)
    bufnr, row, col, curswant = unpack(vim.fn.getcurpos(winnr))
    buffer.hide_by_winid(id)

    return {
        winid = id,
        row = row - 1,
        col = col - 1,
    }
end

function buffer:getpos(expr)
    local bufnr = self.index
    expr = expr or '.'
    local id = self:to_win({}, bufnr)
    local bufnr, row, col, off = unpack(vim.fn.getpos(expr))
    buffer.hide_by_winid(id)

    return {
        winid = id,
        row = row-1,
        col = col-1,
    }
end

function buffer:getvcurpos()
    local bufnr = self.index
    local from = self:getpos("'<", bufnr)
    local till = self:getpos("'>", bufnr)

    return {
        id = from.winid,
        start_row = from.row,
        end_row = till.row,
        start_col = from.col,
        end_col = till.col,
    }
end

function buffer:add_hook(event, f, opts)
    local bufnr = self.index
    oblige(self:bufexists(bufnr), 'Invalid buffer provided: %d', bufnr)
    event = event or 'BufEnter'
    local name = 'doom_buffer_' ..  bufnr
    local au 

    if not self.au then
        au = augroup(name, 'Doom buffer augroup for ' .. bufnr)
    end

    au:add(event, sprintf('<buffer=%d>', bufnr), f, opts)
end

function buffer:delete()
    self.status[self.index] = nil
end

function buffer:set_keymap(mode, keys, f, attribs, doc, event)
    oblige(f)
    oblige(doc)

    assoc(self, {'keymaps', mode, keys}, {})

    keys = keys or self.keys
    mode = mode or 'n'
    event = event or 'BufEnter'
    attribs = attribs or 'buffer'
    local doc = 'Keybinding for buffer: ' .. self.index
    local pattern = sprintf('<buffer=%d>', self.index)
    local k =  kbd(mode, keys, f, attribs, doc, event, pattern)
    self.keymaps[mode][keys] = k
    k:enable()
end

function buffer:disable_keymap(mode, keys)
    modes = modes or 'n'
    local k = assoc(self.keymaps, {m, keys})
    if k then k:disable() end
end

function buffer:replace_keymap(mode, keys, f, attribs, event, pattern)
    mode = mode or 'n'
    local keybinding = assoc(self.keymaps, {mode, keys})

    if keybinding then
        keybinding:replace(f, attribs, event, pattern)
    end
end

function buffer:to_win_prompt(hook, doc, comment, win_opts)
    oblige(doc, 'No documentation for callback given')
    oblige(hook, 'No callback provided.')

    local text = self:read(pos)
    comment = comment or '#'
    self:write({}, map(function(s) return comment .. ' ' .. s end, text))

    self:set_keymap('n', 'gs', function() 
        hook(filter(function(s) 
            if match(s, '^' .. comment) then
                return true
            end
            return false
        end, self:read({})))
    end, 'buffer', doc, 'BufEnter', sprintf('<buffer=%d>', self.index))

    self.prompt = true
    self.comment = comment
    self:to_win(win_opts)
end

return buffer
