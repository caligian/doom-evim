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
kbd.global_bind = vim.api.nvim_set_keymap
kbd.local_bind = vim.api.nvim_buf_set_keymap
kbd.global_unbind = vim.api.nvim_del_keymap
kbd.local_unbind = vim.api.nvim_buf_del_keymap
kbd.bind = kbd.global_bind
kbd.lbind = kbd.local_bind
kbd.lunbind = kbd.local_unbind
kbd.unbind = kbd.global_unbind

local function wk_register(keys, doc)
    if not packer_plugins['which-key.nvim'] then
        return 
    else
        wk = require('which-key')
    end

    if keys:match('<leader>') then
        keys = keys:gsub('<leader>', '')
        wk.register({[keys] = doc}, {prefix='<leader>'})
    elseif keys:match('<localleader>') then
        keys = keys:gsub('<localleader>', '')
        wk.register({[keys] = doc}, {prefix='<localleader>'})
    elseif not keys:match('enabled') then
        wk.register({[keys] = doc})
    end
end

local bindstr = function(modes, keys, f, attribs)
    attribs = attribs or {'silent', 'nowait'}
    attribs = join(map(function(a) return sprintf('<%s>', a) end, attribs, " "))
    local noremap
    attribs, noremap = attribs:gsub('noremap', '')
    local cmds = {}
    local _f = f

    each(function(m)
        if callable(f) then
            _f = ':' .. au.func2ref(f) .. '<CR>'
            push(Doom.au.refs, f)
        end

        if noremap ~= 0 then
            local s = sprintf('%snoremap %s %s', m, keys, _f)
            push(cmds, s)
        else
            local s = sprintf('%smap %s %s', m, keys, _f)
            push(cmds, s)
        end
    end, modes)

    return cmds
end

local function event_bind(event, pattern, modes, keys, f, attribs)
    assert(event or pattern)

    attribs = to_list(attribs)
    if not find(attribs, 'buffer') then push(attribs, 'buffer') end
    event =  event or 'BufEnter'
    pattern = pattern or '*.' .. vim.bo.filetype

    event = to_list(event)
    pattern = to_list(pattern)

    local au = au('doom_kbd_' .. #Doom.au.status+1, sprintf('Augroup for keybinding: [%s] %s', join(modes, ","), keys))

    each(function(e)
        each(function(p)
            each(function(cmd)
                au:add(e, p, sprintf('exe "%s"', cmd))
            end, bindstr(modes, keys, f, attribs))
        end, pattern)
    end, event)

    return au
end

local k_au = event_bind('BufEnter', '*.lua', {'n', 'v'}, '<leader>zf', function() vcmd('echo "hello world"') end, {'noremap'})
k_au:enable()

function kbd:__init(modes, keys, f, attribs, event, pattern)
end

function kbd:enable()
    if self.au then
        self.au:enable()
    else
        bind()
    end
end
