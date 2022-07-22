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

local function unwrap(getter)
    if getter == true then
        return function (self)
            return self
        end
    elseif getter == false then
        return false
    elseif not u.callable(getter) then
        return function (self)
            return self.__vars[getter]
        end
    else
        return function (self)
            return getter(self)
        end
    end
end

-- If getter is true then simply return partial(callback(self, ...))
-- If getter is false then return callback(...)
local function unwrap_for_method(getter, callback)
    assert(getter ~= nil)
    assert(callback)
    pu.assert_type(getter, 'string', 'callable', 'number', 'boolean')

    return function (self, ...)
        local out = unwrap(getter)(self)
        return callback(unwrap(getter)(self), ...)
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
        ['s'] = '__tostring',
    }

    if not operators[op] then
        error('Invalid operator provided: ' .. op)
    end
    op = operators[op]

    if op ~= '__tostring' then
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
            local l,r,f = false, false, false

            if type(cls) == 'table' and type(cls1) == 'table' then
                local m, n = getmetatable(cls), getmetatable(cls1)
                if m and n and m.__name == n.__name then
                    if cls == self then
                        l = unwrap(getter or false)(cls)
                        r = unwrap(getter or false)(cls1)
                        f = lhs
                    else
                        r = unwrap(getter or false)(cls)
                        l = unwrap(getter or false)(cls1)
                        f = rhs or lhs
                    end
                elseif cls == self then
                    l = cls
                    r = cls1
                    f = lhs
                else
                    l = cls1
                    r = cls
                    f = lhs or rhs
                end
            elseif cls == self or cls1 == self then
                if cls == self then
                    l = cls
                    r = cls1
                    f = unwrap_for_method(getter, lhs)
                else
                    l = cls1
                    r = cls
                    f = unwrap_for_method(getter, rhs)
                end
            end

            return f(l, r)
        end
    else
        callback = unwrap_for_method(getter, callback)
    end

    getter = getter or false
    local mt = getmetatable(self)
    mt[op] = callback

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
    callback = unwrap_for_method(getter, callback)
    self.__methods[name] = callback

    return callback
end

function module.include(self, methods, getter)
    pu.assert_t(methods)

    for key, value in pairs(methods) do
        self:define_method(key, value, getter)
    end
end

function module.set_instance_variable(self, key, value)
    self.__vars[key] = value
end

function module.set_constant(self, key, value)
    key = key:upper()
    self.__constants[key] = value
end

function module.get_constant(self, key)
    return self.__constants[key:upper()]
end

function module.get_instance_variable(self, key)
    return self.__vars[key]
end

function module.instance_variables(self)
    return tu.keys(self.__vars)
end

function module.instance_methods(self)
    return tu.keys(self.__methods)
end

function module.get_instance_method(self, name)
    return self.__methods[name]
end

function module.get_bound_instance_method(self, name)
    local f = self.__methods[name]
    if f then
        return function (...)
            return f(self, ...)
        end
    end
end

function module.new(name, vars, methods)
    local self = { __vars = {}, __methods = {}, __constants = {} }
    vars = vars or {}
    methods = methods or {}

    for key, value in pairs(module) do
        if key ~= 'new' then
            self.__methods[key] = value
        end
    end

    if vars.constants then
        pu.assert_t(vars.constants)
        for key, value in pairs(vars.constants) do
            module.set_constant(self, key, value)
        end
    end

    self.__constants = readonly_table(self.__constants)

    if vars.vars then
        pu.assert_t(vars.vars)
        for key, value in pairs(vars.vars) do
            module.set_instance_variable(self, key, value)
        end
    end

    if methods then
        pu.assert_t(methods)
        for key, value in pairs(methods) do
            module.define_method(self, key, value)
        end
    end

    local index = function (cls, k)
        local is_v = module.get_instance_variable(cls, k)
        if is_v then
            return is_v
        end

        local is_c = module.get_constant(cls, k)
        if is_c then
            return is_c
        end

        local is_m = module.get_instance_method(cls, k)
        if is_m then
            return is_m
        end
    end

    return setmetatable(self, {
        __name = name,
        __index = index,
        __newindex = function (cls, k, v)
            cls:set_instance_variable(k, v)
        end,
    })
end

return module
