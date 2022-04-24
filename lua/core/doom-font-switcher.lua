local Utils = require('utils')
local TPickers = require('telescope.pickers')
local TFinders = require('telescope.finders')
local TConf = require('telescope.config').values
local TActions = require('telescope.actions')
local TActionState = require('telescope.actions.state')
local TIvy = require('telescope.themes').get_ivy()
local Rx = require('rex_pcre2')
local TFontSwitcher = {}
local exclude_fonts = Doom.telescope_exclude_fonts or '(Mono|Hack|Monoid|NF|Nerd Font|Terminus|Tamzen)'

function TFontSwitcher.get_fonts(filter_regex)
    local fonts = vim.fn.system('fc-match -a')
    fonts = Utils.split(fonts, "[\n\r]+")

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

    return Utils.keys(fonts_found)
end

function TFontSwitcher.set_font(font)
    local old_font, height = string.match(vim.go.guifont, '([^:]+)([^$]+)')
    vim.go.guifont = font .. height
end

function TFontSwitcher.switch_fonts(opts)
    opts = opts or {}
    opts = vim.tbl_extend('force', opts, TIvy)
    local filter_regex = opts.filter_regex or Doom.telescope_exclude_fonts or '(Hack|Mono|Monoid)'

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

function TFontSwitcher.setup()
    Utils['define-keys']({
    {
            keys = '<leader>xf',
            help = 'Switch between fonts',
            exec = function()
                TFontSwitcher.switch_fonts({filter_regex = exclude_fonts})
            end,
        }
    })
end

return TFontSwitcher
