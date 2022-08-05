local path = require('path')
local yaml = require('yaml')
local iter = require('fun')
local utils = {}

utils.identity = function (i)
    return i
end

utils.blank_p = function (obj)
    if type(obj) ~= 'string' or type(obj) ~= 'table' then
        return
    end

    return #obj == 0
end
utils.is_blank = utils.blank_p

utils.to_callable = function(f)
    assert(utils.func_p(f), 'Only functions can be used in callable tables')
    return setmetatable({}, {__call = function(_, ...) f(...) end})
end

utils.func_to_callable = utils.to_callable
utils.function_to_callable = utils.to_callable

utils.len = function(param)
    if type(param) == 'table' then
        local n = 0
        for _, _ in pairs(param) do
            n = n + 1
        end

        return n
    elseif type(param) == 'string' then
        return #param
    else
        return false
    end
end

utils.range = function (from, till, step)
    assert(from, 'No starting index provided')
    assert(till, 'No ending index provided')

    step = step or 1
    local t = {}

    for i=from, till, step do
        t[#t+1] = i
    end

    return t
end

utils.typeof = function (obj)
    assert(obj ~= nil, 'Object cannot be nil')
    local t = type(obj)

    if t == 'table' then
        local mt = getmetatable(obj)
        if mt and mt.__name then
            return mt.__name
        elseif mt and mt.__call then
            return 'callable'
        end
    end

    return t
end

utils.isa = function (obj, k)
    return utils.typeof(obj) == k
end

utils.is_a = utils.isa

utils.module_p = function (obj)
    assert(obj ~= nil, 'Object cannot be nil')
    local t = type(obj)

    if t == 'table' then
        return t.__name ~= nil
    end

    return false
end
utils.class_p = utils.module_p
utils.is_class = utils.class_p
utils.is_module = utils.module_p

utils.to_stderr = function(s)
    vim.api.nvim_err_writeln(s)
end

utils.system = function(cmd)
    return vim.fn.systemlist(cmd)
end

utils.boolean_p = function(e)
    return type(e) == 'boolean'
end

utils.bool_p = utils.boolean_p
utils.is_boolean = utils.boolean_p
utils.is_bool = utils.boolean_p

utils.nil_p = function (o)
    if o == nil then
        return true
    else
        return false
    end
end

utils.is_nil = utils.nil_p

utils.false_p = function (o)
    if o == false then
        return true
    end

    return false
end

utils.is_false = utils.false_p

utils.defined_p = function(o)
    if not utils.nil_p(o) then
        return true
    else
        return false
    end
end

utils.defined = utils.defined_p
utils.is_defined = utils.defined

utils.true_p = function (o)
    if not utils.nil_p(o) and utils.false_p(o) then
        return true
    else
        return false
    end
end

utils.is_truthful = utils.true_p
utils.is_true = utils.true_p

utils.number_p = function (i)
    return type(i) == 'number'
end

utils.num_p = function(i)
    return utils.number_p(i)
end

utils.is_number = utils.number_p
utils.is_num = utils.num_p

utils.table_p = function (t)
    return type(t) == 'table'
end
utils.is_table = utils.table_p
utils.is_dict = utils.table_p

utils.func_p = function (f)
    return type(f) == 'function'
end
utils.is_function = utils.function_p
utils.is_func = utils.function_p
utils.function_p = utils.func_p

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
utils.is_callable = utils.callable

utils.str_p = function (s)
    return type(s) == 'string'
end

utils.string_p = utils.str_p
utils.is_string = utils.str_p

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

function utils.class_name(obj)
    if not type(obj) == 'table' then
        return false
    end
    local mt = getmetatable(obj)
    if mt and mt.__name then
        return mt.__name
    end
    return false
end

utils.classname = utils.class_name
utils.cname = utils.class_name

utils.to_arr = utils.to_list
utils.to_a = utils.to_arr

utils.inspect = function (...)
    for _, value in ipairs({...}) do
        vim.api.nvim_echo({{vim.inspect(value)}}, false, {})
    end
end

utils.dump = function (...)
    local dumped = {}

    for _, value in ipairs({...}) do
        dumped[#dumped+1] = type(value) == 'string' and value or vim.inspect(value)
    end

    dumped = table.concat(dumped, "\n"):gsub("\n$", '')

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
    end, fh
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
utils.deepcopy = vim.deepcopy

-- Shallow copy
utils.copy = function (src_t)
    local dst_t = {}

    local function copy_level(src, dst)
        for index, value in pairs(src) do
            if utils.table_p(value) then
                dst[index] = {}
                copy_level(value, dst[index])
            else
                dst[index] = value
            end
        end
    end

    copy_level(src_t, dst_t)
    return dst_t
end

utils.vcall = setmetatable({}, {
    __index = function (self, k)
        local f = self[k] or vim.fn[k] or partial(vim.call, k)

        if not self[k] then
            self[k] = f
        end

        return f
    end;
})

utils.vcmd = function (fmt, ...)
    local out = vim.api.nvim_exec(sprintf(fmt, ...), true)
    if out == '' then return false end

    return out
end

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
    return path(os.getenv('HOME'), '.vdoom.d', ...)
end

utils.with_user_config_lua_path = function(...)
    return utils.with_user_config_path('lua', ...)
end

utils.with_stdpath = function (what, ...)
    return path(vim.fn.stdpath(what), ...)
end

utils.with_packer_path = function(what, ...)
    return utils.with_data_path('site', 'pack', 'packer', what, ...)
end

utils.add_global = function(obj, name, force)
    if force then
        _G[name] = obj
    elseif not _G[name] then
        _G[name] = obj
    end

    return obj
end

utils.globalize = function (mod, ks)
    mod = mod or utils

    if not ks then
        for k, f in pairs(mod) do
            if not _G[k] then
                _G[k] = f
            end
        end
    else
        for _, k in pairs(ks) do
            f = mod[k]

            if f and not _G[k] then
                _G[k] = f
            end
        end
    end
end

utils.chomp = function(s)
    if type(s) == 'string' then
        return s:gsub("[\n\r ]$", '')
    elseif type(s) == 'table' then
        for i, v in ipairs(s) do
            if type(v) == 'string' then
                s[i] = s[i]:gsub("[\n\r ]$", '')
            end
        end
    end

    return s
end

utils.tempfile = function()
    return os.tmpname()
end

utils.with_open = function(dst, mode, f)
    mode = mode or 'r'
    local fh = io.open(dst, mode)

    if fh then
        local out = f(fh)
        fh:close()
        return out, dst
    end

    return false, dst
end

function utils.with_tempfile(mode, f, keep)
    mode = mode or 'w'
    local tf = utils.tempfile()
    local fh = io.open(tf, mode) 

    if fh then
        local out = f(fh)
        fh:close()

        if not keep then
            utils.system('rm ' .. tf)
            return  out
        end

        out = out or false

        return out, tf
    end

    return false
end

-- @tparam timeout number Pass -1 to immediately return the result
function utils.wait(f, args, opts)
    assert(f, 'No callable provided')

    args = args or {}
    opts = opts or {}
    local timeout = opts.timeout == nil and 10000 or opts.timeout
    local tries = opts.tries or 10
    local inc = opts.inc or 10
    local out = opts.default
    local sched = opts.sched == nil or false
    assert(args, 'No args provided')

    if sched then 
        assert(timeout ~= false, 'Cannot defer execution without waiting. Please supply a timeout value')

        vim.schedule(function()
            out = f(unpack(args))
        end) 
    else
        out = f(unpack(args))
    end

    local ctr = 0

    if timeout == false then
        return out
    end

    while out == nil and ctr ~= tries do
        if tries == ctr then
            return out
        end

        vim.wait(timeout)
        timeout = timeout + inc
        ctr = ctr + 1
    end

    return out
end

-- @tparam text table {question, default_text, callback }, ...
utils.gets = function(prompt, loop, ...)
    prompt = prompt or '%'
    prompt = prompt .. ' '
    local args = {...}
    local out = {}
    assert(#args > 0, 'No args provided')

    local function _get_input(t)
        assert(#t >= 1, 'No prompt question provided')

        local q, default_text, cb = unpack(utils.to_list(t))
        q = q .. ' ' .. prompt
        default_text = default_text or ''
        local input = vim.fn.input(q, default_text)

        if #input == 0 then
            if loop then 
                return _get_input(t) 
            else
                return false
            end
        else
            if cb then
                assert(utils.callable(cb), 'Invalid callback provided.')
                local is_correct = cb(input)
                if is_correct then 
                    if utils.bool_p(is_correct) then
                        return input
                    else
                        return is_correct 
                    end
                else
                    if loop then 
                        return _get_input(t) 
                    else
                        return false
                    end
                end
            else
                return input
            end
        end
    end

    local n = 1
    for _, i in ipairs(args) do
        out[n] = _get_input(i)
        n = n + 1
    end

    return out
end

function utils.len(obj)
    assert(type(obj) == 'string' or type(obj) == 'table', 'Only tables or strings can be passed')
    return #obj
end

utils.length = utils.len
utils.size = utils.len

return utils
