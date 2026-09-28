#!/usr/bin/env python3
"""Natural-run census, preservation checks and independent uncounted profiles."""
import csv, hashlib, json, os, pathlib, re, subprocess, sys

root = pathlib.Path.cwd()
out = root/'audit/post-structural-fn-dynamic-census/out'
audit = pathlib.Path(sys.argv[1]).resolve()
prod = root/'native/target/release/botlish-native'
env = dict(os.environ, LANG='C.utf8', LC_ALL='C.utf8', PYTHONDONTWRITEBYTECODE='1', BOTLISH_NATIVE_STACK_BYTES=str(64<<20))
for k in list(env):
    if k.startswith('BOTLISH_AUDIT') or k.startswith('BOTLISH_CENSUS'): del env[k]
def run(args, extra=None):
    return subprocess.run(list(map(str,args)),env=env|dict(extra or {}),check=True,capture_output=True,text=True).stdout

checks = []
def stable(text):
    # GC wall time is not an allocation/root/semantic counter.
    return re.sub(r'\b(totalTimeUs|maxPauseUs|durationUs) \d+',r'\1 TIMING',text)
for nir in sorted(out.glob('*.nir')):
    name = nir.stem
    print('natural', name, flush=True)
    expected = run([prod,'run','--alloc','summary',nir])
    (out/f'{name}.production.txt').write_text(expected)
    plain = run([audit,'run','--alloc','summary',nir])
    assert stable(plain) == stable(expected), (name,'audit baseline value/allocation mismatch')
    for repetition in range(2):
        trace = out/f'{name}.counts-{repetition}.tsv'
        actual = run([audit,'run','--alloc','summary',nir], {'BOTLISH_CENSUS':'targets','BOTLISH_CENSUS_OUT':str(trace)})
        assert stable(actual) == stable(expected), (name,'instrumented value/allocation mismatch',actual,expected)
    assert (out/f'{name}.counts-0.tsv').read_bytes() == (out/f'{name}.counts-1.tsv').read_bytes(), (name,'nondeterministic counts')
    for binary, label in [(prod,'production'),(audit,'audit')]:
        obj = out/f'{name}.{label}.o'
        run([binary,'object',obj,nir])
    # Audit-only helper import can change symbol metadata; disassembly and
    # relocations must remain byte-identical apart from the object filename.
    dumps=[]
    for label in ['production','audit']:
        obj=out/f'{name}.{label}.o'
        dumps.append(run(['objdump','-dr',obj]).replace(str(obj),'PROGRAM.o'))
        obj.unlink()
    assert dumps[0] == dumps[1], (name,'STOP: generated machine code changed without counters')
    checks.append(dict(program=name,value_and_allocations_equal=True,counts_repeat=True,machine_code_equal=True))
(out/'preservation.json').write_text(json.dumps(checks,indent=2)+'\n')

# All programs with actual compiled callvalue sites, uniformly 1 warmup +
# 1 collected natural run. Repeat the whole profile independently.
for nir in sorted(out.glob('*.nir')):
    if '= callvalue ' not in nir.read_text(): continue
    for repetition in range(2):
        dest=out/'profiles'/f'{nir.stem}-{repetition}'
        dest.mkdir(parents=True,exist_ok=True)
        print('profile',dest.name,flush=True)
        cmd=['valgrind','--tool=callgrind','--dump-instr=yes','--dump-line=no',
             '--compress-strings=no','--compress-pos=no','--toggle-collect=botlish_audit_run',
             f'--callgrind-out-file={dest}/callgrind.out',str(audit),'bench','2',str(nir)]
        p=subprocess.run(cmd,env=env|{'BOTLISH_AUDIT_SKIP_FIRST':'1','BOTLISH_AUDIT_JITMAP':str(dest/'jitmap.txt')},capture_output=True,text=True,check=True)
        (dest/'run-output.txt').write_text(p.stdout)
        (dest/'valgrind.log').write_text(p.stderr)
        subprocess.run(['python3',root/'audit/post-r2a-dynamic-census/tools/cgcensus.py',dest/'callgrind.out',dest/'jitmap.txt','1',dest,audit],env=env,check=True)
print('complete',flush=True)
