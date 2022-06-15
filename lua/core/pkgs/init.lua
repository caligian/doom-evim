local packer = require('packer')
local pkgs = {}

function pkgs.get_packer_form(plug)
    local t = {}
    local fn = plug:gsub('%.', '_')
    local base = with_config_path('lua', 'core', 'pkgs', 'configs') 
    local stat = path.exists(path(base, 'stat', fn .. '.lua'))

    if stat then
        require('core.pkgs.configs.stat.' .. fn)
    else
        local has_conf = path.exists(path(base, 'config', fn .. '.lua'))
        local has_run = path.exists(path(base, 'run', fn .. '.lua'))
        local has_setup = path.exists(path(base, 'setup', fn .. '.lua'))
        local base_require = 'core.pkgs.configs'

        if has_conf then 
            t.config = function()
                pcall(require, string.format('%s.config.%s', base_require, fn))
            end
        end
        if has_run then 
            t.run = function()
                pcall(require, string.format('%s.run.%s', base_require, fn))
            end
        end
        if has_setup then 
            t.setup = function()
                pcall(require,string.format('%s.setup.%s', base_require, fn))
            end
        end
    end

    return t
end

function pkgs.compile_packer_forms()
    local packages = require('core.pkgs.plugins')
    local user_overrides = {}
    local user_overrides_path = path(os.getenv('HOME'), '.vdoom.d', 'lua', 'user', 'pkgs', 'plugins.lua')

    if path.exists(user_overrides_path) then
        user_overrides = require('user.pkgs.plugins')
        assert_t(user_overrides)
    end

    merge(packages, user_overrides)

    each(function(plug)
        merge(packages[plug], pkgs.get_packer_form(plug))
    end, keys(packages))

    return packages
end

function pkgs.load_all(force_recompile)
    vim.cmd('packadd packer.nvim')
    Doom.pkgs.packages = pkgs.compile_packer_forms()
    Doom.pkgs.packer = packer
    Doom.pkgs.packer.startup(function(use)
        for k, v in pairs(Doom.pkgs.packages) do
            use(v)
        end
    end)
end

return pkgs
