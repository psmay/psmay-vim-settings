
let s:isSetup = 0
let s:nativeHere = expand('<sfile>:p:h')

function! s:setup()
	if !s:isSetup
		let s:here = ExecWithUnixShell_slashCorrectedPath(s:nativeHere)
		let s:pandoc_generic = s:here . '/pandoc-generic.sh'

		let s:isSetup = 1
	endif
endfunction

function! s:pandoc_filter(from_type, to_type, from_line, to_line, switches)
	call s:setup()

	let l:shell_command = s:pandoc_generic . " " . a:from_type . " " . a:to_type

	if (a:switches =~ '\S')
		let l:shell_command = l:shell_command . " " . a:switches
	endif

	let l:range_spec = a:from_line . "," . a:to_line

	let l:exec_command = l:range_spec . "!" . l:shell_command

	set fileencoding=utf-8
	call ExecWithUnixShell(l:exec_command)
endfunction

function! s:pandoc_html_md(from_line, to_line, switches)
	call s:pandoc_filter('html', 'markdown', a:from_line, a:to_line, a:switches)
	set ft=markdown
endfunction

function! s:pandoc_md_xhtml(from_line, to_line, switches)
	call s:pandoc_filter('markdown', 'html', a:from_line, a:to_line, a:switches)
	set ft=xhtml
endfunction

function! s:pandoc_md_html5(from_line, to_line, switches)
	call s:pandoc_filter('markdown', 'html5', a:from_line, a:to_line, a:switches)
	set ft=xhtml
endfunction

command! -range=% HTMLMD call s:pandoc_html_md(<line1>,<line2>,'')
command! -range=% HTMLMDW call s:pandoc_html_md(<line1>,<line2>,'--no-wrap')
command! -range=% HTMLMDA call s:pandoc_html_md(<line1>,<line2>,'--atx-headers')
command! -range=% HTMLMDAW call s:pandoc_html_md(<line1>,<line2>,'--no-wrap --atx-headers')

command! -range=% MDHTML call s:pandoc_md_html5(<line1>,<line2>,'--self-contained')
command! -range=% MDHTMLS call s:pandoc_md_html5(<line1>,<line2>,'--self-contained --standalone')

command! -range=% MDXHTML call s:pandoc_md_xhtml(<line1>,<line2>,'--self-contained')
command! -range=% MDXHTMLS call s:pandoc_md_xhtml(<line1>,<line2>,'--self-contained --standalone')
