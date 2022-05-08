local iter = require('fun')
local utils = dofile('init.lua')
local tu = {}

tu.next = function(gen, param, state)
    local out = {gen(param, state)}
    if out then 
        return out
    else 
        return false
    end
end

-- Compatible with luafun iterables and general iterables
-- Providing -1 in place of {times} will lead to all the elements being extracted. Use with caution when trying to use infinite gen
tu.vec = function(index, times, gen, param, state)
    assert(utils.callable(gen), 'Generator should be callable')
    param = param or utils.table_p(gen) and gen.param
    index = utils.to_list(index or 1)
    times = times or -1
    local acc = {}

    local _collect = function(g, p, s)
        local out = {g(p,s)}

        utils.inspect(out)

        if state then
            state = out[1]
            out = tu.rest(out)
        end

        if #out == 0 then return false end

        if #out == 1 then 
            tu.push(acc, out[1])
            return true
        end

        if #index == 1 then
            index = index[1]

            if index < 0 then 
                tu.push(acc, out)
            elseif out[index] then
                tu.push(acc, out[index])
            end
        else
            local t = {}

            for _, i in ipairs(index) do 
                if out[i] then 
                    tu.push(t, out[i])
                end
            end

            if #t == 1 then 
                tu.push(acc, t[1])
            else
                tu.push(acc, t)
            end
        end

        return true
    end

    local ctr = 1
    repeat
        if not _collect(gen, param, state) then 
            break 
        end

        ctr = ctr + 1
    until times > 0 and ctr > times

    return acc, gen, param, state
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
    return iter.head(arr)
end

tu.last = function (arr)
    return iter.tail(arr)
end

tu.head = function(arr, n)
    n = n or 1

    local h = {}
    for i=1, n do
        local out = iter.head(arr)
        if not out then return h, arr end
        table.insert(h, out)
    end

    return h, arr
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
                _replace_level(a[k], b[k], utils.keys(b[k]), d+1)
            end
        end
    end

    _replace_level(dicta, dictb, utils.keys(dictb), 0)
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

    return _cmp(dicta, dictb, utils.keys(dicta), 0)
end

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
    ks = tu.to_list(ks)
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
    ks = tu.to_list(ks)
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
    local _get = function(k)
        if not arr[k] then return
        else return arr[k]
        end
    end

    return iter.map(_get, ks)
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

tu.add_function = function(f, name, force)
    if force then
        _G[name] = f
    elseif not _G[name] then
        _G[name] = f
    end 

    return f
end

tu.globalize = function ()
    for k, f in pairs(fun) do 
        if not _G[k] and not k:match('globalize') and type(f) == 'function' then
            _G[k] = f
        end
    end
end

tu.imap = function(f, index, gen, param, state)
    index = index or {1}

    return function()
        local out = {tu.vec(index, 1, gen, param, state)}

        if #out == 4 then 
            out, gen, param, state = unpack(out)
        end

        -- state is nil. This is for iter.iter bullshit
        if #out == 3 then
            return
        end

        if #out == 1 then
            return f(unpack(utils.to_list(out[1])))
        end
    end, param, state
end

tu.vec(1, 2, tu.imap(tu.identity, 1, iter.iter({1,2,3,4})))

return tu
