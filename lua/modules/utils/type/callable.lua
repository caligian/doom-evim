local class = require('modules.utils.class')
local fu = require('modules.utils.function')
local common = require('modules.utils.type.common')
local u = require('modules.utils.common')

common.jdump = nil
common.ydump = nil
common.jspit = nil
common.yspit = nil

local func = {}
local m = {}

m.__add = fu.partial

m.__concat = function(f, obj)
    assert(obj)

    if u.callable(obj) then
        return function(...)
            return f(obj(...))
        end
    end
    
    return fu.partial(f, obj)
end

m.__pow = fu.lpartial

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
    self:delegate(common, 'value')
    self:delegate(m, 'value')
    self.value = f

    return self
end

return func
