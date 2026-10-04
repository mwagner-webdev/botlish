# micro.pl -- the two micro-benchmarks of VM-OPCODE-VIABILITY.md section 12:
# recursive fib(30) and a 10M-iteration integer loop, best of 3, startup
# excluded.
use Time::HiRes qw(time);
sub fib { my $n = shift; return $n if $n < 2; return fib($n - 1) + fib($n - 2); }
sub loop_ { my $n = shift; my $acc = 0; while ($n > 0) { $acc += $n; $n -= 1; } return $acc; }
for my $p (["fib", \&fib, 30], ["loop", \&loop_, 10000000]) {
  my $best = 1e9; my $v;
  for (1..3) { my $t = time; $v = $p->[1]->($p->[2]); my $d = time - $t; $best = $d if $d < $best; }
  printf "%s %s %d ms\n", $p->[0], $v, $best * 1000;
}
