import concurrent.futures
import json
import os
from pathlib import Path
import subprocess
import time

OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[1]
os.chdir(ROOT)
env = dict(os.environ, LANG='C.utf8', LC_ALL='C.utf8')
for key in list(env):
    if key == 'CORE_BACKEND' or key.startswith('BOTLISH_'):
        del env[key]
rows = json.loads((OUT / 'results.json').read_text())
selected = [r for r in rows if any('TCL LIMIT STACK' in e for e in r['errors'])]

def run(r):
    command = ['tclsh9.0', 'main.tcl', '-backend', 'compile', '-' + r['mode'], r['path']]
    log = OUT / 'followup' / (r['path'] + '.' + r['mode'] + '.txt')
    log.parent.mkdir(parents=True, exist_ok=True)
    start = time.monotonic()
    with log.open('w') as stream:
        result = subprocess.run(command, env=env, stdout=stream, stderr=subprocess.STDOUT, timeout=180)
    row = dict(path=r['path'], mode=r['mode'], command=command, exit_code=result.returncode, seconds=round(time.monotonic()-start, 3), log=str(log.relative_to(OUT)))
    print(json.dumps(row), flush=True)
    return row

with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
    results = list(pool.map(run, selected))
(OUT / 'followup.json').write_text(json.dumps(results, indent=2) + '\n')
