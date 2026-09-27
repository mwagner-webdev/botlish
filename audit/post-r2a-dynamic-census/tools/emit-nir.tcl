#!/usr/bin/env tclsh9.0
# emit-nir.tcl -- the NIR text bench.tcl's native column would run for a
# bench/*.ir-shaped program, emitted by the tree in the CURRENT DIRECTORY
# (not this script's own tree), so the same script serves the frozen tree
# and historical worktrees alike (POST-R2A-DYNAMIC-CENSUS.md). Observation
# only: native::buildProgramHir + native::nir, default lowering options.
#
#   (cd TREE && tclsh9.0 .../emit-nir.tcl PROGRAM.ir) > OUT.nir
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
core::loadLibrary web
set hir [native::buildProgramHir [core::loadProgramFile [lindex $argv 0]]]
fconfigure stdout -encoding utf-8 -translation lf
puts -nonewline [native::nir $hir {*}[lrange $argv 1 end]]
