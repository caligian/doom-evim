local au = require('core.au')
local telescope = require 'core.telescope'
local wk = require('which-key')
local ex = require('core.kbd.exception')

assoc(Doom, {'kbd', 'status'}, {replace=create_status_t {}})
assoc(Doom.kbd, {'defaults', 'attribs'}, {replace={'silent', 'noremap', 'nowait'}})
local kbd = {
    defaults = Doom.kbd.defaults,
    status = Doom.kbd.status,
    prefixes = Doom.kbd.prefixes,
}
local m = {}

function kbd.oneshot(mode, keys, f, attribs)
    claim(mode, 'string', 'table')
    claim.string(keys)
    claim(f, 'string', 'callable')
    claim(attribs, 'string', 'table', 'boolean')
    attribs = attribs or deepcopy(kbd.defaults.attribs)
    attribs = to_list(attribs)
    local noremap = find(attribs, 'noremap')
    if noremap then attribs[noremap] = nil end
    attribs = vals(attribs)
    noremap = noremap ~= nil and true

    attribs_s = join(map(attribs, function(s)
        if str_p(s) then
            return sprintf('<%s>', s)
        else
            return ''
        end
    end), ' ')

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

function kbd.wk_register(mode, keys, doc, bufnr)
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

function kbd.find(mode, keys, id)
    claim.string(mode, keys)
    if id then
        claim(id, 'string', 'number')
    end

    local found = assoc(Doom.kbd.status, {mode, keys, id})
    if found then
        return found
    end
    return false
end

function kbd.load_prefixes()
    if Doom.kbd.prefixes_loaded then return end

    each(keys(Doom.kbd.prefixes), function(prefix) 
        local doc = Doom.kbd.prefixes[prefix]
        local leader = match(prefix, '<[^>]+>')
        wk.register({[prefix]={name=doc}})
    end)

    Doom.kbd.prefixes_loaded = true
end

function kbd.new(id, mode, keys, callback, attribs, doc, event, pattern)
    claim(id, 'number', 'string')
    claim(mode, 'string', 'table')
    claim.string(keys, doc)
    claim(callback, 'string', 'callable')

    local existing = assoc(kbd.status, {mode, keys, id})
    if existing then return existing end
    if event then claim(event, 'string', 'table') end
    if pattern then claim(pattern, 'string', 'table') end
    if attribs then claim(attribs, 'string', 'table') end
    if event then event = to_list(event) end
    if pattern and num_p(pattern) then
        assert(vim.fn.bufnr(pattern) ~= -1, 'Invalid bufnr provided: ' .. pattern)
        pattern = sprintf('<buffer=%d>', pattern) 
    end
    if pattern then pattern = to_list(pattern) end
    attribs = attribs or kbd.defaults.attribs
    attribs = to_list(attribs)
    local noremap = find(attribs, 'noremap')
    if noremap then attribs[noremap] = nil end
    noremap = noremap ~= nil and true
    local attribs_s = join(map(attribs, function(s)
        if str_p(s) then
            return sprintf('<%s>', s)
        else
            return ''
        end
    end), ' ')

    local self = module.new('keybinding', {
        vars = {
            buffers = {},
            cmd = au.register(callback, 'k');
            global = false,
            id = id,
            mode = mode,
            keys = keys,
            callback = callback,
            attribs = attribs,
            attribs_s = trim(attribs_s),
            doc = doc,
            event = event,
            pattern = pattern,
            mapped = false,
            previous = {},
        }
    })

    self:include(m)
    update(kbd.status, {mode, keys, id}, self)
    return self
end

function m:backup_previous()
    local previous = self.previous
    local current = vim.fn.maparg(self.keys, self.mode, false, 1)

    if #keys(current) == 0 then return false end
    if previous and previous.rhs == current.rhs or self.cmd == current.rhs then return false end

    local _a = trim(join(map({'silent', 'nowait', 'expr', 'buffer'}, function(_attrib)
        if current[_attrib] == 1 then
            return sprintf('<%s>', _attrib)
        else
            return ''
        end
    end), " "))

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

    self.previous = t

    return self.previous
end

function m:enable(force)
    if not force and self.mapped then return self end

    self:backup_previous()

    if self.event or self.pattern or num_p(self.id) then
        if num_p(self.id) then
            assert(vim.fn.bufnr(self.id) ~= 0, 'Invalid bufnr provided: ' .. self.id)
            self.pattern = '<buffer=' .. self.id .. '>'
        else
            self.pattern = self.pattern or sprintf('<buffer=%d>', vim.fn.bufnr())
        end

        self.event =  self.event or 'BufEnter'
        self.au = au.new('doom_kbd_' .. #Doom.au.status, sprintf('Augroup for keybinding: [%s] %s', self.mode, self.keys))
        self.global = false

        self.au:add(self.event, self.pattern, function()
            local cmd = ''

            if self.noremap then
                cmd = sprintf('%snoremap %s %s %s', self.mode, self.attribs_s, self.keys, self.cmd)
            else
                cmd = sprintf('%smap %s %s %s', self.mode, self.attribs_s, self.keys, self.cmd)
            end

            local bufnr = vim.fn.bufnr()
            kbd.wk_register(self.mode, self.keys, self.doc, bufnr)

            push(self.buffers, bufnr)
            vim.cmd(cmd)

            self.mapped = true
        end)

        self.au:enable()

        return self.au
    end

    local cmd = ''
    if self.noremap then
        cmd = sprintf('%snoremap %s %s %s', self.mode, self.attribs_s, self.keys, self.cmd)
    else
        cmd = sprintf('%smap %s %s %s', self.mode, self.attribs_s, self.keys, self.cmd)
    end

    kbd.wk_register(self.mode, self.keys, self.doc)
    self.global = true
    self.mapped = true
    self.cmd = cmd
    vim.cmd(cmd)

    return cmd
end

-- Restore nth previous keybinding
function m:restore_previous()
    if not self.previous then return false end
    vim.cmd(first(self.previous))
    self:disable()
    self.mapped = false
    return true
end

function m:disable(buffers)
    if buffers then
        claim(buffers, 'number', 'table')
        buffers = to_list(buffers)
    end

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

            each(self.buffers, function(bufnr) 
                pcall(function() 
                    vim.api.nvim_buf_del_keymap(bufnr, self.mode, self.keys)
                end)

                self.buffers[bufnr] = nil
            end) 
        end
    end

    self:restore_previous()

    return true 
end

function m:replace(callback, attribs, doc, event, pattern)
    self:disable()

    self.callback = callback
    self.cmd = au.register(callback, 'keybinding') or self.cmd
    self.attribs = attribs or self.attribs
    self.event = event or self.event
    self.pattern = pattern or self.pattern
    self.doc = doc or self.doc

    self:enable()
end

function m:describe()
    inspect(self.__vars)
end

function kbd.describe(query)
    -- Spec: { {mode}, [keys], [id] }
    claim.table(query)
    assert(#query > 0, 'Spec: { {mode}, [keys], [id] }')

    local grp = assoc(Doom.kbd.status, query)
    if not grp then
        error('Invalid query provided. Spec: { {mode}, [keys], [id] }') 
    end

    if grp.__vars then
        inspect(grp.__vars)
    else
        each(items(grp), function(k) 
            local v = false 
            k, v = unpack(k)
            inspect(v.__vars)
        end)
    end
end

return kbd
