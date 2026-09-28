#!/usr/bin/env tclsh9.0
# PWD selects the frozen tree or a separately documented hypothetical copy.
source compiler/compiler.tcl
source surface/surface.tcl
source native/native.tcl
interp recursionlimit {} 20000
lassign $argv path region
if {$region eq {}} {set region 1}
set hir [native::buildProgramHir [hir::lower [surface::readProgramFile $path]]]
puts [dict get [native::lower::program $hir -string-region-opt $region] text]
