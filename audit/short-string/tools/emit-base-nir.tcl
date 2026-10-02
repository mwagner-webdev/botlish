#!/usr/bin/env tclsh9.0
# emit-base-nir.tcl -- the NIR of every canonical corpus program as emitted by
# the tree in the CURRENT DIRECTORY (run it from a checkout of the parent
# commit, d51c0d3, to get the pre-ShortString1 baseline): one OUTDIR/NAME.nir
# per program. Observation only.
#
#   (cd PARENT-CHECKOUT && tclsh9.0 /path/to/emit-base-nir.tcl OUTDIR)
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
set out [lindex $argv 0]
file mkdir $out
set paths {}
foreach name {fib lex-strategy loop-count refined-checks source-checks sum-refined test-selection uri-steady} {
    lappend paths [file join $root bench $name.bot]
}
foreach name {ai_text_clean csv csv_chunked csv_geometric csv_records hashtable matmul string_replace string_reverse} {
    lappend paths [file join $root examples stdlib $name.bot]
}
foreach path $paths {
    set hir [surface::readProgramFile $path]
    set f [open [file join $out [file rootname [file tail $path]].nir] w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f [native::nir $hir]
    close $f
}
