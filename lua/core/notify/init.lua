local Notify = require('notify')
local Notification = {}

function Notification.notify(title, message, level, opts)
    assert(title)
    assert(message)
    opts = opts or {}
    level = level or 'INFO'
    local on_open_hook = opts.on_open
    local on_close_hook = opts.on_close
    local timeout = opts.timeout or 2000
    local render = opts.render or 'default'
    level = string.upper(level)

    if type(message) == 'table' then
        message = table.concat(message, "\n")
    end

    Notify(message, level, {
        on_open = on_open_hook,
        on_close = on_close_hook,
        render = render,
        timeout = timeout,
        title = title,
    })
end

function Notification.info(title, message, opts)
    Notification.notify(title, message, 'info', opts)
end

function Notification.fatal(title, message, opts)
    Notification.notify(title, message, 'fatal', opts)
end

function Notification.trace(title, message, opts)
    Notification.notify(title, message, 'trace', opts)
end

function Notification.debug(title, message, opts)
    Notification.notify(title, message, 'debug', opts)
end

function Notification.warn(title, message, opts)
    Notification.notify(title, message, 'warn', opts)
end

vim.notify = Notify

return Notification
