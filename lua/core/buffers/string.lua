local class = require('classy')
local path = require('path')
local fs = require('path.fs')
local str = class('doom-buffer-string')

function str:__init(obj)
    self.bufnr = obj.bufnr
    self.buffer = obj
end

function str:count()
    self.buffer.exceptions:assert(self.buffer:exists(), 'invalid')
    self.line_count = vim.api.nvim_buf_line_count(self.bufnr)
    return self.line_count
end

function str:lines(opts)
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

function str:current_line()
    self.buffer.exceptions:assert(self.buffer:exists(), 'invalid')

    local cood = self.buffer:exec(function(buffer)
        return buffer:position()
    end)
    
    local opts = opts or {}
    opts.row = opts.row or {}
    opts.row.from = cood.row
    opts.row.till = cood.row+1

    return self:lines(opts)[1]
end

function str:line(ln)
    self.buffer.exceptions:assert(self.buffer:exists(), 'invalid')

    assert(ln)
    local opts = opts or {}
    opts.row = opts.row or {}
    opts.row.from = ln
    opts.row.till = ln + 1

    return self:lines(opts)[1]
end

function str:text(opts)
    assert(opts)
    assert(opts.row)
    assert(opts.col)

    self.buffer.exceptions:assert(self.buffer:exists(), 'invalid')
    local buffer_string = vim.api.nvim_buf_get_text(self.bufnr, opts.row.from, opts.col.from, opts.row.till, opts.col.till, {})

    if opts.nl then
        return table.concat(buffer_string, "\n")
    else
        return buffer_string
    end
end

function str:visual_range(opts)
    self.buffer.exceptions:assert(self.buffer:exists(), 'invalid')

    opts = opts or {nl=true}

    local cood = self.buffer:exec(function(buffer)
        return buffer:position {visual=true}
    end)

    local str = self:text(cood, opts)
    return str
end

function str:dump(method_name, args, kwargs, schedule)
    self.buffer.exceptions:assert(self.buffer:exists(), 'invalid')

    schedule = utils.nil_p(schedule) and true

    if args and type(args) ~= 'table' then
        args = {args}
    end

    local fname = self.buffer.temp_path

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

function str:read(...)
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

return str
