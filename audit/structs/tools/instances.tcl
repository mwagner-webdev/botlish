#!/usr/bin/env tclsh9.0
# instances.tcl -- STRUCTS.md's semantic-instance and codegen-instance census
# of the canonical corpus (bench/*.bot and examples/stdlib/*.bot). Observation
# only; runs against the tree it is started in (pwd is the root).
#
#   (cd TREE && tclsh9.0 audit/structs/tools/instances.tcl OUTFILE [-off])
#
# Per program: the semantic instances (hir::semantic) used by the program, how
# many of them involve a struct type in an argument or the result, how many
# distinct codegen keys (hir::specialize::KeyType of the arguments) those
# struct instances fall on, the codegen instances hir::specialize uses, the
# functions native lowering emits, and the codegen instances whose key mentions
# a struct. "Sharing" is semantic struct instances minus distinct codegen keys:
# instances that share machine code despite differing field semantic types.
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
lassign $argv outfile
set off [expr {"-off" in $argv}]
if {$off} { set hir::semantic::enabled 0 }

proc HasStruct {t} {
    # The pre-struct tree has no struct types: nothing in it is one.
    if {![llength [info commands hir::types::IsStructLike]]} { return 0 }
    if {[hir::types::IsStructLike $t]} { return 1 }
    if {[llength $t] > 1} {
        foreach e $t { if {[llength $e] > 1 && [HasStruct $e]} { return 1 } }
    }
    return 0
}

set programs [concat [lsort [glob -directory [file join $root bench] *.bot]] \
    [lsort [glob -directory [file join $root examples stdlib] *.bot]]]
set out [open $outfile w]
fconfigure $out -encoding utf-8
set totals [dict create semantic 0 structSemantic 0 keys 0 used 0 emitted 0 structCodegen 0]
foreach path $programs {
    set name [file rootname [file tail $path]]
    set hir [surface::readProgramFile $path]
    set rows [hir::semantic::census $hir]
    set structRows {}
    foreach r $rows {
        set has [HasStruct [dict get $r result]]
        foreach a [dict get $r args] { if {[HasStruct $a]} { set has 1 } }
        if {$has} { lappend structRows $r }
    }
    set keys [dict create]
    foreach r $structRows {
        set key [list [dict get $r block] [lmap a [dict get $r args] {hir::specialize::KeyType $a}]]
        dict lappend keys $key [dict get $r id]
    }
    set prepared [native::prepareHir $hir]
    set spec [hir::specialize::analyze $prepared]
    set used [dict get $spec used]
    set structCodegen [lmap id $used {
        set inst [hir::specialize::instance $spec $id]
        set has [HasStruct [dict get $inst result]]
        foreach a [dict get $inst args] { if {[HasStruct $a]} { set has 1 } }
        if {!$has} continue
        hir::specialize::label $spec $id
    }]
    set emitted [llength [dict get [native::lower::program $prepared] functions]]
    puts $out "== $name"
    puts $out "semantic instances: [llength $rows]; with a struct type: [llength $structRows]; distinct codegen keys of those: [dict size $keys]; sharing: [expr {[llength $structRows] - [dict size $keys]}]"
    puts $out "codegen instances used: [llength $used]; emitted functions: $emitted; struct codegen instances: [llength $structCodegen]"
    foreach r $structRows {
        puts $out "  semantic [dict get $r name]<[join [lmap a [dict get $r args] {hir::types::show $a}] {, }]> -> [hir::types::show [dict get $r result]] ([dict get $r status])"
    }
    foreach l $structCodegen { puts $out "  codegen $l" }
    dict incr totals semantic [llength $rows]
    dict incr totals structSemantic [llength $structRows]
    dict incr totals keys [dict size $keys]
    dict incr totals used [llength $used]
    dict incr totals emitted $emitted
    dict incr totals structCodegen [llength $structCodegen]
}
puts $out "== TOTAL"
puts $out $totals
close $out
