local Lsp = {}

function Lsp.on_attach(_, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    vim.cmd('command! Format execute lua vim.lsp.buf.formatting()')
end

function Lsp.setup_lua()
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

-- How to add a new server?
-- Doom.langs.<lang> = {
    -- server = string or {
        -- <server>,
        -- config = {
            -- on_attach = function,
            -- capabilities = dict
            -- }
        -- },
        --
        -- If manual is provided, manual will simply be called similar to the case of sumneko_lua
        -- manual = f()
    -- }

function Lsp.setup_servers()
    local cmp_nvim_lsp = require('cmp_nvim_lsp')
    local nvim_lsp = require('lspconfig')

    map(function (lang)
        local conf = Doom.langs[lang]
        local server = conf.server

        if server then
            conf = server

            if table_p(server) then
                server = server[1]
            end

            if nvim_lsp[server] then
                if conf.manual then
                    if server == 'sumneko_lua' then
                        Lsp.setup_lua()
                    else
                        conf.manual()
                    end
                else
                    conf = conf.config or {
                        on_attach = Lsp.on_attach,
                        capabilities = cmp_nvim_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())
                    }

                    if nvim_lsp[server] then
                        nvim_lsp[server].setup(conf)
                    end
                end
            end
        end
    end, keys(Doom.langs))
end

return Lsp
