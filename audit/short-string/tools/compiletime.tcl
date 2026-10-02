#!/usr/bin/env tclsh9.0
# compiletime.tcl -- SHORT-STRING.md compile-time cost, median of N runs, ms:
#   prepare    native::prepareHir
#   specialize hir::specialize::analyze (the closedness result)
#   range      hir::range::analyze
#   plan       native::shortstr::plan alone (facts + fixpoint + plan)
#   nir off    native::nir with -short-string-opt 0 (every other analysis and
#              NIR emission, the disabled planner included)
#   nir on     native::nir with -short-string-opt 1 (plan + lowering)
#   total off/on  native::codeSize (everything, Cranelift included)
#
#   tclsh9.0 audit/short-string/tools/compiletime.tcl ?-n N? ?PROGRAM.bot...?
source [file join [file dirname [file normalize [info script]]] lib.tcl]
set n 5
set paths {}
set args $argv
while {$args ne ""} {
    if {[lindex $args 0] eq "-n"} { set n [lindex $args 1]; set args [lrange $args 2 end] } else { lappend paths [lindex $args 0]; set args [lrange $args 1 end] }
}
if {$paths eq ""} { set paths [corpusPaths] }
proc median {xs} { set s [lsort -real $xs]; return [lindex $s [expr {[llength $s] / 2}]] }
proc ms {script} { return [expr {[lindex [uplevel 1 [list time $script]] 0] / 1000.0}] }
puts "program | prepare | specialize | range | plan | nir off | nir on | total off | total on (ms, median of $n)"
set sums [lrepeat 8 0.0]
foreach path $paths {
    set hir [surface::readProgramFile $path]
    set P {}; set S {}; set R {}; set PL {}; set N0 {}; set N1 {}; set T0 {}; set T1 {}
    for {set i 0} {$i < $n} {incr i} {
        lappend P [ms {set prepared [native::prepareHir $hir]}]
        lappend S [ms {set spec [hir::specialize::analyze $prepared]}]
        lappend R [ms {set ranges [hir::range::analyze $prepared $spec 1 1 1 1 ""]}]
        lappend PL [ms {native::shortstr::plan $prepared $spec $ranges 1 1}]
        lappend N0 [ms {native::nir $hir -short-string-opt 0}]
        lappend N1 [ms {native::nir $hir -short-string-opt 1}]
        lappend T0 [ms {native::codeSize $hir -short-string-opt 0}]
        lappend T1 [ms {native::codeSize $hir -short-string-opt 1}]
    }
    set row [list [median $P] [median $S] [median $R] [median $PL] [median $N0] [median $N1] [median $T0] [median $T1]]
    puts [format "%-16s | %8.1f | %8.1f | %8.1f | %8.1f | %8.1f | %8.1f | %8.1f | %8.1f" [programName $path] {*}$row]
    set sums [lmap a $sums b $row {expr {$a + $b}}]
}
puts [format "%-16s | %8.1f | %8.1f | %8.1f | %8.1f | %8.1f | %8.1f | %8.1f | %8.1f" TOTAL {*}$sums]
