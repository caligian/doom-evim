return {
    start = {
        { "savq/paq-nvim" };
        { "ryanoasis/vim-devicons" };
        { "tpope/vim-fugitive" };
        { "folke/which-key.nvim" };
        { "svermeulen/vimpeccable" };
        { "gmist/vim-palette" };
        { "unblevable/quick-scope" };
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
        { "nvim-telescope/telescope-fzf-native.nvim" };
        { "nvim-telescope/telescope.nvim" };
        { "lukas-reineke/indent-blankline.nvim" };
        { "folke/persistence.nvim" };
        { "nvim-lua/plenary.nvim" };
        { "preservim/nerdcommenter" };
        { "tpope/vim-surround" };
        { "hrsh7th/vim-vsnip" };
        { "hrsh7th/vim-vsnip-integ" };
        { "rcarriga/nvim-notify" };
    };

    opt = {
        { 
            "iamcco/markdown-preview.nvim";
            pattern = {"*md"};
        };
        { 
            "rafcamlet/nvim-luapad";
            keys = {'n', "<F3>", ':Luapad', false, 'Open an interactive lua buffer'};
        };
        { 
            "folke/trouble.nvim"; 
            keys = {'n', "<leader>lt", ':TroubleToggle', false, 'Toggle trouble'};
        };
        { 
            "plasticboy/vim-markdown";
            pattern = "*.md";
        };
        { 
            "puremourning/vimspector";
            pattern = {"*py", "*rb", "*lua", "*js"};
        };
        { 
            "folke/zen-mode.nvim"; 
            keys = {"n", "<leader>bz", ':ZenMode', false, 'Start zenmode'};
        };
        {
            "nvim-neorg/neorg";
            keys = {'n'; "<leader>oo", ':NeorgStart', false, 'Initialize neorg'};
        };
        {
            "tpope/vim-fugitive";
            keys = {'n', "<leader>gg", ':Git', false, 'Open interactive git'};
        };
        { 
            "tpope/vim-rhubarb"; 
            keys = {"n", "<leader>gG", ":G ", false, "Start Git hub using rhubarb"};
        };
        { 
            "godlygeek/tabular";
            keys = {"n", '<leader>=', ":Tabular ", false, "Tabulate strings"};
        };
        { 
            "preservim/tagbar";
            keys = {'n', "<C-t>", ':TagbarToggle', false, 'Open tags bar'};
        };
        { 
            "nvim-telescope/telescope-file-browser.nvim";
            keys = {'n', '<leader>fF', ':lua require("telescope").load_extension("file_browser"); vim.cmd("Telescope file_browser")', false, 'Open file browser'};
        };
        { 
            "nvim-telescope/telescope-project.nvim";
            keys = {'n', '<leader>pp', ':Telescope project', false, 'Open projects'};
        };
        { 
            "kyazdani42/nvim-tree.lua"; 
            keys = {'n', '<leader>`', ':NvimTreeToggle', false, 'Toggle file tree'}
        };
    };
}
