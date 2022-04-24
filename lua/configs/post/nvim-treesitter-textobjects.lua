local NvimTreesitterConfigs = require('nvim-treesitter.configs')

NvimTreesitterConfigs.setup {
    textobjects =  {
        move =  {
            enable =   true,
            set_jumps =   true,
            goto_next_start =  {
                "]m",  "@function.outer",
                "]]",  "@class.outer"
            },
            goto_next_end =  {"]M", "@function.outer",
            "][",  "@class.outer" },
            goto_previous_start =  {"[m",  "@function.outer",
            "[[",  "@class.outer"},
            goto_previous_end =  {"[M",  "@function.outer",
            "[]",  "@class.outer"},
        },
        select =  {
            enable =  true,
            lookahead =  true,
            keymaps =  {
                ib = "@block.inner",
                ab = "@block.outer",

                iC = "@call.inner",
                aC = "@call.outer",

                ic = "@class.inner",
                ac = "@class.outer",

                ['a;'] =  "@comment.outer",

                iF = "@conditional.inner",
                aF = "@conditional.outer",

                ['if'] = "@function.inner",
                af =   "@function.outer",

                il =   "@loop.inner",
                al =   "@loop.outer",

                ip =   "@parameter.inner",
                ap =   "@parameter.outer",
            }
        }
    }
}
