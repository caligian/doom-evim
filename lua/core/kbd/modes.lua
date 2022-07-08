local kbd = require('core.kbd')

local mode = class('keybinding')
local m = {}
assoc(Doom, {'kbd', 'mode', 'status'}, {})
mode.status = Doom.kbd.mode.status

function mode.new(name, pattern)
    assert(name)
    assert(pattern)
    assert_s(name)
    assert_type(pattern, 'number', 'string')

    if num_p(pattern) then
        if pattern == 0 then
            pattern = '*' 
        elseif vim.fn.bufexists(pattern) ~= 1 then
            error('Invalid bufnr provided ' .. pattern)
        else
            pattern = sprintf('<buffer=%d>', pattern)
        end
    end

    local cls = class.new(name, {
        name = name;
        keys = dict.new({});
        event = 'BufEnter';
        pattern = pattern;
    })

    cls:delegate(m)

    return cls
end

-- Spec: {mode, keys, cb, attribs}, ...
function m:add(...)
    dict.new({...}):each(function (a)
        local m, k, f, a = unpack(a)
        local e = 'BufEnter'
        assert(m)
        assert(k)
        assert(f)
        a = a or {}
        self.keys:push(kbd.new(m, k, f, a, e))
    end)
end

function m:enable()
    self.keys:each(function (k)
        k:enable()
    end)
end

function m:disable()
    self.keys:each(function (k)
       k:disable() 
    end)
end

function m:hook(event, pattern)
    assert_s(event)
    assert_type(pattern, 'number', 'string')

    event = event or 'BufEnter'
    if num_p(pattern) then
        pattern = sprintf('<buffer=%d>', pattern)
    end
end

function m.new(name)
end
