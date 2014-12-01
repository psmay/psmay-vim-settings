
" This runs a script I wrote that serves as a sort of markdown tidy.
" The actual contents of the scripts vary depending on the platform, but
" essentially amount to:
"
"	pandoc -f markdown -t markdown "$@" - | unfix-markdown
"
" Where unfix-markdown is a perl script that undoes some of pandoc's
" overzealous restyling. The main guts are these:
"
"	while(<>) {
"		chomp;
"		# Use stars for lists
"		s/^((?:    )*)-(   )/$1*$2/g;
"		# Kill excessive backslashes
"		s/\\([<>&;*#])/$1/g;
"		say;
"	}
"
" Getting pandoc and these scripts where they belong is an exercise for you.
" Once everything is in place, do :MDMD to settle markdown headers, line
" breaks, and so forth.

if !exists('g:markdown_to_markdown')
	let g:markdown_to_markdown="/home/psmay/bin/markdown-to-markdown"
endif

function! Run_markdown_to_markdown()
	call ExecWithUnixShell("%!" . g:markdown_to_markdown)
	set ft=markdown
endfunction
command! MDMD call Run_markdown_to_markdown()

function! Run_markdown_to_markdown_nowrap()
	call ExecWithUnixShell("%!" . g:markdown_to_markdown . " --no-wrap")
	set ft=markdown
endfunction
command! MDMDW call Run_markdown_to_markdown_nowrap()
