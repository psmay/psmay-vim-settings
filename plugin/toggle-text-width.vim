
function! Toggle_Text_Width()
	if &tw == 76
		set tw=78
	elseif &tw == 78
		set tw=80
	elseif &tw == 80
		set tw=120
	else
		set tw=76
	endif
	set tw
endfunction
command! TW call Toggle_Text_Width()

set tw=120
