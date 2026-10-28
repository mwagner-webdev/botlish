# static.tcl -- check.tcl's static part (EVENT-LOOP-EXPLORATION.md, "Static
# evidence"): the programs the compiler must reject, each with the
# diagnostic kinds it must report, and the driver audit.
# Sourced by check.tcl (claim, ::src, ::only).

set fixtures {
    s-two-drivers         AMBIGUOUS-CONTEXT-IMPLEMENTATION
        "two installed drivers: driver choice is one explicit decision, never a precedence"
    s-sdl-needs-pumps     MISSING-CONTEXT
        "a native library needing a capability (NativePumps) the installed driver lacks"
    s-library-installs    CONTEXT-INSTALLATION-UNSUPPORTED
        "a library cannot install a context, so importing one cannot choose a driver"
    s-adopt-twice         USE-AFTER-MOVE
        "a task handed to the scheduler twice"
    s-resume-adopted      USE-AFTER-MOVE
        "a task resumed directly after the scheduler took it"
    s-wrong-protocol      TYPE
        "a coroutine of another protocol given to the scheduler"
    s-loop-internals      OPAQUE-REPRESENTATION
        "a library reaching into the scheduler's queues"
    s-owned-twice         USE-AFTER-MOVE
        "one affine registration token given to two tasks"
    s-owned-message       COROUTINE-CONTRACT
        "an affine token sent through a resume message"
    s-handler-callback    CONTEXT-FUNCTION-VALUE
        "a handler that needs the loop written as a function value"
    s-capture-task        AFFINE-CAPTURE-UNSUPPORTED
        "a closure capturing a task's handle"
}

proc diagnosticKinds {path} {
    if {[catch {surface::readProgramFile $path -warnings off} message options]} {
        if {[dict exists $options -diagnostics]} {
            return [lmap d [dict get $options -diagnostics] {lindex [dict get $d errorcode] end}]
        }
        return [lindex [dict get $options -errorcode] end]
    }
    return ok
}

foreach {name kinds text} $fixtures {
    if {![string match $::only $name]} continue
    set got [diagnosticKinds [file join $::src $name.bot]]
    claim $name "rejected: $text ($kinds)" [expr {$got eq $kinds}] "got: $got"
}

# The driver audit: which functions require evloop::Driver -- the authority
# to make the loop wait and turn. The application (its entry program and
# its own modules: here wakeprobe, a measurement harness) and evloop may; a
# LIBRARY that does (drivinglib) is reported. Which modules are libraries
# -- independently developed code the application imports -- is the
# audit's input, as it would be an application's. Requiring the driver is
# an ordinary, visible context requirement (hir::contexts::summary), not a
# compile error: the audit is the check.
set ::libraries {drivinglib gameserver quietlib busylib workload ownedreg sdlprobe evsdl evn evsdlhost simdrv}
proc driverRequirers {path} {
    set hir [surface::readProgramFile $path -warnings off]
    set out {}
    foreach line [split [hir::contexts::summary $hir] \n] {
        if {[regexp {^source-function (\S+) \S+ direct-contexts \([^)]*\) required-contexts \(([^)]*)\)} $line -> fn required]
                && "evloop::Driver" in [split [string map {", " ,} $required] ,]} {
            lappend out $fn
        }
    }
    return [lsort -unique $out]
}

proc foreignDriverRequirers {path} {
    set bad {}
    foreach fn [driverRequirers $path] {
        set module [expr {[string first :: $fn] >= 0 ? [string range $fn 0 [expr {[string last :: $fn] - 1}]] : ""}]
        if {$module in $::libraries} { lappend bad $fn }
    }
    return $bad
}

if {[string match $::only s-library-drives] || [string match $::only audit]} {
    set flagged [foreignDriverRequirers [file join $::src s-library-drives.bot]]
    claim s-library-drives "accepted, but the audit reports the library function that drives the loop" \
        [expr {$flagged eq "drivinglib::settle"}] "flagged: $flagged"
}
if {$::only eq "*" || [string match $::only audit]} {
    set offenders {}
    foreach path [lsort [glob -directory $::src {[ab]-*.bot}]] {
        set bad [foreignDriverRequirers $path]
        if {$bad ne ""} { lappend offenders "[file tail $path]: $bad" }
    }
    claim audit "no library function in the experiments' programs requires the driver" \
        [expr {$offenders eq ""}] $offenders
}
