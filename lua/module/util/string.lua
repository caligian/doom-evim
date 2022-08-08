pcre = require('rex_pcre2')

function trim(s)
    return s:match('^%s*(.-)%s*$') or s
end

function ltrim(s)
    return s:match('^%s*(.-)') or s
end

function rtrim(s)
    return s:match('(.-)%s*$') or s
end

split = pcre.split
strip = trim
lstrip = ltrim
rstrip = rtrim

function sed(s, pat_sub, ...)
    assert(s)
    assert(table_p(pat_sub))
    assert(#pat_sub >= 2)

    local pat, sub, times = unpack(pat_sub)
    local rest = {...}
    local n = #rest
    s = pcre.gsub(s, pat, sub, times)

    for i=1, n do
        assert(table_p(rest[i]))
        assert(#rest[i] >= 2)
        s = pcre.gsub(s, unpack(rest[i]))
    end

    return s
end

function lsed(s, pat_sub, ...)
    assert(s)
    assert(table_p(pat_sub))
    assert(#pat_sub == 2)

    local pat, sub, times = unpack(pat_sub)
    local rest = {...}
    local n = #rest
    s = s:gsub(pat, sub, times)

    for i=1, n do
        assert(table_p(rest[i]))
        assert(#rest[i] >= 2)
        local _p, _s, _n = unpack(rest[i])
        s = s:gsub(_p, _s, _n)
    end

    return s
end

function match(s, ...)
    local r = {...}
    local n = #r
    assert(n > 0, 'No patterns provided')

    local function get_match(a, i)
        if i > n then
            return a or false
        end

        local m = pcre.match(a, r[i])
        if not m then
            return false
        else
            return get_match(m, i+1)
        end
    end

    return get_match(s, 1)
end

function lmatch(s, ...)
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

strslice = string.sub
substr = string.sub

function strsplice(s, from, len, ...)
    assert(str_p(s))
    assert(from > 0 and from < #s)

    local args = {...}
    len = len or 0
    s = vim.split(s, "")

    assert(len > 0, 'Len cannot be negative')

    if len == 0 then
        for _, i in ipairs(args) do
            table.insert(s, from, i)
        end
    elseif len > 0 then
        for i=1,len do
            table.remove(s, from)
        end

        for i=#args, 1, -1 do
            table.insert(s, from, args[i])
        end
    end

    return table.concat(s, "")
end

function strfind(s, pat, store)
    local matches = {}
    local n = #s
    local a, b = pcre.find(s, pat)
    if not a then return false end
    matches[#matches+1] = {a, b}

    if store then 
        push(matches[#matches], substr(s, a, b))
    end

    while a ~= nil do
        a, b = pcre.find(s, pat, b+1)
        if a then
            matches[#matches+1] = {a, b}
            if store then 
                push(matches[#matches], substr(s, a, b))
            end
        end
    end

    return matches
end

function lstrfind(s, pat, store)
    local matches = {}
    local n = #s
    local a, b = string.find(s, pat)
    if not a then return false end
    matches[#matches+1] = {a, b,}
    if store then
        push(matches[#matches], substr(s, a, b))
    end

    while a ~= nil do
        a, b = string.find(s, pat, b+1)
        if a then
            matches[#matches+1] = {a, b}
            if store then
                push(matches[#matches], substr(s, a, b))
            end
        end
    end

    return matches
end
