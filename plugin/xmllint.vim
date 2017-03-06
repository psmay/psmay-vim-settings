
" This script adds :XLTAB and :XNSCLEAN as quick XML tidy commands, which are
" based on xmllint. :XLTAB runs xmllint --format using tab indentation (unless
" you change g:xmllint_indent). It also ditches redundant namespaces, recodes
" to UTF-8, and tells you where you screwed up (at which point you undo, make
" corrections, and rerun). :XNSCLEAN does the same without reindenting.
"
" All caveats concerning xmllint apply.

let g:xmllint_indent="	"
let g:xmllint="XMLLINT_INDENT='" . g:xmllint_indent . "' xmllint --encode UTF-8"

function! Run_xmllint_command(cmd)
	call ExecWithUnixShell("%!" . g:xmllint . " " . a:cmd)
	set ft=xml
	set fileencoding=utf8
	set ts=2 sw=2
endfunction

function! Run_xmllint_format()
	call Run_xmllint_command("--encode UTF-8 --format --recover --nsclean -")
endfunction
command! XLTAB call Run_xmllint_format()

function! Run_xmllint_format_to_ascii()
	call Run_xmllint_command("--encode US-ASCII --format --recover --nsclean -")
endfunction
command! XMLLINTASCII call Run_xmllint_format_to_ascii()

function! Run_xmllint_noblanks()
	call Run_xmllint_command("--encode UTF-8 --noblanks --recover --nsclean -")
endfunction
command! XNOBLANKS call Run_xmllint_noblanks()

function! Run_xmllint_canon()
	call Run_xmllint_command("--encode UTF-8 --c14n --recover --nsclean -")
endfunction
command! XCANON call Run_xmllint_canon()

function Run_xmllint_nsclean()
	call Run_xmllint_command("--encode UTF-8 --nsclean -")
endfunction
command! XNSCLEAN call Run_xmllint_nsclean()


