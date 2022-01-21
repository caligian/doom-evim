(module initialize
  {autoload {fnl fennel
             logger logger
             utils utils
             lsp-configs lsp-configs}})

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This module does 2 things: 
; 1. Set the required globals
; 2. Require packages and initialize doom

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; A global logger.
; This will log to doom-evim.log
(tset _G :logger logger)
(logger.ilog "=================================================")
(logger.ilog "DOOM LOG STARTS----------------------------------")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Make the required global tables for doom
(set _G.doom {})
(set _G.doom.lsp {})
(set _G.doom.utils utils)
(set _G.doom.langs {:python {:server "pyright" 
                             :compile "python3"
                             :pattern "*py"
                             :debug "python3 -m pdb"
                             :test "pytest"
                             :build false}

                    :ruby {:server "solargraph"
                           :compile "ruby"
                           :pattern "*rb"
                           :debug "ruby -r debug"
                           :test "rspec"
                           :build "rake"}

                    :lua {:server "sumneko_lua"
                          :compile "/usr/bin/lua"
                          :pattern "*lua"
                          :manual true
                          :debug "lua"
                          :test "lua"
                          :build false}})

(set _G.doom.lambdas {})
(set _G.doom.map-help-groups {:leader {} :localleader {}})

; Runner will be SPC m r
; Testing will be SPC m e
; Compiling will be SPC m c
; Debug will be SPC m d [vs]
(defn make-builder-kbd [lang]
  (let [keys "<leader>mb"
        t (. doom.langs lang)
        builder (. t :builder)
        exec (utils.fmt ":Dispatch %s<CR>" builder)]
    (when builder 
      (utils.define-key {:keys keys
                         :noremap true
                         :key-attribs ["buffer"]
                         :exec exec
                         :patterns (. t :pattern)
                         :events "WinEnter"
                         :help-group "m"
                         :help (utils.fmt "Dispatch job: %s" builder)}))))

(defn make-testing-kbd [lang]
  (let [keys "<leader>me"
        t (. doom.langs lang)
        testing (. t :testing)
        exec (utils.fmt ":!%s %%<CR>" testing)]
    (when testing 
      (utils.define-key {:keys keys
                         :noremap true
                         :key-attribs ["buffer"]
                         :exec exec
                         :patterns (. t :pattern)
                         :events "WinEnter"
                         :help-group "m"
                         :help (utils.fmt "Run test suite" testing)}))))

(defn make-compile-kbd [lang]
  (let [keys "<leader>mc"
        t (. doom.langs lang)
        compile (. t :compile)
        exec (utils.fmt ":!%s %%<CR>" compile)]
    (when compile 
      (utils.define-key {:keys keys
                         :noremap true
                         :key-attribs ["buffer"]
                         :exec exec
                         :patterns (. t :pattern)
                         :events "WinEnter"
                         :help-group "m"
                         :help (utils.fmt "Compile current buffer" compile)}))))

(defn make-debug-kbd [lang]
  (let [keys "<leader>mdv"
        t (. doom.langs lang)
        debugger (. t :debug)
        exec (utils.split-termdebug-buffer debugger false "vsp" true true)]
    (when debug 
      (utils.define-key {:keys keys
                         :noremap true
                         :key-attribs ["buffer"]
                         :exec exec
                         :patterns (. t :pattern)
                         :events "WinEnter"
                         :help-group "m"
                         :help (utils.fmt "Vsplit and debug current buffer" debug)})))

  (let [keys "<leader>mds"
        t (. doom.langs lang)
        debugger (. t :debug)
        exec (utils.split-termdebug-buffer debugger false "sp" true true)]
    (when debug 
      (utils.define-key {:keys keys
                         :noremap true
                         :key-attribs ["buffer"]
                         :exec exec
                         :patterns (. t :pattern)
                         :events "WinEnter"
                         :help-group "m"
                         :help (utils.fmt "Split and debug current buffer" debug)}))))

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
  (vim.cmd "noremap <leader>le  :lua vim.lsp.diagnostic.show_line_diagnostics()<CR>")
  (vim.cmd "noremap [d          :lua vim.lsp.diagnostic.goto_prev()<CR>")
  (vim.cmd "noremap ]d          :lua vim.lsp.diagnostic.goto_next()<CR>")
  (vim.cmd "noremap <leader>lq  :lua vim.lsp.diagnostic.set_loclist()<CR>"))

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

(defn setup-nvim-cmp []
  (let [nvim-lsp (require :lspconfig)
        cmp (require :cmp)
        cmp-nvim-lsp (require :cmp_nvim_lsp)
        luasnip (require :luasnip) ]

    ; Setup nvim-cmp
    (cmp.setup {:snippet {:expand (lambda [args]
                                    (luasnip.lsp_expand args.body))}

                :mapping {"<C-p>"  (cmp.mapping (cmp.mapping.select_prev_item))
                          "<C-n>"  (cmp.mapping (cmp.mapping.select_next_item))
                          "<C-d>"  (cmp.mapping (cmp.mapping.scroll_docs -4))
                          "<C-f>"  (cmp.mapping (cmp.mapping.scroll_docs 4))
                          "<C-Space>" (cmp.mapping.complete)
                          "<C-e>"  (cmp.mapping.close)
                          "<CR>"  (cmp.mapping.confirm {:behavior cmp.ConfirmBehavior.Replace
                                                        :select true})
                          "<Tab>" (fn [fallback]
                                    (if 
                                      (cmp.visible)
                                      (cmp.select_next_item)

                                      (luasnip.expand_or_jumpable) 
                                      (luasnip.expand_or_jump)

                                      (fallback)))

                          "<S-Tab>" (fn [fallback]
                                      (if 
                                        (cmp.visible)
                                        (cmp.select_prev_item)

                                        (luasnip.jumpable -1)
                                        (luasnip.jump -1)

                                        (fallback)))
                          "<CR>" (cmp.mapping.confirm {:select true})}

                :sources [{:name "nvim_lsp"}
                          {:name "luasnip"}]})))

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
            (tset config :on_attach on-attach-f))
          (when (not (. config :capabilities))
            (tset config :capabilities capabilities))
          (let [current-server (. nvim-lsp server)]
            (current-server.setup config)))))))

(defn setup [] 
  (each [lang _ (pairs doom.langs)]
    (make-compile-kbd lang)
    (make-debug-kbd lang)
    (make-testing-kbd lang)
    (make-builder-kbd lang)) 

  (setup-keybindings)
  (setup-nvim-cmp)
  (setup-servers)

  (when doom.lsp.install_sumneko_lua
    (setup-sumneko-lua))
  true)

(when doom.lsp.load_default
  (utils.after! [:nvim-lspconfig 
                 :nvim-treesitter
                 :nvim-lsp-installer
                 :nvim-cmp
                 :cmp-nvim-lsp
                 :cmp_luasnip
                 :LuaSnip]
                #(setup)))

; LSP
(set _G.doom.lsp {:install_sumneko_lua true
                  :load_default true
                  :servers {:solargraph {} :pyright {}}})

; This will proceed to startup of packer with the plugins provided
(require :packages)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Basic configuration options
; These are the global options that users can set in their ~/.vdoom.d/user-init.lua
(tset _G.doom :fnl_config true)

; LSP settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Require user-overrides
; Try requiring user init config
(utils.try-require-else :user-init "DOOM") 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Setup LSP
(utils.try-require-else :lsp-configs "DOOM")
(when doom.lsp.load_default
  (utils.after! [:nvim-lspconfig 
                 :nvim-treesitter
                 :nvim-lsp-installer
                 :nvim-cmp
                 :cmp-nvim-lsp
                 :cmp_luasnip
                 :LuaSnip]
                #(lsp-configs.setup)))
(lsp-configs.setup)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Setup required autocmds
(utils.try-then-else 
  (fn [] 
    (utils.augroup "GlobalHook")
    (utils.augroup "PythonHook")
    (utils.augroup "RubyHook")
    (utils.augroup "LuaHook")
    (utils.autocmd "GlobalHook" "WinLeave" "_temp_output_buffer" ":q"))
  
  #(logger.ilog "[DOOM] (Global,Python,Ruby,Lua)Hook created. _temp_output_buffer will be :q at WinLeave")
  #(logger.error "[DOOM] Could not make augroup: (Global,Python,Ruby,Lua)Hook and _temp_output_buffer :q autocmd"))


; Setup basic utility functions for running files
(utils.try-require-else :runners :DOOM)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; User lua config
; Test if configs are being loaded or not
(utils.try-require-else :user-lua-init "DOOM")
(utils.try-require-else :user-lua-utils "DOOM")
(utils.try-require-else :user-lua-lsp-configs "DOOM")

(tset _G.doom :user {:lua {} :fnl {}})
(tset _G.doom.user.lua :init  (require :user-lua-init))
(tset _G.doom.user.lua :utils (require :user-lua-utils))
(tset _G.doom.user.lua :lsp   (require :user-lua-lsp-configs))

; User fnl config
(utils.try-then-else #(utils.compile-user-fnl-configs)
                     #(when doom.fnl_config
                        (tset _G.doom.user.fnl :init (require :user-fnl-init))
                        (logger.ilog "[USER] Module user-fnl-init OK")

                        (tset _G.doom.user.fnl :lsp  (require :user-fnl-lsp-configs))
                        (logger.ilog "[USER] Module user-fnl-lsp OK")

                        (tset _G.doom.user.fnl :utils (require :user-fnl-utils))
                        (logger.ilog "[USER] Module user-fnl-utils OK"))
                     #(logger.flog "[USER] Could not compile user fnl! Debugging recommended"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Load default configs and keybindings for packages
(utils.try-require-else :configs "DOOM")
(utils.try-require-else :keybindings "DOOM")

; Load user configs & keybindings in lua
(utils.try-require-else :user-lua-configs "USER")
(utils.try-require-else :user-lua-keybindings "USER")

; Load user configs & keybindings in fnl
(when doom.fnl_config
  (utils.try-require-else :user-fnl-configs "USER")
  (utils.try-require-else :user-fnl-keybindings "USER"))

; Load doom's basic repl
(require :repl)

; Doom has started. 
(logger.ilog "DOOM LOG ENDS----------------------------------")
(logger.ilog "=================================================")
