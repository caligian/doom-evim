local class = require('classy')
local path = require('path')
local fs = require('path.fs')
local pkgs = class('doom-package')

function pkgs:__init()
    local packer = false

    local try_require = function() return pcall(function() packer = require('packer') end) end

    if not try_require() then
        local dst = with_packer_path('start', 'packer.nvim')
        vim.fn.system('git clone https://github.com/wbthomason/packer.nvim ' .. dst)
    end

    assert(try_require(), 'Cannot require packer. Please manually clone packer.nvim to stdpath("data")/site/pack/packer/start')

    self.packer = packer
    self.sys_default_pkg_path = with_config_path('lua', 'core', 'pkgs', 'default.lua')
    self.sys_essential_pkg_path = with_config_path('lua', 'core', 'pkgs', 'essential.lua')
    self.user_pkg_path = path(os.getenv('HOME'), '.vdoom.d', 'user', 'pkgs.lua')
end

function pkgs:init_essential_packages()
    for _, i in ipairs({
        "folke/which-key.nvim";
        "hrsh7th/nvim-cmp";
        "nvim-telescope/telescope.nvim";
        "lualine"
    }) do
        local basename = vim.split(i, "/")
        basename = basename[#basename]
        basename = basename:gsub('%.', '_')
        require(sprintf('configs.stat.%s', basename))
    end
end

function pkgs:init_packer()
    vim.cmd('packadd packer.nvim')

    self.packer.init({
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
end

local function load_pkg_path(p)
    if not path.exists(p) then
        return false
    else 
        return dofile(p)
    end
end

function pkgs:load_packages(user_pkg_path)
    user_pkg_path = user_pkg_path or self.user_pkg_path
    self.user_pkg = load_pkg_path(user_pkg_path)
    self.sys_default_pkg = load_pkg_path(self.sys_default_pkg_path)

    if self.user_pkg then
        self.all_pkg = merge(self.sys_default_pkg, self.user_pkg)
    else
        self.all_pkg = self.sys_default_pkg
    end

    return self.all_pkg
end

-- Ensure that you convert all dots to _ while making your configs files
local function require_config(user_or_sys, _type, pkg)
    assert(pkg)
    user_or_sys = user_or_sys or 'user'
    local require_path = false
    local home = os.getenv('HOME')
    pkg = pkg:gsub("%.", '_')

    if user_or_sys == 'user' then
        require_path = path(home, '.vdoom.d', 'user', 'configs', _type, pkg .. '.lua')
    else
        require_path = with_config_path('lua', 'configs', _type, pkg .. '.lua')
    end

    if not path.exists(require_path) then return false end

    if user_or_sys == 'user' then
        require_path = sprintf('user.configs.%s.%s', _type, pkg)
    else
        require_path = sprintf('configs.%s.%s', _type, pkg)
    end

    if _type == 'stat' then 
        require(require_path)
    else
        return function()
            require(require_path)
        end
    end
end

function pkgs:load_configs()
    if not self.all_pkg then self:load_packages() end

    local _add_conf = function(pkg_t, _type, conf)
        if _type == 'pre' then
            pkg_t.setup = conf
        elseif _type == 'post' then
            pkg_t.config = conf
        elseif _type == 'post-install' then
            pkg_t.run = conf
        end
    end

    for k, v in pairs(self.all_pkg) do
        if not type(v) == 'table' then
            v = {v}
        end

        -- sys stuff
        local sys_pre_conf = require_config('sys', 'pre', k)
        local sys_post_conf = require_config('sys', 'post', k)
        local sys_post_install_conf = require_config('sys', 'post-install', k)
        require_config('sys', 'stat', k)

        if sys_pre_conf then
            _add_conf(v, 'pre', sys_pre_conf)
        end

        if sys_post_install_conf then
            _add_conf(v, 'post_install', sys_post_install_conf)
        end

        if sys_post_conf then
            _add_conf(v, 'post', sys_post_conf)
        end

        -- user stuff
        local user_pre_conf = require_config('user', 'pre', k)
        local user_post_conf = require_config('user', 'post', k)
        local user_post_install_conf = require_config('user', 'post-install', k)
        require_config('user', 'stat', k)

        if user_pre_conf then
            _add_conf(v, 'pre', user_pre_conf)
        end

        if user_post_install_conf then
            _add_conf(v, 'post_install', user_post_install_conf)
        end

        if user_post_conf then
            _add_conf(v, 'post', user_post_conf)
        end
    end

    return self.all_pkg
end

function pkgs:startup_packer()
    if not self.all_pkg then self:load_configs() end

    self.packer.startup(function()
        for k, v in pairs(self.all_pkg) do
            self.packer.use(v)
        end
    end)

    return self.packer
end

return pkgs
