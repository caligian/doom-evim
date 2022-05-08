local iter = require('rocks.fun')
local utils = require('modules.utils')
local tu = {}

tu.push = function (arr, ...)
    for _, i in ipairs({...}) do
        table.insert(arr, i)
    end

    return arr
end

tu.pop = function (arr, n)
    local tail = {}

    for i=#arr,#arr-n+1, -1 do
        table.insert(tail, arr[i])
        arr[i] = nil
    end

    return tail, arr
end

tu.extend = function(dst, ...)
    assert(type(dst) == 'table')

    for _, arr in ipairs({...}) do
        arr = utils.to_list(arr)

        for i=1, #arr do
            table.insert(dst, arr[i])
        end
    end

    return dst
end

tu.unshift = function (arr, ...)
    local args = {...}

    for i=1,#args do
        table.insert(arr, 1, args[i])
    end

    return arr
end

tu.shift = function(arr, n)
    local head = {}

    for i=1, n do
        if arr[i] then
            table.insert(head, arr[i])
            table.remove(arr, 1)
        end
    end

    return head, arr
end

tu.splice = function(arr, from, len, ...)
    assert(from > 0 and from < #arr)
    assert(len and len > 0)

    local args = {...}
    len = len or 0

    if len == 0 then
        for i in ipairs(args) do
            table.insert(arr, from, i)
        end
    elseif len > 0 then
        for i=1,len do
            table.remove(arr, from)
        end

        for i=#args, 1, -1 do
            table.insert(arr, from, args[i])
        end
    end

    return arr
end

tu.keys = function (dict)
    local ks = {}

    for key, _ in pairs(dict) do
        table.insert(ks, key)
    end

    return ks
end

tu.vals = function (dict)
    local vs = {}

    for _, value in pairs(dict) do
        table.insert(vs, value)
    end

    return vs
end

tu.slice = function (arr, start, finish)
    assert(start > 0)
    finish = finish or #arr

    local t = {}
    for i=start,finish do
        table.insert(t, arr[i])
    end

    return t
end

tu.butlast = function (arr)
    return tu.slice(arr, 1, #arr-1)
end

tu.rest = function (arr)
    return tu.slice(arr, 2, #arr)
end

tu.first = function (arr)
    return arr[1]
end

tu.last = function (arr)
    return arr[#arr]
end

tu.identity = function (i)
    return i
end

tu.max = function (t)
    return math.max(unpack(t))
end

tu.min = function (t)
    return math.min(unpack(t))
end

-- This will call all the iterators! 
tu.nth = function (k, ...)
    local params = {}

    for _, i in ipairs({...}) do
        if i[k] then
            table.insert(params, i[k])
        end
    end

    return params
end

tu.merge = function(dicta, dictb, depth, f)
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
                table.insert(later, k)
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

    _replace_level(dicta, dictb, keys(dictb), 0)
    return dicta
end

-- This tests for absolute equality. Any failed attempt will lead to the whole table
-- being treated as false
tu.equals = function(dicta, dictb, depth, f)
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
            if type(item_a) ~= type(item_b) then return false end

            if not utils.table_p(item_a) and not utils.table_p(item_b) then 
                if item_a ~= item_b then
                    return false 
                end
            else
                table.insert(later, i)
            end
        end

        for _, i in ipairs(later) do
            local out = _cmp(a[i], b[i], tu.keys(a[i]), d+1)
            cached[a[i]] = out
            if not out then return false end
        end

        return true
    end

    return _cmp(dicta, dictb, keys(dicta), 0)
end

-- Generator
tu.zip = function(...)
    local arrs = {...}
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
    local vs = {}

    for key, value in pairs(dict) do
        tu.push(vs, {key, value})
    end

    return vs
end

-- With side effects
tu.assoc = function (dict, ks, create)
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
    ks = utils.to_list(ks)
    local n = #ks
    local k = tu.first(ks)

    if n == 1 then
        if not dict[k] then
            return false
        elseif utils.callable(sub) then
            dict[k] = sub(dict[k])
        else
            dict[k] = sub
        end
    else
        local _, last_key, prev_dict = tu.assoc(dict, ks)

        if utils.callable(sub) then
            prev_dict[last_key] = sub(prev_dict[last_key])
        else
            prev_dict[last_key] = sub
        end
	end

    return dict
end

tu.get = function(arr, ks)
    local vs = {}

    for _, i in ipairs(ks) do
        if arr[i] then
            table.insert(vs, arr[i])
        end
    end

    return vs
end

tu.find = function(t, i)
    for k, v in pairs(t) do
        if i == v then 
            return k
        end
    end
end

tu.findall = function(t, i)
    local found = {}

    for k, v in pairs(t) do
        if i == v then 
            tu.push(found, k)
        end
    end

    return found
end

-- Misc operations
tu.globalize = function ()
    for k, f in pairs(tu) do 
        if not _G[k] and not k:match('globalize') and type(f) == 'function' then
            _G[k] = f
        end
    end
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
