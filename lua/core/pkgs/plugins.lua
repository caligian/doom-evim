return {
    start = {
        {"kyazdani42/nvim-tree.lua"}; 
        {'guns/vim-sexp' };
        { "savq/paq-nvim" };
        {'ggandor/lightspeed.nvim'};
        { "ryanoasis/vim-devicons" };
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
            keys = {{'luapad', 'n', "<F3>", ':Luapad', false, 'Open an interactive lua buffer'}};
            keep_keys = true;
        };
        { 
            "folke/trouble.nvim"; 
            keys = {{'trouble', 'n', "<leader>lt", ':TroubleToggle', false, 'Toggle trouble'}};
            keep_keys = true;
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
            keys = {{'zenmode', "n", "<leader>bz", ':ZenMode', false, 'Start zenmode'}};
            keep_keys = true;
        };
        {
            "tpope/vim-fugitive";
            keys = {{'Git', 'n', "<leader>gg", ':Git', false, 'Open interactive git'}};
        };
        { 
            "tpope/vim-rhubarb"; 
            keys = {{'Gitbhubarb', "n", "<leader>gG", ":G ", false, "Start Git hub using rhubarb"}};
        };
        { 
            "godlygeek/tabular";
            keep_keys           = true;
            keys                = {
                {'tabular', "n", '<leader>=', function()
                    local pat   = gets('%', false, {'Align using', '/ = /'})
                    if pat[1] then
                        vim.cmd(':Tabularize ' .. first(pat))
                    end
                end, false, "Tabulate strings"}; 
                {'tabular', "v", '<leader>=', function()
                    local pat = gets('%', false, {'Align using', '/=/'})
                    if pat[1] then
                        vim.cmd(":'<,'>Tabularize " .. first(pat))
                    end
                end, false, "Tabulate strings"}};
        };
        { 
            "preservim/tagbar";
            keep_keys = true;
            keys = {{'tagbar', 'n', "<C-t>", ':TagbarToggle', false, 'Open tags bar'}};
        };
        { 
            "nvim-telescope/telescope-file-browser.nvim";
            keys = {{'ts_filebrowser', 'n', '<leader>fF', function()
                local t = require("telescope")
                t.load_extension("file_browser")
                t.setup {extensions={file_browser=merge(copy(telescope.defaults.opts), {hijack_netrw=true})}}
                t.extensions.file_browser.file_browser(telescope.defaults.opts)
            end, false, 'Open file browser'}};
        };
        { 
            "nvim-telescope/telescope-project.nvim";
            keep_keys = true;
            keys = {{'ts_project', 'n', '<leader>pp', function()
                local t = require("telescope")
                t.load_extension("project")
                t.setup {extensions={project=merge(copy(ts.defaults.opts), {hijack_netrw=true})}}
                t.extensions.project.project(ts.defaults.opts)
            end, false, 'Open projects'}};
        };
    };
}
