setlocal foldmethod=indent
setlocal foldnestmax=2

"for vim-ipython
"let g:ipy_completefunc = 'local'
"command! IPy IPython --profile interactive_clean
"silent! IPython --profile interactive_clean

"send current block
nnoremap <buffer> <silent> <localleader>s :call IPython_send_paragraph()<cr>
"send selected text
vnoremap <buffer> <silent> <localleader>s "sy:call IPython_send_statement(@s)<cr>
"send without whitespace
nnoremap <buffer> <silent> <localleader>S ^"sy$:call IPython_send_statement(@s)<cr>
vnoremap <buffer> <silent> <localleader>S <esc>`<^:call Strip_leading_whitespace()<cr>
"run entire file
nnoremap <buffer> <silent> <localleader>r :call IPython_send_statement("run " . expand("%:p") . "\n")<cr>

function! IPython_send_statement(statement)
    let lines = escape(a:statement, '''"') "single and double quotes
    call system("echo $'" . lines . "' | tmux load-buffer - ") 
    call system("tmux paste-buffer -t ipy")
    echo "sent"
endfunction

function! IPython_send_paragraph()
    let pos = getpos('.')
    silent! execute 'normal! vip"sy'
    call IPython_send_statement(@s)
    call setpos('.', pos)
endfunction

function! Strip_leading_whitespace()
    let pos = getpos('.')
    if pos[2] > 1
        "reselect and shift
        silent! execute 'normal! v`><'
        call Strip_leading_whitespace()
        silent! execute "u"
    else
        "yank previous selection into s register
        silent! execute 'normal! "sy`>'
        call IPython_send_statement(@s)
    endif
    call setpos('.', pos)
endfunction

