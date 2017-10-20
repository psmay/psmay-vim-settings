
let s:isSetup = 0
let s:nativeHere = expand('<sfile>:p:h')

function! s:setup()
	if !s:isSetup
		let s:here = ExecWithUnixShell_slashCorrectedPath(s:nativeHere)
		let s:astyle_name = 'astyle'

		let s:isSetup = 1
	endif
endfunction

function! s:astyle_shell_command(rcname, switches)
	call s:setup()

	let l:shell_command = s:astyle_name

	if (a:rcname =~ '\S')
		let l:rcpath = s:here . '/' . a:rcname . '.astylerc'
		let l:shell_command = l:shell_command . " --options='" . l:rcpath . "'"
	endif

	if (a:switches =~ '\S')
		let l:shell_command = l:shell_command . " " . a:switches
	endif

	return l:shell_command
endfunction

function! s:astyle_exec_command(from_line, to_line, rcname, switches)
	let l:shell_command = s:astyle_shell_command(a:rcname, a:switches)
	let l:range_spec = a:from_line . "," . a:to_line
	return l:range_spec . "!" . l:shell_command
endfunction

function! s:astyle(from_line, to_line, rcname, switches)
	set fileencoding=utf-8
	call ExecWithUnixShell(s:astyle_exec_command(a:from_line, a:to_line, a:rcname, a:switches))
endfunction

function! s:astyle_arduino(from_line, to_line, switches)
	call s:run_astyle(a:from_line, a:to_line, 'arduino', a:switches)
	set ft=arduino
endfunction

command! -range=% ASARDUINO call s:astyle(<line1>,<line2>,"arduino",'')
