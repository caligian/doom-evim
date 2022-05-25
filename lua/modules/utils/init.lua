local path = require('path')
local yaml = require('yaml')
local utils = {}

utils.boolean_p = function(e)
    return type(e) == 'boolean'
end

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

utils.defined_p = function(o)
    if not utils.nil_p(o) then
        return true
    else
        return false
    end
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

utils.callable_p = utils.callable

utils.str_p = function (s)
    return type(s) == 'string'
end

utils.string_p = utils.str_p

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
        dumped[#dumped+1] = vim.inspect(value)
    end

    dumped = #dumped == 1 and first(dumped) or dumped
    return dumped
end

utils.sprintf = function(fmt, ...)
    local args = {...}

    for index, val in ipairs(args) do
        if utils.table_p(val) then
            args[index] = vim.inspect(val)
        end
    end

    return string.format(fmt, unpack(args))
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

utils.yspit = function (dst, data)
    utils.spit(dst, yaml.dump(data))
end

utils.yslurp = function (src)
    return yaml.load(utils.slurp(src))
end

utils.ydump = yaml.dump
utils.yload = yaml.load

utils.jdump = vim.fn.json_encode
utils.jload = vim.fn.json_decode

utils.jspit = function (dst, data)
    utils.spit(dst, vim.fn.json_encode(data))
end

utils.jslurp = function (dst)
    return vim.fn.json_decode(utils.slurp(dst))
end

--
-- Misc
--
utils.copy = vim.deepcopy

utils.vcmd = vim.cmd

utils.join_path = function(...)
    return path(...)
end

utils.join = table.concat

utils.with_data_path = function (...)
    return path(vim.fn.stdpath('data'), ...)
end

utils.with_config_path = function (...)
    return path(vim.fn.stdpath('config'), ...)
end

utils.with_config_lua_path = function(...)
    return utils.with_config_path('lua', ...)
end

utils.with_user_config_path = function(...)
    return path(os.getenv('HOME'), '.vdoom.d', 'lua')
end

utils.with_stdpath = function (what, ...)
    return path(vim.fn.stdpath(what), ...)
end

utils.with_packer_path = function(what, ...)
    return utils.with_data_path('site', 'pack', 'packer', what, ...)
end

utils.add_global = function(f, name, force)
    if force then
        _G[name] = f
    elseif not _G[name] then
        _G[name] = f
    end 

    return f
end

utils.globalize = function (mod, ks)
    mod = mod or utils

    if not ks then
        for k, f in pairs(mod) do 
            if not _G[k] and not k:match('globalize') then
                _G[k] = f
            end
        end
    else
        for _, k in pairs(ks) do 
            f = mod[k]

            if f and not _G[k] and not k:match('globalize') then
                _G[k] = f
            end
        end
    end
end

return utils