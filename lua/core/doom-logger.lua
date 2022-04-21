local Logger = {}
local FileLogger = require('logging.file')
local Path = require('path')
local LOGPATH = Path(vim.fn.stdpath('data'), 'doom-evim.log')

function Logger.log(level, message)
    local logger = FileLogger(LOGPATH, "%d-%m-%Y-%H-%M-%S", "[%date] [%level] %message")

    if level:match('debug') then
        logger:debug(message)
    elseif level:match('warn') then
        logger:warn(message)
    elseif level:match('info') then
        logger:info(message)
    elseif level:match('error') then
        logger:error(message)
    elseif level:match('fatal') then
        logger:fatal(message)
    elseif level:match('warn') then
        logger:warn(message)
 
    end
end

function Logger.dlog(msg)
    Logger.log('debug', msg)
end

function Logger.elog(msg)
    Logger.log('error', msg)
end

function Logger.flog(msg)
    Logger.log('fatal', msg)
end

function Logger.ilog(msg)
    Logger.log('info', msg)
end

doom.log_path = Path(vim.fn.stdpath('data'), 'doom-evim.log')

return Logger
