# guard-overhead.tcl -- what the depth guard costs an ordinary program
# (DEPTH-SAFE-NESTED-EXPRESSION-FRONTEND-MILESTONE-1.md, section 20).
#
#   tclsh9.0 bench/guard-overhead.tcl ?-root DIR? ?-reps N? FILE...
#
# Compiles each FILE (a program file: a golden suite, an example) with the
# front end of checkout DIR (this one by default) -reps times (3) in one
# process, and with core IR, the Tcl compiler's unit and native lowering
# once more, and prints per file the fastest front end and the lowerings'
# milliseconds, then their sums. Run it on this checkout and on the
# revision before the milestone (-root) on the same machine: the
# difference is the guards' and the segments' cost where nothing nests
# deep (the guard is one `info level` and a comparison per guarded call).

set options [dict create -root "" -reps 3]
set files {}
while {[llength $argv]} {
    set argv [lassign $argv word]
    if {[dict exists $options $word]} {
        set argv [lassign $argv value]
        dict set options $word $value
    } else {
        lappend files [file normalize $word]
    }
}
set ::dsnState [list $options $files]
set root [dict get $options -root]
if {$root eq ""} {
    set root [file dirname [file dirname [file normalize [info script]]]]
}
source [file join $root native native.tcl]
source [file join $root surface surface.tcl]
lassign $::dsnState options files
set totalFront 0
set totalLower 0
foreach file $files {
    set best ""
    for {set i 0} {$i < [dict get $options -reps]} {incr i} {
        set started [clock microseconds]
        set hir [surface::readProgramFile $file -warnings off]
        set ms [expr {([clock microseconds] - $started) / 1000.0}]
        if {$best eq "" || $ms < $best} {
            set best $ms
        }
    }
    set started [clock microseconds]
    hir::lower $hir
    core::compiler::compileHir $hir
    native::lowered $hir
    set lower [expr {([clock microseconds] - $started) / 1000.0}]
    puts [format "%-60s front %9.1f ms  lowerings %9.1f ms" [file tail $file] $best $lower]
    set totalFront [expr {$totalFront + $best}]
    set totalLower [expr {$totalLower + $lower}]
}
puts [format "%-60s front %9.1f ms  lowerings %9.1f ms" total $totalFront $totalLower]
