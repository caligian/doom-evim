local Version = {}
local Async = dofile('doom-async.lua')
local Utils = require('doom-utils')
local Path = require('path')
local Fs = require('path.fs')
local QTScope = require('doom-telescope')

function Version.runGit(...)
    Async.spawn({split = false, cmd = 'git', args = {...}, cwd = vim.fn.stdpath('config')})
    return Async._stdout
end

function Version.getVersions()
    local versions = Version.runGit('tag', '--list')
    return versions
end

function Version.setVersion()
    QTScope.new({
        getter = Version.getVersions,
        hook = function (version)
--            Version.runGit('checkout', version[1])
            print('Doom\'s version has been changed to', version[1])
        end,
        title = 'doom-version-selector'
    })

end

Version.setVersion()

require('doom-globals')

