local class = require('classy')
local u = require('modules.utils.common')
local tu = require('modules.utils.table')
local param = {}

local claim = function (test, msg)
    assert(test ~= nil)

    if type(test) == 'function' then
        assert(test(), msg)
    else
        assert(test, msg)
    end
end

param.claim = {
    ['function'] = function (obj)
        claim(type(obj) == 'function', 'Object is not a function: ' .. u.dump(obj))
    end;

    number = function (obj)
        claim(type(obj) == 'number', 'Object is not a number: ' .. u.dump(obj))
    end,

    boolean = function (obj)
        claim(type(obj) == 'boolean', 'Object is not a boolean: ' .. u.dump(obj))
    end,

    table = function (obj)
        claim(type(obj) == 'table', 'Object is not a table: ' .. u.dump(obj))
    end,

    userdata = function (obj)
        claim(type(obj) == 'userdata', 'Object is not userdata: ' .. u.dump(obj))
    end,

    callable = function (obj)
        claim(function ()
            if type(obj) ~= 'table' and type(obj) ~= 'function' then
                return false
            end

            if type(obj) == 'table' then
                local mt = getmetatable(obj)
                if mt and mt.__call then
                    return true
                end
                return false
            end

            return true
        end, 'Object is not a callable: ' .. u.dump(obj))
    end,

    string = function (obj)
        claim(function ()
            return type(obj) == 'string'
        end, 'Object is not a string: ' .. u.dump(obj))
    end,
}

local function post_indexing(k, obj, validator)
    local is_opt = false
    if k:match('^opt_') then
        is_opt = true
        k = k:gsub('^opt_', '')
    end

    if is_opt and obj == nil then
        return
    end

    if param.claim[k] and not validator then
        return rawget(param.claim, k)(obj)
    end

    if not type(obj) == 'table' then
        error("Object provided is not a module/class table and not a primitive datatype either: " .. u.dump(obj))
    end

    if not validator then
        local mt = getmetatable(obj)
        if not mt then
            error("Object is a table but does have a metatable defined: " .. u.dump(obj))
        end

        if not mt.__name == k then
            error("Object is not of type: " .. k)
        end
    else
        param.claim.callable(validator)
        claim(function() return validator(obj) end, 'Object validator returned false for object: ' .. u.dump(obj))
    end

    return obj
end

param.claim = setmetatable(param.claim, {
    __newindex = function (self, k, validator)
        rawset(self, k, function (obj)
            return post_indexing(k, obj, validator)
        end)
    end;

    __index = function (self, k)
        return function (obj, validator)
            return post_indexing(k, obj, validator)
        end
    end;

    __call = function (self, obj, ...)
        local args = {...}
        local n = #args
        local failed = 0

        claim(n > 0, 'No objects provided for type checking')

        for _, k in ipairs({...}) do
            local cls = rawget(self, k)
            claim(cls ~= nil, 'Invalid datatype provided: ' .. k)
            local success = pcall(cls, obj)
            if not success then
                failed = failed + 1
            else
                break
            end
        end

        if n == failed then
            error('Could not match any datatype for object: ' .. u.dump(obj))
        end
    end
})

for k, v in pairs(param.claim) do
    param['claim_' .. k] = v
end

param.claim_s = param.claim_string
param.claim_str = param.claim_string
param.claim_b = param.claim_boolean
param.claim_bool = param.claim_boolean
param.claim_h = param.claim_table
param.claim_t = param.claim_table
param.claim_hash = param.claim_hash

function param.typeof(obj)
    local t = type(obj)

    if t == 'table' then
        local mt = getmetatable(t)
        if mt then
            if not mt.__name then return 'table' end
            return mt.__name
        end
    else
        return t
    end
end

function param.claim_equal(a, b)
    claim(a == b, u.sprintf('Param `%s` is not equal to param `%s`', a, b))
end

function param.claim_type_equal(a, b)
    claim(param.typeof(a) == param.typeof(b), u.sprintf('Param `%s` is not equal to param `%s`', a, b))
end

param.claim_eql = param.claim_equal
param.claim_type_eql = param.claim_type_equal

function param.claim_class_equal(a, b)
    local cls_a = class.of(a)
    local cls_b = class.of(b)

    if cls_a and cls_b then 
       claim(cls_a == cls_b, u.sprintf("Class of `%s` is invalid. Given class: `%s`; Required class: `%s`", a, param.typeof(a), param.typeof(b)))
    end
end

param.claim_cls_equal = param.claim_class_equal
param.claim_cls_eql = param.claim_cls_eql

function param.compare_type(a, b)
    return param.typeof(a) == param.typeof(b)
end

function param.compare_class(a, b)
    local c, d = class.of(a), class.of(b)

    if c == nil or d == nil then return false end
    return c == d
end

param.compare_cls = param.compare_class

function param.claim_key(t, ...)
    param.claim_h(t)

    for _, k in ipairs({...}) do
        claim(t[k] ~= nil, u.sprintf("Table %s does not have key %s with the required value", t, k))
    end
end

function param.dfs_compare_table(table_a, table_b, cmp)
    param.claim_h(table_a)
    param.claim_h(table_b)

    if cmp then param.claim_callable(cmp) end
    local new_t = {}
    local _new_t = new_t

    local function __compare(_table_a, _table_b)
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
    param.claim_h(table_a)
    param.claim_h(table_b)
    param.claim_callable(cmp)

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

function param.bfs_claim_table(table_a, table_b, use_value)
    param.claim_h(table_a)
    param.claim_h(table_b)

    local function __compare(_table_a, _table_b)
        local later_ks = {}
        for _, k in ipairs(tu.intersection(tu.keys(_table_a), tu.keys(_table_b))) do
            local a = _table_a[k]
            local b = _table_b[k]
            param.claim_type_equal(a, b)

            if u.table_p(a) then
                if class.of(a) and class.of(b) then
                    param.claim_class_equal(a, b)

                    if use_value then
                        param.claim_key(_table_a, k, b)
                    end
                else
                    push(later_ks, k)
                end
            elseif use_value then
                param.claim_key(_table_a, k, b)
            end
        end

        for _, k in ipairs(later_ks) do
            __compare(_table_a[k], _table_b[k])
        end
    end

    __compare(table_a, table_b)
end

function param.dfs_claim_table(table_a, table_b, use_value)
    param.claim_h(table_a)
    param.claim_h(table_b)

    use_value = use_value == nil and true or false

    local function __compare(_table_a, _table_b)
        for _, k in ipairs(tu.intersection(tu.keys(_table_a), tu.keys(_table_b))) do
            local a = _table_a[k]
            local b = _table_b[k]
            claim(param.compare_type(a, b))

            if u.table_p(a) then
                if class.of(a) and class.of(b) then
                    param.claim_class_equal(a, b)

                    if use_value then
                        param.claim_key(_table_a, k, b)
                    end
                else
                    __compare(_table_a[k], _table_b[k])
                end
            elseif use_value then
                param.claim_key(_table_a, k, b)
            end
        end
    end

    __compare(table_a, table_b)
end

param.claim_table = param.bfs_claim_table

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
