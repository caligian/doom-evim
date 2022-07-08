local class = {}
local pcre = require('rex_pcre2')
local m = {}

function m.name(c)
    return c.__name
end

function m.unwrap_objects(getter, ...)
    local args = {...}

    if getter and type(getter) == 'string' or type(getter) == 'number' then
        local s = getter

        getter = function(self)
            return self[s]
        end
    elseif getter and type(getter) == 'function' then
        local f = getter
        getter = function(self)
            return f(self)
        end
    else
        getter = function(self)
            return self
        end
    end

    for k, v in ipairs(args) do
        if type(v) == 'table' and v.__name then
            args[k] = getter(v)
        end
    end

    return unpack(args)
end

function m.delegate(c, ...)
    assert(c)

    local methods = {...}
    local n_methods = #methods
    local getter = false

    if type(methods[n_methods]) ~= 'table' then
        getter = methods[n_methods]
        methods[n_methods] = nil
        methods = {unpack(methods, 1, n_methods - 1)}
    end

    local t = {}
    for k, v in pairs(methods) do
        assert(type(v) == 'table', 'Rest args should be tables containing kv pairs of function names and callbacks')

        for key, value in pairs(v) do
            t[key] = function(...)
                local args = {...}
                local found = false
                local index = 0
                local obj = false

                while found == false and index ~= #args+1 do
                    local inst = args[index]
                    if type(inst) == 'table' and inst.__name == c.__name then
                        found = index
                        break
                    end
                    index = index + 1
                end

                if found then
                    obj = args[found]
                    local first = args[1]
                    local f_type = type(first)

                    if f_type == 'table' and first.__name and first.__name ~= 'table' then
                        args[found] = first
                        args[1] = obj
                    elseif f_type ~= obj.__name then
                        args[found] = first
                        args[1] = obj
                    end
                end

                return value(m.unwrap_objects(getter or false, unpack(args)))
            end
            c[key] = t[key]
        end
    end

    t.__index = c
    return setmetatable(c, t)
end

function m.nequals(c1, c2)
    if c1.__name == c2.__name then
        return false
    end
    return true
end

function m.equals(c1, c2)
    if c1.__name == c2.__name then
        return true
    end
    return false
end

function class.new(name, opts)
    local self = {}
    self.index = self
    self.__name = name

    for k, v in pairs(opts or {}) do
        self[k] = v
    end

    self.delegate = m.delegate
    self.equals = m.equals
    self.nequals = m.nequals
    self.get_name = m.name

    return self
end

return class
