local class = dofile('../class.lua')
local fu = require('modules.utils.function')
local param = dofile('../param.lua')
local common = dofile('common.lua')
common.jdump = nil
common.ydump = nil
common.jspit = nil
common.yspit = nil

local func = {}
function func.new(f, env)
    assert(f, 'No function provided')

    if f then
        local t = type(f)

        assert(t == 'function' or t == 'table', 'element passed should be either a table with __call or a function')
        if type(f) == 'table' then
            local mt = getmetatable(f)
            assert(m.__call, 'No __call metamethod specified for table')
        end
    end

    local self = class.new('callable', env or {})
    self.value = f
    class.delegate(self, fu, 'value')
    class.delegate(self, common, 'value')

    return self
end

return func
