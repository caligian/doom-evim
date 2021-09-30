" This file contains package declarations

call plug#begin(stdpath('data') . '/plugged')

" Parens and sexp
Plug 'tpope/vim-surround'
Plug 'jiangmiao/auto-pairs'

" Commenting 
Plug 'preservim/nerdcommenter'

" File nav / Project management
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'ryanoasis/vim-devicons'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'kien/ctrlp.vim'
Plug 'jremmen/vim-ripgrep'
Plug 'tpope/vim-obsession'
Plug 'dhruvasagar/vim-prosession'
Plug 'jlanzarotta/bufexplorer'

" LSP stuff [config.vim]
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Themes, Statusline, etc
Plug 'rainglow/vim'
Plug 'flazz/vim-colorschemes'
Plug 'adriamanu/gundam-vim-colorscheme'
Plug 'vim-airline/vim-airline' 
Plug 'vim-airline/vim-airline-themes' 
Plug 'bling/vim-bufferline'

" easymotion
Plug 'easymotion/vim-easymotion'

" For completion
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'roxma/nvim-yarp'
Plug 'roxma/vim-hug-neovim-rpc'

" which-key
Plug 'liuchengxu/vim-which-key'

" Align exp 
Plug 'pix/vim-align'

" Tagbar
Plug 'preservim/tagbar'

" Git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter/'

" Snippets like yasnippets
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'tomtom/tlib_vim'
Plug 'garbas/vim-snipmate'
Plug 'honza/vim-snippets'

call plug#end()

