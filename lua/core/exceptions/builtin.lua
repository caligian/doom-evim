local ex = {
    table = {
        invalid_key = function (t, k)
            return t[k] or false
        end;
        invalid_value = function (t, v)
            return find(t, v) or false
        end;
        blank = function (t)
            return #(keys(t)) ~= 0
        end;
        empty = function (t)
            return #(keys(t)) ~= 0
        end;
    };
    string = {
        no_substring = function (s, pat)
            return match(s, pat) ~= false
        end;
        no_startswith = function (s, pat)
            return match(s, '^' .. pat) ~= false
        end;
        no_endswith = function (s, pat)
            return match(s, pat .. '$') ~= false
        end;
        blank = function (s)
            return #s ~= 0
        end;
    };
    buffer = {
        invalid_bufnr = function (expr)
            return vim.fn.bufname(expr) ~= ''
        end;
        invalid_buffer_winnr = function (bufnr)
            return vim.fn.bufwinnr(bufnr) ~= -1
        end
        invalid_winnr = function (winnr)
            return #(vim.fn.win_findbuf(winnr)) ~= 0
        end
    };
}

local exc = require 'core.exceptions'
local a = exc.new({a=1, b=2})
a:add_cond('invalid_key', ex.table.invalid_key, 'Invalid key supplied')
a.raise.invalid_key('a')
