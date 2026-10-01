#!/usr/bin/env tclsh9.0
# prepare-census.tcl -- MACHINE-CODE-PROOF-LOSS-INVESTIGATION.md, spec item 36:
# the front end's semantic instances (hir::semantic::census) of a program's
# HIR before and after native::prepareHir (which attaches native
# implementations such as web::emailish? and re-checks the HIR). Shows
# whether prepareHir broadens or adds semantic facts. Observation only.
#
#   (cd TREE && tclsh9.0 .../prepare-census.tcl PROGRAM.bot) > OUT.txt
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
set hir [surface::readProgramFile [lindex $argv 0]]
fconfigure stdout -encoding utf-8
foreach {label h} [list before $hir after [native::prepareHir $hir]] {
    puts "== $label prepareHir: [llength [hir::semantic::census $h]] semantic instances"
    foreach r [hir::semantic::census $h] {
        puts "  [dict get $r name]<[join [lmap a [dict get $r args] {hir::types::show $a}] {, }]> -> [hir::types::show [dict get $r result]] [dict get $r status]"
    }
}
