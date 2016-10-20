
function! Run_yaml_fix()
	call ExecWithUnixShell("%!python -c 'import sys; from yaml import safe_load, dump; data = safe_load(sys.stdin); sys.stdout.write(dump(data, default_flow_style=False, width=2147483647));'")
endfunction
command! YAMLPP call Run_yaml_fix()

