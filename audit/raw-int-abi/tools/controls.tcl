#!/usr/bin/env tclsh9.0
# controls.tcl -- RAW-INT-ABI.md "Controls": the struct and String paths the
# raw Int ABI must not disturb. For each program, with -raw-int-abi-opt 0 and
# 1: the struct/transport census text (every fixed-shape struct construction,
# its transport verdict and cut), the allocation summary of one run (objects,
# bytes by kind), the guard count, and whether they are identical.
#
#   tclsh9.0 audit/raw-int-abi/tools/controls.tcl PROGRAM.bot...
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
fconfigure stdout -encoding utf-8 -translation lf
foreach path $argv {
    set hir [surface::readProgramFile $path]
    set rows {}
    foreach abi {0 1} {
        set census [native::transportCensusText $hir -raw-int-abi-opt $abi]
        # the per-instance numbers (frontier scores/verdicts), not timings
        set report [native::allocationReport $hir summary 1 -raw-int-abi-opt $abi]
        set alloc [dict get $report total allocations]
        set bytes [dict get $report total allocatedBytes]
        set kinds {}
        if {[dict exists $report byKind]} {
            dict for {k v} [dict get $report byKind] { lappend kinds $k [dict get $v allocations] }
        }
        set stats [dict get [native::lowered $hir -raw-int-abi-opt $abi] statistics]
        lappend rows [list $census $alloc $bytes $kinds [dict get $stats guards]]
    }
    lassign $rows a b
    puts "$path: struct/transport census [expr {[lindex $a 0] eq [lindex $b 0] ? {identical} : {DIFFERS}}]; allocations off [lindex $a 1] on [lindex $b 1]; bytes off [lindex $a 2] on [lindex $b 2]; by kind [expr {[lindex $a 3] eq [lindex $b 3] ? {identical} : {off [lindex $a 3] / on [lindex $b 3]}}]; guards off [lindex $a 4] on [lindex $b 4]"
}
