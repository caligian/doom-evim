local lsp = {}

function lsp.setup_nvim_cmp()
    local cmp = require("cmp")
    vim.opt.completeopt = "menu,menuone,noselect"

    local lsp_symbols = {
        Text = "   (Text) ",
        Method = "   (Method)",
        Function = "   (Function)",
        Constructor = "   (Constructor)",
        Field = " ﴲ  (Field)",
        Variable = "[] (Variable)",
        Class = "   (Class)",
        Interface = " ﰮ  (Interface)",
        Module = "   (Module)",
        Property = " 襁 (Property)",
        Unit = "   (Unit)",
        Value = "   (Value)",
        Enum = " 練 (Enum)",
        Keyword = "   (Keyword)",
        Snippet = "   (Snippet)",
        Color = "   (Color)",
        File = "   (File)",
        Reference = "   (Reference)",
        Folder = "   (Folder)",
        EnumMember = "   (EnumMember)",
        Constant = " ﲀ  (Constant)",
        Struct = " ﳤ  (Struct)",
        Event = "   (Event)",
        Operator = "   (Operator)",
        TypeParameter = "   (TypeParameter)"
    }

    cmp.setup({
        snippet = {
            expand = function(args)
                vim.fn["vsnip#anonymous"](args.body)
            end
        },
        mapping = {
            ["<C-p>"] = cmp.mapping.select_prev_item(),
            ["<C-n>"] = cmp.mapping.select_next_item(),
            ["<C-d>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<C-e>"] = cmp.mapping.close(),
            ["<CR>"] = cmp.mapping.confirm {
                behavior = cmp.ConfirmBehavior.Replace,
                select = true
            }
        },
        formatting = {
            format = function(entry, item)
                item.kind = lsp_symbols[item.kind] .. " " .. item.kind
                -- set a name for each source
                item.menu =
                ({
                    spell = "[Spell]",
                    buffer = "[Buffer]",
                    calc = "[Calc]",
                    emoji = "[Emoji]",
                    nvim_lsp = "[LSP]",
                    path = "[Path]",
                    look = "[Look]",
                    treesitter = "[treesitter]",
                    nvim_lua = "[Lua]",
                    latex_symbols = "[Latex]",
                    cmp_tabnine = "[Tab9]"
                })[entry.source.name]
                return item
            end
        },
        sources = {
            {name = "nvim_lsp"},
            {name = "conjure"},
            {name = "vsnip"},
            {name = "path"},
            {name = "buffer"},
            {name = "nvim_lua"},
            {name = "treesitter"},
            {name = "spell"}
        }
    })
end

function lsp.on_attach(_, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    vim.cmd('command! Format execute lua vim.lsp.buf.formatting()')
end

function lsp.setup_lua()
    local binarypath = with_data_path('lsp_servers', 'sumneko_lua', 'extension', 'server', 'bin', 'lua-language-server')
    local mainpath = with_data_path('lsp_servers', 'sumneko_lua', 'extension', 'server', 'bin', 'main.lua')
    local runtimepath = split(package.path, ';')
    local sumneko_lua = require('lspconfig').sumneko_lua

    push(runtimepath, 'lua/?.lua')
    push(runtimepath, 'lua/?/init.lua')

    sumneko_lua.setup({
        cmd = {binarypath, '-E', mainpath},
        settings = {
            lua = {
                runtime = {
                    version = 'LuaJIT',
                    path = runtimepath,
                },
                diagnostics = {
                    globals = {'vim'},
                },
                workspace = {
                    library = vim.api.nvim_get_runtime_file("", true)
                },
                telemetry = {
                    enable = false
                },
            }
        }
    })
end

function lsp.setup_servers()
    local nvim_lsp = require('lspconfig')
    local cmp_nvim_lsp = require('cmp_nvim_lsp')
    
    vim.diagnostic.config {
        virtual_text = false,
        signs = false,
        underline = false,
    }

    each(function (lang)
        local server = assoc(Doom.langs, {lang, 'lsp'})

        if not server then return end

        server = to_list(server)
        local server_name = first(server)

        if server.manual then
            if server_name == 'sumneko_lua' then
                lsp.setup_lua()
            elseif callable(server.manual) then
                server.manual()
            elseif str_p(server.manual) then
                system(server.manual)
            end
        else
            server.config = server.config or {
                on_attach = lsp.on_attach,
                capabilities = cmp_nvim_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())
            }

            if nvim_lsp[server_name] then
                nvim_lsp[server_name].setup(server.config)
            end
        end
    end, keys(Doom.langs))
end

lsp.setup_servers()

return lsp
