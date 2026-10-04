# micro.py -- the two micro-benchmarks of VM-OPCODE-VIABILITY.md section 12:
# recursive fib(30) and a 10M-iteration integer loop, best of 3, startup
# excluded.
import time
def fib(n):
    if n < 2: return n
    return fib(n - 1) + fib(n - 2)
def loop(n):
    acc = 0
    while n > 0:
        acc += n
        n -= 1
    return acc
for f, a in ((fib, 30), (loop, 10_000_000)):
    best = 1e9
    for _ in range(3):
        t = time.perf_counter(); v = f(a); best = min(best, time.perf_counter() - t)
    print(f"{f.__name__} {v} {best*1000:.0f} ms")
