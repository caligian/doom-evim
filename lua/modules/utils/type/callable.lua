local module = require 'modules.utils.module'
local tu = require 'modules.utils.table'
local param = require 'modules.utils.param'
local m = require 'modules.utils.function'
local callable = {}

function callable.new(f)
    param.claim.callable(f)

    local mod = module.new('callable', {vars={value=f}})
    mod:include(m, 'value')

    mod:on_operator('+', {m.partial, m.lpartial}, 'value')

    mod:on_operator('*', function (f, a)
        param.claim.table(a)
        if param.typeof(a) == 'hash' then
            return a:map(f)
        end
        return tu.map(f, a)
    end, 'value')

    mod:on_operator('^', function (f, a)
        param.claim.table(a)
        if param.typeof(a) == 'hash' then
            return a:filter(f)
        end
        return tu.filter(f, a)
    end, 'value')

    mod:on_operator('s', function (f)
        return tostring(f)
    end, 'value')

    return mod
end

return callable
