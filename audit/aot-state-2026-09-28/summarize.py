import csv
import json
from collections import Counter
from pathlib import Path
import re

out = Path(__file__).resolve().parent
rows = json.loads((out / 'results.json').read_text())
for row in rows:
    text = (out / row['log']).read_text()
    headers = []
    for line in text.splitlines():
        match = re.match(r'^(.*): (closed|guarded|open)(?: \(transitively (closed|guarded|open)\))?   \[(program|e\d+|i\d+), (.*)\]$', line)
        if match:
            name, status, transitive, region, location = match.groups()
            headers.append(dict(name=name, status=status, transitive=transitive or status, region=region, location=location))
    row['regions'] = headers
    row['status_counts'] = dict(Counter(h['status'] for h in headers))
    row['file_status'] = next((s for s in ('open', 'guarded', 'closed') if s in row['status_counts']), 'frontend error')
    row['blockers'] = dict(Counter(re.findall(r'^    .*?\s+(?:[a-z]+\d+)\s+([A-Z]\w+):', text, re.MULTILINE)))
    row['runtime'] = sorted(set(t for line in text.splitlines() if line.startswith('  runtime:  ') for t in line[12:].split(', ') if t != 'none'))
(out / 'results.json').write_text(json.dumps(rows, indent=2) + '\n')
with (out / 'results.csv').open('w', newline='') as stream:
    writer = csv.writer(stream)
    writer.writerow(['path', 'mode', 'exit_code', 'seconds', 'analysis_complete', 'file_status', 'closed', 'guarded', 'open', 'generic_guards', 'specialized_guards', 'errors'])
    for r in rows:
        writer.writerow([r['path'], r['mode'], r['exit_code'], r['seconds'], r['analysis_complete'], r['file_status'], *[r['status_counts'].get(s, 0) for s in ('closed', 'guarded', 'open')], *[(r['guards'] or {}).get(k, '') for k in ('generic', 'specialized')], ' | '.join(r['errors'])])
summary = {}
for mode in ('aot', 'aot-spec'):
    selected = [r for r in rows if r['mode'] == mode]
    counts = Counter()
    blockers = Counter()
    for row in selected:
        counts.update(row['status_counts'])
        blockers.update(row['blockers'])
    summary[mode] = dict(files=dict(Counter(r['file_status'] for r in selected)), regions=dict(counts), blockers=dict(blockers), runtime_files=dict(Counter(t for r in selected for t in r['runtime'])))
spec = [r for r in rows if r['mode'] == 'aot-spec' and r['analysis_complete']]
summary['guards'] = {key: sum(r['guards'][key] for r in spec) for key in ('generic', 'specialized', 'generic_instances', 'specialized_instances')}
summary['zero_guard_files'] = sum(r['guards']['specialized'] == 0 for r in spec)
summary['remaining_guards'] = [dict(path=r['path'], generic=r['guards']['generic'], specialized=r['guards']['specialized'], blockers=r['blockers']) for r in sorted(spec, key=lambda r: -r['guards']['specialized']) if r['guards']['specialized']]
summary['open_instances'] = [dict(path=r['path'], instances=[h for h in r['regions'] if h['status']=='open']) for r in spec if r['status_counts'].get('open')]
(out / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
print(json.dumps(summary, indent=2))
