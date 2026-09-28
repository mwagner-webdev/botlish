#!/usr/bin/env python3
"""Freeze/provenance and deterministic static export verification."""
import difflib, hashlib, json, os, pathlib, subprocess, sys, tempfile
root=pathlib.Path.cwd(); base=root/'audit/post-structural-fn-dynamic-census'; out=base/'out'
audit=pathlib.Path(sys.argv[1]).resolve(); crate=audit.parents[2]/'native-audit'
env=dict(os.environ,LANG='C.utf8',LC_ALL='C.utf8')
def command(args):return subprocess.check_output(args,text=True,env=env).strip()
def sha(p):return hashlib.sha256(pathlib.Path(p).read_bytes()).hexdigest()
repeat=pathlib.Path(tempfile.mkdtemp(prefix='botlish-static-repeat-'))
subprocess.run(['tclsh9.0',base/'tools/static.tcl',repeat],env=env,check=True,stdout=subprocess.DEVNULL)
assert (repeat/'static.jsonl').read_bytes()==(out/'static.jsonl').read_bytes()
for p in out.glob('*.nir'):assert p.read_bytes()==(repeat/p.name).read_bytes()
subprocess.run(['tclsh9.0','audit/structural-function-types/tools/typecensus.tcl',out/'type-boundaries.txt'],env=env,check=True)
# Match the Windows checkout's clean-filter policy when inspecting its mount
# from WSL. Otherwise unrelated checked-out historical .hir CRLFs look dirty.
subprocess.run(['git','-c','core.autocrlf=true','diff','--exit-code','--','native','hir','core','compiler','surface','lib','bench','examples'],check=True)
scalar=[]
for p in (out/'scalar').rglob('*'):
    if not p.is_file() or p.name=='README.md':continue
    rel=p.relative_to(out/'scalar')
    assert p.read_bytes()==(root/'audit/native-scalar-asm'/rel).read_bytes(), f'STOP: scalar difference {rel}'
    scalar.append(str(rel))
sources={str(p.relative_to(root)):sha(p) for group in ['bench','examples/stdlib','examples/surface'] for p in (root/group).glob('*.bot')}
changes=[]
for p in (crate/'src').rglob('*.rs'):
    rel=p.relative_to(crate)
    before=(root/'native'/rel).read_text();after=p.read_text()
    if before!=after:changes.extend(difflib.unified_diff(before.splitlines(True),after.splitlines(True),fromfile='a/'+str(rel),tofile='b/'+str(rel)))
(out/'audit-build.diff').write_text(''.join(changes))
data=dict(commit=command(['git','rev-parse','HEAD']),tcl='9.0.1',rust=command(['rustc','--version']),cargo=command(['cargo','--version']),
          valgrind=command(['valgrind','--version']),platform=command(['uname','-a']),libc=command(['getconf','GNU_LIBC_VERSION']),
          cranelift='0.135.2',cpu=command(['lscpu']),source_sha256=sources,
          production_binary_sha256=sha(root/'native/target/release/botlish-native'),audit_binary_sha256=sha(audit),
          nir_sha256={p.name:sha(p) for p in out.glob('*.nir')},
          frozen_trees={d:command(['git','rev-parse',f'HEAD:{d}']) for d in ['native/src','hir','core','compiler','surface','lib']},
          static_repeat_identical=True,scalar_baseline_identical=scalar,
          preexisting_untracked=['bench/refined-checks','examples/stdlib/ai_text_clean'],
          dynamic_repetitions=2,profile_repetitions=2,profile_warmup_runs=1,profile_collected_runs=1,
          wall_clock_sessions=5,wall_clock_warmups=1,wall_clock_runs_per_session=20)
(out/'provenance.json').write_text(json.dumps(data,indent=2)+'\n')
print('Static census/NIR deterministic; production sources frozen; scalar baseline identical.')
