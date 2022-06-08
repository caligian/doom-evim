local class = require('classy')
local u = require('modules.utils')
local tu = require('modules.utils.table')
local param = class('doom-param-utils')

local function get_assert_string()
end

function param.assert_s(s)
    assert(u.str_p(s), u.sprintf('Param `%s` is not a string', s))
end

param.assert_string = param.assert_s
param.assert_str = param.assert_s

function param.assert_num(num)
    assert(u.num_p(num), u.sprintf('Param `%s` is not a number', num))
end

param.assert_number = param.assert_num

function param.assert_t(t)
    assert(u.table_p(t), u.sprintf('Param `%s` is not a table', t))
end

param.assert_h = param.assert_t
param.assert_table = param.assert_t

function param.assert_class(cls)
    assert(class.of(cls), u.sprintf('Param `%s` is not a class', cls))
end

param.assert_cls = param.assert_class

function param.assert_func(f)
    assert(u.func_p(f), u.sprintf('Param `%s` is not a function', f))
end

function param.assert_callable(f)
    assert(u.callable(f), u.sprintf('Param `%s` is not a callable', f))
end

function param.assert_type(param, _type)
    assert(type(param) == _type, u.sprintf('Param `%s` is not of type %s', param, _type))
end

function param.assert_equal(a, b)
    assert(a == b, u.sprintf('Param `%s` is not equal to param `%s`', a, b))
end

param.assert_eql = param.assert_equal

-- @tparam params table Form: param_name = param
function param.assert_types(params, _type)
    param.assert_table(params)

    for _, param in ipairs(params) do
        assert(type(param) == _type, u.sprintf('Param `%s` is not of type %s', param, _type))
    end
end

function param.compare_type(a, b)
    return type(a) == type(b)
end

function param.compare_class(a, b)
    local c, d = class.of(a), class.of(b)

    if c == nil or d == nil then return false end
    return c == d
end

param.compare_cls = param.compare_class

function param.assert_key(t, ...)
    for _, k in ipairs({...}) do
        assert(t[k], u.sprintf('Table %s does not has key %s', t, k))
    end
end

function param.dfs_compare_table(table_a, table_b, cmp)
    param.assert_h(table_a, 'table_1')
    param.assert_h(table_b, 'table_2')
    if cmp then param.assert_callable(cmp, 'comparison_function') end

    local function __compare(_table_a, _table_b)
        local later_ks = {}

        for _, k in ipairs(tu.intersection(tu.keys(_table_a), tu.keys(_table_b))) do
            local a = _table_a[k]
            local b = _table_b[k]
            local is_equal = param.compare_type(a, b)

            if u.table_p(a) and is_equal then
                if param.compare_cls(a, b) then
                    a[k] = a == b
                else
                    __compare(a, b, cmp)
                end
            elseif is_equal then
                if cmp then 
                    _table_a = cmp(a, b)
                else
                    _table_a[k] = a == b
                end
            else
                _table_a[k] = false 
            end
        end
    end

    local _table_a, _table_b = u.copy(table_a), u.copy(table_b)
    __compare(_table_a, _table_b)
    return _table_a
end

function param.bfs_compare_table(table_a, table_b, cmp)
    param.assert_h(table_a, 'table_1')
    param.assert_h(table_b, 'table_2')
    if cmp then param.assert_callable(cmp, 'comparison_function') end

    local function __compare(_table_a, _table_b)
        local later_ks = {}
        for _, k in ipairs(tu.intersection(tu.keys(_table_a), tu.keys(_table_b))) do
            local a = _table_a[k]
            local b = _table_b[k]
            local is_equal = param.compare_type(a, b)

            if u.table_p(a) and is_equal then
                if param.compare_cls(a, b) then
                    a[k] = a == b
                else
                    push(later_ks, k)
                end
            elseif is_equal then
                if cmp then 
                    _table_a = cmp(a, b)
                else
                    _table_a[k] = a == b
                end
            else
                _table_a[k] = false 
            end
        end

        for _, k in ipairs(later_ks) do
            __compare(_table_a[k], _table_b[k])
        end
    end

    local _table_a, _table_b = u.copy(table_a), u.copy(table_b)
    __compare(_table_a, _table_b)
    return _table_a
end

function param.bfs_assert_table(table_a, table_b, cmp, use_value)
    param.assert_h(table_a)
    param.assert_h(table_b)

    use_value = use_value == nil and true or false

    local function __compare(_table_a, _table_b)
        local later_ks = {}
        for _, k in ipairs(tu.intersection(tu.keys(_table_a), tu.keys(_table_b))) do
            local a = _table_a[k]
            local b = _table_b[k]
            assert(param.compare_type(a, b), u.sprintf('Param at key %s (%s) in table `%s`  is invalid. Required param type: %s', k, a, _table_a, type(b)))

            if u.table_p(a) then
                if class.of(a) and class.of(b) then
                    assert(param.compare_cls(a, b), u.sprintf('Param at key %s (%s) in table `%s`  is invalid. Required class: %s', k, a, _table_a, type(b)))

                    if use_value then
                        assert(a == b, u.sprintf('Param at key %s (%s) in table `%s`  is invalid. Required param: %s', k, a, _table_a, b))
                    end
                else
                    push(later_ks, k)
                end
            elseif use_value then
                assert(a == b, u.sprintf('Param at key %s (%s) in table `%s`  is invalid. Required param: %s', k, a, _table_a, b))
            end
        end

        for _, k in ipairs(later_ks) do
            __compare(_table_a[k], _table_b[k])
        end
    end

    __compare(table_a, table_b)
end

function param.dfs_assert_table(table_a, table_b, cmp)
    param.assert_h(table_a, 'table_1')
    param.assert_h(table_b, 'table_2')

    local function __compare(_table_a, _table_b)
        for _, k in ipairs(tu.intersection(tu.keys(_table_a), tu.keys(_table_b))) do
            local a = _table_a[k]
            local b = _table_b[k]
            assert(param.compare_type(a, b), u.sprintf('Param at key %s (%s) in table `%s` is invalid. Required param type: %s', k, a, _table_a, type(b)))

            if u.table_p(a) then
                if class.of(a) and class.of(b) then
                    assert(param.compare_cls(a, b), u.sprintf('Param at key %s (%s) in table `%s` have different classes. Required param class: %s', k, a, _table_a, class.of(b)))

                    if use_value then
                        assert(a == b, u.sprintf('Param at key %s (%s) in table `%s` is invalid. Required param: %s', k, a, _table_a, b))
                    end
                else
                    __compare(a, b)
                end
            elseif use_value then
                assert(a == b, u.sprintf('Param at key %s (%s) in table `%s` is invalid. Required param: %s', k, a, _table_a, b))
            end
        end
    end

    __compare(table_a, table_b)
end

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
