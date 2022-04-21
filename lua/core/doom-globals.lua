local Path = require("path")
local Utils = require('doom-utils')

local Doom = {
    fnlConfig = true,

    theme = "everforest",

    lispLangs = {"fennel", "clojure", "scheme"},

    treesitterLangs = {"python", "norg", "fennel", "json", "javascript", "c", "lua", "perl", "ruby"},

    excludeFontsFromPicker = '(Mono|Hack|Monoid|NF|Nerd Font|Terminus|Tamzen)',
    lambdas = {},

    kbdNames = {
        leader = {
            b = "Buffer",
            q = "Buffers+close",
            c = "Commenting",
            i = "Insert",
            ["<space>"] = "Misc",
            l = "LSP",
            t = "Tabs",
            o = "Neorg",
            h = "Help+Telescope",
            f = "Files",
            p = "Project",
            d = "Debug",
            ["&"] = "Snippets",
            x = "Misc",
            m = "Filetype Actions",
            s = "Session",
            g = "Git"
        },
        localleader = {
            [","] = "REPL",
            t = "REPL",
            e = "REPL"
        }
    },

    lsp = {
        installSumnekoLua = false
    },

    templates = {
        directory = Path(vim.fn.stdpath("data"), "doom-templates")
    },

    userCompileFnl = {"fnl/*"},

    langs = {
        python = {
            server = "pyright",
            compile = "python3",
            format = {
                cmd = "python3 -m yapf",
                args = {},
                overwrite = true,
            },
            debug = {
                cmd = "python3 -m pdb",
                args = {},
            },
            test = {
                cmd = "pytest",
                args = {},
            }
        },
        ruby = {
            server = "solargraph",
            debug = {
                cmd = "ruby -r rdebug",
                args = {},
            },
            test = {
                cmd = "rspec",
                args = {},
            },
            build = {
                cmd = "rake",
                args = {},
            },
            format = {
                cmd = "rubocop --fix-layout",
                overwrite = true,
            },
        },
        lua = {
            server = "sumneko_lua",
            manual = true,
            compile = {
                cmd = "lua5.1",
                args = {},
            },
            format = {
                cmd = "luafmt",
                overwrite = true
            }
        },
        fennel = {
            compile = {
                cmd = "fennel",
            }
        },
        perl = {
            compile = {
                cmd = "perl",
            }
        },
        javascript = {
            compile = {
                cmd = "node"
            }
        },
        sh = {
            compile = {
                cmd = "bash"
            }
        }
    }
}

_G.Doom = Doom
return Doom
