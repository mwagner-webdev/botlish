#!/usr/bin/env tclsh9.0
# budget.tcl -- state-budget scaling probe (SELF-RECURSIVE-RESULT-RANGES.md).
# For fib(W) with W in WIDTHS: hir::range::analyze wall time with the
# analysis off and on (median of REPS runs), the state count, and the
# precision (derived result maximum, fits-small).
#
#   tclsh9.0 audit/self-recursive-result-ranges/tools/budget.tcl ?-reps N? ?-widths {..}? ?-limit N?
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 100000
set reps 5
set widths {8 16 32 64 128 256 512}
set limit 1000000
foreach {k v} $argv {
    switch -- $k {
        -reps { set reps $v }
        -widths { set widths $v }
        -limit { set limit $v }
    }
}
proc median {xs} { set s [lsort -real $xs]; return [lindex $s [expr {[llength $s] / 2}]] }
puts [format "%-6s %-12s %-12s %-8s %-10s %s" W off-ms on-ms states fitsSmall "result max"]
foreach w $widths {
    set text "fn fib(n):\n    if n < 2:\n        n\n    else:\n        fib(n - 1) + fib(n - 2)\n\nfib($w)\n"
    set hir [surface::compile [surface::modules::ImportHeader $text]$text t.bot -strict 0]
    set spec [hir::specialize::analyze $hir]
    foreach opt {0 1} {
        set times {}
        for {set i 0} {$i < $reps} {incr i} {
            set t [lindex [time {set a [hir::range::analyze $hir $spec 1 1 1 $opt $limit]}] 0]
            lappend times [expr {$t / 1000.0}]
        }
        set ms($opt) [median $times]
    }
    set states "-"
    set fits "-"
    set max "-"
    dict for {id r} [dict get $a recursive] {
        if {[dict get $r status] eq "solved"} {
            set states [dict size [dict get $r states]]
            set fits [hir::range::fitsSmall [dict get $r result]]
            set max [dict get $r result max]
            if {[string length $max] > 24} { set max "[string range $max 0 20]..." }
        }
    }
    puts [format "%-6s %-12.2f %-12.2f %-8s %-10s %s" $w $ms(0) $ms(1) $states $fits $max]
}
