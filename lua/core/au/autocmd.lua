--@module autocmd
--
local autocmd = deepcopy(require 'core.au.utils')
local m = {}

function autocmd.new(group, event, pattern, callback, opts)
    claim.string(event, pattern, group)
    claim.callable(callback)
    claim.opt_table(opts)

    if not Doom.au.status[group] then
        vim.cmd("augroup " .. group .. "\n    autocmd!\naugroup END")
        Doom.au.status[group] = create_status_t {}
    end

    --local existing = assoc(Doom.au.status, {group, event .. ' ' .. pattern}, {})
    --if existing.__vars then return existing end

    opts = opts or {}
    once = find(opts, 'once')
    nested = find(opts, 'nested')
    local self = {}

    if nested then 
        nested = '++nested' 
    else 
        nested = '' 
    end

    if once then
        once = '++once'
        local f = callback
        callback = function()
            f(self)
            self.enabled = false
        end
    else
        once = ''
    end

    local f = callback
    callback = function()
        f(self)
    end
    local cmd = sprintf('autocmd %s %s %s %s %s %s', group, event, pattern, once, nested, autocmd.register(callback, 'call'))
    cmd = cmd:gsub('%s+', ' ')
    local name = event .. ' ' .. pattern

    self = module.new('autocmd', {
        vars = {
            disable_cmd = sprintf('autocmd! %s %s %s', group, event, pattern);
            group = group;
            name = name;
            cmd = cmd;
            event = event;
            pattern = pattern;
            callback = callback;
            enabled = false;
            count = 0;
            once = #once > 1 and true or false;
            nested = #nested > 1 and true or false;
        }
    })
    self:include(m)
    update(Doom.au.status, {group, name}, self)

    return self
end

function m:enable(force)
    if force and self.enabled == false then
        return self
    end

    vim.cmd(self.cmd)
    self.enabled = true
    self.count = self.count + 1

    return self
end

function m:disable(force)
    self.enabled = false
    pcall(function()
        vim.cmd(self.disable_cmd)
    end)

    return self
end

return autocmd
