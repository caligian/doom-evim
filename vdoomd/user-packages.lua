return {
    essentials = {
        desc = "These are the essential packages without which doom-evim won't run",
        lock = false,
        ["packer.nvim"] = {repo = "wbthomason/packer.nvim", desc = "Plugin Manager"},
        vimpeccable = {repo = "svermeulen/vimpeccable", desc = "For keybindings"},
        ["plenary.nvim"] = {repo = "nvim-lua/plenary.nvim", desc = "Important functions"},
        aniseed = {repo = "Olical/aniseed", desc = "Using fennel (lisp-lua) with neovim"},
        conjure = {repo = "Olical/conjure", desc = "REPL for fennel"},
        ["fennel.vim"] = {repo = "bakpakin/fennel.vim", desc = "Syntax highlighting for fennel"},
        ["which-key.nvim"] = {repo = "folke/which-key.nvim", desc = "Show keybindings at keypress"},
        ["Repeatable.vim"] = {repo = "kreskij/Repeatable.vim", desc = "Make keybindings easily repeatable"}
    },

    ui = {
        desc = "These are important ui enhancements for doom-evim",
        lock = false,
        ["galaxyline.nvim"] = {repo = "glepnir/galaxyline.nvim", desc = "A utilitarian mode-line for doom"},
        ["vim-palette"] = {repo = "gmist/vim-palette", desc = "An awesome collection of colorschemes"},
        ["vim-devicons"] = {repo = "ryanoasis/vim-devicons", desc = "Icons for doom ui"},
        ["nvim-web-devicons"] = {repo = "kyazdani42/nvim-web-devicons", desc = "Icons for doom ui"},
        ["telescope.nvim"] = {repo = "nvim-telescope/telescope.nvim", desc = "Telescope integration for vim. Just like ivy of emacs"},
        ["telescope-project.nvim"] = {repo = "nvim-telescope/telescope-project.nvim", desc = "Project management plugin for telescope"},
        ["telescope-file-browser.nvim"] = {repo = "nvim-telescope/telescope-file-browser.nvim", desc = "File browser plugin for telescope"},
        ["zen-mode.nvim"] = {repo = "folke/zen-mode.nvim", desc = "For a non-distracting editor experience"}
    },

    editor = {
        desc = "These will make editing easier for you.",
        lock = false,
        ["vim-session"] = {repo = "xolox/vim-session"},
        ["vim-misc"] = {repo = "xolox/vim-misc"},
        ["vim-bbye"] = {repo = "moll/vim-bbye", desc = "When the last buffer is killed, the previous one is opened"},
        ["vim-dispatch"] = {repo = "tpope/vim-dispatch", desc = "Use async dispatchers to run jobs"},
        tagbar = {repo = "preservim/tagbar", desc = "A nice tree showing all your tags"},
        undotree = {repo = "mbbill/undotree", desc = "A better undo for doom"},
        nerdcommenter = {repo = "preservim/nerdcommenter", desc = "Effortless commenting"},
        ["vim-markdown"] = {repo = "plasticboy/vim-markdown", desc = "Well, for documentation"},
        ["vim-surround"] = {repo = "tpope/vim-surround", desc = "Quickly surround text with <char>"},
        delimitMate = {repo = "Raimondi/delimitMate", desc = "Autoclose parenthesis and other delimeters"},
        ["indent-blankline.nvim"] = {repo = "lukas-reineke/indent-blankline.nvim", desc = "Show indent guide blanklines"}
    },

    git = {
        desc = "Git plugins for doom",
        lock = false,
        ["vim-fugitive"] = {repo = "tpope/vim-fugitive", desc = "Must-have Git plugin for vim"},
        ["vim-rhubarb"] = {repo = "tpope/vim-rhubarb", desc = "Easily push commits without opening on the browser"},
        ["gitsigns.nvim"] = {repo = "lewis6991/gitsigns.nvim", desc = "Signs for added, removed or changed signs"}
    },

    lsp = {
        desc = "The default LSP configuration used in doom",
        lock = false,
        ["nvim-lspconfig"] = {repo = "neovim/nvim-lspconfig"},
        ["nvim-treesitter"] = {repo = "nvim-treesitter/nvim-treesitter"},
        ["nvim-lsp-installer"] = {repo = "williamboman/nvim-lsp-installer"},
        ["nvim-cmp"] = {repo = "hrsh7th/nvim-cmp"},
        ["cmp-nvim-lsp"] = {repo = "hrsh7th/cmp-nvim-lsp"},
        cmp_luasnip = {repo = "saadparwaiz1/cmp_luasnip"},
        LuaSnip = {repo = "L3MON4D3/LuaSnip"},
        ultisnips = {repo = "SirVer/ultisnips"}
    },

    langs = {
        desc = "Langauge-specific modules for doom",
        lock = false,
        ["pytest.vim"] = {repo = "Vimjass/vim-python-pep8-indent", desc = "Better python indentation"},
        ["vim-rspec"] = {repo = "thoughtbot/vim-rspec", desc = "Rspec plugin for doom"},
        ["vim-rake"] = {repo = "tpope/vim-rake", desc = "Ruby builder for doom"},
        ["vim-projectionist"] = {repo = "tpope/vim-projectionist", desc = "For ruby project handling"},
        ["vim-rails"] = {repo = "tpope/vim-rails", desc = "A nice plugin for ruby rails"},
        ["nvim-luapad"] = {repo = "rafcamlet/nvim-luapad", desc = "A nice lua REPL for vim"}
    }
}
