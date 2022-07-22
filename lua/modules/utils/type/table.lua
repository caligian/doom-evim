local tu = require 'modules.utils.table'
local u = require 'modules.utils.common'
local module = require 'modules.utils.module'
local methods = {}
local hash = {}

local exclude = {
    to_dict = true,
    list_to_dict = true,
    arr_to_dict = true,
    _nth = true,
    _map = true,
    _filter = true,
    _each = true,
    _reduce = true,
    nth = true,
    map = true,
    filter = true,
    each = true,
    reduce = true,
    vec = true,
    range = true,
    to_callable = true
}

for k, v in pairs(tu) do
    if not exclude[k] then
        methods[k] = v
    end
end

methods.nth = tu.nth_
methods.map = tu.map_
methods.filter = tu.filter_
methods.each = tu.each_
methods.imap = tu.imap_
methods.reduce = tu.reduce_

function hash.new(t)
    local m = module.new('methods', {vars={value=t}})
    m:include(methods, 'value')
    m:on_operator('s', u.dump, 'value')
    m:on_operator('+', {tu.push, tu.unshift}, 'value')
    m:on_operator('-', {tu.pop, tu.shift}, 'value')
    m:on_operator('..', tu.extend, 'value')
    m:on_operator('^', methods.filter, 'value')
    m:on_operator('*', methods.map, 'value')
    m:on_operator('%', methods.assoc, 'value')
    return m
end

return hash
