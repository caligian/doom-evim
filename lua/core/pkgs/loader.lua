-- Run .addPaths() to avoid errors such as 'missing path' while requiring hooks

local Yaml = require('yaml')
local Utils = require('doom-utils')
local Path = require('path')
local Fs = require('path.fs')
local doomConfig = vim.fn.stdpath('config')

local PackageLoader = {
    -- Packages that are absolutely necessary
    essentialPackagesPath = Path(doomConfig, 'yaml', 'essentials.yaml'),

    -- Packages that are necessary but not necessary for bootstrapping
    defaultPackagesPath = Path(doomConfig, 'yaml', 'default.yaml'),

    -- Add paths to nvim to require lua modules quickly
    pathsPath = Path(doomConfig, 'yaml', 'paths.yaml'),

    -- Configurations for individual packages are stored here
    preConfPath = Path(doomConfig, 'lua', 'configs', 'pre'),
    postConfPath = Path(doomConfig, 'lua', 'configs', 'post'),
    postInstallConfPath = Path(doomConfig, 'lua', 'configs', 'post-install'),

    -- User stuff
    userPackagesPath = Path(os.getenv('HOME'), '.vdoom.d', 'user', 'yaml', 'packages.yaml'),
    userPathsPath = Path(os.getenv('HOME'), '.vdoom.d', 'user', 'yaml', 'paths.yaml'),
    userPreConfPath = Path(os.getenv('HOME'), '.vdoom.d', 'user', 'configs', 'pre'),
    userPostConfPath = Path(os.getenv('HOME'), '.vdoom.d', 'user', 'configs', 'post'),
    userPostInstallConfPath = Path(os.getenv('HOME'), '.vdoom.d', 'user', 'configs', 'post-install'),
}

if not Path.exists(PackageLoader.userPackagesPath) then
    Fs.mkdir(PackageLoader.userPackagesPath)
end

function PackageLoader.loadYAML(path)
    if Path.exists(path) then
        local fh = io.open(path, 'r')
        local s = fh:read('*a')
        fh:close()
        return Yaml.load(s)
    else
        return {}
    end
end

function PackageLoader.saveYAML(path, data)
    local fh = io.open(path, 'w')
    fh:write(Yaml.dump(data))
    fh:close()
end

function PackageLoader.getPackageHook(_type, pkg, hookType)
    local path = ''

    if _type == 'user' then
        if hookType == 'pre' then
            path = 'user.configs.pre'
        elseif hookType == 'post' then
            path = 'user.configs.post'
        elseif hookType == 'post-install' then
            path = 'user.configs.post-install'
        end
    else
        if hookType == 'pre' then
            path = 'configs.pre'
        elseif hookType == 'post' then
            path = 'configs.post'
        elseif hookType == 'post-install' then
            path = 'configs.post-install'
        end
    end

    path = path .. '.' .. pkg
    return function() require(path) end
end

function PackageLoader.createMasterList()
    local essentials = PackageLoader.loadYAML(PackageLoader.essentialPackagesPath)
    local default = PackageLoader.loadYAML(PackageLoader.defaultPackagesPath)
    local user = PackageLoader.loadYAML(PackageLoader.userPackagesPath)
    local doomPlusUser = vim.tbl_extend('force', essentials, default)
    local packerForms = {}

    for pkg, conf in pairs(doomPlusUser) do
        local packerForm = {}
        assert(conf.repo ~= nil)

        table.insert(packerForm, conf.repo)

        local preHook = PackageLoader.getPackageHook('doom', pkg, 'pre')
        local postHook = PackageLoader.getPackageHook('doom', pkg, 'post')
        local postInstallHook = PackageLoader.getPackageHook('doom', pkg, 'post-install')

        if postInstallHook then
            packerForm.run = postInstallHook
        end

        if preHook then
            packerForm.setup = postInstallHook
        end

        if postHook then
            packerForm.config = postHook
        end

        conf.repo = nil
        conf.desc = nil
        conf.postHook = nil
        conf.preHook = nil
        conf.postInstallHook = nil

        -- Add all the other keys
        for k, v in pairs(conf) do
            packerForm[k] = v
        end

        table.insert(packerForms, packerForm)
    end

    for pkg, conf in pairs(user) do
        local packerForm = {}
        assert(conf.repo ~= nil)

        table.insert(packerForm, conf.repo)

        local preHook = PackageLoader.getPackageHook('user', pkg, 'pre')
        local postHook = PackageLoader.getPackageHook('user', pkg, 'post')
        local postInstallHook = PackageLoader.getPackageHook('user', pkg, 'post-install')

        if postInstallHook then
            packerForm.run = postInstallHook
        end

        if preHook then
            packerForm.setup = postInstallHook
        end

        if postHook then
            packerForm.config = postHook
        end

        conf.repo = nil
        conf.postHook = nil
        conf.preHook = nil
        conf.postInstallHook = nil
        conf.desc = nil

        for k, v in pairs(conf) do
            packerForm[k] = v
        end

        table.insert(packerForms, packerForm)
    end

    return packerForms
end

function PackageLoader.addPaths()
    local luapaths = PackageLoader.loadYAML(PackageLoader.pathsPath)
    local userLuapaths = PackageLoader.loadYAML(PackageLoader.userPathsPath)

    -- For expanding environ vars
    local envVars = setmetatable({}, {
        __index = function (self, k)
            local env = os.getenv(k)
            assert(env)
            rawset(self, k, env)
            return env
        end
    })

    for _, p in ipairs(luapaths.paths or {}) do
        p = string.gsub(p, '[$](%w+)', envVars)
        package.path = string.format('%s;%s', package.path, p)
    end

    for _, p in ipairs(luapaths.cpaths or {}) do
        p = string.gsub(p, '[$](%w+)', envVars)
        package.cpath = string.format('%s;%s', package.cpath, p)
    end

    for _, p in ipairs(userLuapaths.paths or {}) do
        p = string.gsub(p, '[$](%w+)', envVars)
        package.path = string.format('%s;%s', package.path, p)
    end

    for _, p in ipairs(userLuapaths.cpaths or {}) do
        p = string.gsub(p, '[$](%w+)', envVars)
        package.cpath = string.format('%s;%s', package.cpath, p)
    end
end

return PackageLoader
