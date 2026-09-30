#!/usr/bin/env tclsh9.0
# nir.tcl -- the used specialization instance labels and the full NIR text
# of every canonical benchmark (relifted pipeline, as bench/bench.tcl
# compiles), one file per program, so the parent commit's and this tree's
# outputs can be diffed: specialization-key invariance (spec item 62) and
# whether generated code changed (item 76). Observation only.
#
#   (cd TREE && tclsh9.0 audit/intrinsic-function-contracts/tools/nir.tcl OUTDIR)
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
lassign $argv outdir
file mkdir $outdir
foreach path [lsort [glob -directory [file join $root bench] *.bot]] {
    set hir [native::prepareHir [surface::readProgramFile $path]]
    set spec [hir::specialize::analyze $hir]
    set labels [lmap id [dict get $spec used] {hir::specialize::label $spec $id}]
    set nir [dict get [native::lower::program $hir] text]
    set f [open [file join $outdir [file rootname [file tail $path]].nir] w]
    fconfigure $f -encoding utf-8
    puts $f "# instances: [join $labels {, }]"
    puts $f $nir
    close $f
}
puts "wrote $outdir"
