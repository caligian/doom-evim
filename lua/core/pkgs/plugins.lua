--[[
This is the default package declaration for doom. Packages in key 'start' will be loaded along with their configs automatically. Packages in key 'opt' will be manually loaded based on certain trigger. You should follow the package specification given for paq at github.com/savq/paq-nvim. Other than that, there are other keys that are similar to the ones used in packer.nvim.

Additionally, users can edit this table. The overrides files should be located at ~/.vdoom.d/lua/user/pkgs/init.lua

Paq plugin specification:

[1] string username/repo
as      string  
Alias

branch  string  
Git branch for repo

opt     boolean 
Treat the package as optional. However, in this specification, this is redundant

pin     boolean 
Don't update this plugin

run  string|callable  
Run such command/callable after installing/updating plugins 

---

Additional configuration for facilitating lazy-loading:

Combinations of keys that can be supplied:
- keys & rocks 
- event & pattern & rocks
- event & rocks
- pattern & rocks
- cond & rocks

keys    string|table[string]
Load package after pressing these keys. 
Keys should be in the format:
{mode, keys, attribs, doc, event, pattern} where attribs, event, pattern can be string|table and the rest must be strings or keys
If keys is a string then it will be mapped with noremap {keys} {plugin loader}

event   string|table[string]
Load package after this event.

pattern string|table[string]
Load package if pattern is true for buffer, files, etc.

cond    callable
If cond returns true, load the package

rocks   string|table[string]
Luarocks required for the plugin

Loading post-loading configurations:
Configurations are located in core/pkgs/configs. For lazy-loaded packages, these configurations will be loaded as soon as the appropriate event is triggered

--]]

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
