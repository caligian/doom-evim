local ex = require('core.au.exception')
local autocmd = require 'core.au.autocmd'
local au = require('core.au.utils')
local m = {}

assoc(Doom, {'au', 'status'}, create_status_t {})

-- @module au
-- Augroup module 
-- Use this module to create augroup consisting of `autocmd' objects.
-- All the augroups will be saved in the global variable `Doom.au.status`. They will be indexed by augroup names.

-- @function new
-- @tparam[opt=true] name string If boolean then create a random doom augroup
-- @tparam doc string Description
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
            return Doom.au.status[name] 
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

-- @function add
-- @tparam event string,table[string] Vim events to bind a callback to. Use `:h events` to get an overview on what vim events are.
-- @tparam pattern string,table[string] File patterns to match for calling the callback
-- @tparam table opts Table containing other options
-- @table opts
-- @field once boolean Call the callback once and then disable autocmd
-- @field nested boolean Whether autocmds contain nested declarations of autocmds
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
            local name = e .. ' ' .. p
            update(self.autocmds, name, aucmd)
            force = force or false
        end, event)
    end, pattern)

    return self
end

function m:enable(regex, force)
    regex = regex or '.*'
    force = force or false

    for name, aucmd in pairs(self.autocmds) do
        if match(name, regex) then
            aucmd:enable(force)
        end
    end

    return self
end

function m:disable(regex, force)
    regex = regex or '.*'
    force = force or false

    for _, aucmd in pairs(self.autocmds) do
        aucmd:disable(force)
    end

    return self
end

return au
