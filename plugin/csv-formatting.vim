
let s:isSetup = 0
let s:nativeHere = expand('<sfile>:p:h')

function! s:setup()
	if !s:isSetup
		let s:here = ExecWithUnixShell_unixizedPath(s:nativeHere)
		let s:csv_handling = s:here . '/csv-handling.py'

		let s:isSetup = 1
	endif
endfunction

function! s:get_exec_command(from_line, to_line, shell_command)
	let l:range_spec = a:from_line . "," . a:to_line
	let l:command = l:range_spec . "!" . a:shell_command
	return l:command
endfunction

function! s:get_csv_shell_command(output_mode, switches)
	call s:setup()

	let l:shell_command = s:csv_handling

	if (a:output_mode =~ '\S')
		let l:shell_command = l:shell_command . " --json-output-mode " . a:output_mode
	endif

	if (a:switches =~ '\S')
		let l:shell_command = l:shell_command . " " . a:switches
	endif

	return l:shell_command
endfunction

function s:run_csv_shell_command(from_line, to_line, output_mode, switches)
	set fileencoding=utf-8
	let l:shell_command=s:get_csv_shell_command(a:output_mode, a:switches)
	let l:exec_command=s:get_exec_command(a:from_line, a:to_line, l:shell_command)
	call ExecWithUnixShell(l:exec_command)
endfunction

let s:default_switches="--indented 2 --sort-keys"
command! -range=% CSVJSON call s:run_csv_shell_command(<line1>, <line2>, 'arrays', s:default_switches)
command! -range=% CSVJSONOBJECTS call s:run_csv_shell_command(<line1>, <line2>, 'objects', s:default_switches)
