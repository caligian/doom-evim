local Logger = {}
local FileLogger = require('logging.file')
local Path = require('path')
local LOGPATH = Path(vim.fn.stdpath('data'), 'doom.log')

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

function Logger.debug(msg)
    Logger.log('debug', msg)
end

function Logger.error(msg)
    Logger.log('error', msg)
end

function Logger.fatal(msg)
    Logger.log('fatal', msg)
end

function Logger.info(msg)
    Logger.log('info', msg)
end

function Logger.registerModule(M)
    for key, value in pairs(M) do
        if type(value) == 'function' then
            local withErrHandling = function (...)
                local status, final = pcall(value, ...)

                if status then
                    return final
                else
                    Logger.fatal(final)
                end
            end

            M[key] = withErrHandling
        end
    end
end

Doom.logPath = LOGPATH
_G.Logger = Logger
return Logger
