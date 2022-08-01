local buffer = require('core.buffers')
local kbd = require('core.kbd')
local template = {}

assoc(Doom, {'template', 'dir'}, with_user_config_path('templates'))
template.dir = Doom.template.dir

if not path.exists(template.dir) then
    fs.mkdir(template.dir)
end

function template.save(ft, pat, s)
    ft = ft or vim.bo.filetype
    local save = path(template.dir, ft .. '.json')
    local current = path.exists(save) and jslurp(save) or {}
    current[pat] = s

    jspit(save, current)
end

function template.new(split)
    local ft = vim.bo.filetype
    local b = buffer.new(ft .. '_template_buffer', true)
    b:setopts {filetype=ft, buftype='nofile'}
    local fname = path(template.dir, ft .. '.json')
    split = split or 's'

    b:set_keymap('n', 'gs', function()
        buffer.hide_by_winnr(vim.fn.winnr())

        local s = b:read({})

        if #s > 0 then
            local pattern, new_ft = unpack(gets('%', true, {'Template filename (lua) pattern'}, {'Filetype', ft}))
            if new_ft == 'n' then new_ft = ft end

            template.save(new_ft, pattern, s)
        else
            error({'No template string provided in buffer: ' .. self.index})
        end
    end, false, 'Save current template', 'BufEnter')

    return b:split('s')
end

function template.load()
    local fts = {}

    for fn, ftype in fs.dir(Doom.template.dir) do
        if ftype == 'file' and match(fn, 'json$') then
            local ft = split(path.name(fn), '%.')
            pop(ft)
            ft = join(ft, '.')
            fts[ft] = jslurp(fn)
        end
    end

    Doom.template.templates = fts

    return fts
end

function template.enable()
    if not Doom.template.templates then return end

    local autocmd_groups = {}

    each(function(ft)
        autocmd_groups[ft] = {}

        each(function (pat)
            local t = Doom.template.templates[ft][pat]

            if template.au then
                template.au:disable()
            end

            local a = au.new(false, 'Template for filename pattern: ' .. pat)

            a:add('BufNewFile', '*' .. ft, function()
                if lmatch(vim.fn.expand('%:p'), pat) then
                    vim.api.nvim_buf_set_lines(vim.fn.bufnr(), 0, 0, false, t)
                end
            end)

            a:enable()

            autocmd_groups[ft][pat] = a
        end, keys(Doom.template.templates[ft]))
    end, keys(Doom.template.templates))

    template.au = autocmd_groups

    return template.au
end

return template
