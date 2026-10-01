#!/usr/bin/env tclsh9.0
# closedness.tcl -- EXACT-CALLABLE-CLOSED-CALLER.md: per used instance, the
# authoritative InstanceClosed answer next to hir::range's openness for it
# (they are one proof now: closed=1 <=> range-open=0 for a block instance),
# its caller count and exact callable targets. Audit only.
#
#   (cd TREE && tclsh9.0 .../closedness.tcl PROGRAM.bot ...) > OUT.txt
set root [pwd]
set args $argv
set argv {}
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
fconfigure stdout -encoding utf-8 -translation lf
foreach path $args {
    set hir [native::prepareHir [surface::readProgramFile $path]]
    set spec [hir::specialize::analyze $hir]
    puts "== $path"
    puts [hir::specialize::closedAudit $hir $spec]
    set bad 0
    set open [hir::range::OpenInstances $spec $hir]
    foreach id [dict get $spec used] {
        if {[dict get $spec instances $id block] eq "program"} continue
        if {[dict exists $open $id] == [hir::specialize::closed $hir $spec $id]} { incr bad }
    }
    puts "(closed and range-open disagreeing: $bad)"
}
