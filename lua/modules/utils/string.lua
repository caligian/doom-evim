local str = {}
local utils = require('modules.utils')

function str.trim(s)
    s = s:match('^%s*(.-)%s*$')
    return s
end

function str.ltrim(s)
    return s:match('^%s*(.-)')
end

function str.rtrim(s)
    return s:match('(.-)%s*$')
end

str.strip = str.trim
str.lstrip = str.ltrim
str.rstrip = str.rtrim

function str.sed(s, pat_sub, ...)
    assert(s)
    assert(utils.table_p(pat_sub))
    assert(#pat_sub == 2)

    local pat, sub, times = unpack(pat_sub)
    local rest = {...}
    local n = #rest
    s = s:gsub(pat, sub, times)

    for i=1, n do
        assert(utils.table_p(rest[i]))
        assert(#rest[i] >= 2)
        local _p, _s, _n = unpack(rest[i])
        s = string.gsub(s, _p, _s, _n)
    end

    return s
end

function str.globalize(ks)
    utils.globalize(str, ks)
end

function str.match(s, ...)
    local r = {...}
    local n = #r
    assert(n > 0, 'No patterns provided')

    local function get_match(a, i)
        if i > n then
            return a or false
        end

        local m = string.match(a, r[i])
        if not m then
            return false
        else
            return get_match(m, i+1)
        end
    end

    return get_match(s, 1)
end

function str.gmatch(s, pat, iter)
    if iter then
        return string.gmatch(s, pat)
    end

    local matches = {}
    local n = #s
    local a, b = string.find(s, pat)
    if not a or b == n then return false end
    matches[#matches+1] = {a, b}

    while a ~= nil do
        a, b = string.find(s, pat, b+1)
        if a then
            matches[#matches+1] = {a, b}
        end
    end

    return matches
end

return str
