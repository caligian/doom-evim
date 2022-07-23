local tu = require 'modules.utils.table'
local pu = require 'modules.utils.param'
local su = require 'modules.utils.string'
local regex = require 'rex_pcre2'
local u = require 'modules.utils.common'
local module = require 'modules.utils.module'
local yaml = require 'yaml'
local methods = {}
local str = {}
local exclude = {
    to_dict = true,
    list_to_dict = true,
    arr_to_dict = true,

    nth_ = true,
    map_ = true,
    imap_ = true,
    filter_ = true,
    each_ = true,
    reduce_ = true,

    nth = true,
    map = true,
    imap = true,
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

for k, v in pairs(methods) do
    if not k:match('split_pattern') then
        methods[k] = function (obj, ...)
            obj = vim.split(obj.value, obj.split_pattern)
            local out_t = v(obj, ...)
            return table.concat(out_t, '')
        end
    end
end

function str.new(s, pat)
    local m = module.new('methods', {vars={value=s, split_pattern=''}})
    m:include(methods)
    m:include(su, 'value')
    m:on_operator('s', u.dump, 'value')
    m:on_operator('+', {methods.push, methods.unshift})
    m:on_operator('^', methods.filter)
    m:on_operator('*', methods.map)

    local sed = function (a, b)
        return su.sed(a, {b, '', 1})
    end

    m:on_operator('-', {sed, function (obj, s)
        return sed(s, obj)
    end}, 'value')

    m:on_operator('%', function (obj, t)
        obj = table.concat(vim.split(obj.value, ''), '')
        return su.sed(obj, t)
    end, 'value')
    return m
end

return str
