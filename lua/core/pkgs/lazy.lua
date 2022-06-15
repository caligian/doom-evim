--[[
Simple lazy loader for plugins that does not rely upon packer

Principles: 
- Use paq for basic package operations: Updating, etc
- Create a simple autocmd based lazy-loading
--]]

local class = require('classy')
local lazy = {
    -- Lazy packages will be loaded from site/pack/paq/opt
    base_path = with_data_path('site', 'pack', 'doom');
    path = with_data_path('site', 'pack', 'doom', 'opt');
    default_path = with_data_path('site', 'pack', 'doom', 'start');
    plugins_path = with_config_lua_path('core', 'pkgs', 'plugins.lua');
    user_plugins_path = with_user_config_path('lua', 'user', 'pkgs', 'plugins.lua');
    plugin_specs = require('core.pkgs.plugins'); 
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

local function get_lazy_loader_cmd(plugin, config)
    plugin = sed(plugin, {'[^A-Za-z0-9_.-]+', ''}, {'\\.', '_'})
    local dst = with_config_lua_path('core', 'pkgs', 'configs', plugin .. '.lua')
    local req_path = false

    if path.exists(dst) and not Doom.pkgs.loaded[plugin] then 
        req_path = sprintf("core.pkgs.configs.%s", plugin)
    end

    if req_path then
        return au.register(vim.schedule(function()
            vim.cmd('packadd! ' .. plugin)
            Doom.pkgs.loaded[plugin] = true
            if config then vim.cmd(au.register(config)) end
        end))
    end

    return ''
end

local function parse_specs(spec, opt)
    assert(spec[1])

    assert_s(spec[1])
    assert_type(spec.keys, 'table', 'string')
    assert_type(spec.pattern, 'table', 'string')
    assert_type(spec.rocks, 'table', 'string')
    assert_type(spec.event, 'table', 'string')
    assert_callable(spec.cond)
    assert_bool(opt)

    spec.opt = opt
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

        cmd = cmd .. get_lazy_loader_cmd(spec[1], _f) .. ' <CR>'

        spec.cmd = cmd

        vim.cmd(cmd)
    elseif event or pattern then
        assert(pattern)

        pattern = copy(pattern)
        if event then event = copy(event) end
        local a = au(spec[1], 'Oneshot autocmd for plugin: ' .. spec[1])
        a:add(event or 'BufEnter', pattern, get_lazy_loader_cmd(spec[1], false, true), {once=true})
        a:enable()
        spec.augroup = a
    end

    if rocks then each(download_rock, to_list(rocks)) end

    return spec
end

function lazy.load_plugins()
    local specs = lazy.plugin_specs

    if path.exists(lazy.user_plugins_path) then
        merge(specs, require('user.pkgs.plugins'))
    end

    paq(extend(specs.start, map(function(p)
        p = to_list(p)
        p.opt = true
    end, specs.opt)))
    

    for k, v in pairs(lazy.plugin_specs.start) do
    end
end
