local Notify = require('notify')
local Notification = {}

---@class NotifyOptions @Options for an individual notification
---@field title string
---@field icon string
---@field timeout number | boolean: Time to show notification in milliseconds, set to false to disable timeout.
---@field on_open function: Callback for when window opens, receives window as argument.
---@field on_close function: Callback for when window closes, receives window as argument.
---@field keep function: Function to keep the notification window open after timeout, should return boolean.
---@field render function: Function to render a notification buffer.
---@field replace integer | NotifyRecord: Notification record or the record `id` field. Replace an existing notification if still open. All arguments not given are inherited from the replaced notification including message and level.
---@field hide_from_history boolean: Hide this notification from the history
function Notification.show(title, message, level, opts)
     
end
