local class = require('classy')
local au = class('doom-augroup')

au.status = Doom.au.status
au.refs = Doom.au.refs

function au.func2str(f)
    if type(f) == 'string' then
        return f
    elseif type(f) == 'function' then
        local idx = #(keys(Au.status))
        return string.format('lua Doom.au.refs[%d]()', idx+1)
    end
end

function au:__init(name, doc)
    self.name = name
    self.doc = doc
    self.autocmds = {}

    if not self.name then
        self.name = sprintf('doom_group_%d', #self.refs + 1)
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
    event = event or 'BufEnter'
    f = au.func2str(f)
    push(self.refs, f)

    local es = vim.split(e, '%s*,%s*')
    local ep = vim.split(p, '%s*,%s*')
    f = au.func2ref(f)

    if opts.once then
        f = sprintf('++once %d', f)
    end

    if opts.nested then
        f = sprintf('++nested %d', f)
    end

    map(function(_e) 
        map(function(_p)
            local aucmd = sprintf('autocmd %s %s %s %s', self.name, _e, _p, f)
            local au_name = sprintf('%s::%s', _p, _e)
            self.autocmds[name] = au_name
        end, ps)
    end, es)
    
    return self.autocmds
end
