local err = function(fmt)
    return function(...)
        return sprintf(fmt, ...)
    end
end

return {
    no_doc = err('No doc for augroup provided');
    no_f = err('No command for augroup provided');
    no_pat = err('No pattern  for augroup provided');
}
