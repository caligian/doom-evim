local String = {}
local utils = require('modules.utils')

function String.trim(s)
    s = s:match('^%s*(.-)%s*$')
    return s
end

function String.ltrim(s)
    return s:match('^%s*(.-)')
end

function String.rtrim(s)
    return s:match('(.-)%s*$')
end

String.strip = String.trim
String.lstrip = String.ltrim
String.rstrip = String.rtrim

function String.sed(s, pat_sub, ...)
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

function String.globalize(ks)
    utils.globalize(String, ks)
end

return String
