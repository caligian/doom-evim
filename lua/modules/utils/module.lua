local module = {}
local pu = require 'modules.utils.param'
local u = require 'modules.utils.common'
local tu = require 'modules.utils.table'

local function readonly_table(t)
    return setmetatable(t, {
        __newindex = function (...)
            error('Attempting to edit a read-only table')
        end
    })
end

-- If getter is true then simply return partial(callback(self, ...))
-- If getter is false then return callback(...)
local function unwrap_for_method(self, getter, callback)
    assert(getter ~= nil)
    assert(callback)
    pu.assert_type(getter, 'string', 'callable', 'number', 'boolean')

    local f = callback
    if getter == true then
        return function (...)
            return f(self, ...)
        end
    elseif getter == false then
        return callback
    elseif not u.callable(getter) then
        getter = self.__vars[getter]
        return function (...)
            return f(getter, ...)
        end
    else
        return function (...)
            return f(getter(self), ...)
        end
    end
end

-- If {callback} is a table, the first will be used when the 
-- self is on LHS and the second will be assumed for RHS. If nothing is provided, consider callback as the default LHS and RHS handler
function module.on_operator(self, op, callback, getter)
    assert(op)
    assert(callback)
    pu.assert_str(op)
    pu.assert_type(callback, 'table', 'callable')

    local operators = {
        ['+'] = '__add',
        ['-'] = '__sub',
        ['*'] = '__mul',
        ['/'] = '__div',
        ['^'] = '__pow',
        ['%'] = '__mod',
        ['..'] = '__concat',
    }

    if not operators[op] then
        error('Invalid operator provided: ' .. op)
    end

    local lhs, rhs = false, false
    if u.table_p(callback) and not u.callable(callback) then
        assert(#callback == 2, 'Need a callback for when self is on LHS and when self on RHS')
        pu.assert_callable(callback[1])
        pu.assert_callable(callback[2])
        lhs = callback[1]
        rhs = callback[2]
    else
        lhs = callback
    end

    callback = function (cls, cls1)
        if cls == self then
            return lhs(cls, cls1)
        elseif cls1 == self and rhs then
            return rhs(cls1, cls)
        end
    end

    getter = getter or false
    callback = unwrap_for_method(self, getter, callback)
    local mt = getmetatable(self)
    mt[operators[op]] = callback

    return callback
end

function module.name(self)
    local mt = getmetatable(self)
    if mt then
        return self.__name
    end
end

function module.is_same_module(cls, cls1)
    local name = module.name(cls)
    local name1 = module.name(cls1)

    if name and name1 then
        return name == name1
    end
end

module.same_module_p = module.is_same_module

function module.freeze(self)
    rawset(self, '__frozen', true)
    self.__vars = readonly_table(self.__vars)
    self.__methods = readonly_table(self.__methods)
end

function module.is_frozen(self)
    local fr = self.__frozen or false
    return fr
end

module.frozen_p = module.is_frozen

function module.unfreeze(self)
    rawset(self, '__freeze', false)
    local var_mt = getmetatable(self.__vars)
    local m_mt = getmetatable(self.__methods)
    var_mt.__newindex = nil
    m_mt.__newindex = nil
end

function module.define_method(self, name, callback, getter)
    assert(name)
    assert(callback)
    pu.assert_str(name)
    pu.assert_callable(callback)

    getter = getter or false
    callback = unwrap_for_method(self, getter, callback)
    self.__methods[name] = callback

    return callback
end

function module.include(self, methods, getter)
    pu.assert_t(methods)

    for key, value in pairs(methods) do
        self:define_method(key, value, getter)
    end
end

function module.instance_variable_set(self, key, value)
    self.__vars[key] = value
end

function module.const_set(self, key, value)
    key = key:upper()
    self.__constants[key] = value
end

function module.const_get(self, key)
    return self.__constants[key:upper()]
end

function module.instance_variable_get(self, key)
    return self.__vars[key]
end

function module.instance_variables(self)
    return tu.keys(self.__vars)
end

function module.instance_methods(self)
    return tu.keys(self.__methods)
end

function module.instance_method_get(self, name)
    return self.__methods[name]
end

function module.bound_instance_method_get(self, name)
    local f = self.__methods[name]
    if f then
        return function (...)
            return f(self, ...)
        end
    end
end

local function new(name, vars, methods)
    local self = { __vars = {}, __methods = module, __constants = {} }
    vars = vars or {}
    methods = methods or {}

    if vars.constants then
        pu.assert_t(vars.constants)
        for key, value in pairs(vars.constants) do
            module.const_set(self, key, value)
        end
    end

    self.__constants = readonly_table(self.__constants)

    if vars.vars then
        pu.assert_t(vars.vars)
        for key, value in pairs(vars.vars) do
            module.instance_variable_set(self, key, value)
        end
    end

    if methods then
        pu.assert_t(methods)
        for key, value in pairs(methods) do
            module.define_method(self, key, value)
        end
    end

    self['new'] = nil
    local index = function (cls, k)
        local is_v = module.instance_variable_get(cls, k)
        local is_c = module.const_get(cls, k)
        local is_m = module.instance_method_get(cls, k)

        if is_c then
            return is_c
        elseif is_v then
            return is_v
        elseif is_m then
            return is_m
        end
    end

    return setmetatable(self, {
        __name = name,
        __index = index,
        __newindex = function (...)
            error('Attempting to edit a read-only table')
        end,
    })
end

return setmetatable({}, {
    __call = new;
})
