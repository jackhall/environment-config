set textwidth=80
setlocal foldmethod=syntax

nnoremap <buffer> <silent> <localleader>j :call Justify()<cr>

function! Justify()
    let pos = getpos('.')
    silent! execute "normal! {gq}"
    call setpos('.', pos)
endfunction

nnoremap <buffer> <silent> <localleader>r :call Make()<cr>

function! Make()
    call system("tmux set-buffer $'make\n'")
    call system("tmux paste-buffer -t bash")
    echo "sent"
endfunction

