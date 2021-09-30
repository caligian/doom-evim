filetype plugin indent on 
filetype off 

" set declarations here 
set nocompatible
set nobackup
set history=1000
set ruler
set autochdir
set showcmd
set incsearch
set vb
set wildmode=longest,list,full
set wildmenu
set laststatus=2
set mousefocus
set shell=/usr/bin/zsh
set backspace=indent,eol,start
set number
set numberwidth=4
set tabstop=4
set shiftwidth=4
set expandtab
syntax on

" leader key 
nnoremap <SPACE> <Nop>
let mapleader = "\<SPACE>"
let maplocalleader = "," 

echom '<leader>fV to load all user configs/plugins'

function! SourceAllConfigs()
    " The order matters here
    let l:config_dir = '~/.config/nvim/'
    for i in ["packages.vim", "config.vim", "functions.vim", "keybindings.vim"]
        exec ":source " . l:config_dir .. i
    endfor
endfunction

function! SourceUserPlugins()
    " Load everything from user_plugins
    let l:config_dir = '~/.config/nvim/user_plugins/' 
    let l:query = l:config_dir . '*'
    for i in split(glob(l:query), '\n')
        exec ':source ' . i
    endfor
endfunction

noremap <leader>fV :call SourceAllConfigs() \| call SourceUserPlugins() \| echo 'All user configs and plugins loaded!'<CR>
