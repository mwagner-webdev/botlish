import concurrent.futures
import csv
import json
import os
from pathlib import Path
import re
import subprocess
import time
from collections import Counter

ROOT = Path(__file__).resolve().parents[2]
OUT = Path(__file__).resolve().parent
os.chdir(ROOT)
ENV = dict(os.environ, LANG='C.utf8', LC_ALL='C.utf8')
for key in list(ENV):
    if key == 'CORE_BACKEND' or key.startswith('BOTLISH_'):
        del ENV[key]

def capture(args):
    return subprocess.check_output(args, env=ENV, text=True).strip()

files = []
for directory, directories, names in os.walk(ROOT):
    directories[:] = [name for name in directories if name != '.git']
    files.extend(str((Path(directory) / name).relative_to(ROOT)) for name in names if name.endswith('.bot'))
files.sort()
(OUT / 'files.txt').write_text('\n'.join(files) + '\n')
metadata = {
    'commit': capture(['git', 'rev-parse', 'HEAD']),
    'branch': capture(['git', 'branch', '--show-current']),
    'git_status': capture(['git', 'status', '--short']),
    'os': Path('/etc/os-release').read_text(),
    'uname': capture(['uname', '-a']),
    'locale': {k: ENV[k] for k in ('LANG', 'LC_ALL')},
    'tcl': subprocess.run(['tclsh9.0'], input='puts [info patchlevel]\nputs [package require tcltest 2.5]\n', text=True, capture_output=True, env=ENV).stdout,
    'file_count': len(files),
    'timeout_seconds': 180,
}
(OUT / 'environment.json').write_text(json.dumps(metadata, indent=2) + '\n')
print(json.dumps(metadata), flush=True)

def run_one(path, mode):
    command = ['tclsh9.0', 'main.tcl', '-' + mode, path]
    start = time.monotonic()
    log = OUT / 'logs' / (path + '.' + mode + '.txt')
    log.parent.mkdir(parents=True, exist_ok=True)
    timeout = False
    with log.open('w') as stream:
        try:
            proc = subprocess.run(command, stdout=stream, stderr=subprocess.STDOUT, env=ENV, timeout=180)
            rc = proc.returncode
        except subprocess.TimeoutExpired:
            rc = None
            timeout = True
    output = log.read_text()
    headers = []
    for line in output.splitlines():
        match = re.match(r'^(.*): (closed|guarded|open)(?: \(transitively (closed|guarded|open)\))?   \[(program|e\d+|i\d+), (.*)\]$', line)
        if match:
            name, status, transitive, region, location = match.groups()
            headers.append(dict(name=name, status=status, transitive=transitive or status, region=region, location=location))
    blockers = Counter(re.findall(r'^    .*?\s+(?:[a-z]+\d+)\s+([A-Z]\w+):', output, re.MULTILINE))
    guards = re.search(r'^guards: generic (\d+), specialized (\d+); instances: (\d+) generic, (\d+) specialized$', output, re.MULTILINE)
    row = {
        'path': path, 'mode': mode, 'command': command, 'exit_code': rc,
        'timeout': timeout, 'seconds': round(time.monotonic() - start, 3),
        'log': str(log.relative_to(OUT)),
        'analysis_complete': bool(headers) and (mode == 'aot' or guards is not None),
        'status_counts': dict(Counter(h['status'] for h in headers)),
        'regions': headers, 'blockers': dict(blockers),
        'errors': re.findall(r'^   error: (.*)$', output, re.MULTILINE),
        'value': re.findall(r'^   value: (.*)$', output, re.MULTILINE),
        'guards': dict(zip(['generic', 'specialized', 'generic_instances', 'specialized_instances'], map(int, guards.groups()))) if guards else None,
    }
    print(f"{mode:8} rc={str(rc):4} {row['seconds']:7.2f}s analyzed={row['analysis_complete']} {path}", flush=True)
    return row

rows = []
with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
    futures = [pool.submit(run_one, path, mode) for path in files for mode in ('aot', 'aot-spec')]
    for future in concurrent.futures.as_completed(futures):
        rows.append(future.result())
        (OUT / 'results.json').write_text(json.dumps(sorted(rows, key=lambda r: (r['path'], r['mode'])), indent=2) + '\n')
rows.sort(key=lambda r: (r['path'], r['mode']))
with (OUT / 'results.csv').open('w', newline='') as stream:
    writer = csv.writer(stream)
    writer.writerow(['path', 'mode', 'exit_code', 'seconds', 'analysis_complete', 'closed', 'guarded', 'open', 'generic_guards', 'specialized_guards', 'errors'])
    for r in rows:
        writer.writerow([r['path'], r['mode'], r['exit_code'], r['seconds'], r['analysis_complete'], *[r['status_counts'].get(s, 0) for s in ('closed', 'guarded', 'open')], *[(r['guards'] or {}).get(k, '') for k in ('generic', 'specialized')], ' | '.join(r['errors'])])
for mode in ('aot', 'aot-spec'):
    group = [r for r in rows if r['mode'] == mode]
    print(mode, 'exit codes', dict(Counter(r['exit_code'] for r in group)), 'complete analyses', sum(r['analysis_complete'] for r in group), flush=True)
print('Results:', OUT, flush=True)
