#!/usr/bin/env tclsh9.0
# roots.tcl -- RAW-INT-ABI.md GC-root effect: per program, the sums over all
# functions of the GC-root report (native::roots) with the raw Int ABI off (A),
# eligibility-only (B: -raw-demand-opt 0) and demand-filtered (C, the
# default): safepoints, root candidates (managed-capable registers live across
# a safepoint), shadow/frame root slots, and functions that need no root slot.
#
#   tclsh9.0 audit/raw-int-abi/tools/roots.tcl PROGRAM.bot...
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
proc sums {report} {
    set d [dict create safepoints 0 candidates 0 slots 0 functions 0 slotless 0]
    foreach block [split [string map [list "\n\nfunction " "\n\u0001function "] $report] \u0001] {
        if {![regexp {^function \d+} $block]} continue
        regexp {safepoints: (\d+)} $block -> sp
        regexp {root candidates: (\d+)} $block -> rc
        regexp {shadow slots: (\d+)} $block -> sl
        dict incr d safepoints $sp; dict incr d candidates $rc; dict incr d slots $sl; dict incr d functions
        if {$sl == 0} { dict incr d slotless }
    }
    return $d
}
proc zero {} { return [dict create safepoints 0 candidates 0 slots 0 functions 0 slotless 0] }
set tA [zero]; set tB [zero]; set tC [zero]
proc line {a b c} {
    set out {}
    foreach {k label} {safepoints safepoints candidates "root candidates" slots "root slots"} {
        lappend out "$label [dict get $a $k] -> [dict get $b $k] -> [dict get $c $k]"
    }
    lappend out "functions with no slot [dict get $a slotless]/[dict get $a functions] -> [dict get $b slotless]/[dict get $b functions] -> [dict get $c slotless]/[dict get $c functions]"
    return [join $out {; }]
}
puts "(A tagged ABI -> B RawInt eligibility only -> C RawInt + demand suppression)"
foreach path $argv {
    set hir [surface::readProgramFile $path]
    set a [sums [native::roots $hir -raw-int-abi-opt 0]]
    set b [sums [native::roots $hir -raw-int-abi-opt 1 -raw-demand-opt 0]]
    set c [sums [native::roots $hir -raw-int-abi-opt 1 -raw-demand-opt 1]]
    puts "$path: [line $a $b $c]"
    foreach k {safepoints candidates slots functions slotless} {
        dict incr tA $k [dict get $a $k]; dict incr tB $k [dict get $b $k]; dict incr tC $k [dict get $c $k]
    }
}
puts "TOTAL: [line $tA $tB $tC]"
