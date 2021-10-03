let g:run_buffer_ft_assoc = {
            \'ruby'   : 'ruby',
            \'python' : 'python3',
            \'lua'    : 'lua',
            \'sh'     : 'bash'}


function! RunBufferMakeCommand(pipe, binary, filename, params)
    let l:cmd = '! ' . a:pipe . ' ' . a:binary . ' ' . a:filename . ' ' . a:params
    return l:cmd
endfunction

function! RunBufferGetBinary()
    if has_key(g:run_buffer_ft_assoc, &filetype)    
        return get(g:run_buffer_ft_assoc, &filetype)
    else
        return 0
    end
endfunction

function! RunBufferGetPipeString() 
    let l:pipe_input = input('Pipe input % ')
    if (len(l:pipe_input))
        return l:pipe_input . ' | '
    else
        return '' 
    endif
endfunction

function! RunBufferGetParams() 
    let l:params = input('Params % ')
    if (len(l:params))
        return l:params 
    else
        return '' 
    endif
endfunction

function! RunBuffer(pipe, params)
    let l:binary = RunBufferGetBinary()
    if type(l:binary) == v:t_string
        let l:cmd = RunBufferMakeCommand(a:pipe, l:binary, bufname("%"), a:params)
        exec l:cmd
    else
        echo "No binary associated with this buffer yet."
        return 0
   endif
endfunction

" Main functions
function! RunBufferWithArgs()
    let l:pipe = RunBufferGetPipeString()
    let l:params = RunBufferGetParams()
    call RunBuffer(l:pipe, l:params)
endfunction

function! RunBufferNoArgs()
    call RunBuffer('', '')
endfunction

command! -nargs=0 RunBufferWithArgs call RunBufferWithArgs()
command! -nargs=0 RunBuffer call RunBufferNoArgs()

noremap <A-r> :RunBuffer<CR>
noremap <A-R> :RunBufferWithArgs<CR>
