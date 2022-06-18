local paq = require('paq')
local plugins = require('core.pkgs.plugins')

--[[
Simple pkgs loader for plugins that does not rely upon packer

Principles: 
- Use paq for basic package operations: Updating, etc
- Create a simple autocmd based pkgs-loading

This is the default package declaration for doom. Packages in key 'start' will be loaded along with their configs automatically. Packages in key 'opt' will be manually loaded based on certain trigger. You should follow the package specification given for paq at github.com/savq/paq-nvim. Other than that, there are other keys that are similar to the ones used in packer.nvim.

Additionally, users can edit this table. The overrides files should be located at ~/.vdoom.d/lua/user/pkgs/init.lua

Paq plugin specification:

[1] string username/repo
as      string  
Alias

branch  string  
Git branch for repo

opt     boolean 
Treat the package as optional. However, in this specification, this is redundant

pin     boolean 
Don't update this plugin

run  string|callable  
Run such command/callable after installing/updating plugins 

---

Additional configuration for facilitating lazy-loading:

Combinations of keys that can be supplied:
- keys & rocks 
- event & pattern & rocks
- event & rocks
- pattern & rocks

keys    string|table[string]
Load package after pressing these keys. 
Keys should be in the format:
{mode, keys, attribs, f} where attribs, event, pattern can be string|table and the rest must be strings or keys
If keys is a string then it will be mapped with noremap {keys} {plugin loader}. Multiple keydefs can be passed as table[string] in which all of them will be mapped in normal mode or if table[table] then use the above 4 elements to create oneshot keybindings

event   string|table[string]
Load package after this event.

pattern string|table[string]
Load package if pattern is true for buffer, files, etc.

rocks   string|table[string]
Luarocks required for the plugin

Loading post-loading configurations:
Configurations are located in core/pkgs/configs. For lazy-loaded packages, these configurations will be loaded as soon as the appropriate event is triggered

--]]

local class = require('classy')

local pkgs = {
    -- Lazy packages will be loaded from site/pack/paq/opt
    base_path = with_data_path('site', 'pack', 'doom');
    path = with_data_path('site', 'pack', 'doom', 'opt');
    default_path = with_data_path('site', 'pack', 'doom', 'start');
    plugins_path = with_config_lua_path('core', 'pkgs', 'plugins.lua');
    user_plugins_path = with_user_config_path('lua', 'user', 'pkgs', 'plugins.lua');
    plugin_specs = plugins;
    user_plugin_specs = {};
}

local function download_rock(rock)
    local dst = with_data_path('luarocks')
    if not path.exists(dst) then fs.mkdir(dst) end
    local cmd = 'luarocks --lua-version 5.1 --tree ' .. dst .. ' install ' .. rock
    local out = join(system(cmd), "\n")

    if match(out, 'Error:') then
        to_stderr("Failed to install luarock: %s\n%s", rock, out)
    else
        to_stderr('Successfuly installed luarock: %s', rock)
    end
end

local function get_pkgs_loader_cmd(plugin, opt)
    assert(plugin)
    assert(opt ~= nil)

    assert_type(plugin, 'string', 'table')
    assert_bool(opt)

    if boolean_p(config) then config = false end

    local req_path = false
    plugin = path.name(table_p(plugin) and first(plugin) or plugin)
    local name = sed(plugin, {'\\.', '_'})
    local dst = with_config_lua_path('core', 'pkgs', 'configs', name .. '.lua')
    local cmd = false

    if path.exists(dst) then 
        req_path = sprintf("core.pkgs.configs.%s", name)

        cmd = function()
            if opt then 
                vim.api.nvim_exec(':packadd ' .. plugin, true) 
            end

            require(req_path)

            Doom.pkgs.loaded[plugin] = true
        end
    elseif opt then
        cmd = function()
            if opt then 
                vim.api.nvim_exec(':packadd ' .. plugin, true) 
            end
        end
    end

    return cmd
end

local function parse_specs(spec, opt)
    assert(spec)

    assert_type(spec, 'string', 'table')
    spec = to_list(spec)

    assert_s(spec[1])

    if Doom.pkgs.loaded[spec[1]] then return spec end

    assert_type(spec.keys, 'table', 'string')
    assert_type(spec.pattern, 'table', 'string')
    assert_type(spec.rocks, 'table', 'string')
    assert_type(spec.event, 'table', 'string')

    if opt then spec.opt = true end

    local keys = spec.keys
    local pattern = spec.pattern
    local event = spec.event
    local rocks = rocks
    local keep_keys = spec.keep_keys

    if keys then
        local multiple = false

        for _, i in ipairs(to_list(keys)) do
            local _mode, _keys, _f, _attribs, _doc, cmd = false, false, false, false, ''

            assert_type(i, 'string', 'table')

            if str_p(i) then
                _mode = 'n'
                _keys = i
                _attribs = kbd.defaults.attribs
            elseif table_p(i) then
                assert(#i >= 3, 'Need at least 3 vals: mode, keys, f')
                _mode, _keys, _f, _attribs, _doc = unpack(i)
            end

            cmd = function(k)
                get_pkgs_loader_cmd(spec[1], true)()
                if str_p(_f) then
                    vim.cmd(_f) 
                elseif callable(_f) then
                    _f() 
                end
            end

            if keep_keys then
                kbd(_mode, _keys, cmd, _attribs, _doc):enable()
            else
                kbd.oneshot(_mode, _keys, cmd, _attribs)
            end
        end
    elseif event or pattern then
        local a = au(spec[1], 'Oneshot autocmd for plugin: ' .. spec[1])
        local cmd = get_pkgs_loader_cmd(spec[1], true)

        if not event then event = 'BufEnter' end
        if not pattern then pattern = '*' end

        a:add(event, pattern, cmd, {once=true})
        a:enable()

        spec.augroup = a
    elseif cond then
        if callable(cond) then
            if cond() then
                local cmd = get_pkgs_loader_cmd(spec[1], true)
                cmd()
            end
        end
    else
        local cmd = get_pkgs_loader_cmd(spec[1], false)
        if cmd then cmd() end
    end

    if rocks then each(download_rock, to_list(rocks)) end

    return spec
end

function pkgs.load_plugins(force)
    if Doom.pkgs.init then return Doom.pkgs.plugins end

    local specs = pkgs.plugin_specs

    if path.exists(pkgs.user_plugins_path) then
        merge(specs, require('user.pkgs.plugins'))
    end

    local t = {}

    for _, p in ipairs(specs.start) do
        p = to_list(p)
        push(t, parse_specs(p)) 
    end

    for _, p in ipairs(specs.opt) do
        p = to_list(p)
        push(t, parse_specs(p, true)) 
    end

    paq(t)

    pkgs.plugins = t
    pkgs.paq = paq
    Doom.pkgs.paq = paq
    Doom.pkgs.plugins = t

    Doom.pkgs.init = true

    return t
end

return pkgs
