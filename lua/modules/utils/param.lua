local class = require('classy')
local u = require('modules.utils')
local tu = require('modules.utils.table')
local param = class('doom-param-utils')

function param.validate(dict_a, dict_b, set_default, literal_func)
    assert(u.table_p(dict_a), 'dict_a should be a table')
    assert(u.table_p(dict_b), 'dict_b should be a table')

    set_default = set_default ~= false and set_default or false
    literal_func = literal_func == nil and false

    local function _cmp_level(a, b)
        if type(a) ~= type(b) then
            return false
        elseif not u.table_p(a) then
            return a == b
        else
            for _, k in ipairs(tu.intersection(keys(a), keys(b))) do
                local v1 = a[k]
                local v2 = b[k]
                local is_valid = false

                if type(v1) ~= type(v2) then
                    if not set_default then
                        a[k] = false
                    elseif u.callable(set_default) then
                        a[k] = set_default(v1)
                    end
                elseif type(v1) == 'table' then
                    _cmp_level(v1, v2)
                elseif u.func_p(v2) and not literal_func then
                    is_valid = v2(v1)
                elseif v1 ~= v2 and set_default then
                    if u.callable(set_default) then
                        a[k] = set_default(v1)
                    end
                else
                    a[k] = v1 == v2
                end
            end
        end
    end

    local a = copy(dict_a)
    local b = copy(dict_b)

    _cmp_level(a, b)

    return a
end

return param
