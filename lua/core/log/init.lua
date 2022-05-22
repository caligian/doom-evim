local logger = require('logging.file')
local path = require('path')

if not _G.Doom.log then _G.Doom.log = {} end
if not _G.Doom.log.path then _G.Doom.log.path = with_data_path('doom-evim.log') end

if not Doom.log.logger then
    Doom.log.logger = logger(Doom.log.path, '%d-%m-%Y-%H-%M-%S', "[%date] [%level] %message\n")
end

add_global(function(log_type, message)
    log_type = log_type or 'info'
    Doom.log.logger[log_type](Doom.log.logger, message)
end, 'log')

add_global(function(message) log('debug', message) end, 'debug_log')
add_global(function(message) log('fatal', message) end, 'fatal_log')
add_global(function(message) log('warn', message) end, 'warn_log')
add_global(function(message) log('info', message) end, 'info_log')
