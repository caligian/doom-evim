local Class = require('classy')
local utils = require('modules.utils')
local tutils = require('modules.utils.table')
local Au = Class('doom-augroup')

if not _G.Doom then _G.Doom = {au={status={}, refs={}}} end

if not Doom.au.status then
    Doom.au.status = {}
end

if not Doom.au.refs then
    Doom.au.refs = {}
end

Au.status = Doom.au.status
Au.refs = Doom.au.refs

function Au.func2str(f)
    if type(f) == 'string' then
        return f
    elseif type(f) == 'function' then
        local _, idx = #(tutils.keys(self.status))
        return sprintf('lua _G.refs[%d]()', idx+1)
    end
end

function Au:__init(name, doc)
    self.name = name

    if not self.name then
        self.name = '_doom_group_' .. #self.refs + 1
    end

    if doc then
        self.doc = doc
    end

    -- Indexed in the form: `pat::event`
    self.autocmds = {}
end

-- if once=true then this autocmd will not be saved.
function Au:add(event, pat, f, opts)
    opts = opts or {}
    event = event or 'BufEnter'

    assert(pat)

    table.insert(_G.refs, f)
    f = self.func2str(f)

    pat = vim.split(pat, '%s*,%s*')
    event = vim.split(event, '%s*,%s*')

    for _, i in ipairs(pat) do
        for _, j in ipairs(event) do
            if opts.once then
                f = '++once ' .. f
            end

            if opts.nested then
                f = '++nested ' .. f
            end

            local cmd = sprintf('autocmd %s %s %s %s', self.name, j, i, f)
            local save_as = i .. '::' .. j
            self.autocmds[save_as] = cmd
        end
    end
end

function Au:exists()
    if not self.status[self.name] then
        return false
    else
        return true
    end
end

function Au:disable(opts)
    if not self:exists() then
        error {
            enabled = false,
            reason = 'Augroup has not been made. Please run enable(...)',
            au = self,
        }
    end

    opts = opts or {}
    local cmd = 'autocmd! ' .. self.name .. ' '

    if opts.pat and opts.event then
        local k = opts.pat .. '::' .. opts.event

        if opts.autocmds[k] then
            opts.autocmds[k] = nil
        end

        vim.cmd(cmd ..  opts.event .. ' ' .. opts.pat)
    elseif opts.pat then
        vim.cmd(cmd .. '* ' .. opts.pat)
    elseif opts.event then
        vim.cmd(cmd .. opts.event .. ' ' .. opts.pat)
    else
        vim.cmd(cmd)
    end

    self.enabled = true
end

function Au:enable(opts)
    opts = opts or {}

    if not self.status[self.name] then
        vim.cmd("augroup " .. self.name .. "\n    autocmd!\naugroup END")
        self.status[self.name] = self
    end

    if opts.regex then
        for k, v in pairs(self.autocmds) do
            -- This will match against aupat::auevent in self.autocmds
            if k:match(opts.regex) then
                vim.cmd(v)
            end
        end
    elseif opts.pat and opts.event then
        local au = opts.pat .. '::' .. opts.event
        
        if self.autocmds[au] then
            vim.cmd(self.autocmds[au])
        end
    else
        for _, value in pairs(self.autocmds) do
            vim.cmd(value)
        end
    end
end

function Au:delete(opts)
    pcall(self.disable, self, opts)
    self.status[self.pat .. '::' .. self.event] = nil
end

return Au
