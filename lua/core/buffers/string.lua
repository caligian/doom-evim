local Class = require('classy')
local Path = require('path')
local Fs = require('path.fs')
local Str = Class('doom-buffer-string')

function Str:__init(obj)
    self.bufnr = obj.bufnr
    self.buffer = obj
end

function Str:count()
    self.line_count = vim.api.nvim_buf_line_count(self.bufnr)
    return self.line_count
end

function Str:lines(opts)
    assert(opts)
    assert(opts.row)
    assert(opts.row.from)

    opts.row.till = opts.row.till or self:count()
    local buffer_string = vim.api.nvim_buf_get_lines(self.bufnr, opts.row.from, opts.row.till, false)

    if opts.nl then
        return table.concat(buffer_string, "\n")
    else
        return buffer_string
    end
end

function Str:current_line()
    local cood = self.buffer:position()
    local opts = opts or {}
    opts.row = opts.row or {}
    opts.row.from = cood.row
    opts.row.till = cood.col

    return self:lines(opts)[1]
end

function Str:line(ln)
    assert(ln)
    local opts = opts or {}
    opts.row = opts.row or {}
    opts.row.from = ln
    opts.row.till = ln + 1

    return self:lines(opts)[1]
end

function Str:text(opts)
    assert(opts)
    assert(opts.row)
    assert(opts.col)

    local buffer_string = vim.api.nvim_buf_get_text(self.bufnr, opts.row.from, opts.col.from, opts.row.till, opts.col.till, {})

    if opts.nl then
        return table.concat(buffer_string, "\n")
    else
        return buffer_string
    end
end

function Str:visual_range(opts)
    opts = opts or {nl=true}
    local cood = self.buffer:position {visual=true}
    local str = self:text(cood, opts)
    return str
end

function Str:dump(method_name, args, kwargs, schedule)
    if args and type(args) ~= 'table' then
        args = {args}
    end

    local fname = Doom.temp_path or Path(vim.fn.stdpath('data'), 'doom-temp')

    if not Path.exists(fname) then
        Fs.mkdir(fname)
    end

    fname = Path(fname, self.buffer.bufname)

    local exec_this = function ()
        local fh = io.open(fname, 'w')

        if kwargs then
            kwargs.nl = true
        end

        local method = self[method_name]
        assert(method)

        local buffer_string = ''

        if args and kwargs then
            buffer_string = self[method_name](self, unpack(args), kwargs)
        elseif args then
            buffer_string = self[method_name](self, unpack(args))
        elseif kwargs then
            buffer_string = self[method_name](self, kwargs)
        else
            buffer_string = self[method_name](self)
        end

        fh:write(buffer_string)
        fh:close()
    end

    if not schedule then
        exec_this()
        return fname
    else
        vim.schedule(exec_this)
    end
end

function Str:read(...)
    local function _has_string(fh)
        for i in fh:lines() do
            if not i:match('^ *$') then
                return true
            end
        end

        return false
    end

    self:dump(...)

    local fname = Doom.temp_path or Path(vim.fn.stdpath('data'), 'doom-temp', self.buffer.bufname)

    local fh = io.open(fname, 'r')
    local bufstr = fh:read('*a')

    local wait = 100
    local try_n = 100
    while not _has_string(fh) and try_n > 0 do
        fh:close()
        fh = io.open(fname, 'r')

        -- Incremental delay to prevent returning an empty string
        vim.wait(wait)
        wait = wait + wait * 0.9
        try_n = try_n - 1
    end

    return bufstr
end

return Str
