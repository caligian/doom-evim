local path = require('path')
local yaml = require('yaml')
local iter = require('modules.fun')
local utils = {}

utils.system = function(cmd)
    local out, t = false, {}

    if vimz then
        local out = vim.fn.system(cmd)
    else
        local fh = io.popen(cmd, 'r')
        out = fh:read('a')
        fh:close()
    end

    for index, s in ipairs(vim.split(out, "[\n\r]")) do
        t[index] = s
    end

    return t
end

utils.boolean_p = function(e)
    return type(e) == 'boolean'
end

utils.bool_p = utils.boolean_p

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

utils.defined = utils.defined_p

utils.true_p = function (o)
    if not utils.nil_p(o) and utils.false_p(o) then
        return true
    else
        return false
    end
end

utils.is_truthful = utils.true_p

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
utils.split = function(s, pat)
   if utils.str_p(s) then
       return vim.split(s, pat)
   else
       return s
   end
end

--
-- Function ops
--

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
utils.copy = vim.deepcopy

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
    return utils.system('mktemp')[1]
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
    assert(args, 'No args provided')

    args = args or {}
    opts = opts or {}
    local timeout = opts.timeout == nil and 10000 or opts.timeout
    local tries = opts.tries or 10
    local inc = opts.inc or 10
    local out = opts.default
    local sched = opts.sched == nil or false

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

return utils
