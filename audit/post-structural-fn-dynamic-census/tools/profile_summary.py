#!/usr/bin/env python3
"""Compare exclusive work by named code region, isolating profile variation."""
import collections, json, os, pathlib, sys
root=pathlib.Path.cwd()
sys.path.insert(0,str(root/'audit/post-m8a-common-inefficiency/tools'))
import cgprof
out=root/'audit/post-structural-fn-dynamic-census/out'
results={}
paths=list((out/'profiles').glob('*'))+list((out/'counterfactual').glob('*'))
for p in sorted(p for p in paths if p.is_dir() and (p/'callgrind.out').exists()):
    events, cost, names, arcs, totals=cgprof.parse_callgrind(p/'callgrind.out')
    funcs,ranges=cgprof.load_jitmap(p/'jitmap.txt')
    ir=events.index('Ir')
    selfc=collections.Counter()
    for addr,v in cost.items():
        r=cgprof.jit_lookup(ranges,addr)
        key=f'JIT {r[2]["id"]} {r[2]["name"]} {r[3]}' if r else names.get(addr,('?','?'))[1]
        selfc[key]+=v[ir]
    indirect={}
    for caller,site,cobj,cfn,target,count,vals in arcs:
        r=cgprof.jit_lookup(ranges,site)
        if r and cfn and cfn.split("'")[0].endswith('rt_call_value'):
            # Callgrind distinguishes recursive contexts with '2, '3, ... .
            # Costs sum; the site's instruction count is counted just once.
            row=indirect.setdefault(site,dict(fid=r[2]['id'],name=r[2]['name'],calls=cost[site][ir],inclusive_ir=0))
            row['inclusive_ir']+=vals[ir]
    key=('cf-' if p.parent.name=='counterfactual' else '')+p.name
    results[key]=dict(total=sum(v[ir] for v in cost.values()),self=dict(selfc),sites=list(indirect.values()))
(out/'work.json').write_text(json.dumps(results,indent=2)+'\n')
lines=[]
for name in results:
    if not name.endswith('-0'):continue
    a,b=results[name],results[name[:-1]+'1']
    lines.append(f'{name[:-2]}: {a["total"]} / {b["total"]} Ir; difference {b["total"]-a["total"]}')
    for fn in sorted(set(a['self'])|set(b['self'])):
        x,y=a['self'].get(fn,0),b['self'].get(fn,0)
        if x!=y: lines.append(f'  {fn}: {x} -> {y} (delta {y-x})')
    lines.append('  callvalue subtrees: '+str(a['sites']))
(out/'repeatability.txt').write_text('\n'.join(lines)+'\n')
print('\n'.join(lines))
