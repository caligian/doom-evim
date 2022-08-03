local ex = {}
local m = {}

function ex.new(obj)
    return module.new('exception', {vars={obj=obj, raise={}}}, m)
end

-- @tparam name string Name of the exception raised
-- @tparam callback callable Callback accepting an object and returning a boolean. If false/nil is returned then error is raised
-- @tparam message string Message to show in the error if the test fails
-- @treturn function
function m:add_condition(name, callback, message, getter)
    claim.string(name, message)
    claim.callable(callback)
    if getter then claim(getter, 'callable', 'string', 'number') end

    local obj = self.obj
    self.raise[name] = function (...)
        if callable(getter) then
            obj = getter(self.obj)
        else
            obj = self.obj[getter]
        end
        local out = callback(obj, ...)
        if out == false or out == nil then
            error(sprintf("%s", {obj=self.obj, desc=message, id=name}))
        else
            return true
        end
    end

    return self.raise[name]
end

m.add_cond = m.add_condition

function ex.throw(test, message)
    claim(test, 'boolean', 'callable')
    claim.string(message)

    if callable(test) then
        test = test()
    end

    if not test then
        error(message)
    end
end

function ex.raise(obj, message)
    error({obj=obj, message=message})
end

add_global(ex.throw, 'throw')
add_global(ex.raise, 'raise')

return ex
