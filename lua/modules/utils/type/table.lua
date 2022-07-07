local class = require('modules.utils.class')
local tu = require('modules.utils.table')
local param = require('modules.utils.param')
local common = require('modules.utils.type.common')

local tbl = {}
tbl.compare = param.bfs_compare_table
tbl.assert_ = param.bfs_assert_table
tbl.assert_key = param.assert_key
tbl.map = function (t, f, ...)  return tu.map(f, t, ...) end
tbl.imap = function (t, f, ...) return tu.imap(f, t, ...) end
tbl.filter = function (t, f) return tu.filter(f, t) end
tbl.reduce = function (t, f, init) return tu.reduce(f, t, init) end
tbl.each = function (t, f, ...) tu.each(f, t, ...) end
tbl.nth = function (t, k, ...) return tu.nth(k, t, ...) end

function tbl.new(t)
    t = t or {}

    local self = class.new('table')
    self.value = t
    class.delegate(self, tu, 'value')
    class.delegate(self, common, 'value')

    return self
end

return tbl
