local TreesitterConfigs = require('nvim-treesitter.configs')

TreesitterConfigs.setup {
    ensure_installed =  Doom.treesitter_langs,
    sync_install =  true,
    highlight =  {enable = false},
    indent =  {enable = false}
}
