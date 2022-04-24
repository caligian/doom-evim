local Packages = {}
local Utils = require('doom-utils')
local Core = require('aniseed.core')
local Packer = require('packer')
local PackageLoader = require('doom-package-loader')

function Packages.setup()
    Doom.packages = PackageLoader.createMasterList()

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
        for _, conf in pairs(Doom.packages) do
            use(conf)
        end
    end)
end


return Packages
