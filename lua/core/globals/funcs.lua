local yaml = require('yaml')

_G.inspect = function (...)
    for _, value in ipairs({...}) do
        vim.api.nvim_echo({{vim.inspect(value)}}, false, {})
    end
end

_G.to_list = function (i, force)
    if table_p(i) then
        if force then
            return {i}
        else
            return i
        end
    else
        return {i}
    end
end

_G.keys = function (dict)
    local ks = {}

    for key, _ in pairs(dict) do
        table.insert(ks, key)
    end

    return ks
end

_G.vals = function (dict)
    local vs = {}

    for _, value in pairs(dict) do
        table.insert(vs, value)
    end

    return vs
end

_G.list_p = function (t)
    if #(keys(t)) > 0 then
        return false
    else
        return true
    end
end

_G.num_p = function (i)
    return type(i) == 'number'
end

_G.table_p = function (t)
    return type(t) == 'table'
end

_G.func_p = function (f)
    return type(f) == 'function'
end

_G.callable = function (f)
    if table_p(t) and f.__call or func_p(f) then
        return true
    end
end

_G.dict_p = function (dict)
    if #dict > 0 then
        return false
    else
        return true
    end
end

_G.str_p = function (s)
    return type(s) == 'string'
end

_G.split = vim.split

_G.copy = vim.deepcopy

_G.dump = function (...)
    local dumped = {}

    for _, value in ipairs({...}) do
        table.insert(dumped, vim.inspect(value))
    end

    return unpack(dumped)
end

_G.sprintf = string.format

_G.echo = function (fmt, ...)
    local args = {...}

    for index, value in ipairs(args) do
        if type(value) == 'table' then
            args[index] = dump(value)
        end
    end

    local s = sprintf(fmt, unpack(args))
    vim.api.nvim_echo({{s}}, false, {})
end

_G.printf = function (s, ...)
    print(string.format(s, ...))
end

-- Contains all the global variables
if not _G.Doom then
    _G.Doom = {}
end

_G.push = table.insert

_G.extend = function (dst, src, start, finish)
    if type(src) == 'table' then
        return vim.list_extend(dst, src, start, finish)
    else
        table.insert(dst, src)
    end
end

_G.slice = function (arr, start, finish)
    finish = finish or #arr
    return vim.list_slice(arr, start, finish)
end

_G.butlast = function (arr)
    return slice(arr, 1, #arr-1)
end

_G.vcmd = vim.cmd

_G.vcall = vim.call

_G.call = function (f, ...)
    return f(...)
end

_G.partial = function (f, ...)
    local args = {...}

    return function (...)
        return f(unpack(extend(args, {...})))
    end
end

_G.gsub = string.gsub

_G.sed = function (s, pat, sub, ...)
    local args = {...}
    local n = #args

    assert(n > 0 and n % 2 == 0, 'Rest of the args should be even in number')

    s = s:gsub(pat, sub)

    if n > 0 then
        for i = 1, #n, 2 do
            local _pat = args[i]
            local _sub = args[i+1]
            s = s:gsub(_pat, _sub)
        end
   end

   return s
end

_G.path = require('path')

_G.fs = require('path.fs')

_G.grep = string.match

_G.first = function (arr)
    return arr[1]
end

_G.last = function (arr)
    return arr[#arr]
end

_G.unpush = function (arr, ...)
    return extend({...}, arr)
end

_G.pop = function (arr)
    local new = butlast(arr)
    return last(arr), new
end

_G.rest = function (arr)
    local r = {}

    for index, value in ipairs(arr) do
        if index > 1 then
            push(r, value)
        end
    end

    return r
end

_G.map = function (f, arr)
    local acc = {}

    local function _recurse(it)
        local out = {it()}

        if #out > 0 then
            out = f(unpack(out))
            push(acc, out or false)
            _recurse(it)
        end
    end

    if callable(arr) then
        _recurse(arr)
    else
        for _, value in ipairs(arr) do
            extend(acc, f(value))
        end

        for key, value in pairs(arr) do
            acc[key] = f(value)
        end
    end

    return acc
end

_G.filter = function (f, arr)
    local acc = {}

    local function _recurse(it)
        local out = {it()}

        if #out > 0 then
            out = f(unpack(out))
            if out then
                push(acc, out)
            end
            _recurse(it)
        end
    end

    if callable(arr) then
        _recurse(arr)
    else
        for _, value in ipairs(arr) do
            local out = f(value)
            if out then
                push(acc, out)
            end
        end

        for key, value in pairs(arr) do
            local out = f(value)
            if out then
                acc[key] = out
            end
        end
    end

    return acc
end

-- If iterators are passed and there are multiple return values, then all the values will be sent in a table
-- Only compatible with arrays. Dict keys are skipped
_G.reduce = function (f, arr)
    local acc = false

    local function _recurse(it, times)
        times = times or 1
        local out = {it()}

        if #out > 0 then
            if #out == 1 then
                out = first(out)
            end

            if times == 1 then
                acc = out
            else
                acc = f(acc, out)
            end

            _recurse(it, times+1)
        end
    end

    if callable(arr) then
        _recurse(arr)
    else
        if #arr > 1 then
            acc = first(arr)

            for i = 2, #arr, 1 do
                acc = f(acc, arr[i])
            end
        else
            return first(arr)
        end
    end

    return acc
end

_G.with_data_path = function (...)
    return path(vim.fn.stdpath('data'), ...)
end

_G.with_config_path = function (...)
    return path(vim.fn.stdpath('config'), ...)
end

_G.with_stdpath = function (what, ...)
    return path(vim.fn.stdpath(what), ...)
end

_G.dig = function (dict, ks, create)
    local t = dict
    local last_key = false

    for _, key in ipairs(ks) do
        if not t[key] and create then
            t[key] = {}
        end

        if t[key] then
            last_key = key

            if table_p(t[key]) then
                t = t[key]
            else
                return t[key], last_key, t
            end
        end
    end

    return t[last_key], last_key, t
end

_G.update = function (dict, ks, sub)
    local function _replace(x, f)
        if f then
            x = f(x)
        end

        return x
    end

    if #ks > 1 then
        local _, last_key, prev_dict = dig(dict, ks)

        if callable(sub) then
            prev_dict[last_key] = _replace(prev_dict[last_key], sub)
        else
            prev_dict[last_key] = sub
        end
    else
        if dict[ks[1]] then
            if callable(sub) then
                dict[ks[1]] = _replace(dict[ks[1]], sub)
            else
                dict[ks[1]] = sub
            end
        end
    end

    return dict
end

_G.iterchain = function (...)
    local all_arrs = {...}
    local arr_index = 1
    local index = 1

    return function ()
        local function _recurse(ai, i)
            if all_arrs[ai] then
                if not all_arrs[ai][i] then
                    arr_index = arr_index + 1
                    index = 1
                    return _recurse(ai+1, 1)
                else
                    index = index + 1
                    return all_arrs[ai][i]
                end
            end
        end

        return _recurse(arr_index, index)
    end
end

_G.iter = function (arr)
    return iterchain(arr)
end

-- get_idx specifies which arg to record
_G.vec = function (iter, pick)
    local acc = {}
    pick = pick or {1}
    pick = to_list(pick)

    local function _recurse(it)
        if it then
            if callable(it) then
                local out = {it()}

                if #out > 0 then
                    if #pick == 1 and first(pick) == -1 then
                        push(acc, out)
                    else
                        map(function (idx)
                            if out[idx] then
                                push(acc, out[idx])
                            end
                        end, pick)
                    end
                    _recurse(it)
                end
            end
        end
    end

    _recurse(iter)

    return acc
end

_G.slurp = function (src, iter)
    local fh = io.open(src, 'r')

    if fh then
        if iter then
            local s = ''

            return function ()
                s = fh:read()

                if s then
                    return s
                else
                    fh:close()
                end
            end
        else
            local s = fh:read('*a')
            fh:close()
            return s
        end
    end
end

-- @see vim.tbl_deep_extend
_G.merge = function (a, b, merge_method)
    merge_method = merge_method or 'force'
    return vim.tbl_deep_extend(merge_method, a, b)
end

_G.spit = function (dst, s, mode)
    local fh = io.open(dst, mode or 'w')

    if fh then
        fh:write(s)
        fh:close()
        return true
    end
end

_G.yml = {
    spit = function (dst, data)
        spit(dst, yaml.dump(data))
    end,

    slurp = function (src)
        return yaml.load(slurp(src))
    end,

    dump = yaml.dump,
    load = yaml.load,
}

_G.json = {
    dump = vim.fn.json_encode,
    load = vim.fn.json_decode,

    spit = function (dst, data)
        spit(dst, vim.fn.json_encode(data))
    end,

    slurp = function (dst)
        return vim.fn.json_decode(slurp(dst))
    end
}

-- just like for i=1,n,2 do
_G.range = function (from, till, skip)
    skip = skip or 1
    local n = {}

    if from > till and skip then
        skip = skip * -1
    end

    for i = from, till, skip do
        push(n, i)
    end

    return n
end

_G.identity = function (i)
    return i
end

_G.max = function (t)
    return math.max(unpack(t))
end

_G.min = function (t)
    return math.min(unpack(t))
end

_G.at = function (index, ...)
    local arrs = {...}
    local t = {}

    return map(function (a)
       return a[index]
    end, arrs)
end

_G.zip = function (...)
    local function _zip(args, max_len)
        local t = {}

        return map(function (index)
            return at(index, unpack(args))
        end, range(1, max_len))
    end

    local all_arrs = {...}

    local max_len = min(map(function (t)
        return #t
    end, all_arrs))

    return _zip(all_arrs, max_len)
end

_G.zipmap = function (f, ...)
    return zip(f, ...)
end
