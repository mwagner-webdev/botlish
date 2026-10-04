# micro.rb -- the two micro-benchmarks of VM-OPCODE-VIABILITY.md section 12:
# recursive fib(30) and a 10M-iteration integer loop, best of 3, startup
# excluded.
def fib(n) = n < 2 ? n : fib(n - 1) + fib(n - 2)
def loop_(n) ; acc = 0; while n > 0; acc += n; n -= 1; end; acc; end
[[:fib, 30], [:loop_, 10_000_000]].each do |f, a|
  best = 1e9
  3.times { t = Process.clock_gettime(Process::CLOCK_MONOTONIC); v = send(f, a); best = [best, Process.clock_gettime(Process::CLOCK_MONOTONIC) - t].min; $v = v }
  puts "#{f} #{$v} #{(best*1000).round} ms"
end
