(module package-utils
  {autoload {utils utils
             core aniseed.core
             fun fun}})

(set _G.doom.user_packages (require :user-packages))

(set _G.doom.default_packages {:essentials 
                               {:desc "These are the essential packages without which doom-evim won't run" 
                                :lock false
                                :packer.nvim {:repo "wbthomason/packer.nvim" :desc "Plugin Manager"}
                                :vimpeccable {:repo "svermeulen/vimpeccable" :desc "For keybindings"}
                                :plenary.nvim {:repo "nvim-lua/plenary.nvim" :desc "Important functions"} 
                                :aniseed {:repo "Olical/aniseed" :desc "Using fennel (lisp-lua) with neovim"}
                                :conjure {:repo "Olical/conjure" :desc "REPL for fennel"}
                                :fennel.vim {:repo "bakpakin/fennel.vim" :desc "Syntax highlighting for fennel"}
                                :which-key.nvim {:repo "folke/which-key.nvim" :desc "Show keybindings at keypress"}
                                :Repeatable.vim {:repo "kreskij/Repeatable.vim" :desc "Make keybindings easily repeatable"}} 

                               :ui 
                               {:desc "These are important ui enhancements for doom-evim"
                                :lock false
                                :galaxyline.nvim {:repo "glepnir/galaxyline.nvim" :desc "A utilitarian mode-line for doom"}
                                :vim-palette {:repo "gmist/vim-palette" :desc "An awesome collection of colorschemes"}
                                :vim-devicons {:repo "ryanoasis/vim-devicons" :desc "Icons for doom ui"}
                                :nvim-web-devicons {:repo "kyazdani42/nvim-web-devicons" :desc "Icons for doom ui"}
                                :telescope.nvim {:repo "nvim-telescope/telescope.nvim" :desc "Telescope integration for vim. Just like ivy of emacs"}
                                :telescope-project.nvim {:repo "nvim-telescope/telescope-project.nvim" :desc "Project management plugin for telescope"}
                                :telescope-file-browser.nvim {:repo "nvim-telescope/telescope-file-browser.nvim" :desc "File browser plugin for telescope"}
                                :zen-mode.nvim {:repo "folke/zen-mode.nvim" :desc "For a non-distracting editor experience"}}

                               :editor
                               {:desc "These will make editing easier for you."
                                :lock false
                                :vim-session {:repo "xolox/vim-session"}
                                :vim-misc {:repo "xolox/vim-misc"}
                                :vim-bbye {:repo "moll/vim-bbye"  :desc "When the last buffer is killed, the previous one is opened"}
                                :vim-dispatch {:repo "tpope/vim-dispatch"  :desc "Use async dispatchers to run jobs"}
                                :tagbar {:repo "preservim/tagbar"  :desc "A nice tree showing all your tags"}
                                :undotree {:repo "mbbill/undotree"  :desc "A better undo for doom"}
                                :nerdcommenter {:repo "preservim/nerdcommenter" :desc "Effortless commenting"}
                                :vim-markdown {:repo "plasticboy/vim-markdown" :desc "Well, for documentation"}
                                :vim-surround {:repo "tpope/vim-surround" :desc "Quickly surround text with <char>"}
                                :delimitMate {:repo "Raimondi/delimitMate" :desc "Autoclose parenthesis and other delimeters"}
                                :indent-blankline.nvim {:repo "lukas-reineke/indent-blankline.nvim" :desc "Show indent guide blanklines"}}

                               :git 
                               {:desc "Git plugins for doom"
                                :lock false
                                :vim-fugitive {:repo "tpope/vim-fugitive" :desc "Must-have Git plugin for vim"}
                                :vim-rhubarb {:repo "tpope/vim-rhubarb" :desc "Easily push commits without opening on the browser"}
                                :gitsigns.nvim {:repo "lewis6991/gitsigns.nvim" :desc "Signs for added, removed or changed signs"} }

                               :lsp {:desc "The default LSP configuration used in doom"
                                     :lock false
                                     :nvim-lspconfig {:repo "neovim/nvim-lspconfig" :locked false}
                                     :nvim-treesitter {:repo "nvim-treesitter/nvim-treesitter" :locked false}
                                     :nvim-lsp-installer {:repo "williamboman/nvim-lsp-installer" :locked false}
                                     :nvim-cmp {:repo "hrsh7th/nvim-cmp" :locked false}
                                     :cmp-nvim-lsp {:repo "hrsh7th/cmp-nvim-lsp" :locked false}
                                     :cmp_luasnip {:repo "saadparwaiz1/cmp_luasnip" :locked false}
                                     :LuaSnip {:repo "L3MON4D3/LuaSnip" :locked false}
                                     :ultisnips {:repo "SirVer/ultisnips" :locked false}}

                               :langs
                               {:desc "Langauge-specific modules for doom"
                                :lock false

                                ; Python
                                :pytest.vim {:repo "Vimjass/vim-python-pep8-indent" :desc "Better python indentation"}

                                ; Ruby
                                :vim-rspec {:repo "thoughtbot/vim-rspec" :desc "Rspec plugin for doom"}
                                :vim-rake {:repo "tpope/vim-rake" :desc "Ruby builder for doom"}
                                :vim-projectionist {:repo "tpope/vim-projectionist" :desc "For ruby project handling"}
                                :vim-rails {:repo "tpope/vim-rails" :desc "A nice plugin for ruby rails"}

                                ; Lua
                                :nvim-luapad {:repo "rafcamlet/nvim-luapad" :desc "A nice lua REPL for vim"}}})

(set _G.doom.package_forms {})
(set _G.doom.user_package_forms {})

(defn make-package-forms [t]
  (let [target-t {}]
    (core.map #(when (. t $1)
                 (let [category $1
                      pkgs-t (. t category)
                      pkgs (core.map #(when (and (not (= $1 "desc")) 
                                                 (not (= $1 "lock")))
                                        $1) 
                                     (utils.keys pkgs-t))
                      lock-status (if (. pkgs-t :lock)
                                    (utils.vec (fun.take (fun.cycle [(. pkgs-t) :lock])))
                                    (core.map #(let [_pkg-t (. pkgs-t $1)
                                                     _lock  (or (. _pkg-t :lock) true)]
                                                 _lock)
                                              pkgs))
                      repos (core.map #(let [_pkg-t (. pkgs-t $1)] (. _pkg-t :repo)) pkgs)]
                  (for [i 1 (length pkgs)]
                    (tset target-t (. pkgs i) (let [_repo (. repos i)
                                                    _lock (. lock-status i)
                                                    _name (. pkgs i)
                                                    t {}]
                                                (table.insert t _repo)
                                                (tset t :lock _lock)
                                                t))))) 
              [:essentials :ui :editor :git :lsp :langs])
    target-t))

(set _G.doom.default_package_forms (make-package-forms doom.default_packages))
(set _G.doom.user_package_forms (make-package-forms doom.user_packages))

(defn get-master-list []
  (let [default-packages doom.default_package_forms
        default-pkgs (utils.keys default-packages)
        default-pkgs (Set default-pkgs)

        current-packages doom.user_package_forms
        current-pkgs (utils.keys current-packages)
        current-pkgs (Set current-pkgs)

        new-pkgs     (utils.set-items (current-pkgs.difference default-pkgs))
        missing-pkgs (utils.set-items (default-pkgs.difference current-pkgs))
        remaining-pkgs (utils.set-items (current-pkgs.difference (Set new-pkgs)))
        doom-packages {}
        master-t []]

    ; Disable missing packages
    (when (> (length missing-pkgs) 0) 
      (each [_ k (ipairs missing-pkgs)]
        (tset default-packages k nil)))

    (when (> (length new-pkgs) 0)
      (each [_ k (ipairs new-pkgs)]
        (tset doom-packages k (. current-packages k))
        (table.insert master-t (. current-packages k))))

    (when (> (length remaining-pkgs) 0)
      (each [_ k (ipairs remaining-pkgs)]
        (tset doom-packages k (. current-packages k))
        (table.insert master-t (. current-packages k))))

    (tset doom :packages doom-packages)
    master-t))
