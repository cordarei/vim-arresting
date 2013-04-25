" arresting.vim - make your vim ar-reST-ing
"
" Author: Joseph Irwin <https://github.com/cordarei/>


if exists('g:loaded_arresting') || &cp
  finish
endif
let g:loaded_arresting = 1


let s:rst_title_char = "="

" From http://docutils.sourceforge.net/docs/ref/rst/restructuredtext.html#sections
" The following are all valid section title adornment characters:

" ! " # $ % & ' ( ) * + , - . / : ; < = > ? @ [ \ ] ^ _ ` { | } ~
" Some characters are more suitable than others. The following are recommended:

" = - ` : . ' " ~ ^ _ * + #

let s:valid_rst_heading_chars = '!"#$%&''()*+,-./:;<=>?@[\]^_`{|}~'
let s:recommended_rst_heading_chars = '=-`:.''"~^_*+#'
let s:python_rst_heading_chars = '=-^"'
let s:default_rst_heading_chars = '=-#*'
let s:current_rst_heading_chars = s:default_rst_heading_chars


function! s:getchar()
  let c = getchar()
  if c =~ '^\d\+$'
    let c = nr2char(c)
  endif
  return c
endfunction

function! s:make_rst_heading(chr, above)
  let c = substitute(a:chr, "&", "\\\\&", "") " fix ampersand
  let savereg = @@
  normal! mqyy
  let @@ = substitute(@@, ".", c, "g")
  let @@ = substitute(@@, ".$", "", "")
  if (a:above)
    execute "normal! O\<esc>pj"
  endif
  execute "normal! o\<esc>"
  normal! p`q
  let @@ = savereg
endfunction

function! s:thisline()
  return getline('.')
endfunction

function! s:nextline()
  return getline(line('.') + 1)
endfunction

function! s:prevline()
  return getline(line('.') - 1)
endfunction

function! s:is_valid_heading_line(str)
  if a:str =~ '\v^(.)\1*$' && match(s:valid_rst_heading_chars, a:str[0]) > -1
    return 1
  else
    return 0
  endif
endfunction

function! s:is_heading()
  if s:is_valid_heading_line(s:nextline()) && len(s:thisline()) == len(s:nextline())
    return 1
  else
    return 0
  endif
endfunction

function! s:has_overline()
  if s:is_valid_heading_line(s:prevline()) && len(s:thisline()) == len(s:prevline())
    return 1
  else
    return 0
  endif
endfunction

function! s:change_heading_char(chr)
  if s:is_heading()
    let c = a:chr
    call setline(line('.')+1, substitute(s:nextline(), '.', c, 'g'))
    if s:has_overline()
      call setline(line('.')-1, substitute(s:prevline(), '.', c, 'g'))
    endif
  endif
endfunction

nnoremap <silent> <Plug>ArrestingMaketitle :call <SID>make_rst_heading(<SID>getchar(), 1)<cr>
nnoremap <silent> <Plug>ArrestingMakeheading :call <SID>make_rst_heading(<SID>getchar(), 0)<cr>
nnoremap <silent> <Plug>ArrestingChangeheadingchar :call <SID>change_heading_char(<SID>getchar())<cr>

function! ArrestingCreateDefaultMappings()
  nmap <buffer> <localleader>rt <Plug>ArrestingMaketitle
  nmap <buffer> <localleader>rh <Plug>ArrestingMakeheading
  nmap <buffer> <localleader>rc <Plug>ArrestingChangeheadingchar
endfunction

" vim:set ft=vim sw=2 sts=2 et:
