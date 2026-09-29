#!/usr/bin/env tclsh9.0
# compiletime.tcl -- front-end compile time (surface::readProgramFile: parse,
# resolve, type inference -- including, in this milestone's tree, intrinsic
# contract inference -- and every static check) of each canonical program,
# median of N runs. Runs against whatever tree it is started in.
#
#   (cd TREE && tclsh9.0 audit/intrinsic-function-contracts/tools/compiletime.tcl N)
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
set n [expr {[llength $argv] ? [lindex $argv 0] : 5}]
set programs [concat \
    [lsort [glob -directory [file join $root bench] *.bot]] \
    [lsort [glob -directory [file join $root examples stdlib] *.bot]]]
set total 0
foreach path $programs {
    set times {}
    for {set i 0} {$i < $n} {incr i} {
        set t0 [clock microseconds]
        surface::readProgramFile $path -strict 0
        lappend times [expr {[clock microseconds] - $t0}]
    }
    set median [lindex [lsort -integer $times] [expr {$n / 2}]]
    set total [expr {$total + $median}]
    puts [format "%-40s %8.1f ms" [file tail $path] [expr {$median / 1000.0}]]
}
puts [format "%-40s %8.1f ms" total [expr {$total / 1000.0}]]
