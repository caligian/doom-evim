local buffer = require('core.buffer')
local kbd = require('core.kbd')
local snippet = {}

assoc(Doom, {'snippet', 'dirs'}, {replace={with_user_config_path('snippets')}})
assoc(Doom, {'snippet', 'dir'}, {replace=Doom.snippet.dirs[1] or ''})
snippet.dirs = Doom.snippet.dirs
snippet.dir = Doom.snippet.dir

if not vim.g.vsnip_snippet_dirs then
    vim.g.vsnip_snippet_dir = snippet.dirs
end

if not vim.g.vsnip_snippet_dir then
    vim.g.vsnip_snippet_dir = snippet.dir
end

local function create_dir(dir)
    if not path.exists(snippet.dir) then
        fs.mkdir(snippet.dir)
    end
end

if #snippet.dir > 0 then
    create_dir(snippet.dir)
end

each(snippet.dirs, create_dir)

function snippet.save(ft, name, prefix, s)
    ft = ft or vim.bo.filetype
    local save = path(snippet.dir, ft .. '.json')
    local current = path.exists(save) and jslurp(save) or {}
    current[name] = {prefix=prefix, body=s}

    jspit(save, current)
end

function snippet.new(split)
    local ft = vim.bo.filetype
    local b = buffer.new(ft .. '_snippet_buffer', true)
    b:setopts {filetype=ft, buftype='nofile'}
    local fname = path(snippet.dir, ft .. '.json')
    split = split or 's'

    b:set_keymap('n', 'gs', function()
        buffer.hide_by_winnr(vim.fn.winnr())
        local s = b:read({})

        if #s > 0 then
            local name, prefix, new_ft = unpack(gets('%', true, {'Snippet name'}, {'Snippet prefix'}, {'Filetype', ft}))
            if new_ft == 'n' then new_ft = ft end
            snippet.save(new_ft, name, prefix, s)
        end
    end, false, 'Save current snippet', 'BufEnter')

    b:split(split)
end

return snippet
