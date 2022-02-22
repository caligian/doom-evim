(set _G.doom (require :globals))
(local utils (require :utils))
(local logger (require :logger))

(utils.try-then-else (fn [] 
                       (let [fnl (require :fennel)
                             kbd (require :keybindings)
                             pkg (require :packages)
                             runner (require :runners)
                             core (require :aniseed.core)
                             repl (require :repl)
                             snippet (require :snippets)
                             lsp (require :lsp-configs)]

                         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                         ; Doom logging starts
                         (logger.ilog "=================================================")
                         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                         ; Make some of these modules accessible to the user
                         (set doom.utils utils)
                         (set doom.logger logger)
                         (set doom.runner runner)

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

                         ; Setup packages
                         (pkg.setup)

                         ; Setup doom runner & REPL
                         (runner.setup)
                         (repl.setup)

                         ; Load default configurations
                         (require :configs)
                         (require :specs)

                         ; Require user-overrides
                         (require :user-init)
                         (require :user-specs)

                         ; Setup LSP
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
                                 500)

                         ; Register help
                         ; Register all help-groups in <leader>
                         (let [wk (require :which-key)]
                           (each [k group-name (pairs doom.map-help-groups.leader)]
                             (wk.register {k {:name group-name}} {:prefix "<leader>"}))

                           (each [k group-name (pairs doom.map-help-groups.localleader)]
                             (wk.register {k {:name group-name}} {:prefix "<localleader>"})))

                         ; Compile user fennel configs
                         ; They shall be required by users when needed
                         (utils.convert-to-lua)

                         ; Load the theme and also change the modeline colors accordingly
                         (utils.set-theme)

                         ; Setup keybindings
                         (kbd.setup)

                         ; Set an autocmd for theme changes
; This is to ensure that modeline colors follow suit
                         (utils.autocmd "GlobalHook" "ColorScheme" "*" #((. (require :modeline) :setup_colors)))))
                     #(logger.ilog "Configuration loaded successfuly!")
                     #(logger.flog (utils.fmt "DEBUG required:\n%s" $1)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
