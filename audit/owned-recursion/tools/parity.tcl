# parity.tcl -- the recursive-ownership verdict against the walk it replaced,
# over real programs (OWNED-RECURSION-DECLARATION-SUMMARY-MILESTONE-1.md,
# "Old and new").
#
#   tclsh9.0 audit/owned-recursion/tools/parity.tcl ?FILE ...?
#
# Compiles each program (by default every golden suite and the examples'
# programs), collects every affine named struct type its HIR gives an
# expression, a binding or a declaration's field -- applications included,
# at any depth -- and asks both the compiler (hir::structs::OwnedRecursion)
# and the old walk (reference.tcl). A program the compiler rejects is
# reported as such (its types are not collected). Each type is:
#
#   same      both accept or both reject
#   old-bound the old walk stopped at its depth or budget ("unbounded")
#   DIFFERENT anything else (the fuzzer, fuzz.tcl, classifies the kinds of
#             difference random declaration graphs produce; real programs
#             are expected to have none)
#
# The last line is "P programs, T types: S same, B old-bound, D DIFFERENT".

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set ::argv0 parity
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root audit owned-recursion tools reference.tcl]

set files $argv
if {$files eq {}} {
    set files [lsort [glob -directory [file join $root tests golden] *.bot]]
    foreach pattern {examples/*/*.bot examples/*/*/*.bot} {
        lappend files {*}[lsort [glob -nocomplain -directory $root $pattern]]
    }
}

# Every named struct type in TYPE, at any depth.
proc namedIn {type resultVar} {
    upvar 1 $resultVar result
    if {[llength $type] < 2} {
        return
    }
    if {[hir::types::IsNamedStruct $type]} {
        dict set result $type 1
    }
    foreach part $type {
        if {$part ne $type} {
            namedIn $part result
        }
    }
}

set counts [dict create programs 0 rejected 0 types 0 same 0 old-bound 0 DIFFERENT 0]
foreach file $files {
    dict incr counts programs
    if {[catch {surface::readProgramFile $file -warnings off} hir]} {
        dict incr counts rejected
        continue
    }
    hir::activate $hir
    set types [dict create]
    dict for {e node} [dict get $hir exprs] {
        if {[catch {hir::typeOf $hir $e} t]} continue
        namedIn $t types
    }
    foreach entry [dict getdef $hir sourceTypes {}] {
        if {[dict getdef $entry kind ""] ne "struct"} continue
        foreach {name t} [dict get $entry fields] {
            namedIn $t types
        }
    }
    dict for {type -} $types {
        if {[string first imprint $type] >= 0 || ![hir::types::IsAffine $type]} continue
        dict incr counts types
        set new [expr {[hir::structs::OwnedRecursion $type] eq "" ? "ok" : "recursive"}]
        set old [::reference::owned::OwnedRecursion $type]
        set old [expr {$old eq "" ? "ok" : [lindex $old 0]}]
        if {$old eq $new} {
            dict incr counts same
        } elseif {$old eq "unbounded"} {
            dict incr counts old-bound
        } else {
            dict incr counts DIFFERENT
            puts "DIFFERENT [file tail $file]: [hir::types::show $type]: old $old, new $new"
        }
    }
}
puts "[dict get $counts programs] programs ([dict get $counts rejected] rejected), [dict get $counts types] affine named struct types: [dict get $counts same] same, [dict get $counts old-bound] old-bound, [dict get $counts DIFFERENT] DIFFERENT"
exit [expr {[dict get $counts DIFFERENT] > 0}]
