local err = function(fmt)
    return function(...)
        return sprintf(fmt, ...)
    end
end

return {
    bufnr_not_valid = err('Buffer with bufnr %d does not exist');
    bufnr_not_visible = err('Buffer with bufnr %d is not visible');
    bufname_not_valid = err('Buffer with bufname %s is invalid');
    winnr_not_valid = err('Window winnr %d is invalid. Buffer is invisible');
    winid_not_valid = err('Window winid %d is invalid. Buffer is invisible');
    no_start_col = err('No start column provided in pos %s');
    no_start_row = err('No start row provided in pos %s');
    no_doc = err('No doc for keybinding provided');
    no_f = err('No command for keybinding provided');
}
