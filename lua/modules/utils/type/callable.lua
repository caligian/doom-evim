local class = require('modules.utils.class')
local fu = require('modules.utils.function')
local param = require('modules.utils.param')
local common = require('modules.utils.type.common')
local u = require('modules.utils')

common.jdump = nil
common.ydump = nil
common.jspit = nil
common.yspit = nil

local func = {}
local m = {}

local function unwrap(...)
    local args = {...}
    for i, v in ipairs(args) do
        if type(v) == 'table' then
            if v.__name and v.value then
                args[i] = v.value
            end
        end
    end

    return unpack(args)
end

local function wrap(f)
    return function(...)
        local out = f(unwrap(...))
        if type(out) == 'function' then
            out = func.new(out)
        end
        return out
    end
end

for key, value in pairs(fu) do
    m[key] = wrap(value)
end

m.__add = wrap(function(a, b)
    local m, n = u.callable(a), u.callable(b)
    if m then
        return fu.partial(a, b)
    else
        return fu.lpartial(b, a)
    end
end)

m.__concat = m.__add

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

local f = func.new(inspect)
inspect(f:partial(1,2,3,4))

return func
