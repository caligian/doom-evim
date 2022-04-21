local Lsp = {}
local Path = require('path')
local Utils = require('doom-utils')
local Core = require('aniseed.core')
local Str = require('aniseed.string')

function Lsp.onAttach(arg, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    vim.cmd('command! Format execute lua vim.lsp.buf.formatting()')
end

function Lsp.setupSumnekoLua()
    local binaryPath = Path(vim.fn.stdpath('data'), 'lsp_servers', 'sumneko_lua', 'extension', 'server', 'bin', 'lua-language-server')
    local mainPath = Path(vim.fn.stdpath('data'), 'lsp_servers', 'sumneko_lua', 'extension', 'server', 'bin', 'main.lua')
    local runtimePath = vim.split(package.path, ';')
    local nvimLSP = require('lspconfig')
    local sumnekoLua = nvimLsp.sumneko_lua

    table.insert(runtimePath, 'lua/?.lua')
    table.insert(runtimePath, 'lua/?/init.lua')

    sumnekoLua.setup({
        cmd = {binaryPath, '-E', mainPath},
        settings = {
            lua = {
                runtime = {
                    version = 'LuaJIT',
                    path = runtimePath,
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

function Lsp.setupServers()
    local cmpNvimLsp = require('cmp_nvim_lsp')
    local nvimLsp = require('lspconfig')
    
    for lang, conf in pairs(Doom.langs) do
        if conf.server and not conf.manual then
            local onAttachF = conf.onAttach or Lsp.onAttach
            local capabilities = conf.capabilities or cmpNvimLsp.update_capabilities(vim.lsp.protocol.make_client_capabilities)

            conf.onAttach = onAttachF
            conf.capabilities = capabilities

            if nvimLsp[conf.server] then
                nvimLsp[conf.server].setup(conf.config)
            end
        end
    end
end

function Lsp.setup()
end
