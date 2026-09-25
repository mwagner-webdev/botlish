#!/usr/bin/env tclsh9.0
# measure.tcl -- best-of-RUNS native execution time of a probe program,
# JIT compile excluded (native::measure, the same mechanism bench.tcl's
# Cranelift column uses), repeated SESSIONS times; prints each session's
# best and the median. Non-production inspection helper.
#
#   tclsh9.0 audit/comprehensive-generated-code/tools/measure.tcl PROGRAM RUNS SESSIONS ?LOWER-OPTIONS...?
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
set argv [lassign $argv path runs sessions]
if {[file extension $path] eq ".bot"} {
    set hir [surface::readProgramFile $path]
} else {
    set hir [native::buildProgramHir [core::loadProgramFile $path]]
}
set bests {}
for {set i 0} {$i < $sessions} {incr i} {
    lassign [native::measure $hir $runs {*}$argv] lower compile best collections value
    lappend bests $best
}
set sorted [lsort -real $bests]
set median [lindex $sorted [expr {[llength $sorted] / 2}]]
puts [format "%s %s: value=%s median=%.2f us min=%.2f us max=%.2f us sessions={%s}" \
    [file tail $path] $argv [core::formatValue $value] $median [lindex $sorted 0] [lindex $sorted end] \
    [join [lmap b $bests {format %.2f $b}] { }]]
