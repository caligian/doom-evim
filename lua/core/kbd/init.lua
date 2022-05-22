local Class = require('classy')
local Buf = require('core.buffers')
local Au = require('core.au')
local Wk = require('which-key')
local Kbd = Class('doom-kbd')

if not Doom.kbd then
    Doom.kbd = {}
end

if not Doom.kbd.status then Doom.kbd.status = {} end

Kbd.status = Doom.kbd.status

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

Kbd.prefixes = Doom.kbd.prefixes

-- Disables and reenables autocmds and keybindings
function Kbd:replace(f, doc)
    assert(f)
    assert(doc)

    self.cmd = f
    self.doc = doc
    self:enable()

    if self.connected then
        for _, bufnr in ipairs(self.connected) do
            local buf = Buf(bufnr)

            buf:exec(function ()
                for _, m in ipairs(self.modes) do
                    vim.cmd(m .. 'unmap ' .. self.keys)
                end
            end)
        end
    end

    
    if self.au then
        self.au:delete()
        self.au = Au()

        -- To remove keybindings from buffers, exec ummap on each buffer.
        -- Record the buffer while self:enable()
        -- simply tabnew into those buffers and unmap them, However, ensure that those buffers exist.
        -- 
        self.au:add(self.event, self.pat, self.cmd)
        self.au:enable()
    end
end

local function wk_register(keys, doc)
    if keys:match('<leader>') then
        keys = keys:gsub('<leader>', '')
        Wk.register({[keys] = doc}, {prefix='<leader>'})
    elseif keys:match('<localleader>') then
        keys = keys:gsub('<localleader>', '')
        Wk.register({[keys] = doc}, {prefix='<localleader>'})
    elseif not keys:match('enabled') then
        Wk.register({[keys] = doc})
    end
end

-- opts required for au
function Kbd:__init(event, pat, modes, attribs, keys, f, doc, opts)
    opts = opts or {}
    self._binder = vim.api.nvim_set_keymap

    self.mapped = false

    if event then
        assert(pat)
    end

    if pat then
        assert(event)
    end

    assert(keys, 'Keys have not been supplied')
    assert(f, 'No command for keybinding has been supplied')
    assert(doc, 'No documentation for current keybinding has been supplied')

    local split_at_comma = function (s)
        return vim.split(s, "%s*,%s*")
    end

    if not modes then
        self.modes = {'n'}
    else
        self.modes = split_at_comma(trim(modes))
    end

    self.attribs = {}
    if not attribs then
        self.attribs = {silent=true}
    else
        for _, i in ipairs(split_at_comma(attribs)) do
           self.attribs[i] = true
        end
    end

    if self.attribs.buffer then
        self._binder = function (...)
            local buffer = vim.fn.bufnr()
            vim.api.nvim_buf_set_keymap(buffer, ...)
            self.connected = {}
            push(self.connected, buffer)
        end

        self.attribs.buffer = nil
    end

    if type(f) == 'function' then
        self.attribs.callback = f
        f = ''
    end

    self.attribs.desc = trim(doc)
    self.attribs.noremap = self.attribs.noremap == nil and true
    self.keys = trim(keys)
    self.cmd = f
    self.event = event
    self.pat = pat
    self.doc = doc
    self.opts = opts
end

function Kbd:enable()
    local function _apply()
        for _, m in ipairs(self.modes) do
            if #self.cmd > 0 then 
                self.cmd = ':' .. self.cmd .. '<CR>'
            end

            self._binder(m, self.keys, self.cmd, self.attribs)
            self.status[m] = self.status[m] or {}
            self.status[m][self.keys] = self
        end

        wk_register(self.keys, self.doc)
        self.mapped = true
    end

    if not self.event or not self.pat then
        _apply()
    else
        if not self.au then
            self.au = Au()
        end

        self.au:add(self.event, self.pat, function ()
            _apply()
        end, self.opts)

        self.au:enable()
    end
end

function Kbd:delete()
    local function _unbind()
        for _, m in ipairs(self.modes) do
            if self.mapped then
                vim.cmd(m .. 'unmap ' .. self.keys)
                self.status[m][self.keys] = nil
            end
        end

        self.mapped = false
    end

    if self.connected then
        for _, bufnr in ipairs(self.connected) do
            local buf = Buf(vim.fn.bufname(bufnr))
            buf:exec(_unbind)
        end

        self.connected = nil
    else
        _unbind()
    end

    if self.au then
        self.au:disable()
    end
end

function Kbd:disable()
    local function _unbind()
        for _, m in ipairs(self.modes) do
            if self.mapped then
                vim.cmd(m .. 'unmap ' .. self.keys)
            end
        end

        if self.mapped then
            self.mapped = false
        end
    end

    if self.connected then
        for _, bufnr in ipairs(self.connected) do
            local buf = Buf(vim.fn.bufname(bufnr))
            buf:exec(_unbind)
        end

        self.connected = nil
    else
        _unbind()
    end

    if self.au then
        self.au:disable()
    end
end

if not Doom.kbd.prefixes.enabled then
    Doom.kbd.prefixes.enabled = true

    for keys, doc in pairs(Doom.kbd.prefixes) do 
        wk_register(keys, doc)
    end
end

return Kbd
