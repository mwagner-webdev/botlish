import json
import os
from pathlib import Path
import subprocess

out = Path(__file__).resolve().parent
os.chdir(out.parents[1])
env = dict(os.environ, LANG='C.utf8', LC_ALL='C.utf8')
for key in list(env):
    if key == 'CORE_BACKEND' or key.startswith('BOTLISH_'):
        del env[key]
rows = []
for setup in ('ascii', 'fixtures'):
    for mode in ('aot', 'aot-spec'):
        command = ['tclsh9.0', str(out / 'context.tcl'), setup, '-' + mode]
        result = subprocess.run(command, env=env, text=True, capture_output=True, timeout=180)
        log = out / (setup + '.' + mode + '.txt')
        log.write_text(result.stdout + result.stderr)
        row = dict(setup=setup, mode=mode, exit_code=result.returncode, command=command, log=log.name)
        rows.append(row)
        print(json.dumps(row), flush=True)
        print('\n'.join(result.stdout.splitlines()[-4:]), flush=True)
(out / 'context.json').write_text(json.dumps(rows, indent=2) + '\n')
