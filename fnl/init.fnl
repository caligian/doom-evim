(module initialize
  {autoload {fnl fennel
             logger logger
             core aniseed.core
             utils utils
             lsp-configs lsp-configs}})

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Doom logging starts
(logger.ilog "=================================================")
(logger.ilog "DOOM LOG STARTS----------------------------------")

; Require globals. They will be contained in _G.doom
(utils.try-require :globals)

; Require packages
(utils.try-require :packages)

; Use this to set post-package-init configuration
(tset _G :after! (lambda after! [pkg config-f]
                   (let [packages (utils.listify pkg)
                         loaded   (core.filter #(. doom.packages $1) packages)
                         equals   (= (length packages) (length loaded))]
                     (if equals 
                       (do (config-f) true)
                       false))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Require user-overrides
(utils.try-require :user-init "DOOM") 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Setup LSP
(utils.try-require :lsp-configs "DOOM")
(when doom.lsp.load_default
  (after! [:nvim-lspconfig 
           :nvim-treesitter
           :nvim-lsp-installer
           :nvim-cmp
           :cmp-nvim-lsp
           :cmp-vsnip
           :vim-vsnip
           :cmp-buffer
           :cmp-path
           :cmp-cmdline]
          #(lsp-configs.setup)))

; Setup basic utility functions for running files
(utils.try-require :runners :DOOM)

; Load doom's basic repl
(utils.try-require :repl :DOOM)

; Load package-configs
(utils.try-require :configs)

; Load keybindings
(utils.try-require :keybindings)

; Compile user fennel configs
(utils.try-then-else #(utils.convert-to-lua)
                     #(logger.ilog (utils.fmt "[USER]: User fennel modules compiled successfuly to lua: %s" (vim.inspect doom.user_compile_fnl)))
                     #(logger.flog (utils.fmt "[USER]: Could not compile user fennel files. DEBUG REQUIRED\n $1")))

; Doom logging stops
(logger.ilog "DOOM LOG ENDS----------------------------------")
(logger.ilog "=================================================")
