local u = require('modules.utils')
local tu = u.deepcopy(require('modules.utils.table'))
local str = require('modules.utils.string')
local param = require('modules.utils.param')
local iter = require('fun')
local cls = {}

tu.compare = param.bfs_compare_table
tu.assert = param.bfs_assert_table
tu.assert_key = param.assert_key

local fun = {}
fun.map = function (t, f, ...)  return tu.map(f, t, ...) end
fun.imap = function (t, f, ...) return tu.imap(f, t, ...) end
fun.filter = function (t, f) return tu.filter(f, t) end
fun.reduce = function (t, f, init) return tu.reduce(f, t, init) end
fun.each = function (t, f, ...) tu.each(f, t, ...) end
fun.nth = function (t, k, ...) return tu.nth(k, t, ...) end

cls.new_table = function (...)
    return setmetatable({...}, {
        __index = function (_, k)
            if fun[k] then
                return fun[k]
            elseif table[k] then
                return table[k]
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
            local f =  str[k] or string[k] or false

            if f then
                return function (_, ...)
                    return f(s, ...)
                end
            else
                error('Invalid function name provided: ' .. k)
            end
        end;
        __name = 'doom-string';
    })
end

return cls
