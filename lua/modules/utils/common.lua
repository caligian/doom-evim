local path = require('path')
local yaml = require('yaml')
local iter = require('fun')

function table_ro(t)
    return setmetatable(t, {
        __newindex = function (...)
            error('Attempting to edit a read-only table')
        end
    })
end

function mt_get(t, key)
    local mt = getmetatable(t)
    if mt then
        return rawget(mt, key)
    end
end

function mt_def(t, key, f)
    local mt = getmetatable(t)
    if mt then
        rawset(mt, key, f)
    end
end

identity = function (i)
    return i
end

blank_p = function (obj)
    if type(obj) ~= 'string' or type(obj) ~= 'table' then
        return
    end

    return #obj == 0
end
is_blank = blank_p

to_callable = function(f)
    assert(func_p(f), 'Only functions can be used in callable tables')
    return setmetatable({}, {__call = function(_, ...) f(...) end})
end

func_to_callable = to_callable
function_to_callable = to_callable

len = function(param)
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

range = function (from, till, step)
    assert(from, 'No starting index provided')
    assert(till, 'No ending index provided')

    step = step or 1
    local t = {}

    for i=from, till, step do
        t[#t+1] = i
    end

    return t
end

typeof = function (obj)
    assert(obj ~= nil, 'Object cannot be nil')
    local t = type(obj)

    if t == 'table' then
        local mt = getmetatable(obj)
        if mt and mt.__type then
            return mt.__type
        elseif mt and mt.__call then
            return 'callable'
        end
    end

    return t
end

isa = function (obj, k)
    return typeof(obj) == k
end

isa = isa

module_p = function (obj)
    assert(obj ~= nil, 'Object cannot be nil')
    local t = type(obj)

    if t == 'table' then
        return t.__name ~= nil
    end

    return false
end
class_p = module_p
is_class = class_p
is_module = module_p

to_stderr = function(s)
    vim.api.nvim_err_writeln(s)
end

system = function(cmd)
    return vim.fn.systemlist(cmd)
end

boolean_p = function(e)
    return type(e) == 'boolean'
end

bool_p = boolean_p
is_boolean = boolean_p
is_bool = boolean_p

nil_p = function (o)
    if o == nil then
        return true
    else
        return false
    end
end

is_nil = nil_p

false_p = function (o)
    if o == false then
        return true
    end

    return false
end

is_false = false_p

defined_p = function(o)
    if not nil_p(o) then
        return true
    else
        return false
    end
end

defined = defined_p
is_defined = defined

true_p = function (o)
    if not nil_p(o) and false_p(o) then
        return true
    else
        return false
    end
end

is_truthful = true_p
is_true = true_p

number_p = function (i)
    return type(i) == 'number'
end

num_p = function(i)
    return number_p(i)
end

is_number = number_p
is_num = num_p

table_p = function (t)
    return type(t) == 'table'
end
is_table = table_p
is_dict = table_p

func_p = function (f)
    return type(f) == 'function'
end
is_function = function_p
is_func = function_p
function_p = func_p

callable = function (f)
    if func_p(f) then
        return true
    end

    if not table_p(f) then
        return false
    end

    local mt = getmetatable(f)
    if mt and mt.__call then
        return true
    end
end

callable_p = callable
is_callable = callable

str_p = function (s)
    return type(s) == 'string'
end

string_p = str_p
is_string = str_p

to_list = function (i, force)
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

function class_name(obj)
    if not type(obj) == 'table' then
        return false
    end

    return mt_get(obj, '__name')
end

classname = class_name
cname = class_name
to_arr = to_list
to_a = to_arr

inspect = function (...)
    for _, value in ipairs({...}) do
        vim.api.nvim_echo({{vim.inspect(value)}}, false, {})
    end
end

dump = function (...)
    local dumped = {}

    for _, value in ipairs({...}) do
        dumped[#dumped+1] = type(value) == 'string' and value or vim.inspect(value)
    end

    dumped = table.concat(dumped, "\n"):gsub("\n$", '')

    return dumped
end

sprintf = function(fmt, ...)
    local args = {...}

    for index, val in ipairs(args) do
        if table_p(val) then
            args[index] = vim.inspect(val)
        end
    end

    return string.format(fmt, unpack(args))
end

printf = function(fmt, ...)
    print(sprintf(fmt, ...))
end

echo = function(fmt, ...)
    vim.api.nvim_echo({{sprintf(fmt, ...)}}, false, {})
end

-- File ops
slurp = function (src, iter)
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

spit = function (dst, s, mode)
    local fh = io.open(dst, mode or 'w')

    if fh then
        fh:write(s)
        fh:close()
        return true
    end
end

yspit = function (dst, data)
    spit(dst, yaml.dump(data))
end

yslurp = function (src)
    return yaml.load(slurp(src))
end

ydump = yaml.dump
yload = yaml.load

jdump = vim.fn.json_encode
jload = vim.fn.json_decode

jspit = function (dst, data)
    spit(dst, vim.fn.json_encode(data))
end

jslurp = function (dst)
    return vim.fn.json_decode(slurp(dst))
end

--
-- Misc
--
deepcopy = vim.deepcopy

-- Shallow copy
copy = function (src_t)
    local dst_t = {}

    local function copy_level(src, dst)
        for index, value in pairs(src) do
            if table_p(value) then
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

vcall = setmetatable({}, {
    __index = function (self, k)
        local f = self[k] or vim.fn[k] or partial(vim.call, k)

        if not self[k] then
            self[k] = f
        end

        return f
    end;
})

vcmd = function (fmt, ...)
    local out = vim.api.nvim_exec(sprintf(fmt, ...), true)
    if out == '' then return false end

    return out
end

join_path = function(...)
    return path(...)
end

join = table.concat

with_data_path = function (...)
    return path(vim.fn.stdpath('data'), ...)
end

with_config_path = function (...)
    return path(vim.fn.stdpath('config'), ...)
end

with_config_lua_path = function(...)
    return with_config_path('lua', ...)
end

with_user_config_path = function(...)
    return path(os.getenv('HOME'), '.vdoom.d', ...)
end

with_user_config_lua_path = function(...)
    return with_user_config_path('lua', ...)
end

with_stdpath = function (what, ...)
    return path(vim.fn.stdpath(what), ...)
end

with_packer_path = function(what, ...)
    return with_data_path('site', 'pack', 'packer', what, ...)
end

add_global = function(obj, name, force)
    if force then
        _G[name] = obj
    elseif not _G[name] then
        _G[name] = obj
    end

    return obj
end

globalize = function (mod, ks)
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

chomp = function(s)
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

tempfile = function()
    return os.tmpname()
end

with_open = function(dst, mode, f)
    mode = mode or 'r'
    local fh = io.open(dst, mode)

    if fh then
        local out = f(fh)
        fh:close()
        return out, dst
    end

    return false, dst
end

function with_tempfile(mode, f, keep)
    mode = mode or 'w'
    local tf = tempfile()
    local fh = io.open(tf, mode) 

    if fh then
        local out = f(fh)
        fh:close()

        if not keep then
            system('rm ' .. tf)
            return  out
        end

        out = out or false

        return out, tf
    end

    return false
end

-- @tparam timeout number Pass -1 to immediately return the result
function wait(f, args, opts)
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
gets = function(prompt, loop, ...)
    prompt = prompt or '%'
    prompt = prompt .. ' '
    local args = {...}
    local out = {}
    assert(#args > 0, 'No args provided')

    local function _get_input(t)
        assert(#t >= 1, 'No prompt question provided')

        local q, default_text, cb = unpack(to_list(t))
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
                assert(callable(cb), 'Invalid callback provided.')
                local is_correct = cb(input)
                if is_correct then 
                    if bool_p(is_correct) then
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

function len(obj)
    if type(obj) == 'string' then
        return #obj
    elseif type(obj) == 'table' then
        local c = 0
        for k, v in pairs(obj) do
            c = c + 1
        end

        return c
    end
end

length = len
size = len
