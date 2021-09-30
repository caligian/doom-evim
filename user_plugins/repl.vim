" Will contain REPL buffer info
" 'ext' => [['assoc_buffer', 'buffer']]
"
function! ReplGetRepl(ext)
    if has_key(g:repl_assoc, a:ext)
        return get(g:repl_assoc, a:ext)
    else
        echo 'No REPL can be launched for this buffer.'
        return 0
    endif
endfunction

function! ReplRun()
    let l:ext = expand('%:e')
    let l:repl = ReplGetRepl(l:ext)
    let l:repl_buffer = '' 
    let l:terminal_job_id = 0

    if type(l:repl) == v:t_number
        return 0
    endif
    
    let l:cmd = 'tabnew | term ' . l:repl
    let l:repl_buffer = ""

    exec l:cmd
    let l:repl_buffer = bufname('%')
    let l:terminal_job_id = b:terminal_job_id
    let l:keep = [l:terminal_job_id, l:repl_buffer]
    let g:repl_buffers[l:ext] = l:keep
    hide

    return l:keep
endfunction

function! ReplExists()
    let l:ext = expand('%:e')
    if has_key(g:repl_buffers, l:ext)
        let l:repl_buf_l = get(g:repl_buffers, l:ext)
        let l:repl_buf = l:repl_buf_l[1]
        let l:repl_exists = bufexists(l:repl_buf)

        if l:repl_exists == 1
            return l:repl_buf_l
        else
            return 0
        endif
    else
        return 0
    end
endfunction

function! ReplSplitAndShow(d, buf)
    let l:cmd = ''
    if a:d == 'v'
        let l:cmd = 'vsplit | wincmd l | buffer ' . a:buf
    else
        let l:cmd = 'split | wincmd j | buffer ' . a:buf
    endif
    exec l:cmd
endfunction

function! ReplValidRepl()
    let l:ext = expand("%:e")
    if has_key(g:repl_assoc, l:ext)
        return 1
    else
        return 0
    endif
endfunction

function! ReplMakeRepl(d)
    let l:valid_assoc = ReplValidRepl()

    if l:valid_assoc == 0
        echo 'No REPL can be launched for this buffer.'
        return 0
    endif
        
    let l:repl_buf_l = ReplExists()

    if type(l:repl_buf_l) == v:t_list
        let l:repl_buf = l:repl_buf_l[1]
        call ReplSplitAndShow(a:d, l:repl_buf)
    else
        let l:repl_buf_l = ReplRun()
        let l:repl_buf = l:repl_buf_l[1]
        if type(l:repl_buf) == v:t_string
            call ReplSplitAndShow(a:d, l:repl_buf)
        endif
    endif
endfunction

function! ReplMakeReplVsplit()
    call ReplMakeRepl('v')
endfunction

function! ReplMakeReplSplit()
    call ReplMakeRepl('s')
endfunction

function! ReplSendString()
    let l:str_a = split(@0, '\n') 
    let l:repl_buf_l = ReplExists()

    if type(l:repl_buf_l) == v:t_number
        echo "No REPL exists for this buffer."
        return 0
    else
        let l:repl_buffer_job_id = l:repl_buf_l[0]
        call chansend(l:repl_buffer_job_id, l:str_a)
        call chansend(l:repl_buffer_job_id, "\r")
        return v:true
    endif
endfunction

function! ReplSendRegion()
    normal! ma`<v`>y'a
    call ReplSendString()
endfunction

function! ReplSendTillPoint()
    normal! maggv'a$y'a
    call ReplSendString()
endfunction

function! ReplSendLine()
    normal! ma^v$y'a
    call ReplSendString()
endfunction

function! ReplSendBuffer()
    normal! maggvGy'a
    call ReplSendString()
endfunction

" Defining commands
command! -nargs=0 ReplRun echo ReplRun()
command! -nargs=0 ReplVsplit call ReplMakeReplVsplit()
command! -nargs=0 ReplSplit call ReplMakeReplSplit()
command! -nargs=0 ReplSendString call ReplSendString()
command! -nargs=0 ReplSendRegion call ReplSendRegion()
command! -nargs=0 ReplSendTillPoint call ReplSendTillPoint()
command! -nargs=0 ReplSendLine call ReplSendLine()
command! -nargs=0 ReplExists echo ReplExists()
command! -nargs=0 ReplSendBuffer call ReplSendBuffer()

