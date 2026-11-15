import resource, subprocess, sys, time
t = time.time()
p = subprocess.run(sys.argv[1:], capture_output=True, text=True)
wall = time.time() - t
ru = resource.getrusage(resource.RUSAGE_CHILDREN)
sys.stdout.write(p.stdout[-1500:])
sys.stdout.write(p.stderr[-800:])
print(f"exit {p.returncode} wall {wall:.2f}s user {ru.ru_utime:.2f}s maxrss {ru.ru_maxrss} KiB")
