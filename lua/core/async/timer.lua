local uv = vim.loop
local m = {}
local timer = {}

function timer.new(callback, opts)
    claim.callable(callback)
    claim.opt_table(opts)

    opts = opts or {}
    opts.timeout = opts.timeout or 100
    opts.n = opts.n or 0

    claim.number(opts.timeout)
    claim.number(opts.n)

    return module.new('timer', {
        vars = {
            timer = uv.new_timer();
            counter = 0;
            timeout = opts.timeout;
            n = opts.n;
            callback = vim.schedule_wrap(function ()
                self.timer:stop()
                self.timer:close()
                callback()
            end);
        }
    }, m)
end

function m:stop()
    self.timer:stop()
    self.timer:close()
end

function m:start()
    local run = self.timer:start(self.timeout, self.n, self.callback) == 0

    if run then
        self.counter = self.counter + 1
    end

    return run == 0 
end

function m:again()
    return self.timer:again() == 0
end

function m:set_repeat(new_repeat)
    opts.n = new_repeat
    self.timer:set_repeat(new_repeat)
end

function m:get_repeat()
    return self.timer:get_repeat()
end

function m:get_due_in()
    return self:get_due_in()
end

return timer
