#!/usr/bin/env python3
"""Reuse the historical exact-target *control*, on today's surface source.

Only a fresh scratch copy of lib/web.bot is patched. This is an oracle
ceiling with caller-specific scanner clones, not a finite-dispatch model.
"""
import hashlib, os, pathlib, shutil, subprocess, sys
root=pathlib.Path.cwd()
out=root/'audit/post-structural-fn-dynamic-census/out/counterfactual'
out.mkdir(parents=True,exist_ok=True)
scratch=pathlib.Path(sys.argv[1]).resolve()
audit=pathlib.Path(sys.argv[2]).resolve()
assert not scratch.exists(), 'Use fresh scratch directory'
scratch.mkdir()
env=dict(os.environ,LANG='C.utf8',LC_ALL='C.utf8',PYTHONDONTWRITEBYTECODE='1')
for k in list(env):
    if k.startswith('BOTLISH_CENSUS') or k.startswith('BOTLISH_AUDIT'):del env[k]
paths=subprocess.check_output(['git','ls-files','core','compiler','surface','hir','lib','native/*.tcl','bench/*.bot'],text=True).splitlines()
for name in paths:
    target=scratch/name
    target.parent.mkdir(parents=True,exist_ok=True)
    shutil.copy2(root/name,target)
patch=root/'audit/post-module-static-exact-target-census/counterfactual/exact-target.diff'
subprocess.run(['patch','-p1','-d',str(scratch),'-i',str(patch)],check=True)
(out/'scratch-web.diff').write_text(subprocess.run(['diff','-u',root/'lib/web.bot',scratch/'lib/web.bot'],capture_output=True,text=True).stdout)
emit=root/'audit/post-structural-fn-dynamic-census/tools/emit.tcl'
prof=root/'audit/post-r2a-dynamic-census/tools/profile-nir.sh'
for name,tree,region in [('exact',scratch,1),('exact-noregion',scratch,0),('production-noregion',root,0)]:
    nir=out/f'{name}.nir'
    p=subprocess.run(['tclsh9.0',emit,'bench/refined-checks.bot',str(region)],cwd=tree,env=env,capture_output=True,text=True,check=True)
    nir.write_text(p.stdout)
    result=subprocess.run([root/'native/target/release/botlish-native','run','--alloc','summary',nir],env=env,capture_output=True,text=True,check=True).stdout
    assert 'value {list {{int 400} {int 0}}}' in result, result
    (out/f'{name}.alloc.txt').write_text(result)
    for rep in range(2):
        dest=out/f'{name}-{rep}'
        subprocess.run(['bash',prof,audit,nir,'2',dest],env=env,check=True)
print('Exact-target controls complete; no source files in the working tree changed.')
