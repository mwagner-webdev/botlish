# core.tcl -- loads the reference evaluator.
#
#   source core/core.tcl
#   core::formatValue [core::eval {call {ref +} {const 1} {const 2}}]   ;# => 3

package require Tcl 8.6

apply {{dir} {
    foreach file {
        errors value completion env ir
        block native callable refine runtime evaluator
        primitives predicates programfile
    } {
        uplevel #0 [list source [file join $dir $file.tcl]]
    }
}} [file dirname [file normalize [info script]]]

package provide core 0.1
