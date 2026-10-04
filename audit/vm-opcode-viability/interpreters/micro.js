// micro.js -- the two micro-benchmarks of VM-OPCODE-VIABILITY.md section 12:
// recursive fib(30) and a 10M-iteration integer loop, best of 3, startup
// excluded. Run with node --jitless.
function fib(n) { return n < 2 ? n : fib(n - 1) + fib(n - 2); }
function loop(n) { let acc = 0; while (n > 0) { acc += n; n -= 1; } return acc; }
for (const [f, a] of [[fib, 30], [loop, 10000000]]) {
  let best = 1e9, v;
  for (let i = 0; i < 3; i++) { const t = process.hrtime.bigint(); v = f(a); best = Math.min(best, Number(process.hrtime.bigint() - t) / 1e6); }
  console.log(`${f.name} ${v} ${Math.round(best)} ms`);
}
