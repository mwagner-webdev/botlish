#!/usr/bin/env tclsh9.0
# alloc.tcl -- per-workload dynamic allocation census
# (POST-M8A-COMMON-INEFFICIENCY-CENSUS.md). Observation only:
# native::allocationReport in "sites" mode (runtime/metrics.rs), one run,
# plus the same in "summary" mode over RUNS runs (the last run's counters:
# steady state, constant table excluded -- it is "static").
#
#   tclsh9.0 audit/post-m8a-common-inefficiency/tools/alloc.tcl PROGRAM OUTFILE ?LOWER-OPTIONS...?
#
# PROGRAM: a bench/*.ir file (web library loaded, as bench.tcl does) or a
# .bot file.
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
set argv [lassign $argv path out]
if {[file extension $path] eq ".bot"} {
    set hir [surface::readProgramFile $path]
} else {
    core::loadLibrary web
    set hir [native::buildProgramHir [core::loadProgramFile $path]]
}
set lines {}
foreach {label runs mode} {first-run 1 sites steady-state 3 summary} {
    set r [native::allocationReport $hir $mode $runs {*}$argv]
    set t [dict get $r total]
    lappend lines "== $label (runs=$runs, report = last run)"
    lappend lines "  total: allocations [dict get $t allocations], allocatedBytes [dict get $t allocatedBytes] (header [dict get $t headerBytes], payload [dict get $t payloadBytes]), peakLiveObjects [dict get $t peakLiveObjects], peakLiveBytes [dict get $t peakLiveBytes]"
    set sem 0; set priv 0
    dict for {kind k} [dict get $r byKind] {
        set n [dict get $k allocations]
        if {$kind in {StringPlan ListPlan}} { incr priv $n } else { incr sem $n }
        if {$n} {
            lappend lines [format "  %-13s %8d objects %10d bytes (header %d, payload %d)" $kind $n \
                [dict get $k allocatedBytes] [dict get $k headerBytes] [dict get $k payloadBytes]]
        }
    }
    lappend lines "  semantic allocations $sem, private optimization (plan) allocations $priv"
    set st [dict get $r static]
    lappend lines "  static constant table: [dict get $st allocations] objects, [dict get $st bytes] bytes"
    set gc [dict get $r gc]
    lappend lines "  gc: cycles [dict get $gc cycles], reclaimedObjects [dict get $gc reclaimedObjects], totalTimeUs [dict get $gc totalTimeUs]"
    lappend lines "  copies: [dict get $r copies]"
    lappend lines "  traversal: [dict get $r traversal]"
    lappend lines "  construction: [dict get $r construction]"
    if {$mode eq "sites"} {
        lappend lines "  sites (func | location | operation | kind | allocations | bytes):"
        foreach s [dict get $r sites] {
            set loc [dict get $s location]
            set where [expr {[dict exists $loc file] ? "[file tail [dict get $loc file]]:[dict get $loc line]" : "-"}]
            lappend lines [format "    %-28s %-14s %-18s %-12s %6d %8d" [dict get $s func] $where [dict get $s operation] \
                [dict get $s objectKind] [dict get $s allocations] [dict get $s allocatedBytes]]
        }
    }
    lappend lines ""
}
set f [open $out w]
fconfigure $f -encoding utf-8
puts -nonewline $f [join $lines \n]
close $f
