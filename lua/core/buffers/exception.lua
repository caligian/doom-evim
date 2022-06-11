local err = function(fmt)
    return function(...)
        return u.sprintf(fmt, ...)
    end
end

return {
    bufnr_not_valid = err('Buffer with bufnr %d does not exist');
    bufnr_not_visible = err('Buffer with bufnr %d is not visible');
    winnr_not_valid = err('Window winnr %d is invalid. Buffer is invisible');
    winid_not_valid = err('Window winid %d is invalid. Buffer is invisible');
    no_start_col = err('No start column provided: ')
}
