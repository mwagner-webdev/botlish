#!/usr/bin/env python3
"""fnsizes.py COMMIT... -- per-function machine-code bytes, by Botlish label,
from the committed audit/native-scalar-asm/*.asm at each COMMIT (the
committed scalar-assembly corpus; nothing is rebuilt). Prints, per file,
only the labels whose sizes differ between the commits. Run from the
repository root. MACHINE-CODE-PROOF-LOSS-INVESTIGATION.md."""
import subprocess, sys, re, collections
commits = sys.argv[1:]
files = subprocess.run(['git','ls-tree','-r','--name-only',commits[-1],'audit/native-scalar-asm/'],capture_output=True,text=True).stdout.split()
files = [f for f in files if f.endswith('.asm')]
def parse(commit, path):
    r = subprocess.run(['git','show',f'{commit}:{path}'],capture_output=True,text=True)
    if r.returncode: 
        return None
    txt = r.stdout
    m = re.search(r'per function: ([0-9 ]+)\)', txt)
    if not m: return None
    sizes = [int(x) for x in m.group(1).split()]
    labels = re.findall(r'^;\s+botlish_fn_(\d+) / botlish_entry_\d+ -> (.*)$', txt, re.M)
    out = collections.defaultdict(list)
    for (i,lab),s in zip(labels,sizes):
        out[lab].append(s)
    return out
for f in files:
    data = [parse(c,f) for c in commits]
    labs = []
    for d in data:
        if d:
            for k in d:
                if k not in labs: labs.append(k)
    rows=[]
    for k in labs:
        vals = [ (','.join(map(str,d[k])) if d and k in d else '-') for d in data]
        if len(set(vals))>1: rows.append((k,vals))
    if rows:
        print('==',f)
        print('   %-40s %s' % ('label', ' '.join('%10s'%c[:7] for c in commits)))
        for k,vals in rows:
            print('   %-40s %s' % (k[:40], ' '.join('%10s'%v[:10] for v in vals)))
