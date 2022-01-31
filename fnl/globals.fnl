(module globals)

(set _G.doom {:fnl_config true

              ; Use doom's basic async runner
              :default_runner true

              ; Use doom's basic repl
              :default_repl true

              ; Use doom's non-package keybindings
              :default_keybindings true

              ; Use some keybindings for vim-help
              :default_help_keybindings true

              ; Use doom's default configuration
              :default_package_configs true

              ; Lisp langs to which delimitMate will not start
              :lisp_langs ["fennel" "clojure" "scheme"]

              ; Languages to use with treesitter
              :treesitter_langs [:python :yaml :json :javascript :c :lua :perl :fennel :ruby]

              ; Contains all the anonymous functions used in autocmds and keybindings
              :lambdas {}

              ; which-key queries this to get the description of <leader>[PREFIX]
              :map-help-groups {:leader {:b "Buffers"
                                         :q "Buffers+Close"
                                         :c "Commenting"
                                         "<space>" "Misc"
                                         :l "LSP"
                                         :t "Tabs"
                                         :h "Help+Telescope"
                                         :f "Files"
                                         :p "Project"
                                         :d "Debug"
                                         :x "Misc"
                                         :m "Filetype Actions"
                                         :s "Session"
                                         :g "Git"}

                                :localleader {"," "REPL"
                                              "t" "REPL"
                                              "e" "REPL"}}

              :dap {:default [:debugpy
                              :vscode-node-debug2
                              :local-lua-debugger-vscode]}

              ; LSP defaults
              :lsp {:install_sumneko_lua true
                    :load_default true
                    :servers {:solargraph {}
                              :pyright {}}}
 

              ; Contains user-package declarations
              :user_packages  (require :user-packages)

              ; Only matters if fnl_config = true
              :user_compile_fnl ["init" "utils" "keybindings" "configs" "lsp-configs"]

              :repl {:ft {:sh "bash"
                          :ruby "irb"
                          :perl "perl"
                          :fennel "fennel"
                          :python "python"
                          :lua "lua"
                          :powershell "powershell"
                          :ps1 "powershell"}

                     ; form: {:cmd {:id terminal_job_id :buffer bufnr}}
                     :running_repls {}}

              :default_packages (require :default_packages)

              ; Basic setup for languages
              ; Used by doom's runner
              :langs {:python {:server "pyright" 
                               :compile "python3"
                               :debug "python3 -m pdb"
                               :test "pytest"
                               :build false}

                      :ruby {:server "solargraph"
                             :compile "ruby"
                             :debug "ruby -r debug"
                             :test "rspec"
                             :build "rake"}

                      :lua {:server "sumneko_lua"
                            :compile "/usr/bin/lua"
                            :manual true
                            :debug "lua"
                            :test "lua"
                            :build false}}})

; Create some important autocmds
(vim.cmd "augroup GlobalHook\n  autocmd!\naugroup END")
(vim.cmd "autocmd GlobalHook WinLeave _temp_output_buffer :q")
