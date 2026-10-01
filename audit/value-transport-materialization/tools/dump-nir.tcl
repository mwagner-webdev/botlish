#!/usr/bin/env tclsh9.0
# dump-nir.tcl -- writes the NIR of every canonical program (bench/*.bot and
# examples/stdlib/*.bot) of the tree it is run in to OUTDIR/NAME.nir, under the
# native options given after OUTDIR. Observation only; used to compare the
# policies (and trees) byte for byte.
#
#   (cd TREE && tclsh9.0 audit/value-transport-materialization/tools/dump-nir.tcl OUTDIR ?OPTION...?)
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 200000
set outdir [lindex $argv 0]
set opts [lrange $argv 1 end]
file mkdir $outdir
foreach path [concat [lsort [glob -directory [file join $root bench] *.bot]] \
        [lsort [glob -directory [file join $root examples stdlib] *.bot]]] {
    set name [file rootname [file tail $path]]
    set hir [native::prepareHir [surface::readProgramFile $path]]
    set f [open [file join $outdir $name.nir] w]
    fconfigure $f -encoding utf-8
    puts -nonewline $f [dict get [native::lowered $hir {*}$opts] text]
    close $f
}
