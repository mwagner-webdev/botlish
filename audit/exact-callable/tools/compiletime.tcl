#!/usr/bin/env tclsh9.0
# compiletime.tcl -- EXACT-CALLABLE-CLOSED-CALLER.md: compile-time phases of
# a program on a tree, median of N runs (default 5), milliseconds:
#   prepare    native::prepareHir (re-check; creates the semantic instances)
#   specialize hir::specialize::analyze (codegen instances; on this tree it
#              also computes the one closedness result)
#   range      hir::range::analyze
#   lower      native::nir minus the three above: every other analysis
#              (escape, stringregion, blockescape, construction, ...) and NIR
#              emission
#   cranelift  native::codeSize minus native::nir: the Rust driver
#   total      native::codeSize (everything)
# Runs unchanged on the frozen tree and this tree.
#
#   (cd TREE && tclsh9.0 .../compiletime.tcl ?-n N? PROGRAM.bot ...)
set root [pwd]
set args $argv
set argv {}
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
set n 5
if {[lindex $args 0] eq "-n"} { set n [lindex $args 1]; set args [lrange $args 2 end] }
proc median {xs} { set s [lsort -real $xs]; return [lindex $s [expr {[llength $s] / 2}]] }
proc ms {script} { return [expr {[lindex [uplevel 1 [list time $script]] 0] / 1000.0}] }
puts "program | prepare | specialize | range | lower | cranelift | total (ms, median of $n)"
foreach path $args {
    set hir [surface::readProgramFile $path]
    set P {}; set S {}; set R {}; set L {}; set C {}; set T {}
    for {set i 0} {$i < $n} {incr i} {
        set p [ms {set prepared [native::prepareHir $hir]}]
        set s [ms {set spec [hir::specialize::analyze $prepared]}]
        set r [ms {set ranges [hir::range::analyze $prepared $spec]}]
        set nirMs [ms {set nir [native::nir $hir]}]
        set tot [ms {native::codeSize $hir}]
        lappend P $p; lappend S $s; lappend R $r
        lappend L [expr {max(0.0, $nirMs - $p - $s - $r)}]
        lappend C [expr {max(0.0, $tot - $nirMs)}]
        lappend T $tot
    }
    puts [format "%s | %.0f | %.0f | %.0f | %.0f | %.0f | %.0f" $path [median $P] [median $S] [median $R] [median $L] [median $C] [median $T]]
}
