local neorg = require('neorg')

neorg.setup({
    load =  {
        ['core.keybinds'] =  {
            config =  {
                default_keybinds =  true,
                neorg_leader =  "<Leader>o",
            },
        },

        ['core.integrations.nvim-cmp'] =  {
            config =  {}
        },

        ['core.norg.journal'] =  {
            config =  {
                workspace =  "journal",
                strategy =  "flat",
            },
        },

        ['core.defaults'] = {},

        ['core.norg.concealer'] =  {config =  {}},

        ['core.presenter'] =  {config =  {}},

        ['core.norg.qol.toc'] =  {config =  {}},

        ['core.norg.manoeuvre'] =  {config =  {}},

        ['core.norg.dirman'] =  {
            config =  {
                workspaces =  {
                    work =  "~/Work",
                    journal =  "~/Personal/Journal",
                    gtd =  "~/Personal/GetThingsDone",
                    default_workspace =  "~/Personal/neorg",
                    personal =  "~/Personal",
                    diary =  "~/Personal/Diary",
                },
            },
        },
    },
})
