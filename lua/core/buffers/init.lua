local bufutils = dofile('utils.lua')
local buffer = class('doom-buffer')
bufutils.support_doom_buffer(buffer)
buffer.status = Doom.buffer.status

function buffer:__init(expr)
    if not expr then
        expr = sprintf('doom-buffer-%d', #keys(self.status))
    else
        expr = trim(expr)
        if match(expr, "%%:?[a-z]?") then expr = vim.fn.expand(expr) end
    end

    self.name = expr
    self.index = vim.fn.bufadd(self.name)
    vim.fn.bufload(self.index)

    if self.status[self.index] then
        return self.status[self.index]
    else
        self.status[self.index] = self
        self.status[self.name] = self
    end

    return self
end

b = buffer()
b:add_hook()
