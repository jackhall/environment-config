set textwidth=80


nnoremap <buffer> <silent> <localleader>j :call Justify()<cr>

function! Justify()
    let pos = getpos('.')
    silent! execute "normal! {gq}"
    call setpos('.', pos)
endfunction

