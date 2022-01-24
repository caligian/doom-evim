-- This file contains a list of package declarations in packer_forms. This is the format.
-- Unless modified, this table is equivalent to the default one doom uses.
-- However, these are the primary packages used. Hence if you remove anything, that package will not be used. If you add a new package, that package will be used.

return {
    -- essentials
    ["packer.nvim"] = {"wbthomason/packer.nvim" , lock = true},
    vimpeccable = {"svermeulen/vimpeccable" , lock = true},
    ["plenary.nvim"] = {"nvim-lua/plenary.nvim" , lock = true},
    aniseed = {"Olical/aniseed" , lock = true},
    conjure = {"Olical/conjure" , lock = true},
    ["fennel.vim"] = {"bakpakin/fennel.vim" , lock = true},
    ["which-key.nvim"] = {"folke/which-key.nvim" , lock = true},
    ["Repeatable.vim"] = {"kreskij/Repeatable.vim" , lock = true},
    ["paredit.vim"] = {"vim-scripts/paredit.vim" , lock = true},

    -- ui
    ["dirbuf.nvim"] = {"elihunter173/dirbuf.nvim" , lock = true},
    ["galaxyline.nvim"] = {"glepnir/galaxyline.nvim" , lock = true},
    ["vim-palette"] = {"gmist/vim-palette" , lock = true},
    ["vim-devicons"] = {"ryanoasis/vim-devicons" , lock = true},
    ["nvim-web-devicons"] = {"kyazdani42/nvim-web-devicons" , lock = true},
    ["telescope.nvim"] = {"nvim-telescope/telescope.nvim" , lock = true},
    ["telescope-project.nvim"] = {"nvim-telescope/telescope-project.nvim" , lock = true},
    ["telescope-file-browser.nvim"] = {"nvim-telescope/telescope-file-browser.nvim" , lock = true},
    ["zen-mode.nvim"] = {"folke/zen-mode.nvim" , lock = true},
    ["twilight.nvim"] = {"folke/twilight.nvim" , lock = true},

    -- editor
    ["formatter.nvim"] = {"mhartington/formatter.nvim" , lock = true},
    ["vim-session"] = {"xolox/vim-session" , lock = true},
    ["vim-misc"] = {"xolox/vim-misc" , lock = true},
    ["vim-bbye"] = {"moll/vim-bbye" , lock = true},
    ["vim-dispatch"] = {"tpope/vim-dispatch" , lock = true},
    tagbar = {"preservim/tagbar" , lock = true},
    undotree = {"mbbill/undotree" , lock = true},
    nerdcommenter = {"preservim/nerdcommenter" , lock = true},
    ["vim-markdown"] = {"plasticboy/vim-markdown" , lock = true},
    ["markdown-preview.nvim"] = {"iamcco/markdown-preview.nvim" , lock = true},
    ["vim-surround"] = {"tpope/vim-surround" , lock = true},
    delimitMate = {"Raimondi/delimitMate" , lock = true},
    ["indent-blankline.nvim"] = {"lukas-reineke/indent-blankline.nvim" , lock = true},

    -- git
    ["vim-fugitive"] = {"tpope/vim-fugitive" , lock = true},
    ["vim-rhubarb"] = {"tpope/vim-rhubarb" , lock = true},
    ["gitsigns.nvim"] = {"lewis6991/gitsigns.nvim" , lock = true},

    -- lsp
    ["nvim-lspconfig"] = {"neovim/nvim-lspconfig" , lock = true},
    ["nvim-treesitter"] = {"nvim-treesitter/nvim-treesitter" , lock = true},
    ["nvim-lsp-installer"] = {"williamboman/nvim-lsp-installer" , lock = true},
    ['friendly-snippets'] = {"rafamadriz/friendly-snippets" , lock = true},
    ['vim-vsnip'] = {"hrsh7th/vim-vsnip" , lock = true},
    ['cmp-vsnip'] = {"hrsh7th/cmp-vsnip" , lock = true},
    ['vim-vsnip-integ'] = {"hrsh7th/vim-vsnip-integ" , lock = true},
    ['cmp-nvim-lsp'] = {"hrsh7th/cmp-nvim-lsp" , lock = true},
    ['cmp-buffer'] = {"hrsh7th/cmp-buffer" , lock = true},
    ['cmp-path'] = {"hrsh7th/cmp-path" , lock = true},
    ['cmp-cmdline'] = {"hrsh7th/cmp-cmdline" , lock = true},
    ['nvim-cmp'] = {"hrsh7th/nvim-cmp" , lock = true},

    -- langs
    ["vim-rspec"] = {"thoughtbot/vim-rspec" , lock = true},
    ["vim-rake"] = {"tpope/vim-rake" , lock = true},
    ["vim-projectionist"] = {"tpope/vim-projectionist" , lock = true},
    ["vim-rails"] = {"tpope/vim-rails" , lock = true},
    ["nvim-luapad"] = {"rafcamlet/nvim-luapad" , lock = true},
}

