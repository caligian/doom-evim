local path = require('path')
local yaml = require('yaml')
local utils = {}

utils.nil_p = function (o)
    if o == nil then 
        return true
    else
        return false
    end
end

utils.false_p = function (o)
    if o == false then 
        return true
    end

    return false
end

utils.true_p = function (o)
    if not utils.nil_p(o) and utils.false_p(o) then
        return true
    else
        return false
    end
end

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

--	
-- String ops
--
utils.split = vim.split

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

utils.add_global = function(f, name, force)
    if force then
        _G[name] = f
    elseif not _G[name] then
        _G[name] = f
    end 

    return f
end

utils.globalize = function ()
    for k, f in pairs(utils) do 
        if not _G[k] and not k:match('globalize') and type(f) == 'function' then
            _G[k] = f
        end
    end
end

return utils
