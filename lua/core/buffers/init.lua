local class = require('classy')
local kbd = require('core.kbd')
local path = require('path')
local augroup = require('core.au')
local buffer = class('doom-buffer')
local exception = require('core.buffers.exception')

buffer.status = Doom.buffer.status

-- Class methods
function buffer.find_by_bufnr(bufnr)
    claim.number(bufnr)

    if vim.fn.bufexists(bufnr) == 0 then return false end
    if Doom.buffer.status[bufnr] then return Doom.buffer.status[bufnr] end
    return false
end

function buffer.find_by_winnr(winnr)
    claim.number(bufnr)

    return buffer.find_by_bufnr(vim.fn.winbufnr(winnr))
end

function buffer.find_by_winid(id)
    claim.number(id)

    return buffer.find_by_bufnr(vim.fn.winbufnr(vim.fn.win_id2win(id)))
end

function buffer.find_by_bufname(expr)
    claim(expr, 'string', 'number')

    expr = trim(expr)

    if match(expr, '^%%:?[a-z]?') then
        expr = vim.fn.expand(expr)
    end

    local bufnr = vim.fn.bufnr(expr)
    if bufnr == -1 then return false end

    return buffer.find_by_bufnr(bufnr)
end

function buffer.hide_by_winid(id)
    claim.number(id)

    vim.api.nvim_win_close(id, true)
end

function buffer.hide_by_winnr(winnr)
    claim.number(winnr)

    buffer.hide_by_winid(vim.fn.win_getid(winnr))
end

function buffer.focus_by_winid(id)
    claim.number(id)

    return 0 ~= vim.fn.win_gotoid(id)
end

function buffer.focus_by_winnr(winnr)
    claim.number(winnr)

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
    return vim.fn.bufload(self.index) ~= 0
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
        claim.number(buf2.index)
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
        claim.number(buf2.index)
        return buf1.index == buf2
    end
end

buffer.not_equals = buffer.nequals
buffer.__eq = buffer.equals
buffer.__neq = buffer.nequals

function buffer:wincall(f, ...)
    assert(self:exists(), exception.bufname_not_valid(self.index))

    claim.string(f)
    
    local api = vim.api[f]
    local vimfn = vim.fn[f]

    if not api and not vimfn then
        error('Invalid function provided to call: ' .. fn)
    end

    local caller = api and api or vimfn and vimfn
    local id = vim.fn.bufwinid(self.index)

    if id ~= -1 then
        return caller(vim.fn.bufwinid(self.index), ...)
    end
end

function buffer:call(f, ...)
    assert(self:exists())

    claim.string(f)
    
    local api = vim.api[f]
    local vimfn = vim.fn[f]

    if not api and not vimfn then
        error('Invalid function provided to call: ' .. fn)
    end

    local caller = api and api or vimfn and vimfn
    return caller(self.index, ...)
end

function buffer:__init(name, scratch)
    claim.string(name)
    claim.boolean(scratch)

    self.name = name
    self.scratch = scratch and true or false
end

function buffer.new(name, scratch)
    local bufnr
    local is_temp

    if scratch then
        name = name or with_data_path('temp', 'doom-scratch-buffer' .. '.' .. vim.bo.filetype)
        if assoc(Doom.buffer.status, name) then
            name = name .. '_1'
        end

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


    if buffer.status[bufnr] then
        return buffer.status[bufnr]
    end

    local self = buffer(name, scratch)

    self.index = bufnr
    self.name = name
    self.scratch = scratch and true or false
    self.status[bufnr] = self
    self.status[self.name] = self
    if is_temp then
        self:setopts({buftype='nofile', swapfile=false, buflisted=false})
    elseif scratch then
        self:setopts({buflisted=false, swapfile=false, filetype=vim.bo.filetype})
    end
    
    return self
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
    opts.relative = opts.relative or 'cursor'
    local current_height = vim.o.lines
    local current_width = vim.o.columns
    opts.width = opts.width or current_width
    opts.height = opts.height or current_height
    opts.row = opts.row or 0
    opts.col = opts.col or 0
    opts.border = 'double'
    opts.style = opts.style or 'minimal'
    opts.height = math.floor(opts.height/2)
    opts.width = math.ceil(opts.width/2)

    return vim.api.nvim_open_win(self.index, true, opts)
end

function buffer:exec(f, ...)
    assert(self:exists(), exception.bufnr_not_valid(self.index))

    local args = {...}

    return vim.api.nvim_buf_call(self.index, function()
        return f(unpack(args))
    end)
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

    pos = pos or {}
    pos.start_row = pos.start_row or 0
    local bufnr = self.index

    if str_p(s) then s = split(s, "[\n\r]") end

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

    claim(s, 'table', 'string')
    claim.string(prepend)
    claim.string(_type)
    claim.string(_follow)

    local bufnr = self.index
    prepend = prepend and 'P' or 'p'
    prepend = prepend == 'p' and true or false
    _type = not _type and 'c' or _type
    _follow = _follow == nil and true or _follow

    if str_p(s) then s = split(s, "\n\r") end

    return self:exec(vim.api.nvim_put, s, _type, prepend, _follow)
end

function buffer:getcurpos()
    assert(self:exists(), exception.bufnr_not_valid(self.index))

    return self:exec(function ()
        local row, col, curswant
        bufnr, row, col, curswant = unpack(vim.fn.getcurpos(vim.fn.winnr()))
        return {
            winid = id,
            row = row - 1,
            col = col - 1,
            curswant = curswant,
        }
    end)
end

function buffer:getpos(expr)
    assert(self:exists(), exception.bufnr_not_valid(self.index))

    return self:exec(function ()
        expr = expr or '.'
        local bufnr, row, col, off = unpack(vim.fn.getpos(expr))
        buffer.hide_by_winid(id)

        return {
            winid = id,
            row = row-1,
            curswant = off,
            col = col-1,
        }
    end)
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
        au = augroup.new(name, 'Doom buffer augroup for ' .. bufnr)
    end

    au:add(event, sprintf('<buffer=%d>', bufnr), f, opts)
end

function buffer:delete()
    pcall(function ()
        vim.cmd('bwipeout ' .. self:exec(function ()
            return vim.fn.expand('%:p')
        end))
    end)

    self.status[self.index] = nil
end

buffer.wipeout = buffer.delete

function buffer:set_keymap(mode, keys, f, attribs, doc, event)
    assert(mode)
    assert(keys)
    assert(f)
    assert(doc)

    assoc(self, {'keymaps', mode, keys}, {})
    event = event or 'BufEnter'
    attribs = attribs or 'buffer'
    local doc = 'Keybinding for buffer: ' .. self.index
    local pattern = sprintf('<buffer=%d>', self.index)
    local k = kbd.new(mode, keys, f, attribs, doc, event, pattern)
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

    claim(doc, 'string')
    claim.table(win_opts)
    claim.string(comment)
    claim.string(doc)
    claim(hook, 'callable', 'string')

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

function buffer:split(direction, opts)
    claim(direction, 'string', 'boolean')

    direction = direction or 's'
    direction = strip(direction)
    direction = match('^([svtf])', direction)
    opts = opts or {}

    claim.table(opts)

    local cmd = ''

    if direction == 's' then
        if opts.reverse then
            cmd = sprintf(':split | b %d', self.index)
        else
            cmd = sprintf(':split | wincmd j | b %d', self.index)
        end
    elseif direction == 'v' then
        if opts.reverse then
            cmd = sprintf(':vsplit | b %d', self.index)
        else
            cmd = sprintf(':vsplit | wincmd l | b %d', self.index)
        end
    elseif direction == 't' then
        vim.cmd(sprintf(':tabnew | b %d', self.index))
        return vim.fn.winnr()
    elseif direction == 'f' then
        opts.reverse = nil
        opts.force_resize = nil
        return self:to_win(opts)
    end

    local height, width = -1, -1
    if not opts.resize then
        width = self:call('winwidth')
        height = self:call('winheight')
        width = width == -1 and 30 or width
        height = height == -1 and 20 or height
    else
        claim.table(opts.resize)
        assert(opts.resize.height or opts.resize.width)
        claim.number(opts.resize.width)

        height = opts.resize.height
        width = opts.resize.width
    end

    self:load()
    local lines = self:read({})
    lines = filter(function (s) return #s > 0 end, lines)
    n = #lines

    if n == 0 and opts.force_resize == false then
        return
    else
        vim.cmd(cmd)
        if direction == 's' then
            height = n > 0 and n < height and n or height
            height = math.ceil(height)
            height = height + 3
            vim.cmd(':resize ' .. height)
        end
    end

    return vim.fn.winnr()
end

function buffer:tabnew(opts)
    return self:split('t', opts)
end

function buffer:vsplit(opts)
    return self:split('v', opts)
end

function buffer:save(where)
    claim.string(where)

    if not where then where = self.name end

    self:exec(function() 
        vcmd('w ' .. where)
    end)
end

return buffer
