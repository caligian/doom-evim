local Path = require("path")

return {
    fnlConfig = true,
    theme = "everforest",
    lispLangs = {"fennel", "clojure", "scheme"},
    treesitterLangs = {"python", "norg", "fennel", "json", "javascript", "c", "lua", "perl", "ruby"},
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
                overwrite = true
            },
            debug = {cmd = "python3 -m pdb"},
            test = {cmd = "pytest"}
        },
        ruby = {
            server = "solargraph",
            debug = {cmd = "ruby -r rdebug"},
            test = {cmd = "rspec"},
            build = {cmd = "rake"},
            format = {
                cmd = "rubocop --fix-layout",
                overwrite = true,
            },
        },
        lua = {
            server = "sumneko_lua",
            manual = true,
            compile = "lua5.1",
            format = {cmd = "luafmt", overwrite = true}
        },
        fennel = {
            compile = "fennel"
        },
        perl = {
            compile = "perl"
        },
        javascript = {
            compile = "node"
        },
        sh = {
            compile = "bash"
        }
    }
}
