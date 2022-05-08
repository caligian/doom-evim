local path = require('path')
local class = require('classy')
local fs = require('path.fs')
local yaml = require('yaml')
local utils = {}

utils.number_p = function (i)
    return type(i) == 'number'
end

utils.num_p = function(i)
    return utils.number_p(i)
end

utils.table_p = function (t)
    return type(t) == 'table'
end

utils.func_p = function (f)
    return type(f) == 'function'
end

utils.callable = function (f)
    if utils.func_p(f) then
        return true
    end

    if not utils.table_p(f) then
        return false
    end

    local mt = getmetatable(f)
    if mt and mt.__call then
        return true
    end
end

utils.str_p = function (s)
    return type(s) == 'string'
end

utils.to_list = function (i, force)
    if utils.table_p(i) then
        if force then
            return {i}
        else
            return i
        end
    else
        return {i}
    end
end

utils.inspect = function (...)
    for _, value in ipairs({...}) do
        vim.api.nvim_echo({{vim.inspect(value)}}, false, {})
    end
end

utils.dump = function (...)
    local dumped = {}

    for _, value in ipairs({...}) do
        table.insert(dumped, vim.inspect(value))
    end

    return unpack(dumped)
end

utils.sprintf = function(fmt, ...)
    assert(#({...}) > 0)
    return string.format(fmt, utils.dump(...))
end

utils.printf = function(fmt, ...)
    print(utils.sprintf(fmt, ...))
end

utils.echo = function(fmt, ...)
    vim.api.nvim_echo({{utils.sprintf(fmt, ...)}}, false, {})
end

utils.to_stderr = function(fmt, ...)
    vim.api.nvim_err_writeln(utils.sprintf(fmt, ...))
end

utils.slice = function (arr, start, finish)
    finish = finish or #arr
    return vim.list_slice(arr, start, finish)
end

utils.butlast = function (arr)
    return utils.slice(arr, 1, #arr-1)
end

utils.rest = function (arr)
    return utils.slice(arr, 2, #arr)
end

utils.first = function (arr)
    return arr[1]
end

utils.last = function (arr)
    return arr[#arr]
end

utils.head = function(arr, n)
    n = n or 1
    return slice(arr, 1, n)
end

utils.tail = function(arr, n)
    n = n or 1
    n = n - 1
    local len = #arr
    return slice(arr, len - n, len)
end

utils.identity = function (i)
    return i
end

utils.max = function (t)
    return math.max(unpack(t))
end

utils.min = function (t)
    return math.min(unpack(t))
end

utils.push = table.insert

utils.pop = function (arr)
    arr[#arr-1] = nil
    return utils.last(arr)
end

utils.extend = function (dst, src, src_start, src_finish)
    if type(src) == 'table' then
        src_start = src_start or 1
        src_finish = src_finish or #src

        for i=src_start, src_finish do 
            table.insert(dst, src[i])
        end
    else
        table.insert(dst, src)
    end

    return dst
end

-- Does not modify the table. Keep in mind.
utils.unshift = function (arr, ...)
    return utils.extend({...}, arr)
end

-- Does not modify the table. Keep in mind.
utils.shift = function(arr)
    local t = {}

    for i=2,#arr do
        utils.push(t, arr[i])
    end

    return arr[1], t
end

--
-- Dict ops
--
utils.keys = function (dict)
    local ks = {}

    for key, _ in pairs(dict) do
        table.insert(ks, key)
    end

    return ks
end

utils.vals = function (dict)
    local vs = {}

    for _, value in pairs(dict) do
        table.insert(vs, value)
    end

    return vs
end

utils.items = function(dict)
    local vs = {}

    for key, value in pairs(dict) do
        utils.push(vs, {key, value})
    end

    return vs
end

utils.assoc = function (dict, ks, create)
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

utils.merge = function (a, b, merge_method)
    merge_method = merge_method or 'force'
    return vim.tbl_deep_extend(merge_method, a, b)
end

utils.update = function (dict, ks, sub)
    ks = utils.to_list(ks)
    local n = #ks
    local k = utils.first(ks)

    if n == 1 then
        if not dict[k] then
            return false
        elseif utils.callable(sub) then
            dict[k] = sub(dict[k])
        else
            dict[k] = sub
        end
    else
        local _, last_key, prev_dict = utils.assoc(dict, ks)

        if utils.callable(sub) then
            prev_dict[last_key] = sub(prev_dict[last_key])
        else
            prev_dict[last_key] = sub
        end
	end

    return dict
end

utils.get = function(arr, ks)
    local _get = function(k)
        if not arr[k] then return
        else return arr[k]
        end
    end

    return iter.map(_get, ks)
end

utils.tequals = function (arra, arrb, depth, collapse)
    arra = class.of(arra) == array and arra._items or arra
    arrb = class.of(arrb) == array and arrb._items or arrb
    arra = vim.deepcopy(arra)
    arrb = vim.deepcopy(arrb)
    collapse = collapse or false

    if collapse and #arra ~= #arrb then return false end

    depth = depth or 5

    local _eq 
    local _compare

    function _compare(a, b, k, d)
        local outa = a[k]
        local outb = b[k]

        if not outb then 
            a[k] = false
            return a
        end

        local ta = type(outa)
        local tb = type(outb)

        if ta ~= tb then 
            a[k] = false
            return a
        end

        if ta ~= 'table' and tb ~= 'table' then
            a[k] = outa == outb
            return a
        end

        local mta = getmetatable(outa)
        local mtb = getmetatable(outb)

        if mta and mtb and mta.__eq and mtb.__eq then
            a[k] = outa == outb
            return a
        else
            return _eq(a[k], b[k], d+1)
        end
    end

    function _eq(a, b, d)
        d = d or 0 

        if d >= depth then
            return a
        end

        if collapse and #a ~= #b then
            return false
        end

        local later = {}
        for k, v in pairs(a) do
            if type(a[k]) ~= type(b[k]) then
                a[k] = false
                if collapse then return false end
            elseif not utils.table_p(a[k]) and not utils.table_p(b[k]) then
                a[k] = a[k] == b[k]
                if collapse and not a[k] then return false end
            else
                table.insert(later, k)
            end
        end

        for _, k in ipairs(later) do
            a[k] = _compare(a, b, k, d)
        end

        return a
    end

    return _eq(arra, arrb)
end

--	
-- String ops
--
utils.split = vim.split

utils.find = function(t, i)
    for k, v in pairs(t) do
        if i == v then 
            return k
        end
    end
end

utils.findall = function(t, i)
    local found = {}

    for k, v in pairs(t) do
        if i == v then 
            utils.push(found, k)
        end
    end

    return found
end

-- Works like piped grep calls
utils.match = function(s, ...)
    local m = s
    local proceed = false

    for _, i in ipairs({...}) do
        local _m = m:match(i)
        if _m then 
            m = _m 
            proceed = true
        else 
            if m == s then 
                return false
            else
                return m
            end
        end
    end

    return m
end

utils.gmatch = function(s, pat)
    return string.gmatch(s, pat)
end

-- Gets n instances of pattern {i}
utils.pos = function(s, i, n)
end

--
-- Function ops
--

utils.vcall = vim.call

utils.call = function (f, ...)
    return f(...)
end

utils.partial = function (f, ...)
    local args = {...}

    return function (...)
        return f(unpack(extend(args, {...})))
    end
end

utils.lpartial = function(f, ...)
    local t = {...}
    return function(...)
        return f(unpack(extend(t, {...})))
    end
end

-- File ops
utils.slurp = function (src, iter)
    local fh = io.open(src, 'r')

    if not fh then return end

    if not iter then
        s = fh:read('*a')
        return s
    end

    local s = ''
    return function ()
        s = fh:read()

        if s then
            return s
        else
            fh:close()
        end
    end
end

utils.spit = function (dst, s, mode)
    local fh = io.open(dst, mode or 'w')

    if fh then
        fh:write(s)
        fh:close()
        return true
    end
end

utils.yml = {
    spit = function (dst, data)
        spit(dst, yaml.dump(data))
    end,

    slurp = function (src)
        return yaml.load(slurp(src))
    end,

    dump = yaml.dump,
    load = yaml.load,
}

utils.json = {
    dump = vim.fn.json_encode,
    load = vim.fn.json_decode,

    spit = function (dst, data)
        spit(dst, vim.fn.json_encode(data))
    end,

    slurp = function (dst)
        return vim.fn.json_decode(slurp(dst))
    end
}

--
-- Misc
--
utils.copy = vim.deepcopy

utils.path = require('path')

utils.fs = require('path.fs')

utils.vcmd = vim.cmd

utils.with_data_path = function (...)
    return path(vim.fn.stdpath('data'), ...)
end

utils.with_config_path = function (...)
    return path(vim.fn.stdpath('config'), ...)
end

utils.with_stdpath = function (what, ...)
    return path(vim.fn.stdpath(what), ...)
end

utils.each = function(f, arr)
    return iter.each(f, arr)
end

utils.globalize = function ()
    for k, f in pairs(fun) do 
        if not _G[k] and not k:match('globalize') and type(f) == 'function' then
            _G[k] = f
        end
    end
end

return utils
