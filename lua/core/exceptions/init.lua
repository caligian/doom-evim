add_global(function(test, fmt, ...)
    if not test then 
        error(sprintf(fmt, ...))
    else
        return true
    end
end, 'oblige')
