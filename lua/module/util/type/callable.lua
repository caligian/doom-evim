ns 'Callable'

function callable(f)
    param.claim.callable(f)

    local mod = Callable {}
    mod:set_instance_variable('value', f)
    mod:include(m, 'value')

    mod:on_operator('+', {m.partial, m.lpartial}, 'value')
    mod:on_operator('s', tostring, 'value')

    mod:on_operator('*', function (f, a)
        param.claim.table(a)
        if a.isa and a:isa(Table) or a:isa(Array) then
            return a:map(f)
        end
        return tu.map(a, f)
    end, 'value')

    mod:on_operator('^', function (f, a)
        param.claim.table(a)
        if a.isa and a:isa(Table) or a:isa(Array) then
            return a:filter(f)
        end
        return tu.filter(a, f)
    end, 'value')

    return mod
end
