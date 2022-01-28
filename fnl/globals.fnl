(module globals)

(set _G.doom {:fnl_config true

              ; Use doom's basic async runner
              :default_runner true

              ; Use doom's basic repl
              :default_repl true

              ; Use doom's non-package keybindings
              :default_keybindings true

              ; Use doom's default configuration
              :default_package_configs true

              ; Languages to use with treesitter
              :treesitter_langs [:python :yaml :json :javascript :c :lua :perl :fennel :ruby]

              ; Contains all the anonymous functions used in autocmds and keybindings
              :lambdas {}

              ; which-key queries this to get the description of <leader>[PREFIX]
              :map-help-groups {:leader {}
                                :localleader {}}

              ; LSP defaults
              :lsp {:install_sumneko_lua true
                    :load_default true
                    :servers {:solargraph {} :pyright {}}}
 

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

              :dap {:default {:python "debugpy"
                              :javascript "vscode-node-debug2"
                              :lua "local-lua-debugger-vscode"}}

              ; Basic setup for languages
              ; Used by doom's runner
              :langs {:python {:server "pyright" 
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
                            :build false}}

              ; Default package declarations
              :default_packages {; essentials
                                 :packer.nvim {1 "wbthomason/packer.nvim" :lock true}
                                 :vimpeccable {1 "svermeulen/vimpeccable" :lock true}
                                 :plenary.nvim {1 "nvim-lua/plenary.nvim" :lock true} 
                                 :aniseed {1 "Olical/aniseed" :lock true}
                                 :conjure {1 "Olical/conjure" :lock true}
                                 :fennel.vim {1 "bakpakin/fennel.vim" :lock true}
                                 :which-key.nvim {1 "folke/which-key.nvim" :lock true}
                                 :Repeatable.vim {1 "kreskij/Repeatable.vim" :lock true}

                                 ; ui 
                                 :twilight.nvim {1 "folke/twilight.nvim" :lock true}
                                 :galaxyline.nvim {1 "glepnir/galaxyline.nvim" :lock true}
                                 :vim-palette {1 "gmist/vim-palette" :lock true}
                                 :vim-devicons {1 "ryanoasis/vim-devicons" :lock true}
                                 :nvim-web-devicons {1 "kyazdani42/nvim-web-devicons" :lock true}
                                 :telescope.nvim {1 "nvim-telescope/telescope.nvim" :lock true}
                                 :telescope-project.nvim {1 "nvim-telescope/telescope-project.nvim" :lock true}
                                 :telescope-file-browser.nvim {1 "nvim-telescope/telescope-file-browser.nvim" :lock true}
                                 :zen-mode.nvim {1 "folke/zen-mode.nvim" :lock true}

                                 ; editor
                                 :formatter.nvim {1 "mhartington/formatter.nvim" :lock true}
                                 :vim-session {1 "xolox/vim-session"}
                                 :vim-misc {1 "xolox/vim-misc"}
                                 :vim-bbye {1 "moll/vim-bbye"  :lock true}
                                 :vim-dispatch {1 "tpope/vim-dispatch"  :lock true}
                                 :tagbar {1 "preservim/tagbar"  :lock true}
                                 :undotree {1 "mbbill/undotree"  :lock true}
                                 :nerdcommenter {1 "preservim/nerdcommenter" :lock true}
                                 :vim-markdown {1 "plasticboy/vim-markdown" :lock true}
                                 :vim-surround {1 "tpope/vim-surround" :lock true}
                                 :delimitMate {1 "Raimondi/delimitMate" :lock true}
                                 :indent-blankline.nvim {1 "lukas-reineke/indent-blankline.nvim" :lock true}

                                 ; git
                                 :vim-fugitive {1 "tpope/vim-fugitive" :lock true}
                                 :vim-rhubarb {1 "tpope/vim-rhubarb" :lock true}
                                 :gitsigns.nvim {1 "lewis6991/gitsigns.nvim" :lock true} 

                                 ; lsp
                                 :nvim-lspconfig {1 "neovim/nvim-lspconfig" :locked false}
                                 :nvim-treesitter {1 "nvim-treesitter/nvim-treesitter" :locked false}
                                 :nvim-lsp-installer {1 "williamboman/nvim-lsp-installer" :locked false}

                                 :friendly-snippets {1 "rafamadriz/friendly-snippets"}

                                 :vim-vsnip {1 "hrsh7th/vim-vsnip"}
                                 :vim-vsnip-integ {1 "hrsh7th/vim-vsnip-integ"}

                                 :cmp-vsnip {1 "hrsh7th/cmp-vsnip"}
                                 :cmp-nvim-lsp {1 "hrsh7th/cmp-nvim-lsp"}
                                 :cmp-buffer {1 "hrsh7th/cmp-buffer"}
                                 :cmp-path {1 "hrsh7th/cmp-path"}
                                 :cmp-cmdline {1 "hrsh7th/cmp-cmdline"}
                                 :nvim-cmp {1 "hrsh7th/nvim-cmp"}

                                 ; Ruby
                                 :vim-rspec {1 "thoughtbot/vim-rspec" :lock true}
                                 :vim-rake {1 "tpope/vim-rake" :lock true}
                                 :vim-projectionist {1 "tpope/vim-projectionist" :lock true}
                                 :vim-rails {1 "tpope/vim-rails" :lock true}

                                 ; Lua
                                 :nvim-luapad {1 "rafcamlet/nvim-luapad" :lock true}}})

; Create some important autocmds
(vim.cmd "augroup GlobalHook\n  autocmd!\naugroup END")
(vim.cmd "autocmd GlobalHook WinLeave _temp_output_buffer :q")
