-- local class = require('modules.utils.class')
local class = dofile('../class.lua')
local tu = require('modules.utils.table')
local param = require('modules.utils.param')
local common = require('modules.utils.type.common')

local m = {}
local tbl = {}
function tbl.new(t)
    t = t or {}

    local self = class.new('table', {value=t})
    self:delegate(common, m, 'value')

    return self
end

local exclude = {
    map = true;
    filter = true;
    imap = true;
    reduce = true;
    each = true;
    nth = true;
}

for key, value in pairs(tu) do
    if not exclude[key] then
        tbl[key] = value
    end
end

m.compare = param.bfs_compare_table
m.assert = param.bfs_assert_table
m.assert_key = param.assert_key
m.map = function (t, f, ...)  return tu.map(f, t, ...) end
m.imap = function (t, f, ...) return tu.imap(f, t, ...) end
m.filter = function (t, f) return tu.filter(f, t) end
m.reduce = function (t, f, init) return tu.reduce(f, t, init) end
m.each = function (t, f, ...) tu.each(f, t, ...) end
m.nth = function (t, k, ...) return tu.nth(k, t, ...) end

m.__add = function(t, b)
    tu.push(t, b)
end

m.__concat = function(t, b)
    local m, n = type(t) == 'table', type(b) == 'table'
    if m then
        return tu.extend(t, b)
    end
    return tu.lextend(b, t)
end
m.__div = tu.partition
-- m.__tostring = vim.inspect
m.__pow = tu.get
m.__mul = function (t, n)
    assert(type(n) == 'number', 'Need a number')
    assert(n >= 0, 'N should be greater than equal to zero')

    if n == 0 then
        return {}
    elseif n == 1 then
        return t
    end

    local len = #t
    for i = 1, n-1 do
        for j = 1, len do
            t[#t+1] = t[j]
        end
    end

    return t
end
m.__sub = tu.remove

return tbl
