local fun = {}
local param = require 'modules.utils.param'
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

function fun.ithread(f, ...)
    param.claim.callable(f)

    local args = {f, ...}
    local out = nil
    local n = #args
    local obj = args[n]
    local index = 1
    n = n - 1

    return function ()
        if index > n then
            return 
        end

        local callback = args[index]
        param.claim.callable(callback)

        if out == nil then
            out = callback(obj)
        else
            local prev = out
            out = callback(prev)
        end
        index = index + 1

        return out
    end, args, index
end

function fun.ilthread(...)
    local cbs = {...}
    local n = #cbs
    local obj = cbs[n]
    local out
    local index = n - 1

    return function ()
        if index == 0 then
            return 
        end

        local callback = cbs[index]
        param.claim.callable(callback)

        if out == nil then
            out = callback(obj)
        else
            local prev = out
            out = callback(prev)
        end
        
        index = index - 1
        return out
    end, cbs, index
end

function fun.thread(...)
    local args = {...}
    local n = #args
    local obj = args[n]
    local out
    n = n - 1

    for i=1, n do
        local callback = args[i]
        param.claim.callable(callback)

        if out == nil then
            out = callback(obj)
        else
            local prev = out
            out = callback(prev)
        end
    end

    return out
end

function fun.lthread(...)
    local cbs = {...}
    local n = #cbs
    local obj = cbs[n]
    local out
    n = n - 1

    for i=n, 1, -1 do
        local callback = cbs[i]
        param.claim.callable(callback)

        if out == nil then
            out = callback(obj)
        else
            local prev = out
            out = callback(prev)
        end
    end

    return out
end


return fun
