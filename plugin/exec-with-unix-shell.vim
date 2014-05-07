
if has('win32') || has('win64')
	let g:unix_shell="C:/cygwin64/bin/bash"
	let g:unix_shellcmdflag="--login -c"
	let g:unix_shellxquote="\""
else
	let g:unix_shell=&shell
	let g:unix_shellcmdflag=&shellcmdflag
	let g:unix_shellxquote=&shellxquote
endif
	

function! ExecWithUnixShell(to_execute)
	let l:former_shell=&shell
	let l:former_shellcmdflag=&shellcmdflag
	let l:former_shellxquote=&shellxquote

	try
		let &shell=g:unix_shell
		let &shellcmdflag=g:unix_shellcmdflag
		let &shellxquote=g:unix_shellxquote

		exec a:to_execute
	finally
		let &shell=l:former_shell
		let &shellcmdflag=l:former_shellcmdflag
		let &shellxquote=l:former_shellxquote
	endtry
endfunction
