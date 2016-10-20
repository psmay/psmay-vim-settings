
function! Run_yaml_fix()
	call ExecWithUnixShell("%!perl -E 'use YAML::XS qw/LoadFile DumpFile/; use open qw/:std :utf8/; undef $/; $y=LoadFile(\\*STDIN); DumpFile(\\*STDOUT, $y)'")
endfunction
command! YAMLPP call Run_yaml_fix()

