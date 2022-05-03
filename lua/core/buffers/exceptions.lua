local Exception = require('core.exceptions')

local M = setmetatable({}, {
    __call = function (buf_obj)
        local e = Exception(buf_obj)

        e:add('invalid', function (obj)
            return {invalid=true, buffer=obj, reason='Buffer does not exist'}
        end)

        e:add('invisible', function (obj)
            return {invisible=true, buffer=obj, reason='Buffer window is invisible'}
        end)

        e:add('unknown', function (obj)
            return {unknown=true, buffer=obj, reason='Unknown error'}
        end)

        return e
    end
})

return M
