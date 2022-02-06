(module lsp-configs
  {autoload {utils utils
             core aniseed.core
             str aniseed.string
             fnl fennel}})

(defn setup-keybindings []
  (utils.define-keys [{:keys "<leader>lb"
                       :exec ":lua vim.lsp.buf.declaration()<CR>"
                       :help "Show declarations"}

                      {:keys "<leader>l?"
                       :exec ":lua vim.lsp.buf.definition()<CR>"
                       :help "Show definitions"}

                      {:keys "<leader>lk"
                       :exec ":lua vim.lsp.buf.hover ()<CR>"
                       :help "Show documentation"}

                      {:keys "<leader>li"
                       :exec ":lua vim.lsp.buf.implementation()<CR>"
                       :help "Show implementations"}

                      {:keys "<leader>lS"
                       :exec ":lua vim.lsp.buf.signature_help()<CR>"
                       :help "Show signature help"}

                      {:keys "<leader>lA"
                       :exec ":lua vim.lsp.buf.add_workspace_folder()<CR>"
                       :help "Add workspace folder"}

                      {:keys "<leader>lR"
                       :exec ":lua vim.lsp.buf.remove_workspace_folder()<CR>"
                       :help "Remove workspace folder"}

                      {:keys "<leader>lL"
                       :exec ":lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>"
                       :help "List workspace folders"}

                      {:keys "<leader>lT"
                       :exec ":lua vim.lsp.buf.type_definition()<CR>"
                       :help "Show type definitions"}

                      {:keys "<leader>lr"
                       :exec ":lua vim.lsp.buf.rename()<CR>"
                       :help "Rename buffer"}

                      {:keys "<leader>lR"
                       :exec ":lua vim.lsp.buf.references()<CR>"
                       :help "Show buffer references"}

                      {:keys "<leader>la"
                       :exec ":lua vim.lsp.buf.code_action()<CR>"
                       :help "Show code actions"}

                      {:keys "<leader>lc"
                       :exec ":lua vim.lsp.buf.range_code_action()<CR>"
                       :help "Show range code actions"}

                      {:keys "<leader>le"
                       :exec ":lua vim.diagnostic.open_float()<CR>"
                       :help "Open diagnostics in float"}

                      {:keys "<leader>ldp"
                       :exec ":lua vim.lsp.diagnostic.goto_prev()<CR>"
                       :help "Show previous diagnostic"}

                      {:keys "<leader>ldn"
                       :exec ":lua vim.lsp.diagnostic.goto_next()<CR>"
                       :help "Show next diagnostic"}

                      {:keys "<leader>lq"
                       :exec ":lua vim.lsp.diagnostic.set_loclist()<CR>"
                       :help "Set loclist"}]))

(defn on-attach-f [arg bufnr]
  (vim.api.nvim_buf_set_option bufnr "omnifunc" "v:lua.vim.lsp.omnifunc")
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
  ; Disable the annoying lsp virtual text. We got trouble.nvim
  (vim.diagnostic.config {:virtual_text false
                          :signs true
                          :underline true
                          :update_in_insert true
                          :severity_sort true})

  (require :nvim_cmp_setup)
  (setup-keybindings)
  (setup-servers)

  (when doom.lsp.install_sumneko_lua
    (setup-sumneko-lua))
  true)
