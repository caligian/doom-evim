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

param.claim = setmetatable({}, {
    __newindex = nil;
    __index = function (self, k)
        local is_opt = false
        local inversion = false

        if k:match('^opt_') then
            is_opt = true
            k = k:gsub('^opt_', '')
        elseif k:match('^_') then
            is_opt = true
            k = k:gsub('^_', '')
        end
        if k:match('^not_') then
            inversion = true
            k = k:gsub('^not_', '')
        elseif k:match('^[!~]') then
            inversion = true
            k = k:gsub('^[!~]', '')
        end

        k = k .. '_p'
        if not u[k] then
            error('Invalid type provided: ' .. k)
        end

        return function (...)
            for _, obj in ipairs({...}) do
                local msg = 'Object %s is not a %s'
                if is_opt and obj == nil then 
                    return true
                end

                local correct_type = u[k](obj) 
                if inversion then
                    correct_type = not correct_type
                    msg = 'Object %s is a %s'
                end
                if not correct_type then
                    error(u.sprintf(msg, obj, k:gsub('_p', '')))
                end
                return true
            end
        end
    end;
    __call = function (self, ...)
        local args = {...}
        local obj = args[1]
        local n = #args
        local ks = tu.slice(args, 2, -1)
        local failed = {}

        claim(n > 0, 'No objects provided for type checking')

        for _, k in ipairs(ks) do
            local inversion = false
            if k:match('^not_') then
                inversion = true
            elseif k:match('^[!~]') then
                inversion = true
            end

            local success = pcall(param.claim[k], obj)
            k = k:gsub('^opt_', '')
            k = k:gsub('^[_!~]', '')
            k = k:gsub('^not_', '')

            if not success then
                if inversion then
                    failed[#failed+1] = u.sprintf('Object %s is a %s', obj, k)
                else
                    failed[#failed+1] = u.sprintf('Object %s is not a %s', obj, k)
                end
            else
                break
            end
        end

        if n == #failed then
            obj = u.dump(obj)
            for _, err in ipairs(failed) do
                u.printf(err)
            end
            error('Could not match any datatype for object: ' .. obj)
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
        else
            return 'table'
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

-- Spec: {'type/class', param}, ...
-- For optional params which are either false or nil, they will be ignored
function param.validate_params(...)
    local args = {...}

    for index, i in ipairs(args) do
        param.claim.table(i)
        assert(#i > 1, 'Spec: {class/type, param}')
        local spec, arg = unpack(i)

        if type(spec) ~= 'string' then
            spec = param.typeof(spec)
        end
        
        local is_opt = false
        if spec:match('^opt_') then
            is_opt = true
            spec = spec:gsub('^opt_', '')
        end

        local test = param.typeof(arg) == spec
        if not is_opt then
            assert(test, u.sprintf('Invalid spec provided for %s: %s', arg, spec))
        end

        args[index] = arg
    end

    return unpack(args)
end

return param
