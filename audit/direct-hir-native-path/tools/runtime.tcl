#!/usr/bin/env tclsh9.0
# runtime.tcl -- best-of-N native execution time (native::measure: JIT compile
# excluded) of a few canonical programs through the relifted or the direct
# route. Only to detect accidental regressions: where the NIR is identical the
# machine code is identical and the times differ by noise alone.
#
#   tclsh9.0 runtime.tcl [-root TREE] -mode relift|direct [-runs N]
set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set mode direct
set runs 30
for {set i 0} {$i < [llength $argv]} {incr i} {
    switch -- [lindex $argv $i] {
        -root { set root [file normalize [lindex $argv [incr i]]] }
        -mode { set mode [lindex $argv [incr i]] }
        -runs { set runs [lindex $argv [incr i]] }
    }
}
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
foreach name {bench/fib bench/loop-count bench/uri-steady bench/refined-checks examples/stdlib/csv_records
        examples/stdlib/csv_geometric examples/stdlib/hashtable examples/stdlib/matmul examples/stdlib/string_reverse} {
    set surface [surface::readProgramFile [file join $root $name.bot]]
    set hir [expr {$mode eq "relift" ? [native::buildProgramHir [hir::lower $surface]] : $surface}]
    set r [native::measure $hir $runs]
    puts [format "%-30s best %10.2f us   (compile %d us)" $name [lindex $r 2] [lindex $r 1]]
}
