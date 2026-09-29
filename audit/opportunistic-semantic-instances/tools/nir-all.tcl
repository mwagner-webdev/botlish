#!/usr/bin/env tclsh9.0
# nir-all.tcl -- the used codegen-instance labels and the full NIR text of
# every canonical program (bench/*.bot and examples/stdlib/*.bot; relifted
# pipeline, as bench/bench.tcl compiles), one file per program, so the parent
# commit's and this tree's outputs can be diffed: codegen-instance invariance
# and whether generated code changed. Observation only.
#
#   (cd TREE && tclsh9.0 audit/opportunistic-semantic-instances/tools/nir-all.tcl OUTDIR)
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
lassign $argv outdir
file mkdir $outdir
foreach path [concat [lsort [glob -directory [file join $root bench] *.bot]] \
        [lsort [glob -directory [file join $root examples stdlib] *.bot]]] {
    set hir [native::buildProgramHir [hir::lower [surface::readProgramFile $path]]]
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
