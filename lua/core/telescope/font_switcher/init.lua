-- local telescope = require('core.telescope')
local telescope = require('core.telescope')
local rx = require('rex_pcre2')
local tfont = class('doom-telescope-font-switcher')

tfont.include = Doom.telescope.font_switcher.include or '.*'
tfont.keys = Doom.telescope.font_switcher.keys or '<leader>hf'
tfont.default_height = Doom.telescope.font_switcher.default_height or 13

function tfont:__init(opts)
    assert_t(opts)

    opts = opts or {}
    opts.include = opts.include or tfont.include
    opts.keys = opts.keys or tfont.keys
    opts.picker_opts = opts.opts or {}
    opts.default_height = opts.default_height or tfont.default_height

    assert_s(opts.include)
    assert_s(opts.keys)
    assert_n(opts.default_height)
    assert_t(opts.opts)

    merge(self, opts, 1)
end

function tfont:get_fonts(include)
    assert_s(include)

    include = include or self.include or '.*'

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

function tfont:get_current_font()
    return string.match(vim.go.guifont, '([^:]+)([^$]+)')
end

function tfont:set_font(font, default_font)
    assert_n(default_height)
    assert_s(font)

    default_height = default_height or self.default_height
    assert(match(default_height, '^[0-9]+$'))
    assert(default_height, 'No default height for font provided')

    default_height = tonumber(default_height)
    assert(default_height > 7)

    local set_font = function(face, height)
        font = sed(font, {' ', '\\ '})
        vim.cmd(sprintf('set guifont=%s:%d', font, height))
    end

    return telescope('Select font height', map(dump, range(8, 20)), false, 'fzy', function(height)
        set_font(font, height[1])
    end, {default_text=tostring(default_height)}):find()
end

function tfont:find(include, default_height, picker_opts)
    assert_t(picker_opts)
    assert_s(include)

    picker_opts = picker_opts or self.opts or {}
    include = include or self.include or '.*'
    default_height = default_height or self.default_height or 12

    local title = 'Select font'
    local results = tfont:get_fonts()
    local entry_maker = false
    local sorter = 'fzy_index'
    local default_mapping = function(selection) self:set_font(first(selection), default_height) end

    return telescope(title, results, entry_maker, 'fzy', default_mapping, picker_opts):find()
end

if not kbd.find('n', '<leader>hf', 1) then
    kbd('n', tfont.keys, function() tfont():find() end, {'noremap'}, 'Switch to another font'):enable()
end

return tfont
