local class = require('classy')
local u = require('modules.utils')
local tu = require('modules.utils.table')
local fu = require('modules.utils.function')
local regex = require('rex_pcre2')

local param = {}

function param.assert_boolean(b)
    assert(b == true or b == false, u.sprintf('Param `%s` is not a boolean', b))
end

param.assert_bool = param.assert_boolean
param.assert_b = param.assert_bool

function param.assert_s(s)
    if s ~= nil then
        assert(u.str_p(s), u.sprintf('Param `%s` is not a string', s))
    end
end

param.assert_string = param.assert_s
param.assert_str = param.assert_s

function param.assert_num(num)
    if num ~= nil then
        assert(u.num_p(num), u.sprintf('Param `%s` is not a number', num))
    end
end

param.assert_number = param.assert_num
param.assert_n = param.assert_num

function param.assert_t(t)
    if t ~= nil then
        assert(u.table_p(t), u.sprintf('Param `%s` is not a table', t))
    end
end

param.assert_h = param.assert_t
param.assert_table = param.assert_t

function param.assert_class(cls)
    if cls ~= nil then
        assert(class.of(cls), u.sprintf('Param `%s` is not a class', cls))
    end
end

param.assert_cls = param.assert_class

function param.assert_func(f)
    if f ~= nil then
        assert(u.func_p(f), u.sprintf('Param `%s` is not a function', f))
    end
end

function param.assert_callable(f)
    if f ~= nil then
        assert(u.callable(f), u.sprintf('Param `%s` is not a callable', f))
    end
end

function param.assert_type(param, ...)
    if param == nil then return end

    local fail = 0
    local t_param = type(param)
    local failed = {}

    local args = {...}
    local n = #args

    for _, i in ipairs(args) do
        if i == 'callable' then
            if not u.callable(param) then
                fail = fail + 1
                tu.push(failed, i)
            end
        elseif not match(i, '(table|boolean|string|number|function|userdata)') then
            local param_cls = class.of(param_cls)
            if not param_cls or not table_p(param_cls) or not param_cls.__name == i then
                fail = fail + 1
                tu.push(failed, i)
            end
        elseif t_param ~= i then
            fail = fail + 1
            tu.push(failed, i)
        end
    end

    assert(fail ~= n, dump(failed) .. string.format(' failed to match with param type `%s`', type(param)))
end

function param.assert_equal(a, b)
    assert(a == b, u.sprintf('Param `%s` is not equal to param `%s`', a, b))
end

function param.assert_type_equal(a, b)
    assert(type(a) == type(b), u.sprintf('Param `%s` is not equal to param `%s`', a, b))
end

param.assert_eql = param.assert_equal
param.assert_type_eql = param.assert_type_equal

function param.assert_class_equal(a, b)
    local cls_a = class.of(a)
    local cls_b = class.of(b)

    if cls_a and cls_b then 
        assert(cls_a == cls_b, u.sprintf("Class of `%s` is invalid. Given class: `%s`; Required class: `%s`", a, type(a), type(b)))
    end
end

param.assert_cls_equal = param.assert_class_equal
param.assert_cls_eql = param.assert_cls_eql

function param.compare_type(a, b)
    return type(a) == type(b)
end

function param.compare_class(a, b)
    local c, d = class.of(a), class.of(b)

    if c == nil or d == nil then return false end
    return c == d
end

param.compare_cls = param.compare_class

function param.assert_key(t, default, ...)
    param.assert_h(t)

    default = default == nil and false

    for _, k in ipairs({...}) do
        local no_key_err_msg = u.sprintf("Table %s does not have key %s with the required value", t, k)

        if default then
            no_key_err_msg = no_key_err_msg .. ': ' .. u.dump(default)
        end

        assert(t[k], no_key_err_msg)
    end
end

function param.dfs_compare_table(table_a, table_b, cmp)
    param.assert_h(table_a)
    param.assert_h(table_b)

    if cmp then param.assert_callable(cmp) end
    local new_t = {}
    local _new_t = new_t

    local function __compare(_table_a, _table_b)
        local later_ks = {}

        for _, k in ipairs(tu.intersection(tu.keys(_table_a), tu.keys(_table_b))) do
            local a = _table_a[k]
            local b = _table_b[k]
            local is_equal = param.compare_type(a, b)

            if u.table_p(a) and is_equal then
                if param.compare_cls(a, b) then
                    if cmp then
                        _new_t[k] = cmp(a, b)
                    else
                        _new_t[k] = a == b
                    end
                else
                    _new_t[k] = {}
                    _new_t = _new_t[k]
                    __compare(a, b, cmp)
                end
            elseif is_equal then
                if cmp then 
                    _new_t[k] = cmp(a, b)
                else
                    _new_t[k] = a == b
                end
            else
                _new_t[k] = false 
            end
        end
    end

    __compare(table_a, table_b)
    return new_t
end

function param.bfs_compare_table(table_a, table_b, cmp)
    param.assert_h(table_a)
    param.assert_h(table_b)
    param.assert_callable(cmp)

    local new_t = {}
    local _new_t = new_t

    local function __compare(_table_a, _table_b, _new_t)
        local later_ks = {}
        for _, k in ipairs(tu.intersection(tu.keys(_table_a), tu.keys(_table_b))) do
            local a = _table_a[k]
            local b = _table_b[k]
            local is_equal = param.compare_type(a, b)

            if u.table_p(a) and is_equal then
                if param.compare_cls(a, b) then
                    if cmp then
                        _new_t[k] = cmp(a, b)
                    else
                        _new_t[k] = a == b
                    end
                else
                    push(later_ks, k)
                end
            elseif is_equal then
                if cmp then 
                    _new_t[k] = cmp(a, b)
                else
                    _new_t[k] = a == b
                end
            else
                _new_t[k] = false 
            end
        end

        for _, k in ipairs(later_ks) do
            _new_t[k] = {}
            __compare(_table_a[k], _table_b[k], _new_t[k])
        end
    end

    __compare(table_a, table_b, _new_t)
    return new_t
end

function param.bfs_assert_table(table_a, table_b, use_value)
    param.assert_h(table_a)
    param.assert_h(table_b)

    local function __compare(_table_a, _table_b)
        local later_ks = {}
        for _, k in ipairs(tu.intersection(tu.keys(_table_a), tu.keys(_table_b))) do
            local a = _table_a[k]
            local b = _table_b[k]
            param.assert_type_equal(a, b)

            if u.table_p(a) then
                if class.of(a) and class.of(b) then
                    param.assert_class_equal(a, b)

                    if use_value then
                        param.assert_key(_table_a, k, b)
                    end
                else
                    push(later_ks, k)
                end
            elseif use_value then
                param.assert_key(_table_a, k, b)
            end
        end

        for _, k in ipairs(later_ks) do
            __compare(_table_a[k], _table_b[k])
        end
    end

    __compare(table_a, table_b)
end

function param.dfs_assert_table(table_a, table_b, use_value)
    param.assert_h(table_a)
    param.assert_h(table_b)

    use_value = use_value == nil and true or false

    local function __compare(_table_a, _table_b)
        for _, k in ipairs(tu.intersection(tu.keys(_table_a), tu.keys(_table_b))) do
            local a = _table_a[k]
            local b = _table_b[k]
            assert(param.compare_type(a, b))

            if u.table_p(a) then
                if class.of(a) and class.of(b) then
                    param.assert_class_equal(a, b)

                    if use_value then
                        param.assert_key(_table_a, k, b)
                    end
                else
                    __compare(_table_a[k], _table_b[k])
                end
            elseif use_value then
                param.assert_key(_table_a, k, b)
            end
        end
    end

    __compare(table_a, table_b)
end

param.assert_table = param.bfs_assert_table

function param.bfs_compare(a, b, cmp)
    if not param.compare_type(a, b) then
        return false
    elseif not param.compare_cls(a, b) then
        return false
    elseif u.table_p(a) then
        return param.bfs_compare_table(a, b, cmp)
    end

    return a == b
end

function param.dfs_compare(a, b, cmp)
    if not param.compare_type(a, b) then
        return false
    elseif not param.compare_cls(a, b) then
        return false
    elseif u.table_p(a) then
        return param.dfs_compare_table(a, b, cmp)
    end

    return a == b
end

param.compare = param.bfs_compare

return param
