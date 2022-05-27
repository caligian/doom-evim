local fun = {}
local utils = require('modules.utils')

function fun.globalize(ks)
    utils.globalize(ks or fun)
end

function fun.partial(f, ...)
    local outer = {...}

    return function(...)
        return f(unpack(extend(outer, {...})))
    end
end

function fun.lpartial(f, ...)
    local outer = {...}

    return function(...)
        return f(unpack(extend({...}, outer)))
    end
end

function fun.identity(i)
    return i
end

return fun
