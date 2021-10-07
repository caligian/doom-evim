" You have to restart vim after editing this file :(. Be careful
"
"

"" Grep convenience funcs
" Fdfind
function! SearchStringInDir(fregex, dglob, regex)
ruby << EOF

fregex, dglob, regex = VIM::evaluate('a:fregex'), VIM::evaluate('a:dglob'), VIM::evaluate('a:regex')

# Modify the exclude strings as required. 
out = %x(fdfind "#{fregex}" "#{dglob}" --exclude '\.git' --exclude '\.*' -X egrep -n "#{regex}" {})
puts out
EOF
endfunction
command! -nargs=+ Grep call SearchStringInDir(<f-args>)

" Fdfind . 
function! SearchFileInThisDir(file)
    exec 'Fdfind ' . a:file . ' . ""'
endfunction
command! -nargs=+ FdfindHere call SearchFileInThisDir(<f-args>)

function! LoadBuffer()
    if (expand("%:e") == "vim")
        exec "source " . expand("%:p")
    else
        echom 'This is not a vimscript buffer'
    endif
endfunction
command! -nargs=0 LoadBuffer call LoadBuffer()
