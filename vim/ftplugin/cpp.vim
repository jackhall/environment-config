setlocal foldmethod=syntax
setlocal foldnestmax=3

nnoremap <buffer> <silent> <localleader>r :call Make()<cr>

function! Make()
    call system("tmux set-buffer $'make\n'")
    call system("tmux paste-buffer -t bash")
    echo "sent"
endfunction

