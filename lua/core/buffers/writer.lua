local Class = require('classy')
local Write = Class('doom-buffer-string-writer')

function Write:__init(buf)
    self.buffer = buf
end

function Write:lines(lines, opts)
    self.buffer.exceptions:assert(self.buffer:exists(), 'invalid')
    opts = opts or {}
    opts.row = opts.row or {}

    assert(opts.row.from)
    opts.row.till = opts.row.till or opts.row.from + #lines

    vim.api.nvim_buf_set_lines(self.buffer.bufnr, opts.row.from, opts.row.till, false, lines)

    return true
end

function Write:text(lines, opts)
    assert(lines)
    self.buffer.exceptions:assert(self.buffer:exists(), 'invalid')

    opts = opts or {}
    opts.row = opts.row or {}
    opts.col = opts.col or {}

    assert(self.row.from)

    opts.row.till = opts.row.till or opts.row.from + #lines
    opts.col.from = opts.col.from or 0
    opts.col.till = opts.col.till or #(self.buffer.string:line(opts.row.till))

    vim.api.nvim_buf_set_text(self.buffer.bufnr, opts.row.from, opts.col.from, opts.row.till, opts.col.till, lines)

    return true
end

function Write:line(line_number, line)
    line_number = line_number or self.buffer:position().row

    assert(line)
    self.buffer.exceptions:assert(self.buffer:exists(), 'invalid')
    opts = opts or {}
    vim.fn.setbufline(self.buffer.bufnr, line_number + 1, line)
end

return Write
