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

-- @tparam text table {<display text>, <cb>}, ...
nv.gets = function(prompt, loop, ...)
    prompt = prompt or '% '
    loop = loop == nil and false
    local args = {...}
    local out = {}
    
    local function _get_input(t)
        local text, cb = unpack(to_list(t))
        local input = vim.fn.input(prompt or '% ', text)

        if input == '' then
            if loop then return _get_input(text, cb) end
            return false
        else
            if cb then
                oblige(callable(cb), 'Invalid callback provided.')
                local is_correct = cb(input)
                if is_correct then 
                    if bool_p(is_correct) then
                        return input
                    else
                        return is_correct 
                    end
                else
                    if loop then 
                        return _get_input(text, cb) 
                    else
                        return false
                    end
                end
            else
                return input
            end
        end
    end

    return map(_get_input, args)
end

return nv
