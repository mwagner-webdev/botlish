#!/usr/bin/env tclsh9.0
# timing.tcl -- RANGE-FIXPOINT-SCALING.md: compile-time cost of the range
# analysis on a tree. Per program: the frontend (surface::readProgramFile,
# once), hir::range::analyze on the prepared HIR and its specialization
# (median of N runs, default 3) and native::lowered (once), milliseconds,
# plus the number of AnalyzeInstance walks one analyze makes (an untimed,
# counted run).
#
#   tclsh9.0 audit/range-fixpoint-scaling/tools/timing.tcl ?-n N? ?-root TREE? PROGRAM.bot ...
#
# TREE (default: the current directory) is the compiler tree to measure, so
# the same script times a frozen worktree and this one.
set root [pwd]
set n 3
set args $argv
while {[lindex $args 0] in {-n -root}} {
    if {[lindex $args 0] eq "-n"} { set n [lindex $args 1] } else { set root [file normalize [lindex $args 1]] }
    set args [lrange $args 2 end]
}
set argv {}
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
proc median {xs} { set s [lsort -real $xs]; return [lindex $s [expr {[llength $s] / 2}]] }
proc ms {script} { return [expr {[lindex [uplevel 1 [list time $script]] 0] / 1000.0}] }
proc walks {hir spec} {
    set ::walks 0
    rename hir::range::AnalyzeInstance hir::range::AnalyzeInstance__counted
    proc hir::range::AnalyzeInstance {args} {
        incr ::walks
        tailcall AnalyzeInstance__counted {*}$args
    }
    try {
        hir::range::analyze $hir $spec
    } finally {
        rename hir::range::AnalyzeInstance {}
        rename hir::range::AnalyzeInstance__counted hir::range::AnalyzeInstance
    }
    return $::walks
}
fconfigure stdout -buffering line
puts [format "%-22s %6s %10s %10s %10s %8s" program ids frontend range lowered walks]
foreach path $args {
    set frontend [ms {set hir [surface::readProgramFile $path -warnings off]}]
    set prepared [native::prepareHir $hir]
    set spec [hir::specialize::analyze $prepared]
    hir::range::analyze $prepared $spec
    set R {}
    for {set i 0} {$i < $n} {incr i} {
        lappend R [ms {hir::range::analyze $prepared $spec}]
    }
    set lowered [ms {native::lowered $hir}]
    puts [format "%-22s %6d %10.1f %10.1f %10.1f %8d" [file tail $path] [llength [dict get $spec used]] \
        $frontend [median $R] $lowered [walks $prepared $spec]]
}
