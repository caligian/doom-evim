local fun = {}
local utils = require('modules.utils')
local tutils = require('modules.utils.table')

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

local classy = require('classy')
utils.add_global(classy, 'class')
utils.add_global(classy.multimethod, 'multimethod')
utils.add_global(classy.overload, 'overload')

return fun
