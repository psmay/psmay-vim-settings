
" ExecWithUnixShell() is essentially a substitute for exec() that temporarily
" replaces shell, shellcmdflag, and shellxquote options with some
" Cygwin-friendly substitutes if the current vim is the Windows-native
" version. The substitution is only effective for the duration of the exec, so
" Windows-specific shell functionality isn't broken. If the current vim isn't
" Windows-native, no substitution is made.
"
" ExecWithUnixShell_target() returns "native" if it doesn't detect Windows,
" "cygwin" if it detects Windows and a Cygwin installation, or "" if it
" detects Windows but no Cygwin installation. Eventually I'd like to make it
" possible to use WSL, but that's not currently happening.
"
" When the target is "cygwin", ExecWithUnixShell_slashCorrectedPath()
" accepts a string and returns that string with backslashes replaced by
" forward slashes. Otherwise, the function returns its argument unmodified.
"
" Similarly, when the target is "cygwin", ExecWithUnixShell_unixizedPath()
" accepts a string and passes it to `cygpath -u` to get the Cygwin
" counterpart of a Windows path. Otherwise, the function returns its
" argument unmodified.
"
" Caveats:
" * Cygwin is detected using the presence and expected behavior of `cygpath`
"   found via PATH or in `C:\cygwin64\bin`, `C:\cygwin\bin`,
"   `D:\cygwin64\bin`, `D:\cygwin\bin`. The right way to influence this
"   behavior is probably to add your Cygwin's `bin` dir to your PATH so the
"   correct `cygpath` runs when no leading dirs are applied.
" * The default g:execWithUnixShell_shell is as below, which is correct if
"   Cygwin was detected correctly. Changing this in vimrc is supposed to
"   work (I haven't verified that it does).
" * ExecWithUnixShell() doesn't take a command line directly; it takes
"   whatever exec() takes. For example, the right way to uniq the whole
"   buffer would be ExecWithUnixShell("%!uniq").
" * Be aware of what the options given by shellcmdflag do and don't do (the
"   default is `--login -c`), particularly concerning startup scripts.

let s:isSetup = 0

function! s:setup()
	if !s:isSetup
		" Only attempt to find a Cygwin root path if this vim is Windows-native.
		" (Also, don't touch if manually set.)
		if !exists('g:execWithUnixShell_cygwinRoot')
			let g:execWithUnixShell_cygwinRoot = ""
			if has('win32') || has('win64')
				let g:execWithUnixShell_cygwinRoot = s:locateCygwinRoot()
				if g:execWithUnixShell_cygwinRoot != ""
					let s:target = "cygwin"
				else
					let s:target = ""
				endif
			else
				let s:target = "native"
			endif
		endif

		" If a Cygwin root is known (and g:execWithUnixShell_substitute is true),
		" ExecWithUnixShell() will swap in /bin/bash --login -c for the shell
		" settings. Otherwise, the default shell settings are used.
		if s:target == "cygwin"
			if !exists('g:execWithUnixShell_substitute')
				let g:execWithUnixShell_substitute = 1
			endif
			if !exists('g:execWithUnixShell_shell') 
				let g:execWithUnixShell_shell=g:execWithUnixShell_cygwinRoot . "/bin/bash"
			endif
			if !exists('g:execWithUnixShell_shellcmdflag')
				let g:execWithUnixShell_shellcmdflag="--login --norc -c"
			endif
			if !exists('g:execWithUnixShell_shellxquote')
				let g:execWithUnixShell_shellxquote="\""
			endif
		else
			if !exists('g:execWithUnixShell_substitute')
				let g:execWithUnixShell_substitute = 0
			endif
		endif

		let s:isSetup = 1
	endif
endfunction

" Replaces backslashes with forward slashes.
function! s:slashCorrectedPath(path)
	return substitute(a:path, '\\', '/', 'g')
endfunction

function! s:getCygpathForRoot(root)
	if a:root == ""
		" Empty root means use whatever is on PATH
		return "cygpath"
	else
		return a:root . "/bin/cygpath"
	endif
endfunction

function s:getCurrentCygpath()
	call s:setup()
	if s:target != "cygwin"
		return ""
	else
		return s:getCygpathForRoot(g:execWithUnixShell_cygwinRoot)
	endif
endfunction

" Passes a path to cygpath to get its Cygwin equivalent.
function! s:cygpathUnixizedPath(path)
	let l:escaped_path = shellescape(a:path)
	let l:result = system(s:getCurrentCygpath() . " -u " . l:escaped_path)
	let l:exit_code = v:shell_error

	if l:exit_code == 0
		" System result has some garbage at the end
		return substitute(l:result, '\n$', '', '')
	else
		return ""
	endif
endfunction


" cygpath is assumed to positively indicate the presence of a Cygwin
" installation, and even without PATH properly set, calling `cygpath -w /`
" returns the corresponding forward-slashed Windows-style path of the root
" (e.g. `C:/cygwin64`).

" Accepts the assumed path of the `cygpath` to run.
" On success, returns the result of `cygpath -w /` (with forward slashes)
" for that `cygpath`.
" On failure, returns "".
function! s:runCygpathToFindRootDir(cygpath)
	let result = system(a:cygpath . " -w /")
	let exit_code = v:shell_error
	if exit_code == 0
		let result = s:slashCorrectedPath(substitute(result, '\n$', '', ''))
		return result
	else
		return ""
	endif
endfunction

" Accepts a guess at a cygwin root (e.g. `C:/cygwin64`) or the empty string
" to guess using PATH.
" Returns same as s:runCygpathToFindRootDir().
function! s:guessAtCygwinRootUsingCygpath(guessedRoot)
	let l:cygpath = s:getCygpathForRoot(a:guessedRoot)
	return s:runCygpathToFindRootDir(l:cygpath)
endfunction

" Guesses at Cygwin root for a few common possibilities. A guess based on
" PATH should always be first.
" Returns same as s:runCygpathToFindRootDir().
function s:locateCygwinRoot()
	let foundRoot = ""
	for guessedRoot in ["", "C:/cygwin", "C:/cygwin64", "D:/cygwin", "D:/cygwin64"]
		let foundRoot = s:guessAtCygwinRootUsingCygpath(guessedRoot)
		if foundRoot != ""
			break
		endif
	endfor
	return foundRoot
endfunction


" Replaces backslashes with forward slashes if substitution is enabled and
" there is a known cygwin root.
function! ExecWithUnixShell_slashCorrectedPath(path)
	call s:setup()
	if g:execWithUnixShell_substitute && g:execWithUnixShell_cygwinRoot != ""
		return s:slashCorrectedPath(a:path)
	else
		return a:path
	endif
endfunction

function! ExecWithUnixShell_unixizedPath(path)
	call s:setup()
	if g:execWithUnixShell_substitute && g:execWithUnixShell_cygwinRoot != ""
		return s:cygpathUnixizedPath(a:path)
	else
		return a:path
	endif
endfunction

function! ExecWithUnixShell_target()
	call s:setup()
	return s:target
endfunction

function! ExecWithUnixShell(to_execute)
	call s:setup()

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
