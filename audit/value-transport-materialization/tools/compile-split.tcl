#!/usr/bin/env tclsh9.0
# compile-split.tcl -- compile-time impact of struct scalar replacement over
# the canonical corpus: per program and in total, the median of RUNS runs
# (milliseconds) of
#   specialize   hir::specialize::analyze (the semantic instances the lowering uses)
#   escape       hir::escape::analyze: the representation analysis this
#                milestone extended (per-expression use scan, per-function
#                aggregate planning, call-edge inspection)
#   lower        native::lower::program end to end (includes specialize,
#                ranges, escape and the other analyses, and NIR emission)
#   cranelift    the Cranelift JIT compile of that NIR (native::measure)
# Observation only; runs against whatever tree it is started in (pwd).
#
#   (cd TREE && tclsh9.0 audit/value-transport-materialization/tools/compile-split.tcl ?RUNS?)
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 200000
set runs [expr {[llength $argv] ? [lindex $argv 0] : 7}]
proc median {values} { lindex [lsort -real $values] [expr {[llength $values] / 2}] }
proc ms {script} {
    set t0 [clock microseconds]
    uplevel 1 $script
    return [expr {([clock microseconds] - $t0) / 1000.0}]
}
set paths [concat [lsort [glob -directory [file join $root bench] *.bot]] \
    [lsort [glob -directory [file join $root examples stdlib] *.bot]]]
puts [format "%-24s %10s %10s %10s %10s %10s" program specialize escape escape-leg lower cranelift]
set sums {0 0 0 0 0}
foreach path $paths {
    set hir [native::prepareHir [surface::readProgramFile $path]]
    set spec [hir::specialize::analyze $hir]
    set t {}
    foreach stage {specialize escape escapelegacy lower cranelift} {
        set samples {}
        for {set i 0} {$i < $runs} {incr i} {
            switch $stage {
                specialize { lappend samples [ms {hir::specialize::analyze $hir}] }
                escape     { lappend samples [ms {hir::escape::analyze $hir $spec}] }
                escapelegacy { lappend samples [ms {hir::escape::analyze $hir $spec 1 {policy legacy}}] }
                lower      { lappend samples [ms {native::lower::program $hir}] }
                cranelift  { lappend samples [expr {[lindex [native::measure $hir 1] 1] / 1000.0}] }
            }
        }
        lappend t [median $samples]
    }
    puts [format "%-24s %10.2f %10.2f %10.2f %10.2f %10.2f" [file rootname [file tail $path]] {*}$t]
    set sums [lmap a $sums b $t {expr {$a + $b}}]
}
puts [format "%-24s %10.2f %10.2f %10.2f %10.2f %10.2f" TOTAL {*}$sums]
