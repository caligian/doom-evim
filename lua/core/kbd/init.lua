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

    local current = vim.fn.maparg(self.keys, self.mode, false, 1)
    if current ~= '' then return false end
    if previous.rhs == current.rhs then return false end

    if not previous.rhs == current.rhs then
        local _a = trim(join(map(function(_attrib)
            if t[_attrib] == 1 then
                return sprintf('<%s>', _attrib)
            else
                return ''
            end
        end, {'silent', 'nowait', 'expr', 'buffer'}), " "))

        if current.noremap == 1 then
            push(self.previous, {sprintf('%snoremap %s %s %s', self.mode, _a, current.lhs, current.rhs), rhs=current.rhs})
        else
            push(self.previous, {sprintf('%smap %s %s %s', self.mode, _a, current.lhs, current.rhs), rhs=current.rhs})
        end
    end

    return self.previous
end

function kbd:enable(force)
    if not force and not self.mapped then return end

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
    self.attribs = join(map(function(s) return sprintf('<%s>', s) end, keys(attribs)), " ")

    local _f = self.f
    if callable(self.f) then
        _f = ':' .. au.func2ref(self.f) .. '<CR>'
        push(Doom.au.refs, self.f)
    end
    self.f = _f

    if event or self.pattern then
        self.event =  self.event or 'BufEnter'
        self.pattern = self.pattern or '*.' .. vim.bo.filetype
        self.event = to_list(self.event)
        self.pattern = to_list(self.pattern)
        local bufnr = match(self.pattern, '<buffer=(%d+)>') or vim.fn.bufnr()
        self.au = au('doom_kbd_' .. #Doom.au.status, sprintf('Augroup for keybinding: [%s] %s', self.mode, self.keys))
        local cmd = ''

        if is_noremap then
            cmd = sprintf('%snoremap %s %s %s', self.mode, self.attribs, self.keys, self.f)
        else
            cmd = sprintf('%smap %s %s %s', self.mode, self.attribs, self.keys, self.f)
        end

        local _bind = function()
            bufnr = bufnr or vim.fn.bufnr()
            kbd.wk_register(self.mode, self.keys, self.doc, bufnr)
            assoc(self.buffers, bufnr, true)
            self.buffers[bufnr] = sprintf('autocmd BufEnter <buffer=%d> ++once :silent! exe "%sunmap %s"', bufnr, self.mode, self.keys)
            vim.cmd(cmd)
        end

        self.global = false
        self.mapped = true
        self.au:add(self.event, self.pattern, self.f)
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

function kbd:restore()
    if not self.previous or #self.previous == 0 then return false end

    self:disable()
    self.au = nil

    for index, cmd in ipairs(self.previous) do
        vcmd(first(cmd))
    end

    self.previous = nil
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
            each(function(disable_au) vim.cmd(disable_au) end, vals(self.buffers))
            self.buffers = nil
        end
    end

    self:restore_previous()

    return true 
end

function kbd:replace(mode, f, attribs, event, pattern)
    self:disable()

    self.mode = mode or self.mode
    self.f = f or self.f
    self.attribs = attribs or self.attribs
    self.event = event or self.event
    self.pattern = pattern or self.pattern
    self.doc = doc or self.doc

    self:enable()
end

return kbd
