(module initialize
  {autoload {fnl fennel
             logger logger
             utils utils}})

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; A global logger.
(tset _G :logger logger)
(logger.ilog "=================================================")
(logger.ilog "DOOM LOG STARTS----------------------------------")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Make the required global tables for doom
(tset _G :doom {})
(tset _G.doom :lsp {})
(tset _G.doom :utils utils)
(tset _G.doom :default_packages {"wbthomason/packer.nvim" true

                                 ; Ruby stuff
                                 "tpope/vim-rails" true
                                 "tpope/vim-rake" true
                                 "tpope/vim-projectionist" true
                                 "vim-ruby/vim-ruby" true
                                 "skalnik/vim-vroom" true

                                 ; Markdown mode
                                 "plasticboy/vim-markdown" true

                                 ; Async
                                 "tpope/vim-dispatch" true

                                 ; Python stuff
                                 "alfredodeza/pytest.vim" true

                                 ; zk 
                                 "dagle/zk.nvim" true

                                 "svermeulen/vimpeccable" true

                                 "nvim-lua/plenary.nvim" true

                                 "nvim-telescope/telescope-project.nvim" true
                                 "nvim-telescope/telescope.nvim" true
                                 "nvim-telescope/telescope-file-browser.nvim" true

                                 "moll/vim-bbye" true

                                 "folke/zen-mode.nvim" true

                                 "folke/which-key.nvim" true

                                 "Vimjas/vim-python-pep8-indent" true
                                 "lukas-reineke/indent-blankline.nvim" true

                                 "tpope/vim-fugitive" true
                                 "tpope/vim-rhubarb" true
                                 "lewis6991/gitsigns.nvim" true

                                 "kreskij/Repeatable.vim" true

                                 "tpope/vim-surround" true
                                 "Raimondi/delimitMate" true

                                 "rafcamlet/nvim-luapad" true

                                 ; Tags in a side-window
                                 "preservim/tagbar" true

                                 ; Better undo
                                 "mbbill/undotree" true

                                 ; Debugger
                                 "mfussenegger/nvim-dap" true
                                 "Pocco81/DAPInstall.nvim" true

                                 ; Themes
                                 "bling/vim-bufferline" true
                                 "itchyny/lightline.vim" true
                                 "rafi/awesome-vim-colorschemes" true
                                 "ryanoasis/vim-devicons" true
                                 "kyazdani42/nvim-web-devicons" true

                                 ; lsp-stuff
                                 "neovim/nvim-lspconfig" true
                                 "nvim-treesitter/nvim-treesitter" true
                                 "williamboman/nvim-lsp-installer" true
                                 "hrsh7th/nvim-cmp" true
                                 "hrsh7th/cmp-nvim-lsp" true
                                 "saadparwaiz1/cmp_luasnip" true
                                 "L3MON4D3/LuaSnip" true

                                 ; Fennel support
                                 "Olical/aniseed" true
                                 "Olical/conjure" true
                                 "bakpakin/fennel.vim" true})
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Load all packages
(utils.try-require-else :user-packages "DOOM")
(tset _G.doom :packages (require :user-packages))
(require :packages)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Basic configuration options
(tset _G.doom :fnl_config true)

; LSP settings
(tset _G.doom.lsp :servers {:solargraph {} :pyright {}})
(tset _G.doom.lsp :install_sumneko_lua true)
(tset _G.doom.lsp :load_default true)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Setup LSP
(utils.try-require-else :lsp-configs "DOOM")

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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Require user-overrides
; Disabling packages is simple. Just put nil as value for any package that you don't want
; Try requiring user init config
(utils.try-require-else :user-init "DOOM") 

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
; Load default configs
(utils.try-require-else :configs "DOOM")
(utils.try-require-else :keybindings "DOOM")

; Load user configs in lua
(utils.try-require-else :user-lua-configs "USER")
(utils.try-require-else :user-lua-keybindings "USER")

; Load user configs in fnl
(when doom.fnl_config
  (utils.try-require-else :user-fnl-configs "USER")
  (utils.try-require-else :user-fnl-keybindings "USER"))

(logger.ilog "DOOM LOG ENDS----------------------------------")
(logger.ilog "=================================================")
