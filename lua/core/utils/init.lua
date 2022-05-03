local Utils = {}

function Utils.keys(t)
    local k = {}

    for key, _ in pairs(t) do
        table.insert(t, key)
    end

    return k
end

function Utils.vals(t)
    local v = {}

    for _, value in pairs(t) do
        table.insert(t, value)
    end

    return v
end

function Utils.len(t)
    local arr_len = 0
    local dict_len = 0

    for _, _ in pairs(t) do
        dict_len = dict_len + 1
    end

    for _, _ in ipairs(t) do
        arr_len = arr_len + 1
    end

    return arr_len, dict_len
end

return Utils
