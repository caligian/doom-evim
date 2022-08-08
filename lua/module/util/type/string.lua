local tu = require 'modules.utils.table'
local pu = require 'modules.utils.param'
local su = require 'modules.utils.string'
local regex = require 'rex_pcre2'
local u = require 'modules.utils.common'
local module = require 'modules.utils.module'
local yaml = require 'yaml'
local M = {}
local str = {}

function str.new(s)
    s = s or ''
    pu.claim.string(s)

    local self = module.new('string', {
        vars = {
            value = s;
            split_pattern = ' +';
        };
    })

    self:include(su, 'value')
    self:include(tu, function (cls)
        return vim.split(cls.value, cls.split_pattern)
    end)
    self:on_operator('s', u.identity, 'value')

    return self
end

return str
