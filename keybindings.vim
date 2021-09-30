" Package independent keybindings
"
" User maps: <C-,> <C-;>  <C-/?
"
" <C-,> Window management
"
"Fixing the fucking ESC key in terminal 
tnoremap <Esc> <C-\><C-n> 

" Command mode
noremap <leader><leader> : 
" Buffer stuff
noremap <leader>bk :q!<CR>

" Buffers 
noremap <leader>bb :BufExplorer<CR>
noremap <leader>bq :q!<CR>
noremap <leader>bk :hide<CR>
noremap <leader>qw :xa<CR>
noremap <leader>qq :qa!<CR>
noremap <leader>be :CtrlP<CR>
noremap <leader>bn :noh<CR>

" Theming, help, history 
noremap <leader>ht :colorscheme 
noremap <leader>hh :<C-f>

" Files
noremap <leader>ff :CtrlP<CR> 
noremap <leader>fs :w<CR>
noremap <leader>fd :e! DIR
noremap <leader>fD :CtrlP DIR
noremap <leader>fp :e! ~/.config/nvim/
noremap <leader>fv :w <bar> source %<CR>
noremap <leader>fr :CtrlPMRUFiles<CR>

"" Search strings
noremap <leader>ss :s/\v//
noremap <leader>s% :%s/\v//

" GNU Linux 
noremap <leader>sf :Fdfind 
noremap <leader>/  :Grep
noremap <leader>sP :!perl -p -e 's///'; 
noremap <leader>sS :!perl -p -e 's///' DIR/*

" Tab management
noremap <C-,><C-k> :tabclose<CR>
noremap <C-,><C-n> :tabnext<CR>
noremap <C-,><C-p> :tabprevious<CR>
noremap <C-,><C-f> :tabfind
noremap <C-,><C-e> :tabedit
noremap <C-,><C-t> :tabnew

"" Easymotion
map  <A-"> <Plug>(easymotion-bd-f)
nmap <A-"> <Plug>(easymotion-overwin-f)

" s{char}{char} to move to {char}{char}
nmap s <Plug>(easymotion-overwin-f2)

" Move to line
map <A-n> <Plug>(easymotion-bd-jk)
nmap <A-n> <Plug>(easymotion-overwin-line)

" Move to word
map  <A-'> <Plug>(easymotion-bd-w)
nmap <A-'> <Plug>(easymotion-overwin-w)

" reply.vim [REPL]
noremap  <localleader>'  : Repl<CR>
noremap  <localleader>ee : ReplSend<CR>
vnoremap <localleader>er : '<,'>ReplSend<CR>

" NERDTree
nnoremap <leader>tt <nop>
nnoremap <leader>tn :NERDTreeFocus<CR>
nnoremap <leader>te :NERDTree<CR>
nnoremap <leader>tt :NERDTreeToggle<CR>
nnoremap <leader>tf :NERDTreeFind<CR>
nnoremap <leader>tb :NERDTreeFind <bar> :Bookmark<CR>

" Align
noremap <leader>= :Align 

" Tagbar
noremap <C-t> :TagbarToggle<CR>

" vim-fugitive | Git-gutter
noremap <leader>gg :Git<CR>
noremap <leader>gi :Git init<CR>
noremap <leader>ga :Git add %<CR>
noremap <leader>gs :Git stage %<CR>
noremap <leader>gc :Git commmit %<CR>
noremap <leader>gp :Git push 
noremap <leader>gm :Git merge 
noremap <leader>gb :GitGutterEnable<CR>
noremap <leader>gB :GitGutterDisable<CR>

" Theming
noremap <leader>htt :colorscheme 
noremap <leader>hta :AirlineTheme 

" Plugin Management
noremap <leader>hpi :PlugInstall<CR>
noremap <leader>hpc :PlugClean<CR>
noremap <leader>hpd :PlugDiff<CR>
noremap <leader>hpn :PlugSnapshot<CR>
noremap <leader>hps :PlugStatus<CR>
noremap <leader>hpu :PlugUpdate<CR>
noremap <leader>hpp :PlugUpgrade<CR>

" Shell
noremap <leader>` :! 

" repl and repl_any
noremap <leader>" :ReplVsplit<CR>
noremap <leader>' :ReplSplit<CR>
noremap <leader>er :ReplSendRegion<CR>
noremap <leader>ee :ReplSendLine<CR>
noremap <leader>eb :ReplSendBuffer<CR>
noremap <leader>ep :ReplSendTillPoint<CR>
noremap <leader>et :ReplSendString<CR>

noremap <localleader>" :ReplAnyVsplit<CR>
noremap <localleader>' :ReplAnySplit<CR>
noremap <localleader>er :ReplAnySendRegion<CR>
noremap <localleader>ee :ReplAnySendLine<CR>
noremap <localleader>eb :ReplAnySendBuffer<CR>
noremap <localleader>ep :ReplAnySendTillPoint<CR>
noremap <localleader>et :ReplAnySendString<CR>
