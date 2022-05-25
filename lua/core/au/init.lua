local class = require('classy')
local au = class('doom-augroup')

au.status = Doom.au.status
au.refs = Doom.au.refs

function au.func2ref(f)
    if type(f) == 'string' then
        return f
    elseif type(f) == 'function' then
        local idx = #au.refs + 1
        return string.format('lua Doom.au.refs[%d]()', idx)
    end
end

function au:__init(name, doc)
    self.name = name
    self.doc = doc
    self.autocmds = {}

    if not self.name then
        self.name = sprintf('doom_group_%d', len(au.status) + 1)
    end
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
    opts = opts or {}
    event = event or 'BufEnter'
    local _f = au.func2ref(f); push(au.refs, f)
    pat = to_list(pat)
    event = to_list(event)

    if opts.once then
        _f = sprintf('++once %d', _f)
    end

    if opts.nested then
        _f = sprintf('++nested %d', _f)
    end

    map(function(_e) 
        map(function(_p)
            local aucmd = sprintf('autocmd %s %s %s %s', self.name, _e, _p, _f)
            local au_name = sprintf('%s::%s', _p, _e)
            self.autocmds[au_name] = {aucmd, enabled=false}
        end, pat)
    end, event)

    return self.autocmds
end

function au:enable(regex_or_pat, event)
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
            vim.cmd(self.autocmds[au])
            self.autocmds[au].enabled = true
        end
    end
end

function au:disable(pat, event)
    if pat and event then
        local k = sprintf('pat::event', pat, event)

        if self.autocmds[k] and self.autocmds[k].enabled then
            self.autocmds[k].enabled = false
            vim.cmd(sprintf('autocmd! %s %s %s', self.name, event, pat))
        end
    elseif pat then
        for aupat, value in pairs(self.autocmds) do
            if aupat:match(pat) and value.enabled then
                value.enabled = false
                vim.cmd(sprintf('autocmd! %s * %s', self.name, pat))
            end
        end
    elseif event then
        for auevent, value in pairs(self.autocmds) do
            if auevent:match(event) then
                value.enabled = false
            end
        end
        vim.cmd(sprintf('autocmd! %s %s', self.name, event))
    else
        for auevent, value in pairs(self.autocmds) do
            value.enabled = false
        end
        vim.cmd(sprintf('autocmd! %s', self.name))
    end
end

return au
