let g:is_chicken=1

""for code completion, needs scheme-word-list dict file
""trouble with code completion so far...
setlocal complete+=,k~/.vim/scheme-word-list

""to find words in files mentioned in use or require-extension
"setlocal include=\^\(\\(use\\\|require-extension\\)\\s\\+
"setlocal includeexpr=substitute(v:fname,'$','.scm','')
"setlocal path+=/usr/lib/chicken/3
"setlocal suffixesadd=.scm

"recognize some chicken keywords
setlocal lispwords+=let-values,condition-case
setlocal lispwords+=with-input-from-string,with-output-to-string
setlocal lispwords+=handle-exceptions,call/cc,rec,receive
setlocal lispwords+=call-with-output-file

"so that '==' can be used to indent a toplevel S-expression
nnoremap <silent> == :call Scheme_indent_top_sexp()<cr>
function! Scheme_indent_top_sexp()
    let pos = getpos('.')
    silent! execute "normal! 99[(=%"
    call setpos('.', pos)
endfunction

"setlocal foldmethod=indent

"need to create a screen window called 'csi' and run csi in it for this:
nnoremap <buffer> <silent> <localleader>s :call Scheme_eval_defun()<cr>
vnoremap <buffer> <silent> <localleader>s "sy:call Scheme_send_sexp(@s)<cr>
nnoremap <buffer> <silent> <localleader>r :call Scheme_send_sexp("(load \"" . expand("%:p") . "\")")<cr>
nnoremap <buffer> <silent> <localleader>R :call Scheme_send_sexp("csi -s " . expand("%:p"))<cr>

function! Scheme_send_sexp(sexp)
    "add an escape character for these characters: \ "
    let ss = escape(a:sexp, '\"')
    call system("tmux send-keys -t csi \"" . ss . "\n\"")
    "call system("tmux paste-buffer -t csi") "assumes session name is csi
    echo "sent"
endfunction

function! Scheme_eval_defun()
    let pos = getpos('.')
    silent! execute "normal! 99[(yab"
    call Scheme_send_sexp(@")
    call setpos('.', pos)
endfunction

