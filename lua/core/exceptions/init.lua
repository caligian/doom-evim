local Class = require('classy')
local Exception = Class('doom-exceptions')

function Exception:__init(obj)
    self.obj = obj
end

-- @param attribs table {func} should return a dict that contains attribs that will be passed along with the error
function Exception:add(func_name, func)
    local attribs = func(self.obj)

    self[func_name] = function ()
        error(attribs)
    end
end

function Exception:assert(test, exception)
    assert(self[exception])

    if not test then
        exception = self[exception]
        exception(self.obj)
    end
end

return Exception
