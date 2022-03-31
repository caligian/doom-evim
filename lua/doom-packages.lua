local Packages = {}
local Utils = require('doom-utils')
local Core = require('aniseed.core')
local Packer = require('packer')

function Packages.setup()
    local systemPackages = require('essential_packages')
    local userPackages = require('user-packages')
    local defaultPackages = require('default_packages')

    doom.packages = vim.tbl_extend('force', defaultPackages, systemPackages, userPackages)
    require('specs')
    require('user-specs')

    vim.cmd('packadd packer.nvim')

    Packer.reset()

    Packer.init({
        git = {
            clone_timeout = 300,
            subcommands = {
                install = 'clone --depth %i --progress',
            },
        },
        profile = {
            enable = true,
        },
    })

    Packer.startup(function (use)
        for _, conf in pairs(doom.packages) do
            use(conf)
        end
    end)
end

return Packages
