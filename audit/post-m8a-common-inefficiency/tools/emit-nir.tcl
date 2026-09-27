#!/usr/bin/env tclsh9.0
# emit-nir.tcl -- the NIR text native::measure/bench.tcl would run for a
# canonical benchmark (POST-M8A-COMMON-INEFFICIENCY-CENSUS.md). Observation
# only: native::buildProgramHir + native::nir with the given lowering
# options (none = the default M8.a-on baseline), exactly bench.tcl's path.
#
#   tclsh9.0 audit/post-m8a-common-inefficiency/tools/emit-nir.tcl PROGRAM.ir OUT.nir ?LOWER-OPTIONS...?
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
set argv [lassign $argv path out]
core::loadLibrary web
if {[file extension $path] eq ".bot"} {
    set hir [surface::readProgramFile $path]
} else {
    set hir [native::buildProgramHir [core::loadProgramFile $path]]
}
set f [open $out w]
fconfigure $f -encoding utf-8 -translation lf
puts -nonewline $f [native::nir $hir {*}$argv]
close $f
