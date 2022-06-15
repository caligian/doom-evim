local err = function(fmt)
    return function(...)
        return sprintf(fmt, ...)
    end
end

return {
    no_telescope = err('No telescope installation found');

    picker = {
        missing = err('No picker provided');
        missing_title = err('No title for picker given');
        missing_results = err('No results provided');
        missing_mappings = err('No default mapping and other mappings provided')
    }
}
