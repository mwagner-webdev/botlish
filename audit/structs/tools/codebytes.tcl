#!/usr/bin/env tclsh9.0
# codebytes.tcl -- machine-code bytes (native::codeSize, specialized) of every
# canonical program (bench/*.bot, examples/stdlib/*.bot), one line per program
# and a total. Observation only; runs against the tree it is started in.
#
#   (cd TREE && tclsh9.0 audit/structs/tools/codebytes.tcl OUTFILE)
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
lassign $argv outfile
set out [open $outfile w]
set total 0
foreach path [concat [lsort [glob -directory [file join $root bench] *.bot]] \
        [lsort [glob -directory [file join $root examples stdlib] *.bot]]] {
    set hir [native::prepareHir [surface::readProgramFile $path]]
    set bytes [lindex [native::codeSize $hir] 0]
    puts $out "[file rootname [file tail $path]] $bytes"
    incr total $bytes
}
puts $out "TOTAL $total"
close $out
