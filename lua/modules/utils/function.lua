local fun = {}
local utils = require('modules.utils')
local tutils = require('modules.utils.table')
local class = require('classy')

function fun.globalize(ks)
    utils.globalize(ks or fun)
end

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

utils.add_global(class, 'class')
utils.add_global(class.multimethod, 'multimethod')
utils.add_global(class.overload, 'overload')

return fun
