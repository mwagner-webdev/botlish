#!/usr/bin/env tclsh9.0
# alloc.tcl -- native allocation report (native::allocationReport summary, one
# run) of every canonical program through the relifted or the direct route.
#
#   tclsh9.0 alloc.tcl [-root TREE] -mode relift|direct
#
# One line per program: allocations, allocated bytes, peak live bytes, GC
# cycles, and the per-kind allocation counts (String List MutableArray Block).
set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set mode direct
for {set i 0} {$i < [llength $argv]} {incr i} {
    switch -- [lindex $argv $i] {
        -root { set root [file normalize [lindex $argv [incr i]]] }
        -mode { set mode [lindex $argv [incr i]] }
    }
}
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
foreach path [concat [lsort [glob -directory [file join $root bench] *.bot]] \
        [lsort [glob -directory [file join $root examples stdlib] *.bot]]] {
    set surface [surface::readProgramFile $path]
    set hir [expr {$mode eq "relift" ? [native::buildProgramHir [hir::lower $surface]] : $surface}]
    if {[catch {native::allocationReport $hir summary} report]} {
        puts [format "%-22s ERROR %s" [file tail $path] [lindex [split $report \n] 0]]
        continue
    }
    set total [dict get $report total]
    set kinds [lmap k {String List MutableArray Block} {dict get $report byKind $k allocations}]
    puts [format "%-22s allocs %7d bytes %9d peak %9d gc %3d  String/List/MutArr/Block %s" \
        [file tail $path] [dict get $total allocations] [dict get $total allocatedBytes] \
        [dict get $total peakLiveBytes] [dict get $report gc cycles] [join $kinds /]]
}
