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

function String.sed(s, pat, sub, ...)
    assert(s)
    assert(pat)
    assert(sub)
    local rest = {...}
    local n = #rest

    s = s:gsub(pat, sub)
    assert(n%2 == 0, 'Require even number of params after the first 3 params')

    if n > 0 then
        for i = 4, n, 2 do
            s = s:gsub(rest[i], rest[i+1])
        end
    end

    return s
end

function String.globalize(ks)
    utils.globalize(String, ks)
end

return String
