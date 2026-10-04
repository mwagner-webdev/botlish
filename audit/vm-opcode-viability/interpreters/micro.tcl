# micro.tcl -- the two micro-benchmarks of VM-OPCODE-VIABILITY.md section 12:
# recursive fib(30) and a 10M-iteration integer loop, best of 3, startup
# excluded.
proc fib {n} { if {$n < 2} { return $n }; expr {[fib [expr {$n - 1}]] + [fib [expr {$n - 2}]]} }
proc loop {n} { set acc 0; while {$n > 0} { set acc [expr {$acc + $n}]; set n [expr {$n - 1}] }; return $acc }
foreach {f a} {fib 30 loop 10000000} {
    set best 1e9
    for {set i 0} {$i < 3} {set i [expr {$i + 1}]} { set t [clock microseconds]; set v [$f $a]; set d [expr {[clock microseconds] - $t}]; if {$d < $best} {set best $d} }
    puts "$f $v [expr {$best / 1000}] ms"
}
