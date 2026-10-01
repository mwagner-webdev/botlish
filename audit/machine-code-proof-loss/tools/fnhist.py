#!/usr/bin/env python3
"""fnhist.py FILE LABEL-REGEX -- walks every commit that changed the committed
audit asm FILE (audit/native-scalar-asm/...) and prints, whenever it changes,
the per-function machine-code bytes of the labels matching LABEL-REGEX,
together with the compiler revision that regeneration's README.md records.
Run from the repository root. MACHINE-CODE-PROOF-LOSS-INVESTIGATION.md."""
import subprocess, sys, re
path, pat = sys.argv[1], re.compile(sys.argv[2])
commits = subprocess.run(['git','log','--format=%h','--reverse','--',path],capture_output=True,text=True).stdout.split()
prev=None
for c in commits:
    txt = subprocess.run(['git','show',f'{c}:{path}'],capture_output=True,text=True).stdout
    m = re.search(r'per function: ([0-9 ]+)\)', txt)
    if not m: continue
    sizes=[int(x) for x in m.group(1).split()]
    labels=re.findall(r'^;\s+botlish_fn_\d+ / botlish_entry_\d+ -> (.*)$', txt, re.M)
    sel=[f'{l}={s}' for l,s in zip(labels,sizes) if pat.search(l)]
    rev=subprocess.run(['git','show',f'{c}:audit/native-scalar-asm/README.md'],capture_output=True,text=True).stdout
    r=re.search(r'git commit: ([0-9a-f]{7})',rev)
    line=' '.join(sel)
    if line!=prev:
        print(c, 'compiler', r.group(1) if r else '?', subprocess.run(['git','log','-1','--format=%ad','--date=short',c],capture_output=True,text=True).stdout.strip(), '|', line)
    prev=line
