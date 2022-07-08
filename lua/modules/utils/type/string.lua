local class = require('modules.utils.class')
-- local class = dofile('../class.lua')
local strutils = require('modules.utils.string')
local common = require('modules.utils.type.common')

strutils.splice = strutils.strsplice
strutils.find = strutils.strfind
strutils.lfind = strutils.lstrfind

local m = {}
local str = {}

str.new = function (s)
    assert(s, 'No initial string provided')
    assert(type(s) == 'string', 'String provided is not a string')

    local self = class.new('string')
    self = self:delegate(strutils, 'value')
    self = self:delegate(m, 'value')
    self.value = s

    return self
end

m.__mod = function (s, b)
    return strutils.sed(s, b)
end
m.__div = function (s, b)
    return vim.split(s, b)
end
m.__pow = function (s, b)
    return strutils.match(s, b)
end
m.__eq = function (s, b)
    return s == b
end
m.__tostring = function (self)
    return s
end
m.__ne = function (s, b)
    return s ~= b
end
m.__concat = function (s, b)
    return s .. b
end
m.__add = function (s, b)
    return m.__concat(s, b)
end
m.__tostring = function (s)
    return s
end
m.__sub = m.__mod

return str
