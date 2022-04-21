local Au = {}
local Utils = require('doom-utils')

function Au.autocmdStr(name, event, pattern, exec)
    if not name then
        name = 'Global'
    end

    if not event then
        event = 'BufEnter'
    end

    if not pattern then
        pattern = '*'
    end

    exec = Utils.register(exec)

    local s =  string.format('autocmd %s %s %s %s', name, event, pattern, exec)
    return s
end

function Au.autocmd(name, event, pattern, exec)
    if not Doom.autocmds then
        Doom.autocmds = {}
    end

    if not Doom.augroups then
        Doom.augroups = {}
    end

    if name then
        if not Doom.augroups[name] then
            Doom.augroups[name] = true
            vim.cmd(string.format("augroup %s\n    autocmd!\naugroup END", name))
        end
    end

    local s = Au.autocmdStr(name, event, pattern, exec)
    table.insert(Doom.autocmds, s)
    vim.cmd(s)
end

function Au.autocmdStrs(...)
    local t = {}

    for _, i in ipairs({...}) do
        table.insert(t, Au.autocmdStr(unpack(i)))
    end

    return t
end

function Au.autocmds(...)
    for _, opt in ipairs({...}) do
        Au.autocmd(unpack(opt))
    end
end

return Au
