local Class = require('classy')
local Write = Class('doom-buffer-string-writer')

function Write:__init(buf)
    self.buffer = buf
end

function Write:lines(lines, opts)
    opts = opts or {}
    opts.row = opts.row or {}
    opts.row.from = opts.row.from or self.buffer:position().row
    opts.row.till = opts.row.till or opts.row.from + #lines

    vim.api.nvim_buf_set_lines(self.buffer.bufnr, opts.row.from, opts.row.till, false, lines)
end

function Write:text(lines, opts)
    assert(lines)

    opts = opts or {}
    opts.row = opts.row or {}
    opts.col = opts.col or {}

    local cood = self.buffer:position()
    opts.row.from = opts.row.from or cood.row
    opts.row.till = opts.row.till or self.buffer:count() - 1
    opts.col.from = opts.col.from or 0
    opts.col.till = opts.col.till or #(self.bufstr:line(opts.row.till))

    vim.api.nvim_buf_set_text(self.buffer.bufnr, opts.row.from, opts.col.from, opts.row.till, opts.col.till, lines)
end

function Write:line(line_number, line, opts)
    opts = opts or {}
    vim.fn.setbufline(self.buffer.bufnr, line_number + 1, line)
end

return Write
