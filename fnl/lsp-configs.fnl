(module lsp-configs
  {autoload {utils utils
             core aniseed.core
             str aniseed.string}})

(defn setup-keybindings []
  (vim.cmd "noremap <leader>lD  :lua vim.lsp.buf.declaration()<CR>")
  (vim.cmd "noremap <leader>ld  :lua vim.lsp.buf.definition()<CR>")
  (vim.cmd "noremap <leader>lk  :lua vim.lsp.buf.hover ()<CR>")
  (vim.cmd "noremap K           :lua vim.lsp.buf.hover()<CR>")
  (vim.cmd "noremap <leader>li  :lua vim.lsp.buf.implementation()<CR>")
  (vim.cmd "noremap <leader>lS  :lua vim.lsp.buf.signature_help()<CR>")
  (vim.cmd "noremap <leader>lA  :lua vim.lsp.buf.add_workspace_folder()<CR>")
  (vim.cmd "noremap <leader>lR  :lua vim.lsp.buf.remove_workspace_folder()<CR>")
  (vim.cmd "noremap <leader>lL  :lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))()<CR>")
  (vim.cmd "noremap <leader>lT  :lua vim.lsp.buf.type_definition()<CR>")
  (vim.cmd "noremap <leader>lr  :lua vim.lsp.buf.rename()<CR>")
  (vim.cmd "noremap <leader>lR  :lua vim.lsp.buf.references()<CR>")
  (vim.cmd "noremap <leader>la  :lua vim.lsp.buf.code_action()<CR>")
  (vim.cmd "noremap <leader>lc  :lua vim.lsp.buf.range_code_action()<CR>")
  (vim.cmd "noremap <leader>le  :lua vim.diagnostic.open_float()<CR>")
  (vim.cmd "noremap [d          :lua vim.lsp.diagnostic.goto_prev()<CR>")
  (vim.cmd "noremap ]d          :lua vim.lsp.diagnostic.goto_next()<CR>")
  (vim.cmd "noremap <leader>lq  :lua vim.lsp.diagnostic.set_loclist()<CR>"))

(defn on-attach-f [arg bufnr]
      (vim.api.nvim_buf_set_option bufnr "omnifunc" "v:lua.vim.lsp.omnifunc")
      (vim.cmd "autocmd CursorHold <buffer> lua vim.lsp.util.show_line_diagnostics()")
      (vim.cmd "command! Format execute lua vim.lsp.buf.formatting()"))

(defn setup-sumneko-lua []
      (let [binary-path (utils.datap "lsp_servers" "sumneko_lua" "extension" "server" "bin" "lua-language-server")
            main-path (utils.datap "lsp_servers" "sumneko_lua" "extension" "server" "bin" "main.lua")
            runtime-path (vim.split package.path ";")
            nvim-lsp (require :lspconfig)
            sumneko-lua (. nvim-lsp :sumneko_lua)]

        (table.insert runtime-path "lua/?.lua")
        (table.insert runtime-path "lua/?/init.lua")

        (sumneko-lua.setup {:cmd [binary-path "-E" main-path]
                            :settings {:lua 
                                       {:runtime {:version "LuaJIT"
                                                  :path runtime-path}
                                        :diagnostics {:globals ["vim"]}
                                        :workspace {:library (vim.api.nvim_get_runtime_file "" true)}
                                        :telemetry {:enable false}}}})))

(defn setup-servers [?servers]
  (let [cmp-nvim-lsp (require :cmp_nvim_lsp)
        nvim-lsp (require :lspconfig)
        langs (utils.keys doom.langs)
        servers (core.map #(let [t (. doom.langs $1)] (or (. t :server) false)) langs)
        confs (core.map #(. doom.lsp.servers $1) langs)
        is-manual (core.map #(let [t (. doom.langs $1)] (or (. t :manual) false)) langs)
        capabilities (cmp-nvim-lsp.update_capabilities (vim.lsp.protocol.make_client_capabilities))]
    (for [i 1 (length langs)]
      (when (and (not (. is-manual i)) 
                 (. servers i))
        (let [server (. servers i)
              config (or (. confs i) {})]

          (when (not (. config :on_attach))
            (set config.on_attach on-attach-f))
          (when (not (. config :capabilities))
            (set config.capabilities capabilities))
          (let [current-server (. nvim-lsp server)]
            (current-server.setup config)))))))

(defn setup [] 
  (require :nvim_cmp_setup)
  (setup-keybindings)
  (setup-servers)

  (when doom.lsp.install_sumneko_lua
    (setup-sumneko-lua))
  true)
