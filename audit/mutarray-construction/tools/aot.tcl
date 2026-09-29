#!/usr/bin/env tclsh9.0
# aot.tcl -- AOT classification of every used specialization instance of
# every canonical benchmark and stdlib program, in the relifted pipeline
# bench/bench.tcl compiles: one line per instance with its hir::aot status
# (and transitive status), so a before/after diff shows any incidental
# change of classification or blockers. Runs against whatever tree it is
# started in (pwd is the root).
#
#   (cd TREE && tclsh9.0 audit/mutarray-construction/tools/aot.tcl OUTFILE)
set root [pwd]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
lassign $argv out
set L {}
set programs [concat [lsort [glob -directory [file join $root bench] *.bot]] \
    [lsort [glob -directory [file join $root examples stdlib] *.bot]]]
set counts [dict create]
foreach path $programs {
    set hir [native::buildProgramHir [hir::lower [surface::readProgramFile $path -strict 0]]]
    set spec [hir::specialize::analyze $hir]
    set regions [hir::specialize::regions $hir $spec]
    lappend L "" "== [file tail $path]"
    foreach id [dict get $spec used] {
        set region [dict get $regions $id]
        set status [dict get $region status]
        dict incr counts $status
        lappend L "  [dict get $region label]: $status (transitively [dict get $region transitive])"
        foreach blocker [dict get $region blockers] {
            lappend L "      blocker: [dict get $blocker kind] [dict get $blocker message]"
        }
    }
}
lappend L "" "# status counts: $counts"
set f [open $out w]
fconfigure $f -encoding utf-8
puts $f [join $L \n]
close $f
puts "wrote $out"
