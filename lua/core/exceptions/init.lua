local exception = {}

function exception.throw(fmt, ...)
    claim.string(fmt)
    error(sprintf(fmt, ...))
end

function exception.throw_if(test, fmt, ...)
    if callable(test) then
        test = test()
    end

    if not test then
        exception.throw(fmt, ...)
    end

    return test
end

return exception
