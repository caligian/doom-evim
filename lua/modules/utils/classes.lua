local u = require('modules.utils')
local tu = u.deepcopy(require('modules.utils.table'))
local str = require('modules.utils.string')
local param = require('modules.utils.param')
local iter = require('fun')
local cls = {}

tu.compare = param.bfs_compare_table
tu.assert = param.bfs_assert_table
tu.assert_key = param.assert_key

local map = function (t, f, ...)  return tu.map(f, t, ...) end
local imap = function (t, f, ...) return tu.imap(f, t, ...) end
local filter = function (t, f) return tu.filter(f, t) end
local reduce = function (t, f, init) return tu.reduce(f, t, init) end
local each = function (t, f, ...) tu.each(f, t, ...) end
local nth = function (t, k, ...) return tu.nth(k, t, ...) end

cls.new_table = function (...)
    return setmetatable({...}, {
        __index = function (_, k)
            if k == 'nth' then
                return nth
            elseif k == 'nth' then
                return map
            elseif k == 'imap' then
                return imap
            elseif k == 'filter' then
                return filter
            elseif k == 'reduce' then
                return reduce
            elseif k == 'each' then
                return each
            elseif k == 'to_iter' then
                return iter.iter(_)
            elseif tu[k] then
                return tu[k]
            else
                error('Invalid method provided: ' .. k)
            end
        end;

        __name = 'doom-table';
    })
end

cls.new_string = function (s)
    assert(s)
    assert_s(s)

    return setmetatable({string=s}, {
        __index = function (_, k)
            if str[k] then
                return function (_, ...)
                    return str[k](s, ...)
                end
            else
                error('Invalid function name provided: ' .. k)
            end
        end;
        __name = 'doom-string';
    })
end

local a = cls.new_table(1,2,3,4)
local b = cls.new_table('a', 'b', 1, 2)
inspect(a:compare(b))

return cls
