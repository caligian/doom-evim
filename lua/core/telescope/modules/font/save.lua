local tutils = require('modules.utils.table')
local TPickers = require('telescope.pickers')
local TFinders = require('telescope.finders')
local TConf = require('telescope.config').values
local TActions = require('telescope.actions')
local TActionState = require('telescope.actions.state')
local TIvy = require('telescope.themes').get_ivy()
local Rx = require('rex_pcre2')
local TFontSwitcher = {}

if not Doom.telescope then Doom.telescope = {} end

if not Doom.telescope.modules then
    Doom.telescope.modules = {
        font = {
            exclude = '(Mono|Hack|Monoid|NF|Nerd Font|Terminus|Tamzen)',
        },
    }
end

TFontSwitcher.exclude = Doom.telescope.modules.font.exclude

function TFontSwitcher.get_fonts(filter_regex)
    local fonts = vim.fn.system('fc-match -a')
    fonts = vim.split(fonts, "[\n\r]+")

    local fonts_found = {}

    for _, f in ipairs(fonts) do
        if #f > 0 then
            f = Rx.match(f, '^[^"]+"([^"]+)"')

            if filter_regex then
                if Rx.match(f, filter_regex) then
                    fonts_found[f] = true
                end
            else
                fonts_found[f] = true
            end
        end
    end

    return tutils.keys(fonts_found)
end

function TFontSwitcher.set_font(font)
    local old_font, height = string.match(vim.go.guifont, '([^:]+)([^$]+)')

    if old_font then
        vim.go.guifont = font .. height
    end
end

function TFontSwitcher.switch_fonts(opts)
    opts = opts or {}
    opts = vim.tbl_extend('force', opts, TIvy)
    local filter_regex = opts.exclude or Doom.telescope.modules.font.exclude

    TPickers.new(opts, {
        prompt_title = 'fonts',
        finder = TFinders.new_table { results = TFontSwitcher.get_fonts(filter_regex) },
        sorter = TConf.generic_sorter(opts),
        attach_mappings = function (bufnr, map)
            TActions.select_default:replace(function ()
                TActions.close(bufnr)
                local selection = TActionState.get_selected_entry()
                TFontSwitcher.set_font(selection[1])
            end)

            return true
        end
    }):find()
end

return TFontSwitcher
