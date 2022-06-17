local ts = require('core.telescope')
local rx = require('rex_pcre2')
local tfont = class('doom-ts-font-switcher')

assoc(Doom.telescope, {'font_switcher', 'defaults'}, {}) 
local defaults = Doom.telescope.font_switcher.defaults
defaults.keys = defaults.keys or '<leader>hf'
defaults.height = defaults.height or 13
tfont.defaults = defaults
defaults.opts = defaults.opts or ts.defaults.opts

function tfont:__init(opts)
    assert_t(opts)

    opts = opts or {}
    opts.include = opts.include or defaults.include
    opts.keys = opts.keys or defaults.keys
    opts.picker_opts = opts.opts or defaults.opts
    opts.height = opts.height or defaults.height

    assert_s(opts.include)
    assert_s(opts.keys)
    assert_n(opts.height)
    assert_t(opts.opts)

    merge(self, opts, 1)
end

function tfont.get_fonts(include)
    assert_s(include)

    include = include or defaults.include

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

function tfont.set_font(font, default_font)
    assert_n(height)
    assert_s(font)

    height = height or defaults.height
    assert(match(height, '^[0-9]+$'))
    assert(height, 'No default height for font provided')

    height = tonumber(height)
    assert(height > 7)

    local set_font = function(face, height)
        font = sed(font, {' ', '\\ '})
        vim.cmd(sprintf('set guifont=%s:%d', font, height))
    end

    return ts('Select font height', map(dump, range(8, 20)), false, 'fzy', function(height)
        set_font(font, height[1])
    end, merge(defaults.opts, {default_text=tostring(height)})):find()
end

function tfont.set_height(height)
    height = height or defaults.height
    local font = tfont.get_current_font()

    return ts('Select font height', map(dump, range(8, 20)), false, 'fzy', function(height)
        tfont.set_font(font, height[1])
    end, merge({default_text=tostring(height)}, ts.defaults.opts)):find()
end

function tfont:find(include, height, picker_opts)
    assert_t(picker_opts)
    assert_s(include)

    picker_opts = picker_opts or defaults.opts
    include = include or defaults.include
    height = height or defaults.height

    local title = 'Select font'
    local results = tfont.get_fonts()
    local entry_maker = false
    local sorter = 'fzy_index'
    local default_mapping = function(selection) tfont.set_font(first(selection), height) end

    return ts(title, results, entry_maker, 'fzy', default_mapping, picker_opts):find()
end

return tfont
