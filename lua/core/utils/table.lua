local iter = require('fun')
local utils = require('modules.utils')
local tu = {}

local _geti = utils.get_array_or_dict_item
local _getis = utils.get_array_or_dict_items

tu.partition = function (arr, n)
    local items = _geti(arr)

    n = n or 2
    local len = #items

    if n == 0 then return false end
    if n == 1 or n < 1 or n >= len then return items end

    local q = math.floor(len / n)
    local r = len - (q * n)
    local t = {}

    local last_index  
    for i=1, len, n do
        t[#t+1] = {}
        for j=i, i+n-1 do
            table.insert(t[#t], items[j])
            last_index = j
        end
    end

    if len - last_index > 0 then
        for i=last_index+1, len do
            if items[i] then
                table.insert(t[#t+1], items[i])
            end
        end
    end

    return t
end

tu.push = function (arr, ...)
    items = _geti(arr)
    local args = _getis(...)

    for _, i in ipairs(args) do
        items[#items+1] = i
    end

    return arr
end

tu.pop = function (arr, n)
    items = _geti(arr)
    local tail = {}

    for i=#items,#items-n+1, -1 do
        tail[#tail+1] = items[i]
        items[i] = nil
    end

    return tail, arr
end

tu.extend = function(dst, ...)
    items = _geti(dst)
    local args = _getis(...)

    for _, arr in ipairs(args) do
        if not utils.table_p(arr) then
            items[#items+1] = arr
        else
            for i=1, #arr do
                items[#items+1] = arr[i]
            end
        end
    end

    return dst
end

-- Everything is alright till here. 
-- Continue checking from down here.
tu.unshift = function (arr, ...)
    local items = _geti(arr)
    local args = _getis(...)

    for i=1,#args do
        table.insert(items, 1, args[i])
    end

    return arr
end

tu.lextend = function (arr, ...)
    local items = _geti(arr)
    local args = _getis({...})

    for _, a in ipairs(args) do
        if utils.table_p(a) then
            for _, v in ipairs(a) do
                table.insert(items, 1, v)
            end
        else
            table.insert(items, 1, a)
        end
    end

    return arr
end

tu.shift = function(arr, n)
    local items = _geti(arr)
    local head = {}

    for i=1, n do
        if items[i] then
            head[#head+1] = items[i]
            table.remove(items, 1)
        end
    end

    return head, arr
end

tu.splice = function(arr, from, len, ...)
    assert(from > 0 and from < #arr)
    assert(len and len > 0)
    local items = _geti(arr)
    local args = _getis(...)

    len = len or 0

    if len == 0 then
        for i in ipairs(args) do
            table.insert(items, from, i)
        end
    elseif len > 0 then
        for i=1,len do
            table.remove(items, from)
        end

        for i=#args, 1, -1 do
            table.insert(items, from, args[i])
        end
    end

    return arr
end

tu.keys = function (dict)
    dict = _geti(dict)
    local ks = {}

    for key, _ in pairs(dict) do
        ks[#ks+1] = key
    end

    return ks
end

tu.vals = function (dict)
    dict = _geti(dict)
    local vs = {}

    for _, value in pairs(dict) do
        vs[#vs+1] = value
    end

    return vs
end

tu.slice = function (arr, start, finish)
    assert(start > 0)
    arr = _geti(arr)
    finish = finish or #arr

    local t = {}
    for i=start,finish do
        t[#t+1] = arr[i]
    end

    return t
end

tu.butlast = function (arr)
    arr = _geti(arr)
    return tu.slice(arr, 1, #arr-1)
end

tu.rest = function (arr)
    arr = _geti(arr)
    return tu.slice(arr, 2, #arr)
end

tu.first = function (arr)
    arr = _geti(arr)
    return arr[1]
end

tu.last = function (arr)
    arr = _geti(arr)
    return arr[#arr]
end

tu.identity = function (i)
    return i
end

tu.max = function (t)
    t = _geti(t)
    return math.max(unpack(t))
end

tu.min = function (t)
    t = _geti(t)
    return math.min(unpack(t))
end

-- This will call all the iterators! 
tu.nth = function (k, ...)
    local args = _getis(...)
    local params = {}

    for _, i in ipairs(args) do
        if i[k] then
            params[#params+1] = i[k]
        end
    end

    return params
end

tu.merge = function(dicta, dictb, depth, f)
    local _dicta = _geti(dicta)
    local _dictb = _geti(dictb)

    depth = depth or -1
    local cached = {}

    local function _replace_level(a, b, ks, d)
        if #ks == 0 or d > 0 and d == depth then return end

        local k = tu.first(ks)
        local rest = tu.rest(ks)
        local item = b[k]
        local later = {}

        if cached[item] then 
            a[k] = cached[item]
            _replace_level(a, b, rest, d)
        else
            cached[item] = item

            if utils.table_p(a[k]) and utils.table_p(b[k]) then
                later[#later+1] = k
            else
                if f then item = f(a[k], item) end
                a[k] = item
                _replace_level(a, b, rest, d)
            end

            for _, k in ipairs(later) do
                _replace_level(a[k], b[k], keys(b[k]), d+1)
            end
        end
    end

    _replace_level(_dicta, _dictb, keys(_dictb), 0)
    return dicta
end

-- This tests for absolute equality. Any failed attempt will lead to the whole table
-- being treated as false
tu.equals = function(dicta, dictb, depth, f)
    local _dicta = _geti(dicta)
    local _dictb = _geti(dictb)
    local t = false
    depth = depth or -1
    local cached = {}

    local function _cmp(a, b, ks, d)
        if d > 0 and d == depth or #ks == 0 then return false end
        local later = {}

        for _, i in ipairs(ks) do
            local item_a = a[i]
            local item_b = b[i]

            if cached[item_a] ~= nil and cached[item_a] == false then return false end
            if not item_b then return false end

            if f then
                local out = f(item_a, item_b)
                if not out then return false end
            else
                if type(item_a) ~= type(item_b) then return false end

                if not utils.table_p(item_a) and not utils.table_p(item_b) then 
                    if item_a ~= item_b then
                        return false 
                    end
                else
                    later[#later+1] = i
                end
            end
        end

        for _, i in ipairs(later) do
            local out = _cmp(a[i], b[i], tu.keys(a[i]), d+1)
            cached[a[i]] = out
            if not out then return false end
        end

        return true
    end

    return _cmp(_dicta, _dictb, keys(_dicta), 0)
end

-- Generator
tu.zip = function(...)
    local arrs = _getis(...)
    local max_len = {}

    for _, a in ipairs(arrs) do
        table.insert(max_len, #a)
    end
    max_len = math.min(unpack(max_len))

    local state = 1
    local n = #arrs
    return function()
        if state > n then
            return 
        end

        state = state + 1
        return tu.nth(state - 1, unpack(arrs)), arrs, state
    end
end

tu.items = function(dict)
    dict = _geti(dict)
    local vs = {}

    for key, value in pairs(dict) do
        tu.push(vs, {key, value})
    end

    return vs
end

-- With side effects
tu.assoc = function (dict, ks, create)
    dict = _geti(dict)
    ks = utils.to_list(ks)
    local t = dict
    local last_key = false

    for _, key in ipairs(ks) do
        if not t[key] and create then
            t[key] = {}
        end

        last_key = key

        if not utils.table_p(t[key]) then
            return t[key], last_key, t
        end

        -- Is the last table found
        t = t[key]
    end
end

tu.update = function (dict, ks, sub)
    local _dict = _geti(dict)
    ks = utils.to_list(ks)
    local n = #ks
    local k = tu.first(ks)

    if n == 1 then
        if not dict[k] then
            return false
        elseif utils.callable(sub) then
            _dict[k] = sub(_dict[k])
        else
            _dict[k] = sub
        end
    else
        local _, last_key, prev_dict = tu.assoc(_dict, ks)

        if utils.callable(sub) then
            prev_dict[last_key] = sub(prev_dict[last_key])
        else
            prev_dict[last_key] = sub
        end
	end

    return dict
end

tu.get = function(arr, ...)
    arr = _geti(arr)
    local args = _getis(...)
    local vs = {}

    for _, a in ipairs(args) do
        if utils.table_p(a) then
            vs[#vs+1] = tu.assoc(arr, a)
        else
            vs[#vs+1] = a
        end
    end

    return vs
end

tu.find = function(t, i)
    t = _geti(t)
    for k, v in pairs(t) do
        if i == v then 
            return k
        end
    end
end

tu.findall = function(t, i)
    t = _geti(t)
    local found = {}

    for k, v in pairs(t) do
        if i == v then 
            tu.push(found, k)
        end
    end

    return found
end

tu.imap = function (f, ...)
    local arrs = _getis(...)
    local max_len = {}

    for _, a in ipairs(arrs) do
        table.insert(max_len, #a)
    end
    max_len = math.min(unpack(max_len))

    local index = 1
    return function ()
        if index > max_len then return end
        index = index + 1
        local out = f(unpack(tu.nth(index-1, unpack(arrs))))
        return out
    end, arrs, index
end

tu.ifilter = function (f, ...)
    local arrs = _getis(...)
    local max_len = {}

    for _, a in ipairs(arrs) do
        table.insert(max_len, #a)
    end
    max_len = math.min(unpack(max_len))

    local index = 1
    return function ()
        if index > max_len then return end
        index = index + 1
        local out = f(unpack(tu.nth(index-1, unpack(arrs))))
        if out then return true else return false end
    end, arrs, index
end

tu.map = function (f, ...)
    local out = {}
    local arrs = _getis(...)
    local max_len = {}

    for _, a in ipairs(arrs) do
        tu.push(max_len, #a)
    end

    max_len = math.min(unpack(max_len))

    for i=1, max_len do
        local v = tu.nth(i, ...) or false
        tu.extend(out, f(unpack(v)))
    end

    return out
end

tu.reduce = function (f, arr, init)
    arr = _geti(arr)
    init = init or false

    for _, v in ipairs(arr) do 
        init = f(v, init)
    end

    return init
end

tu.filter = function (f, ...)
    local out = {}
    local arrs = _getis(...)
    local max_len = {}

    for _, a in ipairs(arrs) do
        tu.push(max_len, #a)
    end
    max_len = math.min(unpack(max_len))

    for i=1, max_len do
        local v = tu.nth(i, ...) or false
        local _o = f(unpack(v)) or false
        tu.extend(out, _o)
    end

    return out
end

-- Iterator operations
tu.vec = function (index, n, gen, param, state)
    index = index or -1
    n = n or -1

    local acc = {}

    local _add = function(g, p, s)
        local out = {g(p, s)}

        if #out == 0 then 
            return
        end

        if #out > 1 and s then
            s = tu.first(out)
            out = slice(out, 2)
        end

        if #out == 1 then
            out = tu.first(out)
        end

        if not utils.table_p(index) then
            if index == -1 then
                tu.push(acc, out)
            else
                tu.push(acc, out[index] or false)
            end
        else
            for _, i in ipairs(index) do
                tu.push(acc, out[i])
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

    return acc, gen, param, state
end

return tu
