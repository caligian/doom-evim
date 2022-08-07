local tu = require 'modules.utils.table'
local u = require 'modules.utils.common'
local iter = require 'fun'
local module = require 'modules.utils.module'
local param = require 'modules.utils.param' 
local yaml = require 'yaml'
local hash = {}

function hash.new(t, it)
    if it then
        return tu.new_iter(t)
    end

    local mod = module.new('table', {vars={value=t}})
    mod:include(tu, 'value')
    mod:on_operator('+', {mod.push, mod.unshift})
    mod:on_operator('-', {mod.pop, mod.shift})
    mod:on_operator('..', {mod.extend, mod.lextend})
    mod:on_operator('^', {mod.filter, mod.filter})
    mod:on_operator('*', {mod.map, mod.map})
    mod:on_operator('%', {mod.assoc, mod.assoc})
    mod:on_operator('s', u.dump, 'value')

    return mod
end

return hash
