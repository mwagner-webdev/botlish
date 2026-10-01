#!/usr/bin/env tclsh9.0
# roots.tcl -- RAW-INT-ABI.md GC-root effect: per program, the sums over all
# functions of the GC-root report (native::roots) with the raw Int ABI off (A),
# eligibility-only (B: -raw-demand-opt 0), demand-filtered with mixed uses
# kept raw (C: -raw-mixed-policy raw) and demand-filtered with mixed uses boxed
# (D, the default): safepoints, root candidates (managed-capable registers live across
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
set configs {
    A {-raw-int-abi-opt 0}
    B {-raw-int-abi-opt 1 -raw-demand-opt 0}
    C {-raw-int-abi-opt 1 -raw-mixed-policy raw}
    D {-raw-int-abi-opt 1}
}
set tot [dict create]
foreach {n o} $configs { dict set tot $n [zero] }
proc line {rows} {
    set out {}
    foreach {k label} {safepoints safepoints candidates "root candidates" slots "root slots"} {
        lappend out "$label [join [lmap r $rows {dict get $r $k}] { -> }]"
    }
    lappend out "functions with no slot [join [lmap r $rows {format %d/%d [dict get $r slotless] [dict get $r functions]}] { -> }]"
    return [join $out {; }]
}
puts "(A tagged ABI -> B RawInt eligibility only -> C demand, mixed uses raw -> D demand, mixed uses boxed)"
foreach path $argv {
    set hir [surface::readProgramFile $path]
    set rows {}
    foreach {n o} $configs {
        set r [sums [native::roots $hir {*}$o]]
        lappend rows $r
        foreach k {safepoints candidates slots functions slotless} { dict set tot $n $k [expr {[dict get $tot $n $k] + [dict get $r $k]}] }
    }
    puts "$path: [line $rows]"
}
puts "TOTAL: [line [lmap {n o} $configs {dict get $tot $n}]]"
