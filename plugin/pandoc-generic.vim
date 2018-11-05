
let s:isSetup = 0
let s:nativeHere = expand('<sfile>:p:h')

function! s:setup()
	if !s:isSetup
		let s:here = ExecWithUnixShell_slashCorrectedPath(s:nativeHere)
		let s:pandoc_generic = s:here . '/pandoc-generic.sh'
		let s:restyle_pandoc_markdown_output = s:here . '/restyle-pandoc-markdown-output.pl'

		let s:isSetup = 1
	endif
endfunction

function! s:get_restyle_command()
	call s:setup()
	return s:restyle_pandoc_markdown_output
endfunction

function! s:pandoc_filter_shell_command(from_type, to_type, switches, filter_command)
	call s:setup()

	let l:shell_command = s:pandoc_generic . " " . a:from_type . " " . a:to_type

	if (a:switches =~ '\S')
		let l:shell_command = l:shell_command . " " . a:switches
	endif

	if (a:filter_command =~ '\S')
		let l:shell_command = l:shell_command . " | " . a:filter_command
	endif

	return l:shell_command
endfunction

function! s:pandoc_filter_exec_command(from_type, to_type, from_line, to_line, switches, filter_command)
	let l:shell_command = s:pandoc_filter_shell_command(a:from_type, a:to_type, a:switches, a:filter_command)
	let l:range_spec = a:from_line . "," . a:to_line
	return l:range_spec . "!" . l:shell_command
endfunction

function! s:pandoc_filter(from_type, to_type, from_line, to_line, switches, filter_command)
	set fileencoding=utf-8
	call ExecWithUnixShell(s:pandoc_filter_exec_command(a:from_type, a:to_type, a:from_line, a:to_line, a:switches, a:filter_command))
endfunction

function! s:pandoc_html_md(from_line, to_line, switches, filter_command)
	call s:pandoc_filter('html', 'markdown', a:from_line, a:to_line, a:switches, a:filter_command)
	set ft=markdown
endfunction

function! s:pandoc_md_xhtml(from_line, to_line, switches, filter_command)
	call s:pandoc_filter('markdown', 'html', a:from_line, a:to_line, a:switches, a:filter_command)
	set ft=xhtml
endfunction

function! s:pandoc_md_html5(from_line, to_line, switches, filter_command)
	call s:pandoc_filter('markdown', 'html5', a:from_line, a:to_line, a:switches, a:filter_command)
	set ft=xhtml
endfunction

function s:pandoc_md_md(from_line, to_line, switches, filter_command)
	call s:pandoc_filter('markdown', 'markdown', a:from_line, a:to_line, a:switches, a:filter_command)
	set ft=markdown
endfunction

function s:pandoc_rst_rst(from_line, to_line, switches, filter_command)
	call s:pandoc_filter('rst', 'rst', a:from_line, a:to_line, a:switches, a:filter_command)
	set ft=markdown
endfunction

function s:pandoc_rst_md(from_line, to_line, switches, filter_command)
	call s:pandoc_filter('rst', 'markdown', a:from_line, a:to_line, a:switches, a:filter_command)
	set ft=markdown
endfunction

function s:pandoc_md_rst(from_line, to_line, switches, filter_command)
	call s:pandoc_filter('markdown', 'rst', a:from_line, a:to_line, a:switches, a:filter_command)
	set ft=markdown
endfunction


command! -range=% MDMD call s:pandoc_md_md(<line1>,<line2>,'',s:get_restyle_command())
command! -range=% MDMDW call s:pandoc_md_md(<line1>,<line2>,'--wrap=none',s:get_restyle_command())
command! -range=% MDMDA call s:pandoc_md_md(<line1>,<line2>,'--atx-headers','')
command! -range=% MDMDAW call s:pandoc_md_md(<line1>,<line2>,'--wrap=none --atx-headers','')

command! -range=% HTMLMD call s:pandoc_html_md(<line1>,<line2>,'','')
command! -range=% HTMLMDW call s:pandoc_html_md(<line1>,<line2>,'--wrap=none','')
command! -range=% HTMLMDA call s:pandoc_html_md(<line1>,<line2>,'--atx-headers','')
command! -range=% HTMLMDAW call s:pandoc_html_md(<line1>,<line2>,'--wrap=none --atx-headers','')

command! -range=% MDHTML call s:pandoc_md_html5(<line1>,<line2>,'--self-contained','')
command! -range=% MDHTMLS call s:pandoc_md_html5(<line1>,<line2>,'--self-contained --standalone','')

command! -range=% MDXHTML call s:pandoc_md_xhtml(<line1>,<line2>,'--self-contained','')
command! -range=% MDXHTMLS call s:pandoc_md_xhtml(<line1>,<line2>,'--self-contained --standalone','')

command! -range=% RSTRST call s:pandoc_rst_rst(<line1>,<line2>,'','')
command! -range=% RSTRSTW call s:pandoc_rst_rst(<line1>,<line2>,'--wrap=none','')
command! -range=% RSTMD call s:pandoc_rst_md(<line1>,<line2>,'--atx-headers','')
command! -range=% RSTMDW call s:pandoc_rst_md(<line1>,<line2>,'--wrap=none --atx-headers','')
command! -range=% MDRST call s:pandoc_md_rst(<line1>,<line2>,'','')
command! -range=% MDRSTW call s:pandoc_md_rst(<line1>,<line2>,'--wrap=none','')
