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
- cond & rocks

keys    string|table[string]
Load package after pressing these keys. 
Keys should be in the format:
{mode, keys, attribs, doc, event, pattern} where attribs, event, pattern can be string|table and the rest must be strings or keys
If keys is a string then it will be mapped with noremap {keys} {plugin loader}

event   string|table[string]
Load package after this event.

pattern string|table[string]
Load package if pattern is true for buffer, files, etc.

cond    callable
If cond returns true, load the package

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

local function get_pkgs_loader_cmd(plugin, config)
    local req_path = false
    plugin = path.name(plugin)
    plugin = sed(plugin, {'[^A-Za-z0-9_.-]+', ''}, {'\\.', '_'})
    local dst = with_config_lua_path('core', 'pkgs', 'configs', plugin .. '.lua')
    local cmd = 'packadd! ' .. plugin
     
    if path.exists(dst) then 
        req_path = sprintf("core.pkgs.configs.%s", plugin)

        return au.register(function()
            vim.cmd(cmd)
            require(req_path)
            Doom.pkgs.loaded[plugin] = true
            if config then vim.cmd(au.register(config)) end
        end)
    end

    return cmd
end

local function parse_specs(spec, opt)
    assert(spec)

    assert_type(spec, 'string', 'table')
    spec = to_list(spec)

    assert_s(spec[1])

    --if Doom.pkgs.loaded[spec[1]] then
        --return 
    --end

    assert_type(spec.keys, 'table', 'string')
    assert_type(spec.pattern, 'table', 'string')
    assert_type(spec.rocks, 'table', 'string')
    assert_type(spec.event, 'table', 'string')
    assert_callable(spec.cond)

    opt = opt == nil and false

    spec.opt = opt == false and nil
    local keys = spec.keys
    local pattern = spec.pattern
    local event = spec.event
    local rocks = rocks

    if keys then
        keys = copy(spec.keys)

        local _mode, _keys, _f, _attribs = false, false, false, false

        if table_p(keys) then
            _mode, _keys, _f, _attribs = unpack(keys)
            assert(_mode)
            assert(_keys)

            assert_s(_mode)
            assert_s(_keys)
            assert_type(_attribs, 'table', 'string')
            assert_type(_f, 'callable', 'string')
        end

        _mode = _mode or 'n'
        _attribs = _attribs or {'noremap', 'silent', 'nowait'}

        local noremap = false

        if str_p(_attribs) then
            _attribs = to_list(_attribs)
        end

        noremap = find(_attribs, 'noremap')
        if noremap then table.remove(_attribs, noremap) end
        noremap = noremap and true

        _attribs = join(map(function(a) return '<' .. a .. '>' end, _attribs), ' ')

        local cmd = ''
        if noremap then
            cmd = sprintf('%snoremap %s %s ', _mode, _attribs, _keys)
        else
            cmd = sprintf('%smap %s %s ', _mode, _attribs, _keys)
        end

        cmd = cmd .. get_pkgs_loader_cmd(spec[1], _f) .. sprintf(' <bar> %sunmap %s<CR>', _mode, _keys)

        spec.cmd = cmd

        vim.cmd(cmd)
    elseif event or pattern then
        assert(pattern)

        pattern = copy(pattern)
        if event then event = copy(event) end
        local a = au(spec[1], 'Oneshot autocmd for plugin: ' .. spec[1])

        local cmd = get_pkgs_loader_cmd(spec[1], true)
        a:add(event or 'BufEnter', pattern, cmd, {once=true})
        a:enable()
        spec.augroup = a
    end

    if rocks then each(download_rock, to_list(rocks)) end

    Doom.pkgs.loaded[spec[1]] = true

    return spec
end

function pkgs.load_plugins()
    local specs = pkgs.plugin_specs

    if path.exists(pkgs.user_plugins_path) then
        merge(specs, require('user.pkgs.plugins'))
    end

    local t = {}

    for _, p in ipairs(specs.start) do
        push(t, parse_specs(p)) 
    end

    for _, p in ipairs(specs.opt) do
        push(t, parse_specs(p, true)) 
    end

    paq(t)
end

return pkgs
