return {
    start = {
        { "savq/paq-nvim" };
        { "tpope/vim-rhubarb" };
        { "ryanoasis/vim-devicons" };
        { "tpope/vim-fugitive" };
        { "folke/which-key.nvim" };
        { "svermeulen/vimpeccable" };
        {'gmist/vim-palette'};
        {'unblevable/quick-scope'};
        {'kyazdani42/nvim-tree.lua'};
        { "hrsh7th/cmp-nvim-lsp" };
        { "hrsh7th/cmp-path" };
        { "hrsh7th/cmp-vsnip" };
        { "Raimondi/delimitMate" };
        { "rafamadriz/friendly-snippets" };
        { "nvim-lualine/lualine.nvim" };
        { "hrsh7th/nvim-cmp" };
        { "williamboman/nvim-lsp-installer" };
        { "neovim/nvim-lspconfig" };
        { "nvim-treesitter/nvim-treesitter" };
        { "nvim-treesitter/nvim-treesitter-textobjects" };
        { "kyazdani42/nvim-web-devicons" };
        { "mhartington/oceanic-next" };
        { "nvim-telescope/telescope-file-browser.nvim" };
        { "nvim-telescope/telescope-fzf-native.nvim" };
        { "nvim-telescope/telescope-project.nvim" };
        { "nvim-telescope/telescope.nvim" };
        { "lukas-reineke/indent-blankline.nvim" };
        { "godlygeek/tabular" };
        { "folke/persistence.nvim" };
        { "nvim-lua/plenary.nvim" };
        { "preservim/tagbar" };
        { "preservim/nerdcommenter" };
        { "tpope/vim-surround" };
        { "hrsh7th/vim-vsnip" };
        { "hrsh7th/vim-vsnip-integ" };
        {'rcarriga/nvim-notify'};
    };

    opt = {
        { 
            "iamcco/markdown-preview.nvim";
            pattern = {'*md'};
        };
        { 
            "rafcamlet/nvim-luapad";
            keys = '<F3>';
        };
        { 
            "folke/trouble.nvim"; 
            keys = '<leader>lt';
        };
        { 
            "plasticboy/vim-markdown";
            pattern = '*.md';
        };
        { 
            "puremourning/vimspector";
            pattern = {'*py', '*rb', '*lua', '*js'};
        };
        { 
            "folke/zen-mode.nvim"; 
            keys = '<leader>bz';
        };
        {
            'nvim-neorg/neorg';
            keys = '<leader>oo';
        };
    };
}
