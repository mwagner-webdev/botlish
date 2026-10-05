#!/usr/bin/env tclsh9.0
# chains.tcl -- RANGE-FIXPOINT-SCALING.md: synthetic call-chain programs.
#
#   tclsh9.0 audit/range-fixpoint-scaling/tools/chains.tcl SHAPE N OUT.bot
#
# SHAPE chain: N functions f1..fN of about ten lines each; fi calls f(i-1)
#   in both branches of an `if` (entry facts travel down the chain, result
#   summaries back up), driven by fN(1, 1000).
# SHAPE narrow: g1..gN calling g(i-1) in both branches, driven by a
#   self-tail loop whose widened entry the narrowing rounds recover, so a
#   narrowed fact travels down the chain one round per call.
lassign $argv shape n out
set lines {}
switch -- $shape {
    chain {
        lappend lines "import list" "fn f0(x, y):" "    \[x, y\]"
        for {set i 1} {$i <= $n} {incr i} {
            set p [expr {$i - 1}]
            lappend lines "fn f$i\(x, y):" "    a = x + $i" "    b = \[a, y, \"s$i\"\]" \
                "    if a < y:" "        f$p\(a, list::length(b))" "    else:" \
                "        c = loop k from 0 to 3:" "            k * a" "        f$p\(list::length(c), y)"
        }
        lappend lines "f$n\(1, 1000)"
    }
    narrow {
        lappend lines "fn g0(x, y):" "    x + y"
        for {set i 1} {$i <= $n} {incr i} {
            set p [expr {$i - 1}]
            lappend lines "fn g$i\(x, y):" "    if x < y:" "        g$p\(x, y - 1)" \
                "    else:" "        g$p\(x - 1, y)"
        }
        lappend lines "fn drive(n):" "    if n < 500:" "        drive(n + 1)" "    else:" \
            "        g$n\(n, 7)" "drive(0)"
    }
    default {
        error "chains.tcl: unknown shape \"$shape\" (chain or narrow)"
    }
}
set channel [open $out w]
puts $channel [join $lines \n]
close $channel
