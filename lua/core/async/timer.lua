local uv = vim.loop
local timer = class('doom-luv-timer')

function timer:__init(timeout, _repeat, callback)
    self.timeout = timeout
    self['repeat'] = _repeat
    self.callback = callback
    self.counter = 0
end

function timer.new(callback, opts)
    claim.callable(callback)
    claim.table(opts)

    opts = opts or {}
    opts.timeout = opts.timeout or 100
    opts['repeat'] = opts['repeat'] or 0

    assert_n(opts.timeout)
    assert_n(opts['repeat'])

    local self = timer(opts.timeout, opts['repeat'], false)

    self.callback = vim.schedule_wrap(function ()
        self.timer:stop()
        self.timer:close()
        callback()
    end)

    self.timer = uv.new_timer()

    return self
end

function timer:stop()
    self.timer:stop()
    self.timer:close()
end

function timer:start()
    local run = self.timer:start(self.timeout, self['repeat'], self.callback) == 0

    if run then
        self.counter = self.counter + 1
    end

    return run == 0 
end

function timer:again()
    return self.timer:again() == 0
end

function timer:set_repeat(new_repeat)
    opts['repeat'] = new_repeat
    self.timer:set_repeat(new_repeat)
end

function timer:get_repeat()
    return self.timer:get_repeat()
end

function timer:get_due_in()
    return self:get_due_in()
end

return timer
