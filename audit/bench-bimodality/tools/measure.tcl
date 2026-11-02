# measure.tcl -- best-of-RUNS native (Cranelift JIT) time and value of
# benchmark programs, as bench/bench.tcl's native column measures them
# (native::measure: one driver process, JIT compilation excluded).
#
#   tclsh9.0 audit/bench-bimodality/tools/measure.tcl ?-runs N? FILE.bot ...
#
# BENCHMARK-BIMODALITY.md's variant measurements; FILE may be a benchmark
# or a variant (variants/NAME/PROGRAM.bot), staged as stage.tcl says.

namespace eval bimodality {}
source [file join [file dirname [file normalize [info script]]] stage.tcl]

set runs 30
set files {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    if {$arg eq "-runs"} {
        set runs [lindex $argv [incr i]]
    } else {
        lappend files $arg
    }
}
foreach path $files {
    set label [file join [file tail [file dirname $path]] [file tail $path]]
    if {[catch {
        bimodality::withHir $path hir {
            lassign [native::measure $hir $runs] lower compile best collections value
        }
        puts [format "%-52s %11.2f us  %s" $label $best [string range [core::formatValue $value] 0 60]]
    } message]} {
        puts [format "%-52s ERROR %s" $label [lindex [split $message \n] 0]]
    }
}
