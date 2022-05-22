local class = require('classy')
local autocmd = require('core.au')
local buffer = class('doom-buffer')

buffer.status = Doom.buffer.status

function buffer.cleanup()
    for key, value in pairs(self.status) do
        if not value:exists() then
            self.status[key] = nil
        end
    end

    return self
end

function buffer:__init(name)
    if name:match('%%:?[a-z]?') then
        name = vim.fn.expand(name)
    end

    self.name = name
    self.index = vim.fn.bufadd(self.name)
    vim.fn.bufload(self.index)
    self.status[self] = self
end

function buffer:exists()
    return 1 == vim.fn.bufexists(self.index)
end

function buffer:is_visible()
    return -1 ~= vim.fn.bufwinnr(self.index)
end

function buffer:is_loaded()
    self.loaded = vim.fn.bufloaded(self.index) == 1
    return self.loaded
end

function buffer:setopts(opts)
    for key, value in pairs(options) do
        vim.api.nvim_buf_set_option(self.index, key, value)
    end
end

function buffer:setvars(vars)
    for key, value in pairs(vars) do
        vim.api.nvim_buf_set_var(self.index, key, value)
    end
end

function buffer:get_win()
    return vim.fn.bufwinnr(self.index)
end

function buffer:unlist()
    self:setopts({buflisted=false})
end

function buffer:__eq(buf)
    if class.of(buf) == buffer then
        return self.index == buf.index
    end
end

function buffer:__ne(buf)
    if class.of(buf) == buffer then
        return self.index ~= buf.index
    end
end

function buffer:get_line_count()
    return vim.api.nvim_buf_line_count(self.index)
end

function buffer:hook(event, f, is_scheduled)
    oblige(self:exists(), 'Cannot set autocmds on buffer: %d', self.index)
    event = event or 'BufEnter'
    local pat = self.name .. '_' ..  self.index

    if not self.au then self.au = {} end
    

end
