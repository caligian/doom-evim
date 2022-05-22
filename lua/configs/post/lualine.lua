-- Requires lualine
local lualine = require("lualine")
local colors = require('core.colors')
local modeline = {}

function modeline.get_gui_colors()
    local colors = vim.api.nvim_eval('execute("hi Normal")')

    if string.match(colors, "cleared") then
        return "#100a0d", "#ababab"
    else
        colors = vim.split(colors, " ")
        local fg = colors[#colors - 1]
        local bg = colors[#colors]
        fg = vim.split(fg, "=")[2]
        bg = vim.split(bg, "=")[2]

        return bg, fg
    end
end

function modeline.setup(bg, fg)
    local c = {}
    c.bg, c.fg = modeline.get_gui_colors()
    c.bg = colors.darken(c.bg, 10)

    local is_dark = colors.get_luminance(c.bg)

    if is_dark then
        c.yellow = "#de935f"
        c.cyan = "#5e8d87"
        c.darkblue = "#5f819d"
        c.green = "#8c9440"
        c.orange = "#e92f2f"
        c.violet = "#a54242"
        c.magenta = "#f996e2"
        c.blue = "#81a2be"
        c.red = "#e92f2f"
    else
        c.yellow = "#4e4e07"
        c.cyan = "#0b4b45"
        c.darkblue = "#21287d"
        c.green = "#07701e"
        c.orange = "#854a00"
        c.violet = "#4f3048"
        c.magenta = "#4f003a"
        c.blue = "#21287d"
        c.red = "#800000"
    end

    local conditions = {
        buffer_not_empty = function()
            return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
        end,
        hide_in_width = function()
            return vim.fn.winwidth(0) > 80
        end,
        check_git_workspace = function()
            local filepath = vim.fn.expand("%:p:h")
            local gitdir = vim.fn.finddir(".git", filepath .. ";")
            return gitdir and #gitdir > 0 and #gitdir < #filepath
        end
    }

    -- Config
    local config = {
        options = {
            -- Disable sections and component separators
            component_separators = "",
            section_separators = "",
            theme = {
                -- We are going to use lualine_c an lualine_x as left and
                -- right section. Both are highlighted by c theme .  So we
                -- are just setting default looks o statusline
                normal = {c = {fg = c.fg, bg = c.bg}},
                inactive = {c = {fg = c.fg, bg = c.bg}}
            }
        },
        sections = {
            -- these are to remove the defaults
            lualine_a = {},
            lualine_b = {},
            lualine_y = {},
            lualine_z = {},
            -- These will be filled later
            lualine_c = {},
            lualine_x = {}
        },
        inactive_sections = {
            -- these are to remove the defaults
            lualine_a = {},
            lualine_b = {},
            lualine_y = {},
            lualine_z = {},
            lualine_c = {},
            lualine_x = {}
        }
    }

    -- Inserts a component in lualine_c at left section
    local function ins_left(component)
        table.insert(config.sections.lualine_c, component)
    end

    -- Inserts a component in lualine_x ot right section
    local function ins_right(component)
        table.insert(config.sections.lualine_x, component)
    end

    ins_left {
        function()
            return "▊"
        end,
        color = {fg = c.blue}, -- Sets highlighting of component
        padding = {left = 0, right = 1} -- We don't need space before this
    }

    ins_left {
        -- mode component
        function()
            -- auto change color according to neovims mode
            local mode_color = {
                n = c.red,
                i = c.green,
                v = c.blue,
                [""] = c.blue,
                V = c.blue,
                c = c.magenta,
                no = c.red,
                s = c.orange,
                S = c.orange,
                [""] = c.orange,
                ic = c.yellow,
                R = c.violet,
                Rv = c.violet,
                cv = c.red,
                ce = c.red,
                r = c.cyan,
                rm = c.cyan,
                ["r?"] = c.cyan,
                ["!"] = c.red,
                t = c.red
            }
            vim.api.nvim_command("hi! LualineMode guifg=" .. mode_color[vim.fn.mode()] .. " guibg=" .. c.bg)
            return ""
        end,
        color = "LualineMode",
        padding = {right = 1}
    }

    ins_left {
        -- filesize component
        "filesize",
        cond = conditions.buffer_not_empty
    }

    ins_left {
        "filename",
        cond = conditions.buffer_not_empty,
        color = {fg = c.magenta, gui = "bold"}
    }

    ins_left {"location"}

    ins_left {"progress", color = {fg = c.fg, gui = "bold"}}

    ins_left {
        "diagnostics",
        sources = {"nvim_diagnostic"},
        symbols = {error = " ", warn = " ", info = " "},
        diagnostics_color = {
            color_error = {fg = c.red},
            color_warn = {fg = c.yellow},
            color_info = {fg = c.cyan}
        }
    }

    -- Insert mid section. You can make any number of sections in neovim :)
    -- for lualine it's any number greater then 2
    ins_left {
        function()
            return "%="
        end
    }

    ins_left {
        -- Lsp server name .
        function()
            local msg = "No Active Lsp"
            local buf_ft = vim.api.nvim_buf_get_option(0, "filetype")
            local clients = vim.lsp.get_active_clients()
            if next(clients) == nil then
                return msg
            end
            for _, client in ipairs(clients) do
                local filetypes = client.config.filetypes
                if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                    return client.name
                end
            end
            return msg
        end,
        icon = "",
        color = {fg = c.fg, gui = "bold"}
    }

    -- Add components to right sections
    ins_right {
        "o:encoding", -- option component same as &encoding in viml
        fmt = string.upper, -- I'm not sure why it's upper case either ;)
        cond = conditions.hide_in_width,
        color = {fg = c.green, gui = "bold"}
    }

    ins_right {
        "fileformat",
        fmt = string.upper,
        icons_enabled = false, -- I think icons are cool but Eviline doesn't have them. sigh
        color = {fg = c.green, gui = "bold"}
    }

    ins_right {
        "branch",
        icon = "",
        color = {fg = c.violet, gui = "bold"}
    }

    ins_right {
        "diff",
        -- Is it me or the symbol for modified us really weird
        symbols = {added = " ", modified = " ", removed = " "},
        diff_color = {
            added = {fg = c.green},
            modified = {fg = c.orange},
            removed = {fg = c.red}
        },
        cond = conditions.hide_in_width
    }

    ins_right {
        function()
            return "▊"
        end,
        color = {fg = c.blue},
        padding = {left = 1}
    }

    -- Now don't forget to initialize lualine
    lualine.setup(config)
end

modeline.setup()

return modeline
