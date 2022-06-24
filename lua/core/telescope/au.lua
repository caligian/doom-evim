local au = require('core.au')
local ts = require('core.telescope')
local colors = require('core.colors')

local a = au.new('telescope_nvim_augroup', 'Telescope.nvim augroup')
a:add('ColorScheme', '*', function ()
    local normal_colors = colors.get_highlight_colors('Normal')
    local bg, fg = normal_colors.guibg, normal_colors.guifg

    bg = colors.darken(bg, -15)
    vcmd(':hi TelescopeNormal guibg=%s guifg=%s', bg, fg)
end)
a:enable()
