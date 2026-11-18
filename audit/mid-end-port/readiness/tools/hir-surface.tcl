# hir-surface.tcl -- what a checked HIR holds, as a boundary would have to
# carry it (PORTABILITY-MID-END-PORT-READINESS-CENSUS-1.md, section 13):
# for each program, the HIR's top-level keys (the exprs and bindings tables
# and every side table) with their entry counts and their share of the
# interchange text, the node kinds of exprs, the declaration registries the
# `declarations` side table carries, and which top-level keys the backends
# read (a grep of compiler/, native/ and ccompile/ for `dict get $hir KEY`
# and `hir::get ... KEY` forms is not reliable, so the census records the
# keys only; the boundary design reads them from HIR-INTERCHANGE.md).
#
#   tclsh9.0 audit/mid-end-port/readiness/tools/hir-surface.tcl FILE.bot...
#
# Prints, per program, `program FILE {exprs N bindings N textKb K}`, then
# `key NAME ENTRIES TEXT-KB` per top-level key, `kinds {KIND COUNT ...}`,
# `declarations {REGISTRY ENTRIES ...}`; finally `union` lines: every
# top-level key and node kind seen in any program.

set checkout [file dirname [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]]
source [file join $checkout surface surface.tcl]
set allKeys [dict create]
set allKinds [dict create]
foreach path $argv {
    set hir [surface::readProgramFile [file normalize $path] -warnings off -cache ""]
    set text [hir::interchange::encode $hir]
    puts [list program [file tail $path] [dict create exprs [dict size [dict get $hir exprs]] \
        bindings [dict size [dict get $hir bindings]] textKb [expr {[string length $text] / 1024}]]]
    dict for {key value} $hir {
        dict incr allKeys $key
        set entries [expr {[string is list $value] && [llength $value] % 2 == 0 ? [llength $value] / 2 : [llength $value]}]
        puts [list key $key $entries [expr {[string length $value] / 1024}]]
    }
    set kinds [dict create]
    dict for {e node} [dict get $hir exprs] {
        dict incr kinds [dict get $node kind]
        dict incr allKinds [dict get $node kind]
    }
    puts [list kinds [lsort -stride 2 -index 1 -integer -decreasing $kinds]]
    set registries {}
    dict for {name value} [dict getdef $hir declarations {}] {
        lappend registries $name [expr {[string is list $value] && [llength $value] % 2 == 0 ? [llength $value] / 2 : [llength $value]}]
    }
    puts [list declarations $registries]
    flush stdout
}
puts [list union keys [dict size $allKeys] [lsort [dict keys $allKeys]]]
puts [list union kinds [dict size $allKinds] [lsort -stride 2 -index 1 -integer -decreasing $allKinds]]
