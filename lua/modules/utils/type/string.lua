local class = dofile('../class.lua')
local strutils = dofile('../string.lua')
local common = dofile('common.lua')

strutils.splice = strutils.strsplice
strutils.find = strutils.strfind
strutils.lfind = strutils.lstrfind

local str = {}
str.new = function (s)
    assert(s, 'No initial string provided')
    assert(type(s) == 'string', 'String provided is not a string')

    local self = class.new('string')
    class.delegate(self, strutils, 'value')
    class.delegate(self, common, 'value')
    self.value = s

    return self
end

return str
