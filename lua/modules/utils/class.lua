local class = {}

function class.new(name, opts)
    local self = {}
    self.index = self
    self.__name = name 

    for k, v in pairs(opts or {}) do
        self[k] = v
    end

    return self
end

function class.name(c)
    return c.__name
end

function class.of(c)
    return c.is_a
end

-- Getter is used to extract the required value from the class
function class.delegate(c, methods, getter)
    assert(c)
    assert(methods)

    getter = getter or function(cls)
        return cls
    end

    local _getter

    local t = type(getter)
    if t == 'string' or t == 'number' then
        local index = getter

        getter = function (c)
            return c[index]
        end
    elseif not getter then
        getter = function (c)
            return c
        end
    end

    for k, v in pairs(methods) do
        c[k] = function(c, ...)
            local out = getter(c)
            return v(getter(c), ...)
        end
    end

    return c
end

function class.nequals(c1, c2)
    if c1.__name == c2.__name then
        return false
    end
    return true
end

function class.equals(c1, c2)
    if c1.__name == c2.__name then
        return true
    end
    return false
end

return class
