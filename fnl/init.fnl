(global doom (require :globals))
(local utils (require :utils))
(local logger (require :logger))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Doom logging starts
(logger.ilog "=================================================")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(local fnl (require :fennel))
(local kbd (require :keybindings))
(local pkg (require :packages))
(local runners (require :runners))
(local core (require :aniseed.core))
(local repl (require :repl))
(local snippets (require :snippets))
(local templates (require :templates))
(local lsp (require :lsp-configs))

; Make some of these modules accessible to the user
(set doom.utils utils)
(set doom.logger logger)
(set doom.runners runners)
(set doom.templates templates)
(set doom.snippets snippets)

; Use this to set post-package-init configuration
(set _G.after! (lambda after! [pkg config-f ?defer]
                 (let [packages (utils.listify pkg)
                       loaded   (core.filter #(. doom.packages $1) packages)
                       equals   (= (length packages) (length loaded))]
                   (if equals 
                     (if ?defer
                       (vim.defer_fn config-f ?defer)
                       (do (config-f) true))
                     false))))

(set _G.specs! (lambda specs! [pkg specs]
                 (let [required-pkg (. doom.packages pkg)]
                   (if required-pkg 
                     (each [k v (pairs specs)]
                       (tset (. doom.packages pkg) k v))))))

(utils.try-then-else #(require :user-init)
                     #(logger.ilog "user-init.lua has been successfuly loaded")
                     #(logger.flog (.. "Debugging required:\n" $1)))

(utils.try-then-else #(pkg.setup)
                     #(logger.ilog "All packages have been successfuly loaded")
                     #(logger.flog (.. "Debugging required:\n" $1)))

(utils.try-then-else #(runners.setup)
                     #(logger.ilog "Runners have been setup sucessfuly.")
                     #(logger.flog (.. "Debugging required:\n" $1)))

(utils.try-then-else #(repl.setup)
                     #(logger.ilog "REPL has been setup.")
                     #(logger.flog (.. "Debugging required:\n" $1)))

(utils.try-then-else #(snippets.setup)
                     #(logger.ilog "Snippets have been setup.")
                     #(logger.flog (.. "Debugging required:\n" $1)))

(utils.try-then-else # (templates.setup)
                     #(logger.ilog "Templates have been setup.")
                     #(logger.flog (.. "Debugging required:\n" $1)))

(utils.try-then-else #(require :configs)
                     #(logger.ilog "configs.fnl has been successfuly loaded")
                     #(logger.flog (.. "Debugging required:\n" $1)))

(utils.try-then-else #(do 
                        (lsp.setup)

                        (when doom.lsp.load_default
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
                                  #(lsp.setup)
                                  300))

                        ; Setup vimspector
                        (after! :vimspector 
                                #(require :dap-config)
                                500))
                     #(logger.ilog "LSP successfuly setup")
                     #(logger.flog (.. "Debugging required:\n" $1)))

; Misc stuff
(utils.try-then-else #(do 
                        (let [wk (require :which-key)]
                          (each [k group-name (pairs doom.map-help-groups.leader)]
                            (wk.register {k {:name group-name}} {:prefix "<leader>"}))

                          (each [k group-name (pairs doom.map-help-groups.localleader)]
                            (wk.register {k {:name group-name}} {:prefix "<localleader>"})))

                     ; Convert user files to lua
                     (utils.convert-to-lua)

                     ; Load the theme and also change the modeline colors accordingly
                     (utils.set-theme)
                     (utils.autocmd "GlobalHook" "ColorScheme" "*" #((. (require :modeline) :setup_colors))))
                     #(logger.ilog "Misc stuff setup")
                     #(logger.flog (.. "Debugging required:\n" $1)))

; Setup keybindings
(utils.try-then-else #(kbd.setup)
                     #(logger.ilog "Keybindings have been setup successfuly")
                     #(logger.flog (.. "Debugging required:\n" $1)))
