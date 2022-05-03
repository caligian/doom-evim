local Exception = require('core.exceptions')

local M = setmetatable({}, {
    __call = function (job_obj)
        local e = Exception(job_obj)

        e:add('killed', function (obj)
            return {job=obj, killed=true, reason='Job has been killed or does not exist'}
        end)

        e:add('done', function (obj)
            return {job=obj, done=true, reason='Cannot rerun a done job'}
        end)

        e:add('pending', function (obj)
            return {job=obj, started=false, reason='Job has not been started.'}
        end)

        return e
    end
})

return M
