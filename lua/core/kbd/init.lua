local class = require('classy')
local au = require('core.au')
local wk = false
local kbd = class('doom-kbd')
kbd.prefixes = Doom.kbd.prefixes

function kbd.wk_register(mode, keys, doc, bufnr)
    oblige(mode)
    oblige(keys)
    oblige(doc)

    if not packer_plugins['which-key.nvim'] then
        return 
    else
        wk = require('which-key')
    end

    local opts = {buffer=bufnr, mode=mode}

    if keys:match('<leader>') then
        keys = keys:gsub('<leader>', '')
        opts.prefix = '<leader>'
    elseif keys:match('<localleader>') then
        keys = keys:gsub('<localleader>', '')
        opts.prefix = '<localleader>'
    end

    if opts.prefix then
        wk.register({[keys] = doc}, opts)
    else
        wk.register({[keys] = doc}, opts)
    end
end

function kbd:__init(mode, keys, f, attribs, doc, event, pattern)
    assert(keys)
    assert(f)
    assert(doc)

    self.mode = mode
    self.keys = keys
    self.f = f 
    self.attribs = attribs
    self.doc = doc
    self.event = event
    self.pattern = pattern
    self.mapped = false
end

function kbd:backup_previous()
    assoc(self, {'previous'}, {})

    local previous = self.previous[#self.previous]
    local current = vim.fn.maparg(self.keys, self.mode, false, 1)

    if #keys(current) == 0 then return false end
    if previous and previous.rhs == current.rhs then return false end

    local _a = trim(join(map(function(_attrib)
        if current[_attrib] == 1 then
            return sprintf('<%s>', _attrib)
        else
            return ''
        end
    end, {'silent', 'nowait', 'expr', 'buffer'}), " "))

    local mode = self.mode
    if current.noremap == 1 then
        mode = mode .. 'noremap'
    else
        mode = mode .. 'map'
    end

    local t = {
        mode .. ' ' .. _a .. ' ' .. current.lhs .. ' ' .. current.rhs;
        mapped = false;
        rhs = current.rhs;
    }

    push(self.previous, t)

    return self.previous
end


function kbd:enable(force)
    if not force and self.mapped then return end

    self:backup_previous()

    assert(self.keys)
    assert(self.f)
    assert(self.doc)

    self.mode = self.mode or 'n'
    self.keys = trim(self.keys)
    self.attribs = self.attribs or {'silent', 'nowait'}
    self.attribs = list_to_dict(to_list(self.attribs))
    self.attribs.buffer = true
    local is_noremap = self.attribs.noremap ~= nil
    self.attribs.noremap = nil
    self.attribs = join(map(function(s) return sprintf('<%s>', s) end, keys(self.attribs)), " ")

    if callable(self.f) then
        local _f = au.register(self.f)
        self.f = ':' .. au.register(self.f) .. '<CR>'
    end

    if self.event or self.pattern then
        self.event =  self.event or 'BufEnter'
        self.pattern = self.pattern or '*.' .. vim.bo.filetype
        local bufnr = match(self.pattern, '<buffer=(%d+)>') or vim.fn.bufnr()
        bufnr = tonumber(bufnr)
        self.au = au('doom_kbd_' .. #Doom.au.status, sprintf('Augroup for keybinding: [%s] %s', self.mode, self.keys))

        self.global = false
        self.mapped = true

        self.au:add(self.event, self.pattern, function()
            local cmd = ''

            if is_noremap then
                cmd = sprintf('%snoremap %s %s %s', self.mode, self.attribs, self.keys, self.f)
            else
                cmd = sprintf('%smap %s %s %s', self.mode, self.attribs, self.keys, self.f)
            end

            bufnr = bufnr or vim.fn.bufnr()
            kbd.wk_register(self.mode, self.keys, self.doc, bufnr)
            assoc(self, {'buffers'}, {})
            push(self.buffers, bufnr)
            vim.cmd(cmd)
        end)

        self.au:enable()

        return self.au
    else
        local cmd = ''
        if is_noremap then
            cmd = sprintf('%snoremap %s %s %s', self.mode, self.attribs, self.keys, self.f)
        else
            cmd = sprintf('%smap %s %s %s', self.mode, self.attribs, self.keys, self.f)
        end
        kbd.wk_register(self.mode, self.keys, self.doc, bufnr)

        self.global = true
        self.mapped = true
        vim.cmd(cmd)

        return cmd
    end
end

function kbd:restore_previous()
    if not self.previous or #self.previous == 0 then return false end

    for index, cmd in ipairs(self.previous) do
        if not cmd.mapped then
            vcmd(first(cmd))
            cmd.mapped = true
        end
    end

    return true
end

function kbd:disable()
    if not self.mapped then return false end

    if self.au then self.au:disable() end
    self.mapped = false

    if self.global then
        pcall(function() vim.cmd(sprintf('%sunmap! %s', self.mode, self.keys))  end)
    elseif self.au then
        self.au:disable()

        if self.buffers then
            each(function(bufnr) 
                pcall(function() vim.api.nvim_buf_del_keymap(bufnr, self.mode, self.keys) end)
            end, self.buffers)
            
            self.buffers = {}
        end
    end

    self:restore_previous()

    return true 
end

function kbd:replace(f, attribs, doc, event, pattern)
    self:disable()

    self.f = f or self.f
    self.attribs = attribs or self.attribs
    self.event = event or self.event
    self.pattern = pattern or self.pattern
    self.doc = doc or self.doc

    self:enable()
end

function kbd:save()
    update(Doom.keybindings, {self.mode, self.keys}, self) 
end

return kbd
