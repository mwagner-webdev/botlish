# remaining-copies.tcl -- the two program-sized copies this milestone left
# (SEMANTIC-INSTANCE-SCALABILITY-MILESTONE-1.md, "Remaining limits"):
#
#   tclsh9.0 audit/semantic-instance-scalability/tools/remaining-copies.tcl views FILE...
#   tclsh9.0 audit/semantic-instance-scalability/tools/remaining-copies.tcl contexts FILE...
#
# views: compiles each FILE (the front end of this checkout, warnings off, no
# cache) with hir::semantic::View, hir::traits::PlanCalls and
# hir::semantic::Walk wrapped (audit/mid-end-port/tools/timing.tcl) and prints
# how many views the trait plan made -- each a copy of the program's HIR with
# one instance's snapshot applied -- and what they cost.
#
# contexts: compiles each FILE with hir::types::Block wrapped and prints the
# size of the creating context's `types` at every block typing outside
# region inference: the body's context starts from it, and its first write
# copies it, so the sum is what at most is copied.
#
# Each FILE is compiled in this process, after the previous one.

set here [file dirname [file normalize [info script]]]
set checkout [file dirname [file dirname [file dirname $here]]]
source [file join $checkout surface surface.tcl]
source [file join $checkout audit mid-end-port tools timing.tcl]
lassign $argv mode
switch -- $mode {
    views {
        timing::wrap {::hir::semantic::View ::hir::traits::PlanCalls ::hir::semantic::Walk}
        foreach path [lrange $argv 1 end] {
            timing::reset
            set t0 [clock microseconds]
            set hir [surface::readProgramFile $path -warnings off -cache ""]
            set views [timing::calls ::hir::semantic::View]
            puts [format "%s: %d exprs, front end %.1f s; View %d calls %.2f s (%.1f ms each); PlanCalls %d calls %.2f s; instance walks %d, %.2f s" \
                [file tail $path] [dict size [dict get $hir exprs]] [expr {([clock microseconds] - $t0) / 1e6}] \
                $views [timing::seconds ::hir::semantic::View] \
                [expr {$views ? 1e3 * [timing::seconds ::hir::semantic::View] / $views : 0}] \
                [timing::calls ::hir::traits::PlanCalls] [timing::seconds ::hir::traits::PlanCalls] \
                [timing::calls ::hir::semantic::Walk] [timing::seconds ::hir::semantic::Walk]]
        }
    }
    contexts {
        rename ::hir::types::Block ::hir::types::BlockMeasured
        proc ::hir::types::Block {hirVar outerVar e self} {
            upvar 1 $hirVar hir $outerVar outer
            if {![dict exists $outer spec]} {
                lappend ::sizes [dict size [dict get $outer types]]
            }
            return [BlockMeasured hir outer $e $self]
        }
        foreach path [lrange $argv 1 end] {
            set ::sizes {}
            set hir [surface::readProgramFile $path -warnings off -cache ""]
            set n [llength $::sizes]
            set sum 0
            set max 0
            foreach x $::sizes {
                incr sum $x
                if {$x > $max} {
                    set max $x
                }
            }
            puts "$path: [dict size [dict get $hir bindings]] bindings; $n block typings; creating context's types: mean [expr {$sum / max($n, 1)}], max $max entries; entries copied in all (at most): $sum"
        }
    }
    default {
        error "remaining-copies.tcl: views|contexts FILE..."
    }
}
