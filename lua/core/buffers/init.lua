local class = require('classy')
local kbd = require('core.kbd')
local path = require('path')
local augroup = require('core.au')
local buffer = class('doom-buffer')
local exception = require('core.buffers.exception')

buffer.status = Doom.buffer.status

-- Class methods
function buffer.find_by_bufnr(bufnr)
    assert_num(bufnr)

    if vim.fn.bufexists(bufnr) == 0 then return false end
    if Doom.buffer.status[bufnr] then return Doom.buffer.status[bufnr] end
    return false
end

function buffer.find_by_winnr(winnr)
    assert_num(bufnr)

    return buffer.find_by_bufnr(vim.fn.winbufnr(winnr))
end

function buffer.find_by_winid(id)
    assert_num(id)

    return buffer.find_by_bufnr(vim.fn.winbufnr(vim.fn.win_id2win(id)))
end

function buffer.find_by_bufname(expr)
    assert_type(expr, 'string', 'number')

    expr = trim(expr)

    if match(expr, '^%%:?[a-z]?') then
        expr = vim.fn.expand(expr)
    end

    local bufnr = vim.fn.bufnr(expr)
    if bufnr == -1 then return false end

    return buffer.find_by_bufnr(bufnr)
end

function buffer.hide_by_winid(id)
    assert_num(id)

    vim.api.nvim_win_close(id, true)
end

function buffer.hide_by_winnr(winnr)
    assert_num(winnr)

    buffer.hide_by_winid(vim.fn.win_getid(winnr))
end

function buffer.focus_by_winid(id)
    assert_num(id)

    return 0 ~= vim.fn.win_gotoid(id)
end

function buffer.focus_by_winnr(winnr)
    assert_num(winnr)

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
function buffer:exists()
    return 1 == vim.fn.bufexists(self.index)
end

function buffer:is_visible()
    return -1 ~= vim.fn.bufwinid(self.index)
end

function buffer:is_loaded()
    return vim.fn.bufloaded(self.index) == 1
end

buffer.loaded_p = buffer.is_loaded

function buffer:load()
    vim.fn.bufload(self.name)
end

function buffer:setvars(vars)
    assert(self:exists(), exception.bufnr_not_valid(self.index))

    for key, value in pairs(vars) do
        vim.api.nvim_buf_set_var(self.index, key, value)
    end
end

function buffer:getvars(vars)
    assert(self:exists(), exception.bufnr_not_valid(self.index))

    local t = {}
    for i, o in ipairs(vars) do
        t[o] = vim.api.nvim_buf_get_var(self.index, o)
    end

    return t
end

function buffer:setopts(options)
    assert(self:exists(), exception.bufnr_not_valid(self.index))

    for key, value in pairs(options) do
        vim.api.nvim_buf_set_option(self.index, key, value)
    end
end

function buffer:setvars(vars)
    assert(self:exists(), exception.bufnr_not_valid(self.index))

    for key, value in pairs(vars) do
        vim.api.nvim_buf_set_var(self.index, key, value)
    end
end

function buffer:unlist()
    self:setopts({buflisted=false})
end

function buffer:equals(buf2)
    assert(self:exists(), exception.bufnr_not_valid(self.index))

    local buf1 = self
    if class.of(buf1) == class.of(buf2) then
        assert(buf2:exists(), exception.bufnr_not_valid(buf2.index))
        return buf1.index == buf2.index
    else
        assert_num(buf2.index)
        return buf1.index == buf2
    end
end

function buffer:nequals(buf2)
    assert(self:exists(), exception.bufnr_not_valid(self.index))

    local buf1 = self
    if class.of(buf1) == class.of(buf2) then
        assert(buf2:exists(), exception.bufnr_not_valid(buf2.index))
        return buf1.index == buf2.index
    else
        assert_num(buf2.index)
        return buf1.index == buf2
    end
end

buffer.not_equals = buffer.nequals
buffer.__eq = buffer.equals
buffer.__neq = buffer.nequals

function buffer:__init(name, scratch)
    local bufnr
    local is_temp

    assert_type(name, 'string', 'number')

    if scratch then
        name = with_data_path('temp', 'doom-scratch-buffer' .. '.' .. vim.bo.filetype)
        bufnr = vim.fn.bufadd(name)
    elseif not name then
        name = sprintf('doom-buffer-%d', #(keys(Doom.buffer.status)))
        bufnr = vim.fn.bufadd(name)
        is_temp = true
    else
        if str_p(name) then name = trim(name) end

        if num_p(name) then
            exception.bufname_not_valid(name)
            name = vim.fn.bufname(name)
        elseif name:match('%%:?[a-z]?') then
            name = vim.fn.expand(name)
        end
        bufnr = vim.fn.bufadd(name)
    end

    self.index = bufnr
    self.name = name
    if is_temp then
        self:setopts({buftype='nofile', swapfile=false, buflisted=false})
    elseif scratch then
        self:setopts({buflisted=false, swapfile=false, filetype=vim.bo.filetype})
    end

    if self.status[bufnr] then
        return self.status[bufnr]
    else
        self.status[bufnr] = self
        self.status[self.name] = self
        return self
    end
end

function buffer:get_line_count()
    assert(self:exists(), exception.bufnr_not_valid(self.index))
    return vim.api.nvim_buf_line_count(self.index)
end

-- @tparam opts table Options for vim.api.nvim_open_win
-- @return winid number
function buffer:to_win(opts)
    assert(self:exists(), exception.bufnr_not_valid(self.index))

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

    return vim.api.nvim_open_win(self.index, true, opts)
end

function buffer:exec(f, sched, timeout, tries, inc)
    assert(self:exists(), exception.bufnr_not_valid(self.index))

    local result = false
    local id = self:to_win()
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
    assert(self:exists(), exception.bufnr_not_valid(self.index))

    pos = pos or {}
    local bufnr = self.index
    pos.start_row = pos.start_row or 0
    pos.end_row = pos.end_row or -1

    if not pos.start_col and not pos.end_col then
        return vim.api.nvim_buf_get_text(bufnr, pos.start_row, 0, pos.end_row, -1, {})
    end

    pos.end_col = pos.end_col or -1
    pos.start_col = pos.start_col or 0

    local t = vim.api.nvim_buf_get_text(bufnr, pos.start_row, pos.start_col, pos.end_row, pos.end_col, {})
    if concat then return join(t, "\n") end

    return t
end

function buffer:write(pos, s)
    assert(self:exists(), exception.bufnr_not_valid(self.index))
    assert(pos.start_row, exception.no_start_row(pos))

    pos = pos or {}
    pos.start_row = pos.start_row or 0
    local bufnr = self.index

    if str_p(s) then s = split(s, "\n\r") end

    local count = self:get_line_count()
    pos.end_row = pos.end_row or count
    pos.end_row = pos.end_row > count and count or pos.end_row
    pos.start_row = pos.start_row > count and count or pos.start_row

    if not pos.start_col and not pos.end_col then
        vim.api.nvim_buf_set_lines(bufnr, pos.start_row, pos.end_row, true, s)
        return
    end

    local a = first(self:read({start_row=pos.start_row, end_row=pos.start_row}, false, bufnr))
    local l = a and #a or 0
    local b = first(self:read({start_row=pos.end_row, end_row=pos.end_row}, false, bufnr))
    local m = b and #b or 0

    if l == m == 0 then
        pos.start_col = 0
        pos.end_col = 0
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
    pos = pos or {}
    if pos.start_row then pos.end_row = pos.start_row end
    self:write(pos, s)
end

function buffer:insert(pos, s)
    pos = pos or {}
    pos.end_row = pos.start_row
    pos.end_col = pos.start_col
    self:write(pos, s)
end

function buffer:insert_line(start_row, s)
    self:insert({start_row=start_row, start_col=-1}, s)
end

function buffer:put(s, prepend, _type, _follow)
    assert(self:exists(), exception.bufnr_not_valid(self.index))

    assert_type(s, 'table', string)
    assert_s(prepend)
    assert_s(_type)
    assert_s(_follow)

    local bufnr = self.index
    prepend = prepend and 'P' or 'p'
    _type = not _type and 'c' or _type
    _follow = _follow == nil and true or _follow

    if str_p(s) then s = split(s, "\n\r") end

    sched = sched == nil and false
    timeout = timeout or 10
    tries = tries or 5
    inc = inc or 5
    local f = partial(vim.api.nvim_put, to_list(s), _type, prepend, _follow), 

    self:exec(f, sched, timeout, tries, inc)
end

function buffer:getcurpos()
    assert(self:exists(), exception.bufnr_not_valid(self.index))

    local row, col, curswant
    local id = self:to_win()
    bufnr, row, col, curswant = unpack(vim.fn.getcurpos(winnr))
    buffer.hide_by_winid(id)

    return {
        winid = id,
        row = row - 1,
        col = col - 1,
        curswant = curswant,
    }
end

function buffer:getpos(expr)
    assert(self:exists(), exception.bufnr_not_valid(self.index))

    expr = expr or '.'
    local id = self:to_win()
    local bufnr, row, col, off = unpack(vim.fn.getpos(expr))
    buffer.hide_by_winid(id)

    return {
        winid = id,
        row = row-1,
        curswant = off,
        col = col-1,
    }
end

function buffer:getvcurpos()
    assert(self:exists(), exception.bufnr_not_valid(self.index))

    local from = self:getpos("'<")
    local till = self:getpos("'>")

    return {
        id = from.winid,
        start_row = from.row,
        end_row = till.row,
        start_col = from.col,
        end_col = till.col,
    }
end

function buffer:add_hook(event, f, opts)
    assert(self:exists(), exception.bufnr_not_valid(self.index))

    local bufnr = self.index
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
    assert(mode)
    assert(key)
    assert(f)
    assert(doc)

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
    assert(self:exists(), exception.bufnr_not_valid(self.index))

    modes = modes or 'n'
    local k = assoc(self.keymaps, {m, keys})
    if k then k:disable() end
end

function buffer:replace_keymap(mode, keys, f, attribs, event, pattern)
    assert(self:exists(), exception.bufnr_not_valid(self.index))

    mode = mode or 'n'
    local keybinding = assoc(self.keymaps, {mode, keys})

    if keybinding then
        keybinding:replace(f, attribs, event, pattern)
    end
end

function buffer:to_win_prompt(hook, doc, comment, win_opts)
    assert(self:exists(), exception.bufnr_not_valid(self.index))
    assert(doc, exception.no_doc())
    assert(hook, exception.no_f())

    assert_type(doc, 'string')
    assert_t(win_opts)
    assert_s(comment)
    assert_s(doc)
    assert_type(hook, 'callable', 'string')

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

function buffer:split(reverse)
    assert(self:exists(), exception.bufnr_not_valid(self.index))

    reverse = reverse == nil and false

    if reverse then
        vim.cmd(sprintf(':split | b %d', self.index))
    else
        vim.cmd(sprintf(':split | wincmd j | b %d', self.index))
    end
end

function buffer:vsplit(reverse)
    assert(self:exists(), exception.bufnr_not_valid(self.index))

    reverse = reverse == nil and false

    if reverse then
        vim.cmd(sprintf(':vsplit | b %d', self.index))
    else
        vim.cmd(sprintf(':vsplit | wincmd l | b %d', self.index))
    end
end

function buffer:tabnew()
    assert(self:exists(), exception.bufnr_not_valid(self.index))

    vim.cmd(sprintf(':tabnew | b %d', self.index))
end

function buffer:save(where)
    assert_s(where)

    if not where then where = self.name end

    self:exec(function() 
        vcmd('w ' .. where)
    end)
end

return buffer
