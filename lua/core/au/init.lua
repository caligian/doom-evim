local auu = require('core.au.utils')
local ex = require('core.au.exception')
local autocmd = require 'core.au.autocmd'
local au = auu
local m = {}

function au.new(name, doc)
    claim.opt_string(name)
    claim.string(doc)

    if not name then
        name = sprintf('doom_group_%d', len(au.status) + 1)
    else
        name = name:gsub('[^%w_]+', '')
    end

    if Doom.au.status[name] then
        if Doom.au.status[name].__vars then
            return Doom.au.status(name) 
        end
    end

    local self = module.new('augroup', {
        vars = {
            name = name;
            doc = doc;
            autocmds = {};
        }
    })

    self:include(m)
    return self
end

function m:add(event, pattern, callback, opts)
    claim(event, 'table', 'string')
    claim(pattern, 'table', 'string')
    claim.opt_table(opts)
    claim.callable(callback)

    event = to_list(event)
    pattern = to_list(pattern)

    each(function(p)
        each(function (e)
            local aucmd = autocmd.new(self.name, e, p, callback, opts)
            assoc(self.autocmds, aucmd.name, aucmd)
        end, event)
    end, pattern)

    return self
end

function m:disable(regex, force)
    claim.opt_string(regex)
    regex = regex or '.*'

    force = force or false

    for _, aucmd in pairs(self.autocmds) do
        aucmd:disable(force)
    end

    return self
end

function m:enable(regex, force)
    claim.opt_string(regex)
    regex = regex or '.*'

    force = force or false

    for _, aucmd in pairs(self.autocmds) do
        aucmd:enable(force)
    end

    return self
end

return au
