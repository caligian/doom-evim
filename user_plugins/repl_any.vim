function! ReplAnyGetRepl()
    if has_key(g:repl_any_alias_assoc, g:repl_any_current_alias)
        return get(g:repl_any_alias_assoc, g:repl_any_current_alias)
    else
        echo "No REPL associated with alias: " . g:repl_any_current_alias
        return 0
    endif
endfunction

function! ReplAnyExists()
    if has_key(g:repl_any_buffers, g:repl_any_current_alias)
        let l:repl_buf_l = get(g:repl_any_buffers, g:repl_any_current_alias)
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

function! ReplAnyRun()
    let l:repl = ReplAnyGetRepl()
    if type(l:repl) == v:t_number
        return 0
    endif

    let l:repl_buffer = '' 
    let l:terminal_job_id = 0
    
    let l:cmd = 'tabnew | term ' . l:repl
    exec l:cmd

    let l:repl_buffer = bufname('%')
    let l:terminal_job_id = b:terminal_job_id
    let l:keep = [l:terminal_job_id, l:repl_buffer]
    let g:repl_any_buffers[g:repl_any_current_alias] = l:keep
    hide

    return l:keep
endfunction

function! ReplAnySplitAndShow(d, buf)
    let l:cmd = ''
    if a:d == 'v'
        let l:cmd = 'vsplit | wincmd l | buffer ' . a:buf
    else
        let l:cmd = 'split | wincmd j | buffer ' . a:buf
    endif
    exec l:cmd
endfunction

function! ReplAnyMakeRepl(d)
    let l:repl_buf_l = ReplAnyExists()

    if type(l:repl_buf_l) == v:t_list
        let l:repl_buf = l:repl_buf_l[1]
        call ReplAnySplitAndShow(a:d, l:repl_buf)
    else
       let l:repl_buf_l = ReplAnyRun()
        let l:repl_buf = l:repl_buf_l[1]
        if type(l:repl_buf) == v:t_string
            call ReplAnySplitAndShow(a:d, l:repl_buf)
        endif
    endif
endfunction

function! ReplAnyVsplit()
    call ReplAnyMakeRepl('v')
endfunction

function! ReplAnySplit()
    call ReplAnyMakeRepl('s')
endfunction

function! ReplAnySendString()
    let l:str_a = split(@0, '\n') 
    let l:repl_buf_l = ReplAnyExists()

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

function! ReplAnySendRegion()
    normal! ma`<v`>y'a
    call ReplAnySendString()
endfunction

function! ReplAnySendTillPoint()
    normal! maggv'a$y'a
    call ReplAnySendString()
endfunction

function! ReplAnySendLine()
    normal! ma^v$y'a
    call ReplAnySendString()
endfunction

function! ReplAnySendBuffer()
    normal! maggvGy'a
    call ReplAnySendString()
endfunction

" Defining commands
command! -nargs=0 ReplAnyRun                         echo ReplAnyRun()
command! -nargs=0 ReplAnyVsplit                      call ReplAnyMakeRepl('v')
command! -nargs=0 ReplAnySplit                       call ReplAnyMakeRepl('s')
command! -nargs=0 ReplAnySendString                  call ReplAnySendString()
command! -nargs=0 ReplAnySendRegion                  call ReplAnySendRegion()
command! -nargs=0 ReplAnySendTillPoint               call ReplAnySendTillPoint()
command! -nargs=0 ReplAnySendLine                    call ReplAnySendLine()
command! -nargs=0 ReplAnyExists echo ReplAnyExists()
command! -nargs=0 ReplAnySendBuffer                  call ReplAnySendBuffer()
