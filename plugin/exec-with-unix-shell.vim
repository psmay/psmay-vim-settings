
" ExecWithUnixShell() is essentially a substitute for exec() that temporarily
" replaces shell, shellcmdflag, and shellxquote options with some
" Cygwin-friendly substitutes if the current vim is the Windows-native
" version. The substitution is only effective for the duration of the exec, so
" Windows-specific shell functionality isn't broken. If the current vim isn't
" Windows-native, no substitution is made.
"
" Caveats:
" * The default g:execWithUnixShell_shell is as below, which is correct if
"   Cygwin was installed to C:\Cygwin64. Changing this in vimrc should work.
" * This function doesn't take a command line; it takes whatever exec() takes.
"   For example, the right way to uniq the whole buffer would be
"   ExecWithUnixShell("%!uniq").
" * Be aware of what the options given by shellcmdflag do and don't do (the
"   default is `--login -c`), particularly concerning startup scripts.

let g:execWithUnixShell_substitute=0

if has('win32') || has('win64')
	let g:execWithUnixShell_substitute=1

	if !exists('g:execWithUnixShell_shell') 
		let g:execWithUnixShell_shell="C:/cygwin64/bin/bash"
	endif
	if !exists('g:execWithUnixShell_shellcmdflag')
		let g:execWithUnixShell_shellcmdflag="--login -c"
	endif
	if !exists('g:execWithUnixShell_shellxquote')
		let g:execWithUnixShell_shellxquote="\""
	endif
endif

function! ExecWithUnixShell(to_execute)
	if g:execWithUnixShell_substitute
		try
			let l:restore_shell=&shell
			let l:restore_shellcmdflag=&shellcmdflag
			let l:restore_shellxquote=&shellxquote

			let &shell=g:execWithUnixShell_shell
			let &shellcmdflag=g:execWithUnixShell_shellcmdflag
			let &shellxquote=g:execWithUnixShell_shellxquote

			exec a:to_execute
		finally
			let &shell=l:restore_shell
			let &shellcmdflag=l:restore_shellcmdflag
			let &shellxquote=l:restore_shellxquote
		endtry
	else
		exec a:to_execute
	endif
endfunction
