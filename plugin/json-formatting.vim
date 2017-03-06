
function! s:Run_json_fix_modified_indent(from_line, to_line, indent)
	" Parses current text as JSON (though certain errors and extensions are
	" allowed; see JSON::PP doc `loose` and `relaxed` options) and then
	" outputs it in a standard, fixed, pretty form with sorted keys. The
	" output is indented with the `indent` parameter rather than with spaces.
	let tmp = $uuid_5ad529c6_7883_4845_8f96_6fb75c0049ed
	let $uuid_5ad529c6_7883_4845_8f96_6fb75c0049ed = a:indent
	call ExecWithUnixShell(a:from_line . "," . a:to_line . "!perl -MJSON::PP -e '
		\$indent = $ENV{uuid_5ad529c6_7883_4845_8f96_6fb75c0049ed};
		\undef $/;
		\$j=JSON::PP->new
		\	->allow_bignum
		\	->canonical
		\	->loose
		\	->relaxed
		\	->utf8;
		\my $pretty = +(qq($indent) ne q());
		\$j->pretty->indent_length(1) if $pretty;
		\$_=$j->encode($j->decode(<>));
		\s/^( +)/$indent x length($1)/emg if $pretty;
		\print;
		\'")
	let $uuid_5ad529c6_7883_4845_8f96_6fb75c0049ed = l:tmp
endfunction

" Format using a single tab character indent.
command! -range=% JSONPP call s:Run_json_fix_modified_indent(<line1>,<line2>,"\t")
" Format collapsed with no indents.
command! -range=% JSONPP0 call s:Run_json_fix_modified_indent(<line1>,<line2>,"")
" Format using an indent of 1 through 8 spaces.
command! -range=% JSONPP1 call s:Run_json_fix_modified_indent(<line1>,<line2>," ")
command! -range=% JSONPP2 call s:Run_json_fix_modified_indent(<line1>,<line2>,"  ")
command! -range=% JSONPP3 call s:Run_json_fix_modified_indent(<line1>,<line2>,"   ")
command! -range=% JSONPP4 call s:Run_json_fix_modified_indent(<line1>,<line2>,"    ")
command! -range=% JSONPP5 call s:Run_json_fix_modified_indent(<line1>,<line2>,"     ")
command! -range=% JSONPP6 call s:Run_json_fix_modified_indent(<line1>,<line2>,"      ")
command! -range=% JSONPP7 call s:Run_json_fix_modified_indent(<line1>,<line2>,"       ")
command! -range=% JSONPP8 call s:Run_json_fix_modified_indent(<line1>,<line2>,"        ")


function! s:Run_json_check(from_line, to_line)
	call ExecWithUnixShell(a:from_line . "," . a:to_line . "!perl -MJSON::PP -e '
		\undef $/;
		\$j=JSON::PP->new->allow_bignum->utf8;
		\$_=<>;
		\$j->decode($_);
		\print;
		\'")
endfunction
command! -range=% JSONCK call s:Run_json_check(<line1>,<line2>)


function! s:Run_json_stringFromText(from_line, to_line)
	" Converts current text into a JSON string literal suitable for copying
	" directly into a source file for JavaScript, Java, C#, etc.
	call ExecWithUnixShell(a:from_line . "," . a:to_line . "!perl -MJSON::PP -e '
		\undef $/;
		\$_=<>;
		\print $j=JSON::PP->new->allow_nonref->utf8->encode(qq($_));
		\'")
endfunction
command! -range=% JSONSTR call s:Run_json_stringFromText(<line1>,<line2>)

