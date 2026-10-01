#!/usr/bin/env tclsh9.0
# roots.tcl -- RAW-INT-ABI.md GC-root effect: per program, the sums over all
# functions of the GC-root report (native::roots) with the raw Int ABI off/on:
# safepoints, root candidates (managed-capable registers live across a
# safepoint), shadow/frame root slots, and functions that need no root slot.
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
set t0 [dict create safepoints 0 candidates 0 slots 0 functions 0 slotless 0]
set t1 $t0
foreach path $argv {
    set hir [surface::readProgramFile $path]
    set a [sums [native::roots $hir -raw-int-abi-opt 0]]
    set b [sums [native::roots $hir -raw-int-abi-opt 1]]
    puts "$path: safepoints [dict get $a safepoints] -> [dict get $b safepoints]; root candidates [dict get $a candidates] -> [dict get $b candidates]; root slots [dict get $a slots] -> [dict get $b slots]; functions with no slot [dict get $a slotless]/[dict get $a functions] -> [dict get $b slotless]/[dict get $b functions]"
    foreach k {safepoints candidates slots functions slotless} {
        dict incr t0 $k [dict get $a $k]; dict incr t1 $k [dict get $b $k]
    }
}
puts "TOTAL: safepoints [dict get $t0 safepoints] -> [dict get $t1 safepoints]; root candidates [dict get $t0 candidates] -> [dict get $t1 candidates]; root slots [dict get $t0 slots] -> [dict get $t1 slots]; functions with no slot [dict get $t0 slotless]/[dict get $t0 functions] -> [dict get $t1 slotless]/[dict get $t1 functions]"
