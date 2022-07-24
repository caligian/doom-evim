local tu = require 'modules.utils.table'
local u = require 'modules.utils.common'
local module = require 'modules.utils.module'
local yaml = require 'yaml'
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

methods.to_list = function (t, force)
    if force then
        return {t}
    end
    return t
end

methods.nth = tu.nth_
methods.map = tu.map_
methods.filter = tu.filter_
methods.each = tu.each_
methods.imap = tu.imap_
methods.reduce = tu.reduce_

local function spit(m)
    return function (obj, dst)
        u[m](dst, obj)
    end
end

local function slurp(m)
    return function (obj, dst)
        return u[m](dst, obj)
    end
end

methods.yaml_dump = u.ydump
methods.ydump = u.ydump
methods.yaml_load = u.yload
methods.yload = u.yload
methods.yspit = spit('yspit')
methods.yslurp = slurp('yslurp')
methods.json_dump = u.jdump
methods.jdump = u.jdump
methods.json_load = u.jload
methods.jload = u.jload
methods.jspit = spit('jspit')
methods.jslurp = slurp('jslurp')

function hash.new(t)
    local m = module.new('hash', {vars={value=t}})
    m:include(methods, 'value')
    m:on_operator('s', u.dump, 'value')
    m:on_operator('+', {methods.push, methods.unshift}, 'value')
    m:on_operator('-', {methods.pop, methods.shift}, 'value')
    m:on_operator('..', methods.extend, 'value')
    m:on_operator('^', methods.filter, 'value')
    m:on_operator('*', methods.map, 'value')
    m:on_operator('%', methods.assoc, 'value')
    return m
end

return hash
