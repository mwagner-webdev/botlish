import re, subprocess, sys, time, resource, os
env = dict(os.environ)
for kv in sys.argv[1].split(',') if sys.argv[1] != '-' else []:
    k, v = kv.split('='); env[k] = v
t = time.time()
p = subprocess.run(sys.argv[2:], capture_output=True, text=True, env=env)
wall = time.time() - t
ru = resource.getrusage(resource.RUSAGE_CHILDREN)
out = p.stdout + p.stderr
val = re.findall(r'^value (.*)$', out, re.M)
kinds = {}
for m in re.finditer(r'(\w+) \{allocations (\d+) allocatedBytes (\d+)', out):
    kinds[m.group(1)] = (int(m.group(2)), int(m.group(3)))
gc = re.search(r'gc \{cycles (\d+)', out)
co = {k: v for k, v in kinds.items() if v[0] > 0}
cs = re.search(r'coroutines \{[^}]*\}', out)
print(f"value {val[-1] if val else out[-300:]}")
print(f"wall {wall:.3f}s user {ru.ru_utime:.2f}s maxrss {ru.ru_maxrss} KiB gc-cycles {gc.group(1) if gc else '?'}")
print(cs.group(0) if cs else "coroutines -")
print("allocs " + " ".join(f"{k}={v[0]}/{v[1]}B" for k, v in co.items()))
