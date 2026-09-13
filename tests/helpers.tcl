# helpers.tcl -- shared test setup.

package require tcltest 2.5
namespace import -force ::tcltest::*

set ::projectRoot [file dirname [file dirname [file normalize [info script]]]]
source [file join $::projectRoot core core.tcl]

# Evaluates a program given as expressions; returns the formatted value.
proc run {args} {
    return [core::formatValue [core::evalProgram $args]]
}

# Evaluates a program; returns the raw runtime value.
proc runValue {args} {
    return [core::evalProgram $args]
}

# Evaluates a program and returns the error code of the failure it raises.
proc errorCodeOf {args} {
    if {![catch {core::evalProgram $args} message options]} {
        return "no error; value [core::formatValue $message]"
    }
    return [dict get $options -errorcode]
}

# Observable effects for tests only. The language has no mutation; these
# Tcl-backed natives let tests observe evaluation order and repetition.
set ::testLog {}
set ::testTicks 0

proc testLogImpl {v} {
    lappend ::testLog [core::formatValue $v]
    return $v
}

proc testTickImpl {} {
    return [core::value::int [incr ::testTicks]]
}

proc resetEffects {} {
    set ::testLog {}
    set ::testTicks 0
}

if {"test-log" ni [core::native::names]} {
    core::registerNative test-log  -arity 1 -impl testLogImpl
    core::registerNative test-tick -arity 0 -impl testTickImpl
}
