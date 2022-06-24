local class = require('classy')
local ex = require('core.au.exception')
local au = class('doom-augroup')

au.status = Doom.au.status
au.refs = Doom.au.refs

function au.func2ref(f, style)
    assert(f, ex.no_f())

    assert_type(f, 'string', 'callable')
    assert_s(style)

    style = style or 'call'

    if str_p(f) then
        return f
    else
        if match(style, 'index') then
            return #au.refs
        elseif match(style, 'key') then
            return sprintf(':lua Doom.au.refs[%d]()<CR>', #au.refs)
        elseif match(style, 'call') then
            return sprintf(':lua Doom.au.refs[%d]()', #au.refs)
        else
            return sprintf('Doom.au.refs[%d]', #au.refs)
        end
    end
end

function au.register(f, style)
    if callable(f) then push(au.refs, f) end
    return au.func2ref(f, style)
end

function au:__init(name, doc)
    self.name = name
    self.doc = doc
    self.autocmds = {}
end

function au.new(name, doc)
    assert_type(name, 'boolean', 'string')
    assert(doc, 'No documentation provided for augroup')
    assert_s(doc)

    if name == false then
        name = sprintf('doom_group_%d', len(au.status) + 1)
    else
        name = name:gsub('[^%w_]+', '')
    end

    local self = false
    if au.status[name] then
        return au.status(name) 
    end

    return au(name, doc)
end

--[[
Add an autocmd to augroup
@tparam[opt='BufEnter'] event string Event name
@tparam pat string Pattern to match
@tparam f function|string Callback
@tparam opts table
@table opts
@field once[opt=false] Run the autocmd only once
@field nested[opt=false] Autocmd has other autocmd definitions embedded in it.

@treturns table Containing autocmd strings
--]]
function au:add(event, pat, f, opts)
    assert(pat, ex.no_pat())
    assert(f, ex.no_f())

    assert_t(opts)
    assert_type(event, 'string', 'table')
    assert_type(pat, 'string', 'table')

    opts = opts or {}
    event = event or 'BufEnter'
    f = au.register(f)
    pat = to_list(pat)
    event = to_list(event)
    local once = opts.once == nil and '' or '++once'
    local nested = opts.nested == nil and '' or '++nested'

    map(function(_e) 
        map(function(_p)
            local aucmd = sprintf('autocmd %s %s %s %s %s %s', self.name, _e, _p, once, nested, f)
            local au_name = sprintf('%s::%s', _p, _e)
            local t = self.autocmds[au_name]

            if not t then
                self.autocmds[au_name] = {aucmd, enabled=false}
            end
        end, pat)
    end, event)

    return self.autocmds
end

function au:enable(event, regex_or_pat)
    if not self.status[self.name] then
        vim.cmd("augroup " .. self.name .. "\n    autocmd!\naugroup END")
        self.status[self.name] = self
    end

    if not regex_or_pat and not event then
        for _, value in pairs(self.autocmds) do
            if not value.enabled then
                vim.cmd(first(value))
                value.enabled = true
            end
        end
    elseif not event then
        for k, v in pairs(self.autocmds) do
            -- This will match against aupat::auevent in self.autocmds
            if k:match(regex_or_pat) then
                if not v.enabled then
                    vim.cmd(v)
                    v.enabled = true
                end
            end
        end
    else
        local au = regex_or_pat .. '::' .. event

        if self.autocmds[au] and not self.autocmds[au].enabled then
            vim.cmd(first(self.autocmds[au]))
            self.autocmds[au].enabled = true
        end
    end
end

function au:disable(pat, event)
    if pat and event then
        local k = sprintf('%s::%s', pat, event)

        if self.autocmds[k] and self.autocmds[k].enabled then
            self.autocmds[k].enabled = false
            pcall(function()
                vim.cmd(sprintf('autocmd! %s %s %s', self.name, event, pat))
            end)
        end
    elseif pat then
        for aupat, value in pairs(self.autocmds) do
            if aupat:match(pat) and value.enabled then
                value.enabled = false
            end
        end
        pcall(function()
            vim.cmd(sprintf('autocmd! %s * %s', self.name, pat))
        end)
    elseif event then
        for auevent, value in pairs(self.autocmds) do
            if auevent:match(event) then
                value.enabled = false
            end
        end
        pcall(function ()
            vim.cmd(sprintf('autocmd! %s %s', self.name, event))
        end)
    else
        for auevent, value in pairs(self.autocmds) do
            value.enabled = false
        end
        pcall(function()
            vim.cmd(sprintf('autocmd! %s', self.name))
        end)
    end
end

return au
