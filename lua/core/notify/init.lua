local nvim_notify = require('notify')

local function notify(title, message, level, opts)
    assert(title, 'No title provided for notification')
    assert(message, 'No message provided for notification')

    claim.string(title)
    claim.string(message)
    claim.string(level)
    claim.table(opts)

    opts = opts or {}
    level = level or 'info'

    local on_open_hook = opts.on_open
    local on_close_hook = opts.on_close
    local timeout = opts.timeout or 2000
    local render = opts.render or 'default'
    level = string.upper(level)

    if type(message) == 'table' then
        message = table.concat(message, "\n")
    end

    nvim_notify(message, level, {
        on_open = on_open_hook,
        on_close = on_close_hook,
        render = render,
        timeout = timeout,
        title = title,
    })
end

add_global(notify, 'win_notify')
add_global(function(title, message, opts) notify(title, message, 'info', opts) end, 'win_notify_info')
add_global(function(title, message, opts) notify(title, message, 'fatal', opts) end, 'win_notify_fatal')
add_global(function(title, message, opts) notify(title, message, 'debug', opts) end, 'win_notify_debug')
add_global(function(title, message, opts) notify(title, message, 'trace', opts) end, 'win_notify_trace')
add_global(function(title, message, opts) notify(title, message, 'warn', opts) end, 'win_notify_warn')
