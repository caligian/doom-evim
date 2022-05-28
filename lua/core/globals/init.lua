_G.Doom = {
    ui = {
        theme = 'everforest',
    },

    langs = {
        python = {
            lsp = "pyright",
            compile = 'python3',
            format = "python3 -m yapf",
            debug = "python3 -m pdb",
            test = 'pytest',
            repl = 'python3',
        },

        ruby = {
            repl = 'irb',
            lsp = "solargraph",
            compile = 'irb',
            debug = 'ruby -r rdebug',
            test = 'rspec',
            build = 'rake',
            format = {'rubocop --fix-layout', overwrite=true},
        },

        lua = {
            lsp = {"sumneko_lua", manual=true},
            compile = 'lua5.1',
            repl = 'lua5.1'
        },

        fennel = {
            compile = 'fennel',
            repl = 'fennel',
        },

        perl = {
            compile = 'perl',
        },

        javascript = {
            compile = "node",
            repl = 'node',
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
        path = {with_data_path('templates'), with_config_path('templates')}
    },

    snippets = {
        path = {with_data_path('snippets'), with_config_path('snippets')}
    },

    async = { job = { status = {} } },

    au = { status = {}, refs = {}, },

    buffer = {
        status = {},
        temp_path = with_data_path('doom-temp')
    },

    log = { path = with_data_path('doom-evim.log') },

    kbd = { 
        prefixes = {
            ["<leader>b"] = "Buffer",
            ["<leader>q"] = "Buffers+close",
            ["<leader>c"] = "Commenting",
            ["<leader>i"] = "Insert",
            ["<leader><space>"] = "Misc",
            ["<leader>l"] = "LSP",
            ["<leader>t"] = "Tabs",
            ["<leader>o"] = "Neorg",
            ["<leader>h"] = "Help+Telescope",
            ["<leader>f"] = "Files",
            ["<leader>p"] = "Project",
            ["<leader>d"] = "Debug",
            ["<leader>&"] = "Snippets",
            ["<leader>x"] = "Misc",
            ["<leader>m"] = "Filetype Actions",
            ["<leader>s"] = "Session",
            ["<leader>g"] = "Git",
            ["<localleader>,"] = "REPL",
            ["<localleader>t"] = "REPL",
            ["<localleader>e"] = "REPL",
        },
        status = {},
    },

    repl = { status = {} },

    pkgs = {},
}
