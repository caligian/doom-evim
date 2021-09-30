" This file shall contain all the package-related configs
"
" Themes
colorscheme pastel

" Airline
AirlineTheme fairyfloss
let g:airline_theme = 'fairyfloss'
let g:airline#extensions#tabline#enabled = 1
let g:airline_statusline_ontop = 1

" vim-which-key
nnoremap <silent> <leader>      :<c-u>WhichKey '<Space>'<CR>
nnoremap <silent> <localleader> :<c-u>WhichKey  ','<CR>
set timeoutlen=500

" auto-pairs
let g:AutoPairsShortcutFastWrap   = ''
let g:AutoPairsShortcutJump       = ''
let g:AutoPairsShortcutBackInsert = ''

"" reply.vim
" For tracking REPLs across buffers
let g:repl_buffers = {}

" To get the correct REPL 
let g:repl_assoc = {
            \'ps1'  : 'powershell',
            \'py'   : 'python3',
            \'mjs'  : 'node',
            \'js'   : 'node',
            \'rb'   : 'pry',
            \'zsh'  : 'zsh',
            \'bash' : 'bash',
            \'sh'   : 'bash'
            \}

"" reply_any.vim
" For setting a custom REPL for input for the current buffer
let g:repl_any_current_alias = 'shell'

" To get the current command
let g:repl_any_alias_assoc = {'shell': 'zsh'}
let g:repl_any_buffers = {}

" GitGutter
GitGutterDisable
