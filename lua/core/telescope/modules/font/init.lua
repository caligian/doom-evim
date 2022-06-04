local tfont = {}
local telescope = require('core.telescope')
local rx = require('rex_pcre2')

tfont.include = Doom.telescope.modules.font.include

function tfont.get_fonts(include)
    include = include or tfont.include or '.*'

    local fonts = system('fc-list -f "%{family}\n" :spacing=100 | uniq')
    local fonts_found = {}
    each(function(f)
        if rx.match(f, include) then
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

function tfont.set_font(default_height, font)
    default_height = tostring(default_height)
    assert(match(default_height, '^[0-9]+$'))
    assert(default_height, 'No default height for font provided')

    default_height = tonumber(default_height)
    assert(default_height > 7)

    local set_font = function(face, height)
        vim.go.guifont = font .. ':h' .. height
    end

    return telescope('Select font height', map(dump, range(8, 20)), false, 'fzy', function(height)
        set_font(font, tonumber(height))
    end, {default_text=tostring(default_height)})
end

function new_font_picker(include, default_height, opts)
    opts = opts or {}
    include = include or false
    default_height = default_height or 12

    local title = 'Select font'
    local results = tfont.get_fonts()
    local entry_maker = false
    local sorter = 'fzy_index'
    local default_mapping = function(selection) tfont.set_font(default_height, selection) end

    return telescope(title, results, entry_maker, 'fzy', default_mapping, opts or {})
end

return to_callable(new_font_picker)
