local Kbd = {}
local Au =  require('doom-au')
local Str = require('aniseed.string')
local Utils = require('doom-utils')
local Wk = require('which-key')

function Kbd.registerKeybinding(opts)
    local is_leader = opts.leader or false
    local is_localleader = opts.localleader or false
    local keys = opts.keys
    local help = opts.help
    local first_key = string.sub(keys, 1, 1)
    local name = opts.name or 'Name'
    local wk_compat_t = {[first_key] = {name = name}}

    local idx = 1
    local t = nil
    for m in string.gmatch(keys, "([^ ])") do
        if idx > 1 then
            if not t then
                t = wk_compat_t[first_key]
            end

            t[m] = {}
            t = t[m]
        end

        idx = idx + 1
    end

    table.insert(t, help)

    if is_leader or is_localleader then
        if is_leader then
            Wk.register(wk_compat_t, {prefix = '<leader>'})
        else
            Wk.register(wk_compat_t, {prefix = '<localleader>'})
        end
    else
        Wk.register(wk_compat_t)
    end
end

function Kbd.new(...)
    local function _defineKeybinding(opts)
        local leader = opts.leader
        local noremap = opts.noremap or 'noremap'
        local attribs = opts.attribs or {'silent'}
        local mode = opts.mode or 'n'
        local keys = opts.keys
        local exec = opts.exec
        local event = opts.event
        local pattern = opts.pattern
        local name = opts.name

        if not leader then
            leader = ''
        elseif leader == 'l' then
            leader = '<leader>'
        elseif leader == 'll' then
            leader = '<localleader>'
        elseif leader then
            leader = '<leader>'
        end

        noremap = not noremap == false and not noremap and true or false
        if noremap then
            noremap = 'noremap'
        else
            noremap = 'map'
        end

        local modes = {}
        for m in string.gmatch(mode, "([^ ])") do
            table.insert(modes, m)
        end
        mode = modes
        
        if not attribs then
            attribs = '<silent>'
        else
            if type(attribs) == 'table' then
                local s = ''

                for _, i in ipairs(attribs) do
                    s = string.format('%s <%s>', s, i)
                end

                s = Str.trim(s)
                attribs = s
            end
        end

        exec = Utils.register(exec, {kbd = true})

        local kbdStrs = {}

        for _, i in ipairs(mode) do
            local s = string.format('%s%s %s %s%s %s', i, noremap, attribs, leader, keys, exec)
            table.insert(kbdStrs, s)
        end

        if event or pattern then
            event = event or 'BufEnter'
            pattern = pattern or '*'

            for _, i in ipairs(kbdStrs) do
                Au.autocmd('Global', event, pattern, i)
            end
        else
            for _, i in ipairs(kbdStrs) do
                vim.cmd(i)
            end
        end

        if opts.help then
            Kbd.registerKeybinding({
                help = opts.help,
                name = opts.name or 'Name',
                keys = keys,
                leader = (function()
                    if leader == '' then
                        return false
                    elseif leader == '<leader>' then
                        return true
                    else
                        return false
                    end
                end),
                localleader = (function()
                    if leader == '' then
                        return false
                    elseif leader == '<localleader>' then
                        return true
                    else
                        return false
                    end
                end),
            })
        end
    end

    for _, i in ipairs({...}) do
        _defineKeybinding(i)
    end
end

function Kbd.setup()
    for key, name in pairs(Doom.kbdNames.leader) do
        Wk.register({[key] = {name = name}}, {prefix = '<leader>'})

    end

    for key, name in pairs(Doom.kbdNames.localleader) do
        Wk.register({[key] = {name = name}}, {prefix = '<localleader>'})
    end
end

return Kbd
