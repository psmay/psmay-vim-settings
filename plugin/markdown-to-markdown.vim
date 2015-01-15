
let s:isSetup = 0
let s:nativeHere = expand('<sfile>:p:h')

function! s:setup()
	if !s:isSetup
		let s:here = ExecWithUnixShell_slashCorrectedPath(s:nativeHere)
		let s:pandocMarkdownToMarkdown = s:here . '/pandoc-markdown-to-markdown.sh'
		let s:restylePandocMarkdownOutput = s:here . '/restyle-pandoc-markdown-output.pl'

		let s:isSetup = 1
	endif
endfunction

function! s:m2m(fromline, toline, p)
	call s:setup()
	let cmd = s:pandocMarkdownToMarkdown . a:p . " | " . s:restylePandocMarkdownOutput
	let rs = a:fromline . "," . a:toline
	call ExecWithUnixShell(rs . "!" . cmd)
	set ft=markdown
endfunction

command! -range=% MDMD call s:m2m(<line1>,<line2>,'')
command! -range=% MDMDW call s:m2m(<line1>,<line2>,' --no-wrap')
