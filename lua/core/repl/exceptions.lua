local Exception = require('core.exceptions')
local M = {}

setmetatable(M, {
    __call = function (repl_obj)
        local e = Exception(repl_obj)

        e:add('running', function ()
                return {
                    running = true,
                    reason = 'REPL has already been opened for this filetype',
                    repl = repl_obj,
                }
        end)

        e:add('killed', function ()
            return {
                killed = true,
                reason = 'REPL has already been killed or has not been started.',
                repl = repl_obj,
            }
        end)

        e:add('filetype_mismatch', function ()
            return {
                filetype_mismatch = true,
                reason = 'REPL cannot act on an incompatible filetype',
                repl = repl_obj,
            }
        end)

        e:add('unknown', function ()
            return {
                unknown = true,
                reason = 'Error is unknown',
                repl = repl_obj,
            }
        end)
    end
})

return M
