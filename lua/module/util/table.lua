local function valid_t(t)
    assert(type(t) == 'table', dump(t) .. ' is not a table')
    if cname(t) == 'table' then
        return t.value
    elseif cname(t) == 'iterable' then
        return t.param
    end

    return t
end

iter = require('fun')

iterable = function (t)
    t = iter.iter(valid_t(t))
    mt_set(t, '__name', 'iterable')
    mt_set(t, '__type', iter)
    mt_set(t, '__tostring', dump)
    return t
end

to_dict = function(...)
    local args = {...}
    local t = {}

    for _, item in ipairs(args) do 
        t[item] = true
    end

    return t
end

partition = function (arr, n)
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

push = function (arr, ...)
    arr = valid_t(arr)

    for _, i in ipairs({...}) do
        arr[#arr+1] = i
    end

    return arr
end

pop = function (arr, n)
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

extend = function(dst, ...)
    assert(type(dst) == 'table')

    for _, arr in ipairs({...}) do
        if not table_p(arr) then
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

unshift = function (arr, ...)
    arr = valid_t(arr)
    local args = {...}

    for i=1,#args do
        table.insert(arr, 1, args[i])
    end

    return arr
end

lextend = function (arr, ...)
    for _, a in ipairs({...}) do
        if table_p(a) then
            for _, i in ipairs(a) do
                table.insert(arr, 1, i)
            end
        else
            table.insert(arr, 1, a)
        end
    end

    return arr
end

shift = function(arr, n)
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

splice = function(arr, from, len, ...)
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

keys = function (dict)
    dict = valid_t(dict)
    local ks = {}

    for key, _ in pairs(dict) do
        ks[#ks+1] = key
    end

    return ks
end

vals = function (dict)
    dict = valid_t(dict)
    local vs = {}

    for _, value in pairs(dict) do
        vs[#vs+1] = value
    end

    return vs
end

values = vals

slice = function (arr, start, finish)
    assert(start > 0)

    arr = valid_t(arr)
    finish = finish or #arr

    local t = {}
    for i=start,finish do
        t[#t+1] = arr[i]
    end

    return t
end

butlast = function (arr)
    arr = valid_t(arr)
    return slice(arr, 1, #arr-1)
end

rest = function (arr)
    arr = valid_t(arr)
    return slice(arr, 2, #arr)
end

first = function (arr)
    arr = valid_t(arr)
    return arr[1]
end

last = function (arr)
    arr = valid_t(arr)
    return arr[#arr]
end

identity = function (i)
    return i
end

max = function (t)
    return math.max(unpack(valid_t(t)))
end

min = function (t)
    return math.min(unpack(valid_t(t)))
end

-- This will call all the iterators! 
nth = function (...)
    local args = {...}
    local k = args[#args]
    local params = {}

    for i = 1, #args-1 do
        local t = valid_t(args[i])
        if t[k] then
            params[#params+1] = t[k]
        end
    end

    return params
end

merge = function(dicta, dictb, depth, f)
    dicta = valid_t(dicta)
    dictb = valid_t(dictb)
    depth = depth or -1
    local cached = {}

    local function _replace_level(a, b, ks, d)
        if #ks == 0 or d > 0 and d == depth then return end

        local k = first(ks)
        local rest = rest(ks)
        local item = b[k]
        local later = {}

        if cached[item] then 
            a[k] = cached[item]
            _replace_level(a, b, rest, d)
        else
            cached[item] = item

            if table_p(a[k]) and table_p(b[k]) then
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
equals = function(dicta, dictb, depth, f)
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

                if not table_p(item_a) and not table_p(item_b) then 
                    if item_a ~= item_b then
                        return false 
                    end
                else
                    later[#later+1] = i
                end
            end
        end

        for _, i in ipairs(later) do
            local out = _cmp(a[i], b[i], keys(a[i]), d+1)
            cached[a[i]] = out
            if not out then return false end
        end

        return true
    end

    return _cmp(dicta, dictb, keys(dicta), 0)
end

-- Generator
zip = function(...)
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
            push(add, arr[key])
        end
        push(out, add)
    end

    return out
end

izip = iter.zip

items = function(dict)
    local vs = {}
    dict = valid_t(dict)

    for key, value in pairs(dict) do
        vs[#vs+1] = {key, value}
    end

    return vs
end

function tget(tbl, ks, opts)
    assert(tbl)
    assert(ks)

    opts = opts or {}
    ks = to_list(ks)
    local n = #ks

    local function create_new_dict(t, k, value)
        if value ~= nil then
            if value == true then
                t[k] = {}
            elseif value == false then
                t[k] = false
            else
                t[k] = value
            end
        end
    end

    local function recurse(status)
        assert(status)
        assert(status.dict)
        assert(status.depth)

        if status.depth > n then
            return
        end

        local dict = status.dict
        local depth = status.depth
        local key = ks[depth]
        local value = dict[key]
        local replace = opts.replace
        local transform = opts.transform
        local delete = opts.delete

        if value == nil then
            value = '~NO_VALUE~'
        end

        if value == '~NO_VALUE~' then
            if replace ~= nil then
                if depth == n then
                    print('bhangar ki shakal ke bhosdike madarchod')
                    create_new_dict(dict, key, replace)
                    return dict[key], key, dict
                else
                    dict[key] = {}
                    return recurse {
                        depth = depth + 1;
                        dict = {};
                    }
                end
            end
        elseif not is_table(value) then
            if transform then
                dict[key] = transform(value)
            elseif delete then
                dict[key] = nil
            end

            if depth < n then
                if replace then
                    create_new_dict(dict, key, true)

                    return recurse {
                        depth = depth + 1;
                        dict = {};
                    }
                end
            else
                return dict[key], key, dict
            end
        else
            return recurse {
                depth = depth + 1;
                dict = value;
                value = value;
            }
        end
    end

    return recurse {
        dict = tbl;
        depth = 1;
    }
end

assoc = tget

function update(dict, ks, replacement)
    dict = valid_t(dict)

    assert(replacement ~= nil)

    tget(dict, ks, {
        replace = replacement;
    })

    return dict
end

tset = update

function remove(dict, ks)
    dict = valid_t(dict)
    assert(ks ~= nil)
    tget(dict, ks, {delete=true})
    return dict
end
rem = remove

find = function(t, i, depth)
    t = valid_t(t)

    local function recurse(tbl, value, depth, current)
        assert(tbl ~= nil)
        assert(value ~= nil)
        assert(depth ~= nil)

        current = current or 1

        if current > depth then
            return
        end
        
        local later = {}
        for k, v in pairs(tbl) do
            if value == v then
                return k
            end

            if is_table(v) then
                push(later, k)
            end
        end

        for _, k in ipairs(later) do
            local out = recurse(tbl[k], value, depth+1)
            if out then
                return out
            end
        end
    end

    return recurse(t, i, depth or 1)
end

-- misc operations
--
imap = iter.map
ieach = iter.each

each = function(t, f, is_dict)
    t = valid_t(t)
    local it = is_dict and pairs or ipairs

    for _, v in it(t) do
        f(v)
    end
end

map = function (t, f)
    local out = {}
    for _, o in iterable(t):map(f) do
        push(out, o)
    end

    return out
end

reduce = function (arr, f, init)
    arr = valid_t(arr)
    init = init or false

    for _, v in pairs(arr) do
        init = f(v, init)
    end

    return init
end

filter = function (t, f)
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

defaultdict = function (t, default)
    t = t or {}
    t = valid_t(t)
    local out 

    if callable(default) then
        out = default()
    else
        out = default
    end

    return setmetatable(t, {
        __index = function(t, k) 
            local v = rawget(t, k)

            if nil_p(v) then 
                return vim.deepcopy(out)
            end

            return v
        end
    })
end

-- @tparam t table If all the elements are truthy then return true or else return false
all = function(t)
    t = valid_t(t)
    local v = vals(t)
    local n = #v

    return #(filter(function(k)
        local e = t[k]
        return e ~= nil and e ~= false
    end, v)) == n 
end

some = function(t)
    t = valid_t(t)
    local v = vals(t)
    local n = #v

    return #(filter(function(k)
        local e = t[k]
        return e ~= nil and e ~= false
    end, v)) > 0
end

dropfalse = function(t, depth)
    depth = depth or -1
    t = valid_t(t)

    local function recurse(t, level)
        if depth ~= -1 and level > depth then
            return
        end

        local later = {}
        each(keys(t), function(k)
            local v = t[k]
            if v == false then
                t[k] = nil
            elseif is_table(v) then
                push(later)
            end
        end)

        each(later, function(k) 
            recurse(t[k], level+1) 
        end)
    end

    recurse(t, 1)
    return t
end

local function list_to_dict(arr)
    local d = {}

    for _, value in pairs(arr) do
        d[value] = true
    end

    return d
end

union = function(t1, t2)
    assert(t1 ~= nil)
    assert(t2 ~= nil)

    t1 = valid_t(t1)
    t2 = valid_t(t2)
    t1 = to_list(t1)
    t2 = to_list(t2)

    local a = list_to_dict(t1)
    local b = list_to_dict(t2)

    for k, _ in pairs(b) do
        if not a[k] then
            a[k] = true
        end
    end

    return keys(a)
end

intersection = function(t1, t2)
    assert(t1 ~= nil)
    assert(t2 ~= nil)

    t1 = valid_t(t1)
    t2 = valid_t(t2)
    t1 = to_list(t1)
    t2 = to_list(t2)

    local a = list_to_dict(t1)
    local b = list_to_dict(t2)

    for k, _ in pairs(a) do
        if not b[k] then
            a[k] = nil
        end
    end

    return keys(a)
end

difference = function(t1, t2)
    assert(t1 ~= nil)
    assert(t2 ~= nil)

    t1 = valid_t(t1)
    t2 = valid_t(t2)
    t1 = to_list(t1)
    t2 = to_list(t2)

    local a = list_to_dict(t1, true)
    local b = list_to_dict(t2, true)

    for k, _ in pairs(a) do
        if b[k] then
            a[k] = nil
        end
    end

    return keys(a)
end

subset_p = function(t1, t2)
    assert(t1 ~= nil)
    assert(t2 ~= nil)

    t1 = valid_t(t1)
    t2 = valid_t(t2)
    t1 = to_list(t1)
    t2 = to_list(t2)

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

superset_p = function(t1, t2)
    t1 = valid_t(t1)
    t2 = valid_t(t2)
    return subset_p(t2, t1)
end

is_superset = superset_p
is_subset = subset_p

function vec(it, n)
    assert(cname(it) == 'iterable', 'Please use iterable() to create a new luafun iterable')

    local gen, param, state, last_output = it.gen, it.param, it.state
    local out = {}
    n = n or #it.param
    for i=1, n do
        state, last_output = gen(param, state)
        if last_output then
            push(out, last_output)
        else
            break
        end
    end

    return out
end
to_vec = vec

function remove_nil(t)
    for i=1, #t do
        if not t[i] then
            table.remove(t, i)
        end
    end

    return t
end
del_nil = remove_nil
nonil = remove_nil
no_nil = remove_nil
delnil = remove_nil
