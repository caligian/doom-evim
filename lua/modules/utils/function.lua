local fun = {}
local utils = require('modules.utils.common')
local tutils = require('modules.utils.table')

function fun.partial(f, ...)
    local outer = {...}

    return function(...)
        return f(unpack(tutils.extend(outer, {...})))
    end
end

function fun.lpartial(f, ...)
    local outer = {...}

    return function(...)
        return f(unpack(tutils.extend({...}, outer)))
    end
end

function fun.identity(i)
    return i
end

return fun
