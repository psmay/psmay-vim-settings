
function! Run_json_fix()
	" Parses current text as JSON (though certain errors and extensions are
	" allowed; see JSON::PP doc `loose` and `relaxed` options) and then
	" outputs it in a standard, fixed, pretty form with sorted keys. The
	" output is indented with tabs rather than spaces.
	call ExecWithUnixShell("%!perl -MJSON::PP -e 'undef $/; $j=JSON::PP->new->allow_bignum->pretty->indent_length(1)->canonical->loose->relaxed->utf8; $_=$j->encode($j->decode(<>)); s/^( +)/qq(\t) x length($1)/emg;print'")
endfunction
command! JSONPP call Run_json_fix()

function! Run_json_check()
	call ExecWithUnixShell("%!perl -MJSON::PP -e 'undef $/; $j=JSON::PP->new->allow_bignum->utf8; $_=<>; $j->decode($_); print'")
endfunction
command! JSONCK call Run_json_check()
