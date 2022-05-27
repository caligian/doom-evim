local class = require('classy')
local au = require('core.au')
local wk = false
local kbd = class('doom-kbd')

kbd.status = Doom.kbd.status

if not Doom.kbd.prefixes then
    Doom.kbd.prefixes = {
        enabled = false,

        ["<leader>b"] = "Buffer",
        ["<leader>q"] = "Buffers+close",
        ["<leader>c"] = "Commenting",
        ["<leader>i"] = "Insert",
        ["<leader><space>"] = "Misc",
        ["<leader>l"] = "LSP",
        ["<leader>t"] = "Tabs",
        ["<leader>o"] = "Neorg",
        ["<leader>h"] = "Help+Telescope",
        ["<leader>f"] = "Files",
        ["<leader>p"] = "Project",
        ["<leader>d"] = "Debug",
        ["<leader>&"] = "Snippets",
        ["<leader>x"] = "Misc",
        ["<leader>m"] = "Filetype Actions",
        ["<leader>s"] = "Session",
        ["<leader>g"] = "Git",
        ["<localleader>,"] = "REPL",
        ["<localleader>t"] = "REPL",
        ["<localleader>e"] = "REPL",
    }
end

kbd.prefixes = Doom.kbd.prefixes

local function wk_register(m, keys, doc, bufnr)
    oblige(m)
    oblige(keys)
    oblige(doc)

    if not packer_plugins['which-key.nvim'] then
        return 
    else
        wk = require('which-key')
    end

    local opts = {buffer=bufnr}
    local has_prefix = match(keys, 'leader')

    if keys:match('<leader>') then
        keys = keys:gsub('<leader>', '')
        opts.prefix = '<leader>'
    elseif keys:match('<localleader>') then
        keys = keys:gsub('<localleader>', '')
        opts.prefix = '<localleader>'
    end

    if has_prefix then
        wk.register({[keys] = doc}, opts)
    else
        wk.register({[keys] = doc}, opts)
    end
end

local bindstr = function(modes, keys, f, attribs, doc)
    attribs = attribs or {'silent', 'nowait'}
    attribs = to_list(attribs)
    attribs = map(function(s)
        return sprintf('<%s>', s)
    end, attribs)
    attribs = join(attribs, " ")

    local noremap
    attribs, noremap = attribs:gsub('<noremap>', '')
    attribs = trim(attribs)
    local cmds = {}
    local _f = f

    each(function(m)
        if callable(f) then
            _f = ':' .. au.func2ref(f) .. '<CR>'
            push(Doom.au.refs, f)
        end

        if noremap ~= 0 then
            local s = sprintf('%snoremap %s %s %s', m, attribs, keys, _f)
            push(cmds, s)
        else
            local s = sprintf('%smap %s %s %s', m, attribs, keys, _f)
            push(cmds, s)
        end
        wk_register(m, keys, doc, bufnr)
    end, modes)

    return cmds
end

local function event_bind(event, pattern, modes, keys, f, attribs, doc)
    assert(event or pattern)

    attribs = to_list(attribs)
    if not find(attribs, 'buffer') then 
        push(attribs, 'buffer') 
    end
    event =  event or 'BufEnter'
    pattern = pattern or '*.' .. vim.bo.filetype
    event = to_list(event)
    pattern = to_list(pattern)

    local au = au('doom_kbd_' .. #Doom.au.status+1, sprintf('Augroup for keybinding: [%s] %s', join(modes, ","), keys))

    local _bind = function(m, cmd)
        return function()
            local bufnr = match(pattern, '<buffer=(%d+)>')
            bufnr = bufnr or vim.fn.bufnr()
            wk_register(m, keys, doc, bufnr)
            vim.cmd(cmd)
        end
    end

    each(function(e)
        each(function(p)
            each(function(cmd)
                -- Needs debugging here. 
                -- Just make the necessary changes wherever bindstr is present. 
                -- Also ensure that bindstr() returns {[mode] = cmd}
                cmd = sprintf('exe "%s"', cmd)
                cmd = _bind()
                au:add(e, p, )
            end, bindstr(modes, keys, f, attribs, doc))
        end, pattern)
    end, event)

    return au
end

function kbd:__init(modes, keys, f, attribs, doc, event, pattern)
    self.modes = modes
    self.keys = keys
    self.f = f
    self.attribs = attribs
    self.event = event
    self.pattern = pattern
    self.doc = doc
    self.mapped = false

    oblige(keys)
    oblige(f)
    oblige(doc)
end

function kbd:backup_previous(m)
    local modes = m or self.modes
    modes = to_list(modes)
    assoc(self, {'previous_cmds'}, {})

    local _get_cmd = function(m, t)
        local _cmd = ''

        local _a = trim(join(map(function(_attrib)
            if t[_attrib] == 1 then
                return sprintf('<%s>', _attrib)
            else
                return ''
            end
        end, {'silent', 'nowait', 'expr', 'buffer'}), " "))

        if t.noremap == 1 then
            return sprintf('%snoremap %s %s %s', m, _a, t.lhs, t.rhs)
        else
            return sprintf('%smap %s %s %s', m, _a, t.lhs, t.rhs)
        end
    end

    each(function(m)
        push(self.previous_cmds, _get_cmd(m, vim.fn.maparg(self.keys, m, false, 1)))
    end, modes)

    return self.previous_cmds
end

function kbd:enable(force)
    self:backup_previous()

    if self.event or self.pattern then
        if not self.au then 
            self.au = event_bind(self.event, self.pattern, self.modes, self.keys, self.f, self.attribs)
        end

        if force or not self.mapped then
            self.au:enable()
        end
    elseif force or not self.mapped then
        each(vcmd, bindstr(self.modes, self.keys, self.f, self.attribs))
    end

    self.mapped = true
end

function kbd:restore_previous()
    if not self.previous_cmds then return false end
    self:disable()
    self.au = nil

    each(function(m)
        vcmd(self.previous_cmds[m])
        self.previous_cmds[m] = nil
    end, keys(self.previous_cmds))

    self.previous_cmds = nil

    return true
end

function kbd:disable()
    if not self.mapped then return false end

    local _disable = function(m) 
        self:backup_previous(m)

        pcall(function() 
            vcmd(sprintf('%sunmap! %s', m, self.keys))
        end)

        self.mapped = false
    end

    if self.au then
        self.au:disable()
    end

    each(_disable, self.modes)
    
    self:restore_previous()

    return true 
end

function kbd:replace(modes, f, attribs, event, pattern)
    if event then self.event = event end
    if pattern then self.pattern = pattern end
    if modes then self.modes = modes end
    if f then self.f = f end
    if attribs then self.attribs = attribs end
    local keys = self.keys

    self:disable()

    if self.event or self.pattern then
        self.au = event_bind(self.event, self.pattern, self.modes, self.keys, self.f, attribs)
        self.au:enable()
    else
        each(vcmd, bindstr(self.modes, self.keys, self.f, self.attribs))
    end

    self.mapped = true
end

return kbd
