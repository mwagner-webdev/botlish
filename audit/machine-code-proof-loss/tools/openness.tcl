#!/usr/bin/env tclsh9.0
# openness.tcl -- MACHINE-CODE-PROOF-LOSS-INVESTIGATION.md: for every generic
# (non-program) codegen instance of a program, the two closedness verdicts the
# compiler computes side by side: hir::range::OpenInstances (the test that
# decides whether an instance's parameters get caller-propagated entry Ranges)
# and hir::specialize::closed (M7.c's InstanceClosed, blockescape's
# every-reference-is-an-exact-call proof). An instance that is CLOSED by the
# second but OPEN by the first loses its entry Ranges although every caller
# is known. Observation only.
#
#   (cd TREE && tclsh9.0 .../openness.tcl PROGRAM.bot) > OUT.txt
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
set hir [native::prepareHir [surface::readProgramFile [lindex $argv 0]]]
set spec [hir::specialize::analyze $hir]
set open [hir::range::OpenInstances $spec]
set be [hir::blockescape::analyze $hir $spec]
fconfigure stdout -encoding utf-8
foreach id [dict get $spec used] {
    set inst [hir::specialize::instance $spec $id]
    if {![dict get $inst generic] || [dict get $inst block] eq "program"} continue
    puts [format "%-28s range-open=%d InstanceClosed=%s" [hir::specialize::label $spec $id] [dict exists $open $id] [hir::specialize::closed $hir $spec $id]]
}
