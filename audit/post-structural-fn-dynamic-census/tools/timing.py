#!/usr/bin/env python3
"""Corroborating medians only: 5 sessions, 1 warmup + 20 natural runs each."""
import json, os, pathlib, statistics, subprocess, sys
root=pathlib.Path.cwd(); out=root/'audit/post-structural-fn-dynamic-census/out'
audit=pathlib.Path(sys.argv[1]); prod=root/'native/target/release/botlish-native'
env=dict(os.environ,LANG='C.utf8',LC_ALL='C.utf8',BOTLISH_NATIVE_STACK_BYTES=str(64<<20))
rows=[]
for nir in sorted(out.glob('*.nir')):
    if '= callvalue ' not in nir.read_text():continue
    for label,exe,extra in [('production',prod,{}),('audit-hooks-off',audit,{}),('target-tracking',audit,{'BOTLISH_CENSUS':'targets'})]:
        times=[]
        for session in range(5):
            p=subprocess.run([exe,'bench','21',nir],env=env|extra,capture_output=True,text=True,check=True)
            ts=next(x for x in p.stdout.splitlines() if x.startswith('times '))
            times.append([int(n) for n in ts.split()[2:]])
        rows.append(dict(program=nir.stem,mode=label,ns=times,median_ns=statistics.median(statistics.median(t) for t in times)))
for name in ['exact']:
    nir=out/'counterfactual'/f'{name}.nir';times=[]
    for session in range(5):
        p=subprocess.run([prod,'bench','21',nir],env=env,capture_output=True,text=True,check=True)
        times.append([int(n) for n in next(x for x in p.stdout.splitlines() if x.startswith('times ')).split()[2:]])
    rows.append(dict(program='counterfactual/'+name,mode='production',ns=times,median_ns=statistics.median(statistics.median(t) for t in times)))
(out/'timing.json').write_text(json.dumps(rows,indent=2)+'\n')
for r in rows:print(r['program'],r['mode'],r['median_ns'])
