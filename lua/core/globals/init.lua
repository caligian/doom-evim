add_global(function(t)
    claim.table(t)

    return setmetatable(t, {
        __index = function(self, k)
            claim(k, 'number', 'string', 'table')

            if table_p(k) then
                k = join(map(u.dump, k), "")
            end

            return rawget(self, k)
        end;
        __newindex = function(self, k, v)
            claim(k, 'number', 'string', 'table')

            if table_p(k) then
                k = join(map(u.dump, k), "")
            end

            rawset(self, k, v)
        end;
    })
end, 'create_status_t')

return {
    ui = {
        theme = 'atom-dark',
    },

    langs = {
        shell = 'bash',

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
            compile = 'ruby',
            debug = 'ruby -r rdebug',
            test = 'rspec',
            build = 'rake',
            format = {'rubocop --fix-layout', overwrite=true},
        },

        lua = {
            format = {'luafmt', manual=true};
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

        scheme = {
            compile = 'guile';
            debug = 'guile --debug';
            repl = 'guile';
        };
    },

    editor = {
        lisp_langs = {"fennel", "clojure", "scheme", 'guile'},
    },

    treesitter = {
        defaults = {
            ensure_installed = {
                "python",
                "norg",
                "fennel",
                "json",
                "javascript",
                "c",
                "perl",
                "ruby",
                'lua',
            };
            hightlight = {
                enable = true;
                disable = {'lua'};
            };
            indent = {
                enable = true;
                disable = {'lua', 'ruby'};
            }
        };
    },

    telescope = {
        font_switcher = {
            include = '[a-z]';
            keys = '<leader>hf';
            default_height = 13;
        };
        defaults = {},
    },

    templates = {
        path = {with_data_path('templates'), with_config_path('templates')}
    },

    snippets = {
        path = {with_data_path('snippets'), with_config_path('snippets')}
    },

    async = {job = {status = create_status_t {} }},

    au = {
        status = create_status_t {autocmds={}}; 
        refs = {};
    },

    buffer = {
        status = create_status_t {},
        temp_path = with_data_path('doom-temp')
    },

    log = { path = with_data_path('doom-evim.log') },

    kbd = { 
        prefixes = {
            ["<leader>b"] = "Buffer",
            ["<leader>q"] = "Buffers+close",
            ["<leader>c"] = "Commenting",
            ["<leader>i"] = "Insert",
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
        status = create_status_t {},
    },

    pkgs = {
        paq = require('paq');
        loaded = {},
    },
}
