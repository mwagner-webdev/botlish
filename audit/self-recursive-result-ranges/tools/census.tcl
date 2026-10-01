#!/usr/bin/env tclsh9.0
# census.tcl -- self-recursive instance census over canonical programs
# (SELF-RECURSIVE-RESULT-RANGES.md). Per program: every self-recursive used
# instance with its status/reason and result before/after, and whether the
# emitted NIR differs between -recursive-result-range-opt 0 and 1.
#
#   tclsh9.0 audit/self-recursive-result-ranges/tools/census.tcl PROGRAM.bot...
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
fconfigure stdout -encoding utf-8 -translation lf
foreach path $argv {
    if {[catch {
        set hir [surface::readProgramFile $path]
        set prepared [native::prepareHir $hir]
        set spec [hir::specialize::analyze $prepared]
        set a [hir::range::analyze $prepared $spec]
        set nir0 [native::nir $hir -recursive-result-range-opt 0]
        set nir1 [native::nir $hir -recursive-result-range-opt 1]
    } err]} {
        puts "$path: SKIP ($err)"
        continue
    }
    set rec [dict get $a recursive]
    puts "$path: self-recursive instances [dict size $rec]; NIR [expr {$nir0 eq $nir1 ? {identical} : {DIFFERS}}]"
    dict for {id r} $rec {
        set label [hir::specialize::label $spec $id]
        if {[dict get $r status] eq "solved"} {
            puts "    $label: solved states [dict size [dict get $r states]] result [hir::range::show [dict get $r resultBefore]] -> [hir::range::show [dict get $r result]]"
        } else {
            puts "    $label: rejected [dict get $r reason] -- [dict get $r detail]"
        }
    }
}
