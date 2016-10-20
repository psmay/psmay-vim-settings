
function! Run_yaml_fix()
	call ExecWithUnixShell("%!python -c 'import sys, yaml; data = yaml.load(sys.stdin, Loader=yaml.SafeLoader); yaml.dump(data, stream=sys.stdout, default_flow_style=False, width=2147483647);'")
endfunction
command! YAMLPP call Run_yaml_fix()

function! Run_yaml_json()
	call ExecWithUnixShell("%!python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin, Loader=yaml.SafeLoader), sys.stdout);'")
endfunction
command! YAMLJSON call Run_yaml_json()


