local iter = require('rocks.fun')
local fs = require('path.fs')
dofile('table.lua')

local function vec(index, n, gen, param, state)
    index = index or -1
    n = n or -1

    local acc = {}

    local _add = function(g, p, s)
        local out = {g(p, s)}

        if #out == 0 then 
            return
        end

        if #out > 1 and s then
            s = first(out)
            out = slice(out, 2)
        end

        if #out == 1 then
            out = first(out)
        end

        if not table_p(index) then
            if index == -1 then
                push(acc, out)
            else
                push(acc, out[index] or false)
            end
        else
            for _, i in ipairs(index) do
                push(acc, out[i])
            end
        end

        return true, s
    end

    local success
    local new_state
    local times = 0

    repeat
        success, new_state = _add(gen, param, state) 
        if not success then return acc end
        state = new_state ~= nil and new_state or state
        times = times + 1
    until n > 0 and times == n

    return acc
end
