
let s:xmllint="XMLLINT_INDENT='	' xmllint --encode UTF-8"

function! Run_xmllint_command(cmd)
	call ExecWithUnixShell("%!" . s:xmllint . " " . a:cmd)
	set ft=xml
	set fileencoding=utf8
	set ts=2 sw=2
endfunction

function! Run_xmllint_format()
	call Run_xmllint_command("--format --recover --nsclean -")
endfunction
command! XLT call Run_xmllint_format()

function Run_xmllint_nsclean()
	call Run_xmllint_command("--nsclean -")
endfunction
command! XNSCLEAN call Run_xmllint_nsclean()


