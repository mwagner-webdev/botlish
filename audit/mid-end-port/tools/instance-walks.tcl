# instance-walks.tcl -- what a semantic instance's walk costs as the program
# grows (audit/mid-end-port/README.md, section 8):
#
#   tclsh9.0 audit/mid-end-port/tools/instance-walks.tcl ROOT FILE...
#
# Sources the compiler of checkout ROOT, wraps hir::semantic::Walk,
# hir::semantic::Analyze and hir::signatures::infer (timing.tcl), compiles
# each FILE (front end, warnings off) and prints: its expressions, the front
# end's time, hir::signatures::infer's, the number of instance walks and
# their time, and what one copy of the program's `exprs` table costs.
# hir::semantic::Walk starts every walk from the program's HIR
# (`set scratch [dict get $state base]`), so the walk's first type write
# copies the whole shared `exprs` table (Tcl's copy-on-write): this tool
# times that copy the same way (one `dict set` into a shared copy of the
# compiled HIR, the fastest of 10) and multiplies it by the walks.

set here [file dirname [file normalize [info script]]]
set root [file normalize [lindex $argv 0]]
source [file join $root surface surface.tcl]
source [file join $here timing.tcl]
timing::wrap {::hir::semantic::Walk ::hir::semantic::Analyze ::hir::signatures::infer}
proc peakMb {} {
    if {[catch {open /proc/self/status} channel]} { return "" }
    set kb ""
    foreach line [split [read $channel] \n] {
        if {[regexp {^VmHWM:\s+(\d+)} $line -> kb]} break
    }
    close $channel
    return [expr {$kb / 1024}]
}
foreach path [lrange $argv 1 end] {
    timing::reset
    set t0 [clock microseconds]
    set hir [surface::readProgramFile $path -warnings off -cache ""]
    set front [expr {([clock microseconds] - $t0) / 1e6}]
    set first [lindex [dict keys [dict get $hir exprs]] 0]
    set samples {}
    for {set i 0} {$i < 10} {incr i} {
        set s $hir
        set t0 [clock microseconds]
        dict set s exprs $first type ""
        lappend samples [expr {[clock microseconds] - $t0}]
        unset s
    }
    set copy [expr {[tcl::mathfunc::min {*}$samples] / 1e3}]
    set walks [timing::calls ::hir::semantic::Walk]
    set instances [dict size [dict get $hir semantic instances]]
    puts [format "%s: %d exprs; front end %.1f s; signatures::infer %.1f s; %d semantic instances, %d instance walks, %.1f s in them (%.2f ms each); one exprs copy %.1f ms; walks x copy = %.1f s; peak %s MB" \
        [file tail [file dirname $path]] [dict size [dict get $hir exprs]] $front [timing::seconds ::hir::signatures::infer] \
        $instances $walks [timing::seconds ::hir::semantic::Walk] \
        [expr {$walks == 0 ? 0.0 : 1e3 * [timing::seconds ::hir::semantic::Walk] / $walks}] $copy [expr {$walks * $copy / 1e3}] [peakMb]]
}
