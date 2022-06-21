local nv = {}
local tu = require('modules.utils.table')
local utils = require('modules.utils')

-- @tparam timeout number Pass -1 to immediately return the result
function nv.wait(timeout, tries, inc, sched, f, ...)
    local args = {...}
    timeout = timeout == nil and 10000 or timeout
    tries = tries or 10
    inc = inc or 10

    local out

    if sched then 
        assert(timeout ~= false, 'Cannot defer execution without waiting. Please supply a timeout value')

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

-- @tparam text table {question, default_text, callback }, ...
nv.gets = function(prompt, loop, ...)
    prompt = prompt or '%'
    prompt = prompt .. ' '
    local args = {...}
    local out = {}
    assert(#args > 0, 'No args provided')

    local function _get_input(t)
        assert(#t >= 1, 'No prompt question provided')

        local q, default_text, cb = unpack(utils.to_list(t))
        q = q .. ' ' .. prompt
        default_text = default_text or ''
        local input = vim.fn.input(q, default_text)

        if #input == 0 then
            if loop then 
                return _get_input(t) 
            else
                return false
            end
        else
            if cb then
                assert(utils.callable(cb), 'Invalid callback provided.')
                local is_correct = cb(input)
                if is_correct then 
                    if utils.bool_p(is_correct) then
                        return input
                    else
                        return is_correct 
                    end
                else
                    if loop then 
                        return _get_input(t) 
                    else
                        return false
                    end
                end
            else
                return input
            end
        end
    end

    return tu.map(_get_input, args)
end

return nv
