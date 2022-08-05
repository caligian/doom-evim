local iter = require('fun')
local utils = require('modules.utils.common')
local tu = {}

local function valid_t(t)
    assert(type(t) == 'table', utils.dump(t) .. ' is not a table')
    if utils.cname(t) == 'table' then
        return t.value
    elseif utils.cname(t) == 'iterable' then
        return t.param
    end

    return t
end

tu.new_iter = function (t)
    t = iter.iter(valid_t(t))
    local mt = getmetatable(t)
    mt.__name = 'iterable'
    mt.__tostring = function(self)
        return utils.dump(self)
    end
    return t
end

tu.to_dict = function(...)
    local args = {...}
    local t = {}

    for _, item in ipairs(args) do 
        t[item] = true
    end

    return t
end

tu.partition = function (arr, n)
    arr = valid_t(arr)
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
    arr = valid_t(arr)

    for _, i in ipairs({...}) do
        arr[#arr+1] = i
    end

    return arr
end

tu.pop = function (arr, n)
    arr = valid_t(arr)
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
            arr = valid_t(arr)
            for i=1, #arr do
                dst[#dst+1] = arr[i]
            end
        end
    end

    return dst
end

tu.unshift = function (arr, ...)
    arr = valid_t(arr)
    local args = {...}

    for i=1,#args do
        table.insert(arr, 1, args[i])
    end

    return arr
end

tu.lextend = function (arr, ...)
    for _, a in ipairs({...}) do
        if utils.table_p(a) then
            for _, i in ipairs(a) do
                table.insert(arr, 1, i)
            end
        else
            table.insert(arr, 1, a)
        end
    end

    return arr
end

tu.shift = function(arr, n)
    arr = valid_t(arr)
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

    arr = valid_t(arr)
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
    dict = valid_t(dict)
    local ks = {}

    for key, _ in pairs(dict) do
        ks[#ks+1] = key
    end

    return ks
end

tu.vals = function (dict)
    dict = valid_t(dict)
    local vs = {}

    for _, value in pairs(dict) do
        vs[#vs+1] = value
    end

    return vs
end

tu.values = tu.vals

tu.slice = function (arr, start, finish)
    assert(start > 0)

    arr = valid_t(arr)
    finish = finish or #arr

    local t = {}
    for i=start,finish do
        t[#t+1] = arr[i]
    end

    return t
end

tu.butlast = function (arr)
    arr = valid_t(arr)
    return tu.slice(arr, 1, #arr-1)
end

tu.rest = function (arr)
    arr = valid_t(arr)
    return tu.slice(arr, 2, #arr)
end

tu.first = function (arr)
    arr = valid_t(arr)
    return arr[1]
end

tu.last = function (arr)
    arr = valid_t(arr)
    return arr[#arr]
end

tu.identity = function (i)
    return i
end

tu.max = function (t)
    return math.max(unpack(valid_t(t)))
end

tu.min = function (t)
    return math.min(unpack(valid_t(t)))
end

-- This will call all the iterators! 
tu.nth = function (...)
    local args = {...}
    local k = args[#args]
    local params = {}

    for i = 1, #args-1 do
        local t = valid_t(args[i])
        params[#params+1] = t[k] or false
    end

    return params
end

tu.merge = function(dicta, dictb, depth, f)
    dicta = valid_t(dicta)
    dictb = valid_t(dictb)
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
    dicta = valid_t(dicta)
    dictb = valid_t(dictb)
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
    local len = {}
    local max_len = 0
    local out = {}

    for idx, _ in ipairs(arrs) do
        arrs[idx] = valid_t(arrs[idx])
        local a = arrs[idx]
        a = valid_t(a)
        len[idx] = #a
    end
    max_len = math.max(unpack(len))

    for i = 1, max_len do
        local add = {}
        for index, arr in ipairs(arrs) do
            local key = i > len[index] and 1 or i
            tu.push(add, arr[key])
        end
        tu.push(out, add)
    end

    return out
end

tu.izip = function(...)
    local arrs = {...}
    local len = {}
    local index = 1
    local max_len = 0
    local n = #arrs

    for idx, _ in ipairs(arrs) do
        arrs[idx] = valid_t(arrs[idx])
        local a = arrs[idx]
        a = valid_t(a)
        len[idx] = #a
    end
    max_len = math.max(unpack(len))

    return function ()
        if index > max_len then
            return
        end

        local out = {}
        for i, arr in ipairs(arrs) do
            local key = index > len[i] and 1 or index
            tu.push(out, arrs[i][key])
        end
        index = index + 1

        return out
    end, arrs, index
end

tu.items = function(dict)
    local vs = {}
    dict = valid_t(dict)

    for key, value in pairs(dict) do
        vs[#vs+1] = {key, value}
    end

    return vs
end

-- With side effects
--@tparam transform function Spec: transform(value, table, key, previous_table, previous_key). The function is only used when a key is found
--@tparam create boolean|any If create is true then create a table in its place. If create is false or nil, false is returned. If create is anything else, it is simply put in place of the missing value. If 'd' is passed, that element is removed from the dict iff it is found
tu.assoc = function (dict, ks, opts)
    opts = opts or {}
    dict = valid_t(dict)
    ks = utils.to_list(ks)
    local t = dict
    local last_key = false
    local last_t = t
    local out = {}
    local n = #ks

    for index, key in ipairs(ks) do
        last_key = key
        local v = t[key]

        if not v then
            if n == index then
                if opts.replace ~= nil then
                    if opts.replace == true then
                        t[key] = {}
                    else
                        t[key] = opts.replace
                    end

                    return opts.replace, last_key, last_t, dict
                else
                    return false, last_key, last_t, dict
                end
            elseif opts.replace then
                t[key] = {}
            else
                return false, last_key, last_t, dict
            end
        elseif not utils.table_p(v) then
            if opts.delete then
                local out = vim.deepcopy(t[key])
                t[key] = nil
                return out, last_key, last_t, dict
            elseif opts.replace then
                if opts.replace == true then
                    opts.replace = {}
                end

                t[key] = opts.replace
            elseif opts.transform then 
                assert(callable(opts.transform), 'Transformer must be a callable')
                t[key] = opts.transform(v, t, key, last_t, last_key)
            end

            return t[key], last_key, last_t, dict
        end

        last_t = t
        t = t[key]
    end

    return last_t[last_key], last_key, last_t, dict
end

function tu.update(dict, ks, replacement)
    dict = valid_t(dict)
    tu.assoc(dict, ks, {transform=function(...) return replacement end})
    return dict
end

function tu.remove(dict, ks)
    dict = valid_t(dict)
    tu.assoc(dict, ks, {delete=true})
    return dict
end

-- if table is passed then it will be sent to tu.assoc
tu.get = function(arr, ...)
    arr = valid_t(arr)
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
    t = valid_t(t)
    for k, v in pairs(t) do
        if i == v then 
            return k
        end
    end
end

tu.findall = function(t, i)
    t = valid_t(t)
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
tu.imap = function (t, f)
    return iter.iter(t):map(f)
end

tu.ieach = function (t, f)
    t = valid_t(t)
    iter.iter(t):each(f)
end

tu.each = function (t, f)
    t = valid_t(t)
    for _, value in pairs(t) do
        f(value)
    end
end

tu.map = function (t, f)
    local out = {}
    for _, i in tu.imap(t, f) do
        tu.push(out, i)
    end

    return out
end

tu.reduce = function (arr, f, init)
    arr = valid_t(arr)
    init = init or false

    for _, v in pairs(arr) do
        init = f(v, init)
    end

    return init
end

tu.filter = function (t, f)
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

tu.defaultdict = function (t, default)
    t = t or {}
    t = valid_t(t)
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
    t = valid_t(t)
    local v = tu.vals(t)
    local n = #v

    return #(tu.filter(function(k)
        local e = t[k]
        return e ~= nil and e ~= false
    end, v)) == n 
end

tu.some = function(t)
    t = valid_t(t)
    local v = tu.vals(t)
    local n = #v

    return #(tu.filter(function(k)
        local e = t[k]
        return e ~= nil and e ~= false
    end, v)) > 0
end

local function list_to_dict(arr)
    local d = {}

    for _, value in pairs(arr) do
        d[value] = true
    end

    return d
end

tu.union = function(t1, t2)
    assert(t1 ~= nil)
    assert(t2 ~= nil)

    t1 = valid_t(t1)
    t2 = valid_t(t2)
    t1 = utils.to_list(t1)
    t2 = utils.to_list(t2)

    local a = list_to_dict(t1)
    local b = list_to_dict(t2)

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

    t1 = valid_t(t1)
    t2 = valid_t(t2)
    t1 = utils.to_list(t1)
    t2 = utils.to_list(t2)

    local a = list_to_dict(t1)
    local b = list_to_dict(t2)

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

    t1 = valid_t(t1)
    t2 = valid_t(t2)
    t1 = utils.to_list(t1)
    t2 = utils.to_list(t2)

    local a = list_to_dict(t1, true)
    local b = list_to_dict(t2, true)

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

    t1 = valid_t(t1)
    t2 = valid_t(t2)
    t1 = utils.to_list(t1)
    t2 = utils.to_list(t2)

    local found = 0
    local t1_len = #t1
    t1 = list_to_dict(t1)
    t2 = list_to_dict(t2)

    for k, v in pairs(t2) do
        if t1[k] then
            found = found + 1
        end
    end

    if found == t1_len then return true else return false end
end

tu.superset_p = function(t1, t2)
    t1 = valid_t(t1)
    t2 = valid_t(t2)
    return tu.subset_p(t2, t1)
end

tu.is_superset = tu.superset_p
tu.is_subset = tu.subset_p

function tu.vec(it, n)
    assert(utils.cname(it) == 'iterable', 'Please use tu.new_iter to create a new luafun iterable')

    local gen, param, state, last_output = it.gen, it.param, it.state
    local out = {}
    n = n or #it.param
    for i=1, n do
        state, last_output = gen(param, state)
        if last_output then
            tu.push(out, last_output)
        else
            break
        end
    end

    return out
end

tu.to_vec = tu.vec

return tu
