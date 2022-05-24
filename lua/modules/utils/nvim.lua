local nv = {}
local utils = require('modules.utils')

-- @tparam timeout number Pass -1 to immediately return the result
function nv.wait(timeout, tries, inc, sched, f, ...)
    local args = {...}
    timeout = timeout == nil and 10000 or timeout
    tries = tries or 10
    inc = inc or 10

    local out

    if sched then 
        oblige(timeout ~= false, 'Cannot defer execution without waiting. Please supply a timeout value')

        vim.schedule(function()
            out = f(unpack(args))
        end) 
    else
        out = f(...)
    end

    local ctr = 0

    if timeout == false then
        return out
    end

    while out == nil or out == false and ctr ~= tries do
        if tries == ctr then
            return out
        end

        vim.wait(timeout)
        timeout = timeout + inc
        ctr = ctr + 1
    end

    return out
end

nv.globalize = function()
    utils.globalize(nv)
end

return nv
