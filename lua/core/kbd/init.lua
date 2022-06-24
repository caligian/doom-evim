local au = require('core.au')
local wk = require('which-key')
local ex = require('core.kbd.exception')

local kbd = class('doom-keybinding')
assoc(Doom.kbd, 'status', {})
assoc(Doom.kbd, 'defaults', {})

local defaults = Doom.kbd.defaults
defaults.attribs = {'silent', 'nowait', 'noremap'}
defaults.mode = 'n'

kbd.defaults = defaults
kbd.status = Doom.kbd.status
kbd.prefixes = Doom.kbd.prefixes

function kbd.wk_register(mode, keys, doc, bufnr)
    assert(mode, ex.no_mode())
    assert(keys, ex.no_keys())
    assert(doc, ex.no_doc())

    assert_type(mode, 'string', 'table')
    assert_s(keys)
    assert_s(doc)

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

function kbd.find(mode, keys, n)
    assert(mode, ex.no_mode())
    assert(keys, ex.no_keys())

    if n == nil or n == false then
        n = 1
    else
        assert_n(n)
    end

    return assoc(Doom.kbd.status, {mode, keys, n})
end

function kbd.load_prefixes()
    if Doom.kbd.prefixes_loaded then return end

    each(function(prefix) 
        local doc = Doom.kbd.prefixes[prefix]
        local leader = match(prefix, '<[^>]+>')
        wk.register({[prefix]={name=doc}})
    end, keys(Doom.kbd.prefixes))

    Doom.kbd.prefixes_loaded = true
end

function kbd:__init(mode, keys, f, attribs, attribs_s, doc, event, pattern)
    self.mode = mode
    self.keys = keys
    self.f = f
    self.attribs = attribs
    self.attribs_s = attribs_s
    self.doc = doc
    self.event = event
    self.pattern = pattern
    self.mapped = false
end

function kbd.new(mode, keys, f, attribs, doc, event, pattern)
    assert(mode, ex.no_mode())
    assert(keys, ex.no_keys())
    assert(doc, ex.no_doc())
    assert(f, ex.no_f())

    assert_type(mode, 'string', 'table')
    assert_s(keys)
    assert_s(doc)
    assert_type(f, 'string', 'callable')
    assert_type(attribs, 'string', 'table', 'boolean')
    assert_type(event, 'string', 'table')
    assert_type(pattern, 'string', 'table', 'number')

    attribs = attribs or defaults.attribs
    attribs = to_list(attribs)

    if event then event = to_list(event) end

    if pattern and num_p(pattern) then
        assert(vim.fn.bufnr(pattern) ~= -1, 'Invalid bufnr provided: ' .. pattern)
        pattern = sprintf('<buffer=%d>', pattern) 
    end

    if pattern then pattern = to_list(pattern) end

    local noremap = find(attribs, 'noremap')
    if noremap then attribs[noremap] = nil end

    noremap = noremap ~= nil and true
    local attribs_s = join(map(function(s)
        if str_p(s) then
            return sprintf('<%s>', s)
        else
            return ''
        end
    end, attribs), ' ')

    local self = kbd(mode, keys, f, attribs, attribs_s, doc, event, pattern)
    assoc(self.status, {mode, keys}, {})
    push(self.status[mode][keys], self)

    return self
end

function kbd:backup_previous()
    assoc(self, {'previous'}, {})

    local previous = self.previous[#self.previous]
    local current = vim.fn.maparg(self.keys, self.mode, false, 1)

    if #keys(current) == 0 then return false end
    if previous and previous.rhs == current.rhs or self.f == current.rhs then return false end

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
        mapped = 0,
        rhs = current.rhs;
    }

    push(self.previous, t)

    return self.previous
end

function kbd:enable(force)
    if not force and self.mapped then return end

    self:backup_previous()

    if callable(self.f) then
        self.f = au.register(self.f, 'key')
    end

    if self.event or self.pattern then
        self.event =  self.event or 'BufEnter'
        self.pattern = self.pattern or sprintf('<buffer=%d>', vim.fn.bufnr())
        self.au = au.new('doom_kbd_' .. #Doom.au.status, sprintf('Augroup for keybinding: [%s] %s', self.mode, self.keys))
        self.global = false
        self.mapped = true

        assoc(self, {'buffers'}, {})

        self.au:add(self.event, self.pattern, function()
            local cmd = ''

            if self.noremap then
                cmd = sprintf('%snoremap %s %s %s', self.mode, self.attribs_s, self.keys, self.f)
            else
                cmd = sprintf('%smap %s %s %s', self.mode, self.attribs_s, self.keys, self.f)
            end

            local bufnr = vim.fn.bufnr()
            kbd.wk_register(self.mode, self.keys, self.doc, bufnr)

            push(self.buffers, bufnr)
            vim.cmd(cmd)
        end)

        self.au:enable()

        return self.au
    else
        local cmd = ''
        if self.noremap then
            cmd = sprintf('%snoremap %s %s %s', self.mode, self.attribs_s, self.keys, self.f)
        else
            cmd = sprintf('%smap %s %s %s', self.mode, self.attribs_s, self.keys, self.f)
        end

        kbd.wk_register(self.mode, self.keys, self.doc)

        self.global = true
        self.mapped = true
        self.cmd = cmd
        vim.cmd(cmd)

        return cmd
    end
end

-- Restore nth previous keybinding
function kbd:restore_previous(n)
    assert_num(n)
    n = n or 1
    assert(n > 0, ex.index_not_valid)

    if not self.previous or #self.previous == 0 then return false end
    if #self.previous > n then n = #self.previous end

    local prev = self.previous[n]
    prev.mapped = prev.mapped + 1
    vim.cmd(first(prev))

    return true
end

function kbd:disable(buffers)
    assert_type(buffers, 'number', 'table')
    
    buffers = to_list(buffers)

    if not self.mapped then return false end

    if self.au then self.au:disable() end
    self.mapped = false

    if self.global then
        pcall(function() vim.cmd(sprintf('%sunmap! %s', self.mode, self.keys))  end)
    elseif self.au then
        self.au:disable()

        if self.buffers then
            if not buffers then
                buffers = keys(self.buffers)
            else
                buffers = intersection(buffers, keys(self.buffers))
            end

            each(function(bufnr) 
                pcall(function() 
                    vim.api.nvim_buf_del_keymap(bufnr, self.mode, self.keys)
                end)

                self.buffers[bufnr] = nil
            end, self.buffers)
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


function kbd.oneshot(mode, keys, f, attribs)
    assert(mode, ex.no_mode())
    assert(keys, ex.no_keys())
    assert(f, ex.no_f())

    assert_s(mode, 'string')
    assert_s(keys)
    assert_type(f, 'string', 'callable')
    assert_type(attribs, 'string', 'table', 'boolean')

    attribs = attribs or defaults.attribs
    attribs = to_list(attribs)
    local noremap = find(attribs, 'noremap')
    if noremap then attribs[noremap] = nil end
    attribs = vals(attribs)
    noremap = noremap ~= nil and true

    attribs_s = join(map(function(s)
        if str_p(s) then
            return sprintf('<%s>', s)
        else
            return ''
        end
    end, attribs), ' ')

    local new_f = false

    new_f = au.register(function()
        pcall(function() 
            vim.cmd(sprintf('%sunmap %s', mode, keys)) 
        end)
        if str_p(f) then 
            vim.cmd(f)
        else
            f()
        end
    end, 'key')

    local cmd = ''

    if noremap then
        cmd = sprintf('%snoremap %s %s %s', mode, attribs_s, keys, new_f)
    else
        cmd = sprintf('%smap %s %s %s', mode, attribs_s, keys, new_f)
    end

    vim.cmd(cmd)

    return cmd
end

return kbd
