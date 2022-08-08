valid_types = {
    table = 'table';
    ['function'] = 'function';
    callable = 'callable';
    string = 'string';
    dict = 'dict';
    array = 'array';
    hash = 'hash';
    number = 'number';
    userdata = 'userdata';
    boolean = 'boolean';
    s = 'string';
    t = 'table';
    d = 'dict';
    h = 'dict';
    a = 'array';
    c = 'callable';
    b = 'boolean';
    f = 'function';
    m = 'module';
    n = 'number';
}

local mt = {}

local cb = function (k, opts)
    opts = opts or {}

    return function(obj) 
        if obj == nil and opt then return end
        local out = typeof(obj) == k
        if opts.inv then out = not out end 
        if not out and opts.opt then return true end
        local msg = ''

        if opts.inv then
            msg = sprintf('Object %s is of type: %s', obj or 'NA', k)
        else
            msg = sprintf('Object %s is not of type: %s', obj or 'NA', k)
        end

        if not opts.no_assert then
            assert(out, msg)
        else
            if not out then
                return sprintf('Object %s is not of type: %s', obj or 'NA', k)
            end
            return true
        end
    end
end

local multi_cb = function(k)
    local types = values(filter(keys(valid_types), function(s) return #s == 1 end))
    local regex = '^[' .. join(types) .. ']+$'
    local what = string.match(k, regex)
    if not what then return false end
    what = vim.split(what, '')
    local args = {}

    for _, i in ipairs(what) do
        assert(valid_types[i], 'Invalid type signature provided: ' .. i)
        args[#args+1] = valid_types[valid_types[i]]
    end

    return function(obj)
        local msgs = {}
        for _, k in ipairs(args) do
            local out = cb(k, {no_assert=true})(obj)
            if is_s(out) then
                push(msgs, out)
            elseif out == true then
                return
            end
        end

        echo('%s', join(msgs, "\n"))
        error('Object did not match any given types')
    end
end

local get_cb = function (k)
    local multi_f = multi_cb(k)
    if multi_f then return multi_f end
    k = sed(k, {' +', ''})
    local regex = '^(opt_|not_|!|!~|~|~!|not_opt|opt_not)'
    local flags = pcre.match(k, regex)
    local opt_inv = flags == 'not_opt' or flags == 'opt_not' or flags ==  '~!' or flags == '!~'
    local opt = flags == 'opt_' or flags == '!' or opt_inv
    local inv = flags == 'not_' or flags == '~' or opt_inv
    local options = {
        opt = opt;
        inv = inv;
    }
    k = pcre.gsub(k, regex, '')

    assert(valid_types[k] ~= nil, 'Invalid type provided: ' .. k)

    return cb(k, options) 
end

mt.__index = function(self, k)
    return get_cb(k)
end

mt.__call = function (self, obj, ...)
    assert(obj ~= nil)

    local args = {...}
    assert(#args > 0, 'No types provided')

    local n = #args
    local fail = false
    local msgs = {}
    local fail = 0

    for index, i in ipairs(args) do
        local msg = get_cb(i)(obj)
        if type(msg) == 'string' then
            push(msgs, msg)
            fail = fail + 1
        else
            return
        end
    end

    if fail == n then
        error("\n" .. join(msgs, "\n"))
    end
end

claim = setmetatable({}, mt)
claim_s = claim.string
claim_str = claim.string
claim_b = claim.boolean
claim_bool = claim.boolean
claim_callable = claim.callable
claim_c = claim.callable
claim_f = claim['function']
claim_h = claim.table
claim_t = claim.table
claim_hash = claim.hash
claim_dict = claim.dict

function assert_key(t, ...)
    claim_h(t)

    for _, k in ipairs({...}) do
        assert(t[k] ~= nil, sprintf("Table %s does not have key %s with the required value", t, k))
    end
end

function dfs_compare_table(table_a, table_b, cmp)
    claim_h(table_a)
    claim_h(table_b)

    if cmp then claim_callable(cmp) end
    local new_t = {}
    local _new_t = new_t

    local function __compare(_table_a, _table_b)
        for _, k in ipairs(intersection(keys(_table_a), keys(_table_b))) do
            local a = _table_a[k]
            local b = _table_b[k]
            local is_equal

            if cmp then
                is_equal = cmp(a, b)
            else
                is_equal = typeof(a) == typeof(b)
            end

            if table_p(a) and is_equal then
                _new_t[k] = {}
                _new_t = _new_t[k]
                __compare(a, b, cmp)
            elseif is_equal then
                _new_t[k] = a == b
            else
                _new_t[k] = false 
            end
        end
    end

    __compare(table_a, table_b)
    return new_t
end

dfs_cmp_t = dfs_compare_table
dfs_compare_t = dfs_cmp_t

function bfs_compare_table(table_a, table_b, cmp)
    claim_h(table_a)
    claim_h(table_b)

    if cmp then claim_callable(cmp) end
    local new_t = {}
    local _new_t = new_t

    local function __compare(_table_a, _table_b)
        local later = {}

        for _, k in ipairs(intersection(keys(_table_a), keys(_table_b))) do
            local a = _table_a[k]
            local b = _table_b[k]
            local is_equal

            if cmp then
                is_equal = cmp(a, b)
            else
                is_equal = typeof(a) == typeof(b)
            end

            if type(a) == 'table' and is_equal then
                push(later, k)
            elseif is_equal then
                _new_t[k] = a == b
            else
                _new_t[k] = false 
            end
        end

        for _, k in ipairs(later) do
            local a = _table_a[k]
            local b = _table_b[k]
            _new_t[k] = {}
            _new_t = _new_t[k]
            __compare(a, b, cmp)
        end
    end

    __compare(table_a, table_b)
    return new_t
end
bfs_cmp_t = bfs_compare_table
bfs_compare_t = bfs_cmp_t
compare_t = bfs_compare_t

claim(1, '~number')
