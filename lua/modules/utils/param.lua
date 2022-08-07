require('modules.utils.common')
require('modules.utils.table')

local _claim = function (test, msg)
    assert(test ~= nil)

    if type(test) == 'function' then
        assert(test(), msg)
    else
        assert(test, msg)
    end
end

claim = setmetatable({}, {
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
    __call = function (self, obj, ...)
        assert(obj ~= nil, 'No object provided to test')

        local ks = {...}
        local n = #ks
        local failed = {}

        _claim(n > 0, 'No objects provided for type checking')

        for _, k in ipairs(ks) do
            local inversion = false
            if k:match('^not_') then
                inversion = true
            elseif k:match('^[!~]') then
                inversion = true
            end

            local success = pcall(claim[k], obj)
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

claim_s = claim_string
claim_str = claim_string
claim_b = claim_boolean
claim_bool = claim_boolean
claim_h = claim_table
claim_t = claim_table
claim_hash = claim_hash

function claim_key(t, ...)
    claim_h(t)

    for _, k in ipairs({...}) do
        claim(t[k] ~= nil, u.sprintf("Table %s does not have key %s with the required value", t, k))
    end
end

function dfs_compare_table(table_a, table_b, cmp)
    claim_h(table_a)
    claim_h(table_b)

    if cmp then claim_callable(cmp) end
    local new_t = {}
    local _new_t = new_t

    local function __compare(_table_a, _table_b)
        for _, k in ipairs(tu.intersection(tu.keys(_table_a), tu.keys(_table_b))) do
            local a = _table_a[k]
            local b = _table_b[k]
            local is_equal = compare_type(a, b)

            if u.table_p(a) and is_equal then
                if compare_cls(a, b) then
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

function bfs_compare_table(table_a, table_b, cmp)
    claim_h(table_a)
    claim_h(table_b)
    claim_callable(cmp)

    local new_t = {}
    local _new_t = new_t

    local function __compare(_table_a, _table_b, _new_t)
        local later_ks = {}
        for _, k in ipairs(tu.intersection(tu.keys(_table_a), tu.keys(_table_b))) do
            local a = _table_a[k]
            local b = _table_b[k]
            local is_equal = compare_type(a, b)

            if u.table_p(a) and is_equal then
                if compare_cls(a, b) then
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

function bfs_claim_table(table_a, table_b, use_value)
    claim_h(table_a)
    claim_h(table_b)

    local function __compare(_table_a, _table_b)
        local later_ks = {}
        for _, k in ipairs(tu.intersection(tu.keys(_table_a), tu.keys(_table_b))) do
            local a = _table_a[k]
            local b = _table_b[k]
            claim_type_equal(a, b)

            if u.table_p(a) then
                if class.of(a) and class.of(b) then
                    claim_class_equal(a, b)

                    if use_value then
                        claim_key(_table_a, k, b)
                    end
                else
                    push(later_ks, k)
                end
            elseif use_value then
                claim_key(_table_a, k, b)
            end
        end

        for _, k in ipairs(later_ks) do
            __compare(_table_a[k], _table_b[k])
        end
    end

    __compare(table_a, table_b)
end

function dfs_claim_table(table_a, table_b, use_value)
    claim_h(table_a)
    claim_h(table_b)

    use_value = use_value == nil and true or false

    local function __compare(_table_a, _table_b)
        for _, k in ipairs(tu.intersection(tu.keys(_table_a), tu.keys(_table_b))) do
            local a = _table_a[k]
            local b = _table_b[k]
            claim(compare_type(a, b))

            if u.table_p(a) then
                if class.of(a) and class.of(b) then
                    claim_class_equal(a, b)

                    if use_value then
                        claim_key(_table_a, k, b)
                    end
                else
                    __compare(_table_a[k], _table_b[k])
                end
            elseif use_value then
                claim_key(_table_a, k, b)
            end
        end
    end

    __compare(table_a, table_b)
end

claim_table = bfs_claim_table

function bfs_compare(a, b, cmp)
    if not compare_type(a, b) then
        return false
    elseif not compare_cls(a, b) then
        return false
    elseif u.table_p(a) then
        return bfs_compare_table(a, b, cmp)
    end

    return a == b
end

function dfs_compare(a, b, cmp)
    if not compare_type(a, b) then
        return false
    elseif not compare_cls(a, b) then
        return false
    elseif u.table_p(a) then
        return dfs_compare_table(a, b, cmp)
    end

    return a == b
end

compare = bfs_compare

-- Spec: {'type/class', param}, ...
-- For optional params which are either false or nil, they will be ignored
function validate_params(...)
    local args = {...}

    for index, i in ipairs(args) do
        claim.table(i)
        assert(#i > 1, 'Spec: {class/type, param}')
        local spec, arg = unpack(i)

        if type(spec) ~= 'string' then
            spec = typeof(spec)
        end
        
        local is_opt = false
        if spec:match('^opt_') then
            is_opt = true
            spec = spec:gsub('^opt_', '')
        end

        local test = typeof(arg) == spec
        if not is_opt then
            assert(test, u.sprintf('Invalid spec provided for %s: %s', arg, spec))
        end

        args[index] = arg
    end

    return unpack(args)
end

-- This is the coolest param multitype validator  
-- t table
-- h hash (table)
-- d hash (table)
-- s string
-- c callable
-- b boolean
-- f function
-- m module/class
-- n number
claim_type = setmetatable({}, {
    __index = function(self, k)
        local test = {
            s = 'string';
            t = 'table';
            d = 'table';
            h = 'table';
            a = 'table';
            c = 'callable';
            b = 'boolean';
            f = 'function';
            m = 'module';
            n = 'number';
        }
        local what = string.match(k, '^[thdscbfmn]+$')
        assert(what, 'Need any of t, h, d, s, c, b, f, m, n as type signature')
        what = vim.split(what, '')
        local args = {}

        for _, i in ipairs(what) do
            assert(test[i], 'Invalid type signature provided: ' .. i)
            args[#args+1] = test[i]
        end
        return function(...)
            for _, obj in ipairs({...}) do
                claim(obj, unpack(args))
            end
        end
    end
})
