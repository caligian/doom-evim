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
