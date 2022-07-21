local ts = require('core.telescope')
local tf = assoc(Doom.telescope, 'font_switcher') or {
    include = '(Nerd Font|NF|Mono)';
    keys = '<leader>hf';
    default_height = 13;
}

function tf.get_fonts()
    include = include or tf.include
    local fonts = tbl

    each(function(f)
        if match(f, include) then
            if match(f, ',') then
                for _, i in ipairs(split(f, ',')) do
                    fonts[i] = true
                end
            else
               fonts[f] = true 
            end
        end
    end, system('fc-list -f "%{family}\n" :spacing=100 | uniq'))

    return fonts
end

function tf.set_font(font, height)
    assert(font)
    assert(height)
    assert_n(height)
    assert_s(font)

    height = height or tf.default_height 
    assert(match(height, '^[0-9]+$'))
    assert(height, 'No default height for font provided')

    height = tonumber(height)
    assert(height > 7)

    vim.o.guifont = font .. ':h' .. height
    return vim.o.guifont
end

function tf.new()
    local theight = function(sel)
        local heights = map(tostring, range(8, 20))
        local t = ts.new {
            title = 'Select font height',
            results = heights,
            mappings = function (height)
                tf.set_font(sel.value, tonumber(height.value))
            end,
        }
        t:find()

        return 
    end

    return ts.new {
        title = 'Select font',
        results = tf.get_fonts(),
        mappings = theight,
    }
end

return tf
