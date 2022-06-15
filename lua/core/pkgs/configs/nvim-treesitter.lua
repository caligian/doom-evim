local ts = require('nvim-treesitter.configs')

ts.setup {
    ensure_installed =  Doom.treesitter.ensure,
    sync_install =  true,
    highlight =  {enable = false},
    indent =  {enable = false}
}
