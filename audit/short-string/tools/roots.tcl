#!/usr/bin/env tclsh9.0
# roots.tcl -- SHORT-STRING.md GC-root effect: per program, the sums over all
# functions of the GC-root report (native::roots) with ShortString1 off and
# on: safepoints, root candidates (managed-capable registers live across a
# safepoint), shadow/frame root slots. A ShortString1 is a non-root scalar, so
# fewer roots is a side effect, not a goal.
#
#   tclsh9.0 audit/short-string/tools/roots.tcl ?PROGRAM.bot...?
source [file join [file dirname [file normalize [info script]]] lib.tcl]
proc sums {report} {
    set d [dict create safepoints 0 candidates 0 slots 0 functions 0]
    foreach block [split [string map [list "\n\nfunction " "\n\u0001function "] $report] \u0001] {
        if {![regexp {^function \d+} $block]} continue
        regexp {safepoints: (\d+)} $block -> sp
        regexp {root candidates: (\d+)} $block -> rc
        regexp {shadow slots: (\d+)} $block -> sl
        dict incr d safepoints $sp; dict incr d candidates $rc; dict incr d slots $sl; dict incr d functions
    }
    return $d
}
set paths $argv
if {$paths eq ""} { set paths [corpusPaths] }
set t0 [dict create safepoints 0 candidates 0 slots 0 functions 0]
set t1 $t0
foreach path $paths {
    set hir [surface::readProgramFile $path]
    set a [sums [native::roots $hir -short-string-opt 0]]
    set b [sums [native::roots $hir -short-string-opt 1]]
    puts [format "%-16s safepoints %3d -> %3d  root candidates %4d -> %4d  root slots %4d -> %4d" [programName $path] \
        [dict get $a safepoints] [dict get $b safepoints] [dict get $a candidates] [dict get $b candidates] [dict get $a slots] [dict get $b slots]]
    foreach k {safepoints candidates slots functions} {
        dict incr t0 $k [dict get $a $k]; dict incr t1 $k [dict get $b $k]
    }
}
puts [format "%-16s safepoints %3d -> %3d  root candidates %4d -> %4d  root slots %4d -> %4d  (functions %d -> %d)" TOTAL \
    [dict get $t0 safepoints] [dict get $t1 safepoints] [dict get $t0 candidates] [dict get $t1 candidates] [dict get $t0 slots] [dict get $t1 slots] \
    [dict get $t0 functions] [dict get $t1 functions]]
