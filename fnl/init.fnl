(module initialize
  {autoload {fnl fennel
             logger logger
             core aniseed.core
             utils utils
             lsp-configs lsp-configs}})

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Doom logging starts
(logger.ilog "=================================================")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Require globals. They will be contained in _G.doom
(when (not (. _G :doom))
  (utils.try-require :globals))

; Append required modules to doom
(set doom.utils utils)
(set doom.logger logger)

; Use this to set post-package-init configuration
(set _G.after! (lambda after! [pkg config-f]
                 (let [packages (utils.listify pkg)
                       loaded   (core.filter #(. doom.packages $1) packages)
                       equals   (= (length packages) (length loaded))]
                   (if equals 
                     (do (config-f) true)
                     false))))

(set _G.specs! (lambda specs! [pkg specs]
                 (let [required-pkg (. doom.packages pkg)]
                   (if required-pkg 
                     (each [k v (pairs specs)]
                       (tset (. doom.packages pkg) k v))))))

; Require packages
(utils.try-require :packages)

; Require user-overrides
(utils.try-require :user-init "DOOM") 

; Setup LSP
(when doom.lsp.load_default
  (utils.try-require :lsp-configs "DOOM")

  (after! [:nvim-lspconfig 
           :nvim-treesitter
           :nvim-lsp-installer
           :nvim-cmp
           :cmp-nvim-lsp
           :cmp-vsnip
           :vim-vsnip
           :trouble.nvim
           :cmp-buffer
           :cmp-path
           :cmp-cmdline]
          #(lsp-configs.setup)))

; Setup vimspector
(after! :vimspector 
        #(utils.try-require :dap-config :DOOM))

; Setup basic utility functions for running files
(when doom.default_runner
  (utils.try-require :runners :DOOM))

; Load doom's basic repl
(when doom.default_repl
  (utils.try-require :repl :DOOM))

; Load package-configs
(when doom.default_package_configs
  (utils.try-require :configs))

; Load keybindings
(when doom.default_keybindings
  (utils.try-require :keybindings))

; Register help
; Register all help-groups in <leader>
(let [wk (require :which-key)]
  (each [k group-name (pairs doom.map-help-groups.leader)]
    (wk.register {k {:name group-name}} {:prefix "<leader>"}))

  (each [k group-name (pairs doom.map-help-groups.localleader)]
    (wk.register {k {:name group-name}} {:prefix "<localleader>"})))

; Compile user fennel configs
; They shall be required by users when needed
(when doom.fnl_config 
  (utils.try-then-else #(utils.convert-to-lua)
                       #(logger.ilog (utils.fmt "[USER]: User fennel modules compiled successfuly to lua: %s" (vim.inspect doom.user_compile_fnl)))
                       #(logger.flog (utils.fmt "[USER]: Could not compile user fennel files. DEBUG REQUIRED\n $1"))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
