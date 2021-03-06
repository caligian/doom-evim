local iter = require('fun')
local utils = require('modules.utils.common')
local tu = {}

tu.to_dict = function(...)
    local args = {...}
    local t = {}

    for _, item in ipairs(args) do 
        t[item] = true
    end

    return t
end

tu.list_to_dict = function(...)
    local t = {}
    local args = {...}

    for _, arr in ipairs(args) do
        assert(utils.table_p(arr), 'List should be a table')
        t[#t+1] = tu.to_dict(unpack(arr))
    end

    if #t == 1 then return first(t) end
    return t
end

tu.arr_to_dict = tu.list_to_dict

tu.partition = function (arr, n)
    n = n or 1
    local len = #arr

    if n == 0 then return false end
    if n < 1 or n >= len then return arr end

    local q = math.floor(len / n)
    local r = len - (q * n)
    local t = {}

    local last_index  
    for i=1, len, n do
        t[#t+1] = {}
        for j=i, i+n-1 do
            table.insert(t[#t], arr[j])
            last_index = j
        end
    end

    if len - last_index > 0 then
        for i=last_index+1, len do
            if arr[i] then
                table.insert(t[#t+1], arr[i])
            end
        end
    end

    return t
end

tu.push = function (arr, ...)
    for _, i in ipairs({...}) do
        arr[#arr+1] = i
    end

    return arr
end

tu.pop = function (arr, n)
    n = n or 1
    local tail = {}

    for i=#arr,#arr-n+1, -1 do
        tail[#tail+1] = arr[i]
        arr[i] = nil
    end

    if #tail == 1 then tail = tail[1] end
    return tail, arr
end

tu.extend = function(dst, ...)
    assert(type(dst) == 'table')

    for _, arr in ipairs({...}) do
        if not utils.table_p(arr) then
            dst[#dst+1] = arr
        else
            for i=1, #arr do
                dst[#dst+1] = arr[i]
            end
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

tu.lextend = function (arr, ...)
    for _, a in ipairs(...) do
        for _, i in pairs(a) do
            table.insert(a, 1, i)
        end
    end

    return arr
end

tu.shift = function(arr, n)
    n = n or 1
    local head = {}

    for i=1, n do
        if arr[i] then
            head[#head+1] = arr[i]
            table.remove(arr, 1)
        end
    end

    if #head == 1 then head = head[1] end
    return head, arr
end

tu.splice = function(arr, from, len, ...)
    assert(from > 0 and from < #arr)
    local args = {...}
    len = len or 0

    assert(len > 0, 'Len cannot be negative')

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
        ks[#ks+1] = key
    end

    return ks
end

tu.vals = function (dict)
    local vs = {}

    for _, value in pairs(dict) do
        vs[#vs+1] = value
    end

    return vs
end

tu.values = tu.vals

tu.slice = function (arr, start, finish)
    assert(start > 0)
    finish = finish or #arr

    local t = {}
    for i=start,finish do
        t[#t+1] = arr[i]
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
        params[#params+1] = i[k] or false
    end

    return params
end

function tu.nth_(t, k, ...)
    return tu.nth(k, t, ...)
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

    return _cmp(dicta, dictb, keys(dicta), 0)
end

-- Generator
tu.zip = function(...)
    local arrs = {...}
    local max_len = {}

    for _, a in ipairs(arrs) do
        max_len[#max_len] = #a
    end
    max_len = math.min(unpack(max_len))

    local state = 1
    local n = #arrs
    return function()
        if state > n then
            return 
        end

        state = state + 1
        local out = tu.nth(state - 1, unpack(arrs)) or false
        return state, out
    end, arrs, state
end

tu.items = function(dict)
    local vs = {}

    for key, value in pairs(dict) do
        vs[#vs+1] = {key, value}
    end

    return vs
end

-- With side effects
--@tparam transform function Spec: transform(value, table, key, previous_table, previous_key). The function is only used when a key is found
--@tparam create boolean|any If create is true then create a table in its place. If create is false or nil, false is returned. If create is anything else, it is simply put in place of the missing value. If 'd' is passed, that element is removed from the dict iff it is found
tu.assoc = function (dict, ks, create, transform)
    ks = utils.to_list(ks)
    local n = #ks
    local t = dict
    local last_key = false
    local last_t = t
    local out = {}

    for index, key in ipairs(ks) do
        last_key = key
        local v = t[key]

        if not v then
            if create ~= nil and transform ~= 'd' then
                if index == n then
                    if create == true then
                        t[key] = {}
                    else
                        t[key] = create
                    end

                    return create, last_key, last_t, dict
                else
                    t[key] = {}
                end
            else
                return false, last_key, last_t, dict
            end
        elseif not utils.table_p(v) then
            if transform == 'd' then
                local out = vim.deepcopy(t[key])
                t[key] = nil
                return out, last_key, last_t, dict
            else
                if transform then 
                    assert(callable(transform), 'Transformer must be a callable')
                    t[key] = transform(v, t, key, last_t, last_key)
                end

                return t[key], last_key, last_t, dict
            end
        elseif transform == 'd' then
            t[key] = nil
        end

        last_t = t
        t = t[key]
    end

    return last_t[last_key], last_key, last_t, dict
end

function tu.update(dict, ks, replacement)
    tu.assoc(dict, ks, replacement, function(...) return replacement end)
    return dict
end

function tu.remove(dict, ks)
    tu.assoc(dict, ks, false, 'd')
    return dict
end

-- if table is passed then it will be sent to tu.assoc
tu.get = function(arr, ...)
    local ks = {...}
    local vs = {}
    local failed = false

    for _, i in ipairs(ks) do
        if utils.table_p(i) then
            local out = tu.assoc(arr, i) or false
            vs[#vs+1] = out
        elseif arr[i] then
            vs[#vs+1] = arr[i]
        else
            failed = true
        end
    end

    if failed then
        return false
    elseif #vs == 1 then
        return vs[1]
    elseif #vs == 0 then
        return false
    else
        return vs
    end
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
            found[#found+1] = k
        end
    end

    return found
end

-- misc operations
--
tu.imap = function (f, ...)
    local arrs = {...}
    local max_len = {}

    for _, a in pairs(arrs) do
        max_len[#max_len+1] = #a
    end
    max_len = math.min(unpack(max_len))

    local index = 1
    return function ()
        if index > max_len then return end
        index = index + 1
        local out = f(unpack(tu.nth(index-1, unpack(arrs)))) or false
        return index, out
    end, arrs, index
end

tu.map = function (f, ...)
    local out = {}
    local arrs = {...}
    local max_len = {}

    for _, a in pairs(arrs) do
        max_len[#max_len+1] = #a
    end
    max_len = math.min(unpack(max_len))

    for i=1, max_len do
        local v = tu.nth(i, ...) or false
        tu.extend(out, f(unpack(v)))
    end

    return out
end

tu.map_ = function (t, f, ...)
    return tu.map(f, t, ...)
end

tu.imap_ = function (t, f, ...)
    return tu.imap(f, t, ...)
end

tu.each = function (f, ...)
    local arrs = {...}
    local max_len = {}

    for _, a in pairs(arrs) do
        max_len[#max_len+1] = #a
    end
    max_len = math.min(unpack(max_len))

    for i=1, max_len do
        local vs = tu.nth(i, ...)
        f(unpack(vs))
    end
end

function tu.each_(t, f, ...)
    return tu.each(f, t, ...)
end

tu.reduce = function (f, arr, init)
    init = init or false

    for _, v in pairs(arr) do 
        init = f(v, init)
    end

    return init
end

function tu.reduce_(arr, f, init)
    return tu.reduce(f, arr, init)
end

tu.filter = function (f, t)
    local correct = {}

    for k, v in pairs(t) do
        local o = f(v)

        if o then
            if o == true then
                correct[k] = v
            else
                correct[k] = o
            end
        end
    end

    return correct
end

function tu.filter_(t, f)
    return tu.filter(f, t)
end

-- iterator operations
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
            local t = {}
            for _, i in ipairs(utils.to_list(index)) do
                tu.push(t, out[i] or false)
            end

            tu.push(acc, t)
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

tu.defaultdict = function (t, default)
    t = t or {}
    local out 

    if utils.callable(default) then
        out = default()
    else
        out = default
    end

    t = setmetatable(t, {
        __index = function(t, k) 
            local v = rawget(t, k)

            if utils.nil_p(v) then 
                return vim.deepcopy(out)
            end

            return v
        end
    })

    return t
end

-- @tparam t table If all the elements are truthy then return true or else return false
tu.all = function(t)
    local v = tu.vals(t)
    local n = #v

    return #(tu.filter(function(k)
        local e = t[k]
        return e ~= nil and e ~= false
    end, v)) == n 
end

tu.some = function(t)
    local v = tu.vals(t)
    local n = #v

    return #(tu.filter(function(k)
        local e = t[k]
        return e ~= nil and e ~= false
    end, v)) > 0
end

tu.blank_p = function (obj)
    if not type(obj) == 'string' or type(obj) == 'table' then
        return
    end

    return #obj == 0
end

tu.is_blank = tu.blank_p

tu.union = function(t1, t2)
    assert(t1 ~= nil)
    assert(t2 ~= nil)

    t1 = utils.to_list(t1)
    t2 = utils.to_list(t2)

    local a = tu.list_to_dict(t1)
    local b = tu.list_to_dict(t2)

    for k, _ in pairs(b) do
        if not a[k] then
            a[k] = true
        end
    end

    return tu.keys(a)
end

tu.intersection = function(t1, t2)
    assert(t1 ~= nil)
    assert(t2 ~= nil)

    t1 = utils.to_list(t1)
    t2 = utils.to_list(t2)

    local a = tu.list_to_dict(t1)
    local b = tu.list_to_dict(t2)

    for k, _ in pairs(a) do
        if not b[k] then
            a[k] = nil
        end
    end

    return tu.keys(a)
end

tu.difference = function(t1, t2)
    assert(t1 ~= nil)
    assert(t2 ~= nil)

    t1 = utils.to_list(t1)
    t2 = utils.to_list(t2)

    local a = tu.list_to_dict(t1, true)
    local b = tu.list_to_dict(t2, true)

    for k, _ in pairs(a) do
        if b[k] then
            a[k] = nil
        end
    end

    return tu.keys(a)
end

tu.subset_p = function(t1, t2)
    assert(t1 ~= nil)
    assert(t2 ~= nil)

    t1 = utils.to_list(t1)
    t2 = utils.to_list(t2)

    local found = 0
    local t1_len = #t1
    t1 = tu.list_to_dict(t1)
    t2 = tu.list_to_dict(t2)

    for k, v in pairs(t2) do
        if t1[k] then
            found = found + 1
        end
    end

    if found == t1_len then return true else return false end
end

tu.superset_p = function(t1, t2)
    return tu.subset_p(t2, t1)
end

tu.range = function (from, till, step)
    assert(from, 'No starting index provided')
    assert(till, 'No ending index provided')

    step = step or 1
    local t = {}

    for i=from, till, step do
        tu.push(t, i)
    end

    return t
end

tu.to_callable = function(f)
    assert(utils.func_p(f), 'Only functions can be used in callable tables')
    return setmetatable({}, {__call = function(_, ...) f(...) end})
end

tu.len = function(param)
    if type(param) == 'table' or type(param) == 'string' then
        return #param
    end
end

return tu
