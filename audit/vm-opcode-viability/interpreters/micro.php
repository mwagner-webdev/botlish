<?php
// micro.php -- the two micro-benchmarks of VM-OPCODE-VIABILITY.md section 12:
// recursive fib(30) and a 10M-iteration integer loop, best of 3, startup
// excluded. Run with -d opcache.enable_cli=0 (no JIT).
function fib($n) { return $n < 2 ? $n : fib($n - 1) + fib($n - 2); }
function loop_($n) { $acc = 0; while ($n > 0) { $acc += $n; $n -= 1; } return $acc; }
foreach ([["fib", 30], ["loop_", 10000000]] as [$f, $a]) {
  $best = 1e9;
  for ($i = 0; $i < 3; $i++) { $t = hrtime(true); $v = $f($a); $best = min($best, (hrtime(true) - $t) / 1e6); }
  printf("%s %s %d ms\n", $f, $v, $best);
}
