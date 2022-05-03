require('core.globals.funcs')

_G.Doom = {
    ui = {
        theme = 'everforest',
    },

    langs = {
            python = {
                server = "pyright",
                compile = 'python3',
                format = "python3 -m yapf",
                debug = "python3 -m pdb",
                test = 'pytest',
            },

            ruby = {
                server = "solargraph",
                compile = 'irb',
                debug = 'ruby -r rdebug',
                test = 'rspec',
                build = 'rake',
                format = {'rubocop --fix-layout', overwrite=true},
            },

            lua = {
                server = {"sumneko_lua", manual=true},
                compile = 'lua5.1',
            },

            fennel = {
                compile = 'fennel',
            },

            perl = {
                compile = 'perl',
            },

            javascript = {
                compile = "node"
            },

            sh = {
                compile = "bash",
                debug = 'bash -x',
            },
        },


    editor = {
        lisp_langs = {"fennel", "clojure", "scheme"},
    },

    treesitter = {
        ensure = {"python", "norg", "fennel", "json", "javascript", "c", "lua", "perl", "ruby"},
    },

    templates = {
        directory = path(vim.fn.stdpath("data"), "doom-templates")
    },
}
