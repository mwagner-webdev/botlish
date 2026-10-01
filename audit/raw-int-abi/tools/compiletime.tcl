#!/usr/bin/env tclsh9.0
# compiletime.tcl -- RAW-INT-ABI.md (adapted from audit/self-recursive-result-
# ranges/tools/compiletime.tcl): compile-time phases of a program, median of
# N runs (default 5), milliseconds:
#   prepare    native::prepareHir
#   specialize hir::specialize::analyze (also the one closedness result)
#   range      hir::range::analyze (including recursive result summaries)
#   abi plan   native::rawabi::plan (the raw Int ABI planner alone)
#   lower      native::nir minus prepare/specialize/range (every other
#              analysis and NIR emission, the ABI plan included)
#   cranelift  native::codeSize minus native::nir: the Rust driver
#   total      native::codeSize (everything)
# The "abi" argument is -raw-int-abi-opt for the nir/total measurements.
#
#   tclsh9.0 audit/raw-int-abi/tools/compiletime.tcl ?-n N? ?-abi 0|1? PROGRAM.bot ...
set root [pwd]
set args $argv
set argv {}
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
set n 5
set abi 1
while {[lindex $args 0] in {-n -abi}} {
    if {[lindex $args 0] eq "-n"} { set n [lindex $args 1] } else { set abi [lindex $args 1] }
    set args [lrange $args 2 end]
}
proc median {xs} { set s [lsort -real $xs]; return [lindex $s [expr {[llength $s] / 2}]] }
proc ms {script} { return [expr {[lindex [uplevel 1 [list time $script]] 0] / 1000.0}] }
puts "abi $abi\nprogram | prepare | specialize | range | abi plan | lower | cranelift | total (ms, median of $n)"
foreach path $args {
    set hir [surface::readProgramFile $path]
    set P {}; set S {}; set R {}; set A {}; set L {}; set C {}; set T {}
    for {set i 0} {$i < $n} {incr i} {
        set p [ms {set prepared [native::prepareHir $hir]}]
        set s [ms {set spec [hir::specialize::analyze $prepared]}]
        set r [ms {set ranges [hir::range::analyze $prepared $spec 1 1 1 1 ""]}]
        set a [ms {native::rawabi::plan $prepared $spec $ranges 1 1}]
        set nirMs [ms {set nir [native::nir $hir -raw-int-abi-opt $abi]}]
        set tot [ms {native::codeSize $hir -raw-int-abi-opt $abi}]
        lappend P $p; lappend S $s; lappend R $r; lappend A $a
        lappend L [expr {max(0.0, $nirMs - $p - $s - $r)}]
        lappend C [expr {max(0.0, $tot - $nirMs)}]
        lappend T $tot
    }
    puts [format "%s | %.0f | %.0f | %.0f | %.2f | %.0f | %.0f | %.0f" $path [median $P] [median $S] [median $R] [median $A] [median $L] [median $C] [median $T]]
}
