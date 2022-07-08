local class = require('modules.utils.class')
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
    self = self:delegate(m)
    self.value = s

    return self
end

local function unwrap(b)
    if type(b) == 'string' or type(b) == 'number' then
        return tostring(b)
    elseif type(b) == 'table' then
        if b.__name == 'string' then
            return b.value
        end
    else
        error('No string representation found for ' .. b)
    end
end

local function get_c(self, b)
    local m, n = type(self), type(b)
    if m == 'table' then return self, b end
    if n == 'table' then return b, self end
end

m.__mod = function (self, b)
    self, b = get_c(self, b)
    return str.new(strutils.sed(self.value, unwrap(b)))
end
m.__div = function (self, b)
    self, b = get_c(self, b)
    return vim.split(self.value, unwrap(b))
end
m.__pow = function (self, b)
    self, b = get_c(self, b)
    return str.new(strutils.match(self.value, unwrap(b)) or '')
end
m.__eq = function (self, b)
    self, b = get_c(self, b)
    return self.value == unwrap(b)
end
m.__tostring = function (self)
    return self.value
end
m.__ne = function (self, b)
    self, b = get_c(self, b)
    return not m.__eq(self, unwrap(b))
end
m.__concat = function (self, b)
    if type(self) == 'table' then
        return str.new(self.value .. unwrap(b))
    elseif type(b) == 'table' then
        return str.new(self .. unwrap(b)) 
    end
end
m.__add = function (self, b)
    return m.__concat(self, b)
end
m.__tostring = function (self)
    self, b = get_c(self, b)
    return self.value
end
m.__sub = m.__mod

return str
