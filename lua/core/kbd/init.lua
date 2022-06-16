local au = require('core.au')
local wk = require('which-key')
local ex = require('core.kbd.exception')

local kbd = class('doom-keybinding')
assoc(Doom.kbd, 'status', {})
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

    n = n or 1
    assert_n(n)
 
    return assoc(kbd.status, {mode, keys, n})
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


function kbd:__init(mode, keys, f, attribs, doc, event, pattern)
    assert(mode, ex.no_mode())
    assert(keys, ex.no_keys())
    assert(doc, ex.no_doc())
    assert(f, ex.no_f())

    assert_type(mode, 'string', 'table')
    assert_s(keys)
    assert_s(doc)
    assert_type(f, 'string', 'table')
    assert_type(attribs, 'string', 'table')
    assert_type(event, 'string', 'table')
    assert_type(pattern, 'string', 'table')

    if not attribs or attribs and #attribs == 0 then
        attribs = {'noremap', 'silent', 'nowait'}
    else
        attribs = to_list(attribs)
    end

    if event then event = to_list(event) end
    if pattern then pattern = to_list(pattern) end

    self.noremap = find(attribs, 'noremap')

    if self.noremap then attribs[self.noremap] = nil end

    self.attribs = vals(attribs)
    self.noremap = self.noremap ~= nil and true
    self.mode = mode
    self.keys = keys
    self.f = f 
    self.attribs_s = join(map(function(s)
        if str_p(s) then
            return sprintf('<%s>', s)
        else
            return ''
        end
    end, self.attribs), ' ')
    self.doc = doc
    self.event = event
    self.pattern = pattern
    self.mapped = 0

    if not self.status[mode] then self.status[mode] = {} end
    if not self.status[mode][keys] then self.status[mode][keys] = {} end
    push(self.status[mode][keys], self)
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
    if not force and self.mapped ~= 0 then return end

    self:backup_previous()

    self.f = au.register(self.f, true)

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

            if self.noremap then
                cmd = sprintf('%snoremap %s %s %s', self.mode, attribs, self.keys, self.f)
            else
                cmd = sprintf('%smap %s %s %s', self.mode, attribs, self.keys, self.f)
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
        if self.noremap then
            cmd = sprintf('%snoremap %s %s %s', self.mode, self.attribs_s, self.keys, self.f)
        else
            cmd = sprintf('%smap %s %s %s', self.mode, self.attribs_s, self.keys, self.f)
        end

        kbd.wk_register(self.mode, self.keys, self.doc, bufnr)

        self.global = true
        self.mapped = self.mapped + 1
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

return kbd
