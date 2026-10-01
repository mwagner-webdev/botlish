#!/usr/bin/env tclsh9.0
# census.tcl -- raw Int ABI census over canonical programs (RAW-INT-ABI.md).
# Observation only. For each program, with -raw-int-abi-opt 0 and 1:
#
#   * the ABI plan: used instances examined, raw parameter positions, raw
#     result positions, instances with any raw ABI (by recursive /
#     non-recursive), tagged-only instances, and the rejection tags;
#   * the emitted NIR: functions with a raw physical signature, call edges
#     by caller/callee ABI (raw->raw, tagged->raw, raw->tagged,
#     tagged->tagged), and rbox/runbox counts, classified into call-boundary
#     conversions (an rbox feeding a call argument or a `ret`, a runbox of a
#     call result or of a parameter) and everything else;
#   * machine-code bytes (native::codeSize).
#
#   tclsh9.0 audit/raw-int-abi/tools/census.tcl ?-detail? PROGRAM.bot...
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
fconfigure stdout -encoding utf-8 -translation lf

set detail 0
set paths {}
foreach a $argv {
    if {$a eq "-detail"} { set detail 1 } else { lappend paths $a }
}

source [file join [file dirname [file normalize [info script]]] nirlib.tcl]

set totals [dict create]
proc total {key n} {
    global totals
    dict incr totals $key $n
}

foreach path $paths {
    if {[catch {
        set hir [surface::readProgramFile $path]
        set prepared [native::prepareHir $hir]
        set r0 [native::lowered $hir -raw-int-abi-opt 0]
        set r1 [native::lowered $hir -raw-int-abi-opt 1]
    } err]} {
        puts "$path: SKIP ($err)"
        continue
    }
    set spec [dict get $r1 specialization]
    set plan [dict get $r1 abiPlan]
    set examined 0; set rawParams 0; set rawResults 0; set anyRaw 0; set both 0; set taggedOnly 0
    set recursiveRaw 0; set nonRecursiveRaw 0
    set reasons [dict create]
    set gains {}
    foreach id [dict get $spec used] {
        set instance [dict get $spec instances $id]
        if {[dict get $instance block] eq "program"} continue
        incr examined
        set p [dict get $plan $id]
        set np [llength [lsearch -all -exact [dict get $p params] rawint]]
        set nr [expr {[dict get $p result] eq "rawint"}]
        incr rawParams $np
        incr rawResults $nr
        foreach reason [concat [dict get $p paramReasons] [dict get $p resultReason]] {
            if {$reason ne ""} { dict incr reasons $reason }
        }
        if {$np > 0 || $nr} {
            incr anyRaw
            if {$np > 0 && $nr} { incr both }
            set recursive 0
            foreach {e target} [dict get $instance calls] {
                if {$target eq $id} { set recursive 1 }
            }
            if {$recursive} { incr recursiveRaw } else { incr nonRecursiveRaw }
            lappend gains "[hir::specialize::label $spec $id] params [join [lmap k [dict get $p params] {expr {$k eq "rawint" ? "raw" : "val"}}] ,] result [expr {$nr ? "raw" : "val"}][expr {$recursive ? " (recursive)" : ""}]"
        } else {
            incr taggedOnly
        }
    }
    set nir0 [dict get $r0 text]
    set nir1 [dict get $r1 text]
    set f0 [nirFunctions $nir0]
    set f1 [nirFunctions $nir1]
    set emittedRaw 0
    foreach f $f1 { if {[hasRaw [lindex $f 2]]} { incr emittedRaw } }
    set conv0 {0 0 0 0}
    set conv1 {0 0 0 0}
    foreach {funcs var} [list $f0 conv0 $f1 conv1] {
        foreach f $funcs {
            set c [conversions [lindex $f 2] [lindex $f 3]]
            set $var [lmap a [set $var] b $c {expr {$a + $b}}]
        }
    }
    set e0 [edgeCensus $f0]
    set e1 [edgeCensus $f1]
    set size0 [lindex [native::codeSize $hir -raw-int-abi-opt 0] 0]
    set size1 [lindex [native::codeSize $hir -raw-int-abi-opt 1] 0]
    puts "$path:"
    puts "  instances examined $examined; raw parameter positions $rawParams; raw results $rawResults; both $both; any raw $anyRaw (recursive $recursiveRaw, non-recursive $nonRecursiveRaw); tagged-only $taggedOnly; emitted NIR functions with a raw signature $emittedRaw of [llength $f1]"
    puts "  rejection tags: [lsort -stride 2 $reasons]"
    puts "  call edges off: [lsort -stride 2 $e0]"
    puts "  call edges on:  [lsort -stride 2 $e1]"
    puts "  rbox/runbox (total, call-boundary rbox, call-boundary runbox) off: [lindex $conv0 0]/[lindex $conv0 1] boundary [lindex $conv0 2]/[lindex $conv0 3]"
    puts "  rbox/runbox (total, call-boundary rbox, call-boundary runbox) on:  [lindex $conv1 0]/[lindex $conv1 1] boundary [lindex $conv1 2]/[lindex $conv1 3]"
    puts "  machine code bytes off $size0 on $size1 ([expr {$size1 - $size0}])"
    if {$detail} {
        foreach g $gains { puts "    gains: $g" }
    }
    foreach {k v} [list examined $examined rawParams $rawParams rawResults $rawResults both $both anyRaw $anyRaw \
            taggedOnly $taggedOnly recursiveRaw $recursiveRaw nonRecursiveRaw $nonRecursiveRaw \
            rbox0 [lindex $conv0 0] runbox0 [lindex $conv0 1] rbox1 [lindex $conv1 0] runbox1 [lindex $conv1 1] \
            brbox0 [lindex $conv0 2] brunbox0 [lindex $conv0 3] brbox1 [lindex $conv1 2] brunbox1 [lindex $conv1 3] \
            bytes0 $size0 bytes1 $size1] {
        total $k $v
    }
    foreach cls {raw->raw tagged->raw raw->tagged tagged->tagged} {
        total off:$cls [dict get $e0 $cls]
        total on:$cls [dict get $e1 $cls]
    }
}
puts "TOTALS: [lsort -stride 2 $totals]"
