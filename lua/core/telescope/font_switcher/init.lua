local ts = require('core.telescope')

local tf = assoc(Doom.telescope, 'font_switcher') or {
    include = '[a-z]';
    keys = '<leader>hf';
    default_height = 13;
}

function tf.get_fonts(include)
    include = include or tf.include
    local fonts = {}

    each(system('fc-list -f "%{family}\n" :spacing=100 | uniq'), function(f)
        if match(f, include) then
            if match(f, ',') then
                for _, i in ipairs(split(f, ',')) do
                    fonts[i] = true
                end
            elseif #f > 0 then
               fonts[f] = true 
            end
        end
    end)

    return keys(fonts)
end

function tf.set_font(font, height)
    claim.opt_number(height)
    claim.string(font)

    height = height or tf.default_height 
    assert(match(height, '^[0-9]+$'))
    assert(height, 'No default height for font provided')

    height = tonumber(height)
    assert(height > 7, 'Height is too small')

    vim.o.guifont = font .. ':h' .. height
    return vim.o.guifont
end

function tf.new()
    local theight = function(sel)
        local heights = map(range(8, 20), tostring)
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
