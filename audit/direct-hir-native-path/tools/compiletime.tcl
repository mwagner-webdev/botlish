#!/usr/bin/env tclsh9.0
# compiletime.tcl -- where the native front of the compiler spends its time,
# per canonical program (bench/*.bot, examples/stdlib/*.bot), median of N runs,
# in milliseconds. Observation only; runs against the tree named by -root.
#
#   tclsh9.0 compiletime.tcl [-root TREE] -mode relift|direct [-runs N]
#
# Columns:
#   frontend  surface::readProgramFile: parse, resolve, types, contracts,
#             semantic instances, ranges of the checks (the HIR analysis)
#   relift    the step between the front end and NIR lowering:
#               -mode relift  hir::lower + native::buildProgramHir (lower to
#                             core IR, rebuild and re-analyze HIR)   [parent tree]
#               -mode direct  native::prepareHir (a no-op unless the program
#                             calls a native with a module implementation/body)
#   nir       native::lower::program on that HIR: specialization, ranges,
#             escape/string-region/block-escape analyses, NIR text
#   cranelift the botlish-native compile of that NIR (JIT), from native::measure
#   total     the four added
set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set mode direct
set runs 5
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

proc median {values} {
    lindex [lsort -real $values] [expr {[llength $values] / 2}]
}
proc us {script} {
    set t0 [clock microseconds]
    uplevel 1 $script
    expr {[clock microseconds] - $t0}
}

set programs [concat [lsort [glob -directory [file join $root bench] *.bot]] \
    [lsort [glob -directory [file join $root examples stdlib] *.bot]]]
set sum [dict create frontend 0 relift 0 nir 0 cranelift 0]
puts [format "%-24s %9s %9s %9s %9s %9s" program frontend $mode nir cranelift total]
foreach path $programs {
    set cols [dict create frontend {} relift {} nir {} cranelift {}]
    for {set i 0} {$i < $runs} {incr i} {
        dict lappend cols frontend [us {set surface [surface::readProgramFile $path]}]
        if {$mode eq "relift"} {
            dict lappend cols relift [us {set hir [native::buildProgramHir [hir::lower $surface]]}]
        } else {
            dict lappend cols relift [us {set hir [native::prepareHir $surface]}]
        }
        dict lappend cols nir [us {native::lower::program $hir}]
        if {[catch {native::measure $hir 1} measured]} {
            dict lappend cols cranelift 0
        } else {
            dict lappend cols cranelift [lindex $measured 1]
        }
    }
    set row {}
    set total 0
    foreach k {frontend relift nir cranelift} {
        set m [median [dict get $cols $k]]
        dict set sum $k [expr {[dict get $sum $k] + $m}]
        set total [expr {$total + $m}]
        lappend row [format %9.1f [expr {$m / 1000.0}]]
    }
    puts [format "%-24s %s %9.1f" [file tail $path] [join $row " "] [expr {$total / 1000.0}]]
}
set row {}
set total 0
foreach k {frontend relift nir cranelift} {
    lappend row [format %9.1f [expr {[dict get $sum $k] / 1000.0}]]
    set total [expr {$total + [dict get $sum $k]}]
}
puts [format "%-24s %s %9.1f" total [join $row " "] [expr {$total / 1000.0}]]
