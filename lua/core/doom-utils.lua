local Utils = {}
local Rx = require('rex_pcre2')
local Core = require('aniseed.core')
local Path = require('path')
local Fs = require('path.fs')
local Str = require('aniseed.string')
local Array = require('array')

function Utils.keys(t)
    local ks = {}

    for k, _ in pairs(t) do
        table.insert(ks, k)
    end

    return ks
end

function Utils.dump(...)
    for _, v in ipairs({...}) do
        print(vim.inspect(v))
    end
end

function Utils.vals(t, opts)
    local vs = {}
    local opts = opts or {}
    local _keys = opts.keys or false
    
    if _keys then
        for _, k in ipairs(_keys) do
            if t[k] then
                table.insert(vs, t[k])
            end
        end
    else
        for _, v in pairs(t) do
            table.insert(vs, v)
        end
    end

    return vs
end

function Utils.items(t)
    local ks = Utils.keys(t)
    local vs = Utils.vals(t, {keys = ks})
    local zipped = {}

    for i=1,#ks do
        local k = ks[i]
        local v = vs[i]

        if v then
            table.insert(zipped, {k, v})
        end
    end

    return zipped
end

-- Get user input according to prompts and hooking functions provided
-- prompts_hooks_t {table}
-- Format: {[ParamName] = {Prompt, function or boolean}}
-- if true is provided in place of [function] then assert(length([string]) != 0)
-- opts [table]
-- Keys:
-- loop [bool] If true, keep prompting until correct input is provided. Default: true
--
function Utils.getUserInput(prompts_hooks_t, opts)
    opts = opts or {}
    local all_responses = {}
    local collect = opts.collect or false
    local collectHook = opts.collectHook
    local iterator = ipairs
    local n = #(Utils.keys(prompts_hooks_t))

    if n == 0 and #prompts_hooks_t > 0 then
        iterator = ipairs
    elseif n > 0  then
        iterator = pairs
    else
        iterator = ipairs
        table.insert(prompts_hooks_t, {'%', true})
    end

    local function _getInput(varname, prompt, f, loop)
        loop = loop or false

        if f == false or f == nil then
            f = false
        else
            f = function (s)
                if #s > 0 then
                    return s
                else
                    return false
                end
            end
        end

        local input = vim.fn.input(prompt .. ' % ')
        local resp = false

        if f then
            resp = f(input)
        elseif #input > 0 then
            resp = input
        end

        if not resp or resp:match('EOF') then
            resp = false
        end

        if resp and collect then
            if not all_responses[varname] then
                all_responses[varname] = {}
            end
            table.insert(all_responses[varname], resp)

            if collectHook then
                collectHook(resp)
            end
        end

        if resp ~= false then
            all_responses[varname] = resp
        elseif loop and not resp then
            _getInput(varname, prompt, f, loop)
        end
    end

    for var, prompt_f in iterator(prompts_hooks_t) do
        _getInput(var, prompt_f[1], prompt_f[2], opts.loop)

        if type(all_responses[var]) == 'table' then
            all_responses[var] = table.concat(all_responses[var], "\n")
        end
    end

    return all_responses
end

function Utils.register(f, opts)
    opts = opts or {}

    if type(f) == 'string' then
        if opts.kbd then
            return string.format(":%s<CR>", f)
        else
            return string.format('%s', f)
        end
    elseif type(f) == 'function' then
        table.insert(Doom.lambdas, f)

        if opts.kbd then
            return string.format(':lua f = Doom.lambdas[%d]; f()<CR>', #Doom.lambdas)
        else
            return string.format('lua f = Doom.lambdas[%d]; f()', #Doom.lambdas)
        end
    end
end

function Utils.toList(e, force)
    force = force or false

    if force or not type(e) == 'table' then
        return {e}
    end

    return e
end

function Utils.exec(cmd, ...)
    vim.cmd(string.format(cmd, ...))
end

function Utils.considerOS(os_funcs)
    for os, e in pairs(os_funcs) do
        if vim.fn.has(os) == 1 then
            return e
        end
    end
end

function Utils.car(arr)
    return arr[1]
end

function Utils.last(arr)
    return arr[#arr]
end

function Utils.cdr(arr)
    return Array.slice(arr, 2, #arr)
end

function Utils.match(s, pattern)
    return Rx.match(s, pattern)
end

function Utils.grep(s, lua_pattern)
    return s:match(lua_pattern)
end

function Utils.withDataPath(...)
    return Path(vim.fn.stdpath('data'), ...)
end

function Utils.withConfigPath(...)
    return Path(vim.fn.stdpath('config'), ...)
end

-- Param at every odd number starting from 3 are substitution strings and
-- params at every even number are regex patterns
function Utils.sed(s, regex, str, ...)
    s, has_matched = string.gsub(s, regex, str)
    local args = {...}

    assert(#args % 2 == 0, 'Even number of args need to be passed as regex, string')

    if #args > 0 then
        for i=1,#args,2 do
            s = string.gsub(s, args[i], args[i+1])
        end
    end

    return s
end

function Utils.pcre2Sed(s, regex, str, ...)
    s, has_matched = Rx.gsub(s, regex, str)
    local args = {...}

    assert(#args % 2 == 0, 'Even number of args need to be passed as regex, string')

    if has_matched > 0 then
        if #args > 0 then
            for i=1,#args,2 do
                s = Rx.gsub(s, args[i], args[i+1])
            end
        end
    end

    return s
end

function Utils.matchSed(s, regex, str, ...)
    old_s = s
    s, has_matched = string.gsub(s, regex, str)
    local args = {...}

    assert(#args % 2 == 0, 'Even number of args need to be passed as regex, string')

    if has_matched == 0 then
        if #args > 0 then
            s = old_s

            for i=1,#args,2 do
                s = string.gsub(s, args[1], args[2])

                if s then
                    return s
                end
            end
        end
    else
        return s
    end
end

function Utils.matchPcre2Sed(s, regex, str, ...)
    old_s = s
    s, has_matched = Rx.gsub(s, regex, str)
    local args = {...}

    assert(#args % 2 == 0, 'Even number of args need to be passed as regex, string')


    if has_matched == 0 then
        if #args > 0 then
            s = old_s

            for i=1,#args,2 do
                s = Rx.gsub(s, args[i], args[i+1])

                if s then
                    return s
                end
            end
        end
    else
        return s
    end
end

return Utils
