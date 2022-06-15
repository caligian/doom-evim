local err = function(fmt)
    return function(...)
        return sprintf(fmt, ...)
    end
end

return {
    no_doc = err('No doc for keybinding provided');
    no_f = err('No command for keybinding provided');
    no_keys = err('No keys for keybinding provided');
    no_mode = err('No mode for keybinding provided');
    index_not_valid = err('Index is invalid');
}
