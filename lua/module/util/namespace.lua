mod = {}

local function set_method(t, k, v)
    claim(k, 'number', 'string')
    claim.table(t)

    local mt = getmetatable(t)
    if mt then
        rawset(mt.__method, k, v)
    end
end

local function set_constant(t, k, v)
    claim(k, 'number', 'string')
    claim.table(t)

    local mt = getmetatable(t)
    if mt then
        rawset(mt.__constant, k, v)
    end
end

local function set_var(t, k, v)
    claim(k, 'number', 'string')
    claim.table(t)

    local mt = getmetatable(t)
    if mt then
        rawset(mt.__var, k, v)
    end
end

local function get_vars(t)
    return mt_get(t, '__var')
end

local function get_methods(t)
    return mt_get(t, '__method')
end

local function get_constants(t)
    return mt_get(t, '__constant')
end

local function get_constant(t, k)
    local exists = get_constants(t)
    if exists then
        return exists[k]
    end
end

local function get_var(t, k)
    local exists = get_vars(t)
    if exists then
        return exists[k]
    end
end

local function get_method(t, k)
    local exists = get_methods(t)
    if exists then
        return exists[k]
    end
end

local function unwrap(getter)
    assert(getter ~= nil)

    if type(getter) == 'boolean' then
        return function (self)
            return self
        end
    elseif not callable(getter) then
        return function (self)
            return get_var(self, getter)
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
    claim.callable(callback)

    return function (self, ...)
        if getter == false then
            return callback(self, ...)
        else
            return callback(unwrap(getter)(self), ...)
        end
    end
end

-- If {callback} is a table, the first will be used when the 
-- self is on LHS and the second will be assumed for RHS. If nothing is provided, consider callback as the default LHS and RHS handler
function mod.on_operator(self, op, callback, getter)
    claim.string(op)
    claim(callback, 'table', 'callable')
    getter = getter or false

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
        if table_p(callback) and not callable(callback) then
            assert(#callback == 2, 'Need a callback for when self is on LHS and when self on RHS')
            claim.callable(callback[1])
            claim.callable(callback[2])
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
                        l = unwrap(getter)(cls)
                        r = unwrap(getter)(cls1)
                        f = lhs
                    else
                        r = unwrap(getter)(cls)
                        l = unwrap(getter)(cls1)
                        f = rhs or lhs
                    end
                elseif cls == self then
                    l = unwrap(getter)(cls)
                    r = cls1
                    f = lhs
                else
                    l = cls1
                    r = cls
                    f = lhs or rhs
                end
            elseif cls == self or cls1 == self then
                if cls == self then
                    l = unwrap(getter)(cls)
                    r = cls1
                    f = unwrap_for_method(getter, lhs)
                else
                    l = unwrap(getter)(cls1)
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
mod.seto = mod.on_operator
mod.setop = mod.on_operator
mod.set_operator = mod.on_operator

function mod.name(self)
    return mt_get(self, '__name')
end

function mod.define_method(self, name, callback, getter)
    claim.string(name)
    claim.callable(callback)

    getter = getter or false
    callback = unwrap_for_method(getter, callback)
    set_method(self, name, callback)
end
mod.setf = mod.define_method
mod.set_method = mod.define_method
mod.set_instance_method = mod.define_method

function mod.include(self, methods, getter)
    claim.table(methods)

    for key, value in pairs(methods) do
        self:define_method(key, value, getter)
    end
end
mod.inherit = mod.include
mod.delegate = mod.include

function mod.set_instance_variable(self, key, value)
    set_var(self, key, value)
end
mod.set_variable = mod.set_instance_variable
mod.set_var = mod.set_instance_variable
mod.setv = mod.set_var

function mod.set_constant(self, key, value)
    set_constant(self, key:upper(), value)
end
mod.setc = mod.set_constant
mod.set_const = mod.set_constant

function mod.get_constant(self, key)
    return get_constant(self, key:upper())
end
mod.getc = mod.get_constant
mod.get_const = mod.get_constant

function mod.get_instance_variable(self, key)
    return get_var(self, key)
end
mod.getv = mod.get_instance_variable
mod.get_var = mod.getv
mod.get_variable = mod.getv

function mod.instance_variables(self)
    return keys(mt_get(self, '__var'))
end
mod.vars = mod.instance_variables
mod.variables = mod.vars
mod.get_vars = mod.vars

function mod.instance_methods(self)
    return keys(mt_get(self, '__method'))
end
mod.methods = mod.instance_methods
mod.get_methods = mod.methods

function mod.get_instance_method(self, name)
    return get_method(self, name)
end
mod.getf = mod.get_instance_method
mod.getm = mod.get_instance_method
mod.get_method = mod.getf

if not Module then
    _G.Module = {}
end

local function create_module(vars)
    local self = { __var = {}, __method = {}, __constant = {} }

    for key, value in pairs(vars) do
        if callable(value) then
            self.__method[key] = value
        elseif key:match('^[A-Z_]+$') then
            self.__constant[key] = value
        else
            self.__var[key] = value
        end
    end

    for key, value in pairs(mod) do
        if callable(value) then
            self.__method[key] = value
        end
    end

    self.__constant = table_ro(self.__constant)
    self.__method = table_ro(self.__method)
    self.__var = table_ro(self.__var)

    return self
end

function mod.instanceof(self, cls)
    return mt_get(self, '__type') == cls
end

function mod.name(self)
    return mt_get(self, '__name')
end

function mod.class(self)
    return mt_get(self, '__type')
end

mod.isa = mod.instanceof
mod.is_a = mod.instanceof

local function new_module(name)
    if name:match('[^0-9a-zA-Z_]') then
        error('Module name cannot contain any nonalphanumeric and nonunderscore characters')
    end

    if not Module[name] then
        Module[name] = {name=name}
    end

    Module[name] = function (vars)
        vars = vars or {}
        local self = {}
        local mt = create_module(vars)
        mt.__name = name
        mt.__type = Module[name]
        mt.__index = function (cls, k)
            local is_v = mt.__var[k]
            if is_v then
                return is_v
            end

            local is_m = mt.__method[k]
            if is_m then
                return is_m
            end

            local is_c = mt.__constant[k]
            if is_c then
                return is_c
            end
        end
        __newindex = function (...)
            error(sprintf('Attempting to write to Module %s without using accessor methods', name))
        end

        self = setmetatable(self, mt)
        if self.initialize then
            self:initialize(vars)
        end

        return self
    end

    _G[name] = Module[name]

    return _G[name]
end

function mod.new(name, vars)
    claim_s(name)
    claim(vars, '!table')
    return new_module(name)(vars)
end

ns = new_module
namespace = new_module
