#!/usr/bin/env tclsh9.0
# variants.tcl -- native-only timing of the four canonical benchmarks
# (bench/*.ir) under the configurations POST-M8A-COMMON-INEFFICIENCY-CENSUS.md
# compares. Observation only: native::measure (bench.tcl's own Cranelift
# mechanism: one subprocess, JIT compiled once, best of RUNS, compile
# excluded), SESSIONS independent sessions, median/min/max reported.
#
#   tclsh9.0 audit/post-m8a-common-inefficiency/tools/variants.tcl ?SESSIONS? ?RUNS...?
#
# Configurations:
#   cranelift         default lowering (M8.a virtual construction ON)
#   cranelift/vc-off  -virtual-construction-opt 0 (historical only)
#   cranelift-generic -specialize 0 (bench.tcl's guarded baseline)
# RUNS per configuration default to 5 (bench.tcl's) and 200 (a lower-noise
# second reading for the microsecond-scale programs).
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
set sessions [expr {[llength $argv] ? [lindex $argv 0] : 5}]
set runList [expr {[llength $argv] > 1 ? [lrange $argv 1 end] : {5 200}}]
core::loadLibrary web
set configs {
    cranelift         {}
    cranelift/vc-off  {-virtual-construction-opt 0}
    cranelift-generic {-specialize 0}
}
foreach path [lsort [glob -directory [file join $root bench] *.ir]] {
    set hir [native::buildProgramHir [core::loadProgramFile $path]]
    foreach {name opts} $configs {
        foreach runs $runList {
            set bests {}
            set failed ""
            for {set i 0} {$i < $sessions} {incr i} {
                if {[catch {native::measure $hir $runs {*}$opts} m opt]} {
                    set failed "[dict get $opt -errorcode]"
                    break
                }
                lassign $m lower compile best collections value
                lappend bests $best
            }
            if {$failed ne ""} {
                puts [format "%-18s %-18s runs=%-4d not measurable: %s" [file tail $path] $name $runs $failed]
                break
            }
            set sorted [lsort -real $bests]
            set median [lindex $sorted [expr {[llength $sorted] / 2}]]
            puts [format "%-18s %-18s runs=%-4d value=%-10s median=%10.2f us  min=%10.2f  max=%10.2f  jit_compile=%s us  sessions={%s}" \
                [file tail $path] $name $runs [core::formatValue $value] $median [lindex $sorted 0] [lindex $sorted end] \
                $compile [join [lmap b $bests {format %.2f $b}] { }]]
            flush stdout
        }
    }
}
