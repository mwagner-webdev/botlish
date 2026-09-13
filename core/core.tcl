# core.tcl -- loads the reference evaluator.
#
#   source core/core.tcl
#   core::formatValue [core::eval {call {ref +} {const 1} {const 2}}]   ;# => 3

package require Tcl 8.6

apply {{dir} {
    foreach file {
        errors value completion env ir type regex
        block native callable refine runtime evaluator
        primitives predicates strings
    } {
        uplevel #0 [list source [file join $dir $file.tcl]]
    }
    # Demonstration library of refined string types (Emailish, UriQueryValue).
    uplevel #0 [list source [file join [file dirname $dir] lib web.tcl]]
    uplevel #0 [list source [file join $dir programfile.tcl]]
}} [file dirname [file normalize [info script]]]

package provide core 0.1
