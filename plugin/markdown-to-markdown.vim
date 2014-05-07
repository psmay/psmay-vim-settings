
let s:markdown_to_markdown="/home/psmay/bin/markdown-to-markdown"

function! Run_markdown_to_markdown()
	call ExecWithUnixShell("%!" . s:markdown_to_markdown)
	set ft=markdown
endfunction
command! MDMD call Run_markdown_to_markdown()
