local kbd = require('core.kbd')
local mode = class('doom-kbd-mode')

assoc(Doom, {'kbd', 'mode', 'status'}, {})
mode.status = Doom.kbd.mode.status

function mode:__init(name)
    self.name = name
    self.keys = new_table()
end

-- Spec: {mode, keys, cb, attribs}, ...
function mode:add(...)
    new_table(...):each(function (a)
        local m, k, f, a = unpack(a)
        assert(m)
        assert(k)
        assert(f)
        a = a or {}
        self.keys:push(kbd.new(m, k, f, a))
    end)
end

function mode:enable()
    self.keys:each(function (k)
        k:enable()
    end)
end

function mode:disable()
    self.keys:each(function (k)
       k:disable() 
    end)
end

function mode:hook(event, pattern)
    assert_s(event)
    assert_type(pattern, 'number', 'string')

    event = 'BufEnter'
    pattern = 
end

function mode.new(name)
end
