
" This script makes it so that you can flip through tabs of 2, 4, and 8 easily
" using the command :TG.
"
" I didn't originate this one.

" Cycle tab stops
function! Toggle_Tab_Width()
	if &ts == 2
		set ts=4 sw=4
	elseif &ts == 4
		set ts=8 sw=8
	else
		set ts=2 sw=2
	endif
endfunction
command! TG call Toggle_Tab_Width()

" Set tabs to 4.
set ts=4 sw=4
