local tfont = {}
local telescope = require('core.telescope')
local rx = require('rex_pcre2')

tfont.exclude = Doom.telescope.modules.font.exclude
tfont.include = Doom.telescope.modules.font.include

function tfont.get_fonts(include, exclude)
    include = include or tfont.include or ''
    exclude = exclude or tfont.exclude or ''

    local fonts = system('fc-list -f "%{family}\n" :spacing=100 | uniq')

    local fonts_found = {}
    fonts = filter(function(f)
        if rx.match(f, include) and rx.match(f, exclude) then
            if match(f, ',') then
                for _, i in ipairs(split(f, ',')) do
                    fonts_found[i] = true
                end
            else
                fonts_found[f] = true
            end
        end
    end, fonts)

    return keys(fonts_found)
end

function tfont.get_current_font()
    return string.match(vim.go.guifont, '([^:]+)([^$]+)')
end

function tfont.set_font(font)
    local set_font = function(face, height)
        vim.go.guifont = font .. ':h' .. height
    end

    return telescope('Select font height', map(dump, range(8, 20)), false, 'fzy', function(height)
        set_font(font, tonumber(height))
    end)
end

return to_callable(function(include, exclude, opts)
    opts = opts or {}
    include = include or false
    exclude = exclude or false

    local title = 'Select font'
    local results = tfont.get_fonts()
    local entry_maker = false
    local sorter = 'fzy_index'
    local default_mapping = function(selection) tfont.set_font(selection) end

    return telescope(title, results, entry_maker, 'fzy', default_mapping, false, opts or {})
end)
