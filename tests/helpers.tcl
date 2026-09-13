# helpers.tcl -- shared test setup.

package require tcltest 2.5
namespace import -force ::tcltest::*

set ::projectRoot [file dirname [file dirname [file normalize [info script]]]]
source [file join $::projectRoot compiler compiler.tcl]
source [file join $::projectRoot native native.tcl]

# The backend under test: CORE_BACKEND=interp (default), compile or cranelift.
if {[info exists ::env(CORE_BACKEND)]} {
    core::useBackend $::env(CORE_BACKEND)
}

# Native coverage (tests/native-coverage.tcl): NATIVE_COVERAGE=FILE appends
# one line per test: {NAME PASSED NATIVE-RUNS UNSUPPORTED-ERRORS}.
if {[info exists ::env(NATIVE_COVERAGE)] && [info commands ::CoverageTest] eq ""} {
    proc ::CoverageTest {name args} {
        set native::unsupported {}
        set native::runs 0
        set failedBefore $::tcltest::numTests(Failed)
        uplevel 1 [list ::tcltest::test $name {*}$args]
        set passed [expr {$::tcltest::numTests(Failed) == $failedBefore}]
        set channel [open $::env(NATIVE_COVERAGE) a]
        fconfigure $channel -encoding utf-8
        puts $channel [list $name $passed $native::runs $native::unsupported]
        close $channel
    }
    rename ::test {}
    interp alias {} ::test {} ::CoverageTest
}

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

# Outcome of EXPRS under BACKEND: {value V LOG} or {error ERRORCODE MESSAGE LOG},
# where LOG is what test-log recorded. V includes runtime evidence, so the
# backends must also agree on what values are proven to be.
proc outcomeUnder {backend exprs} {
    set saved [core::useBackend]
    core::useBackend $backend
    resetEffects
    try {
        if {[catch {core::evalProgram $exprs} result options]} {
            return [list error [dict get $options -errorcode] $result $::testLog]
        }
        return [list value [core::value::show $result 1] $::testLog]
    } finally {
        core::useBackend $saved
    }
}

# "same" if both backends produce the same outcome; otherwise both outcomes.
proc differential {exprs} {
    set a [outcomeUnder interp $exprs]
    set b [outcomeUnder compile $exprs]
    if {$a ne $b} {
        return "interp: $a / compile: $b"
    }
    return same
}

# ---------------------------------------------------------------------------
# HIR

# The HIR of a program given as expressions (non-strict: diagnostics kept).
proc hirOf {args} {
    return [hir::build $args -strict 0]
}

# ExprIds of kind KIND (and, if given, spelling NAME), in pre-order.
proc hirFind {hir kind {name ""}} {
    set result {}
    foreach e [hir::walk $hir] {
        if {[hir::kind $hir $e] ne $kind} {
            continue
        }
        if {$name ne "" && (![dict exists [hir::node $hir $e] name]
                            || [hir::get $hir $e name] ne $name)} {
            continue
        }
        lappend result $e
    }
    return $result
}

# The binding each reference to NAME resolves to, in pre-order.
proc hirRefBindings {hir name} {
    return [lmap e [hirFind $hir ref $name] {hir::get $hir $e binding}]
}

# Shown types of the references to NAME, in pre-order.
proc hirRefTypes {hir name} {
    return [lmap e [hirFind $hir ref $name] {hir::types::show [hir::typeOf $hir $e]}]
}

# NODE with canonical Tcl list quoting, for comparing IR structurally.
proc canonicalIR {node} {
    set op [lindex $node 0]
    switch -- $op {
        const - ref - continue {
            return [list {*}$node]
        }
        bind {
            return [list bind [lindex $node 1] [canonicalIR [lindex $node 2]]]
        }
        block {
            return [list block [list {*}[lindex $node 1]] \
                {*}[lmap e [lrange $node 2 end] {canonicalIR $e}]]
        }
        call - return - break - ok - error-value - if - loop {
            return [list $op {*}[lmap e [lrange $node 1 end] {canonicalIR $e}]]
        }
    }
    error "canonicalIR: unknown node $node"
}

proc canonicalProgram {exprs} {
    return [lmap e $exprs {canonicalIR $e}]
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

# The refined-type tests use the optional web library.
core::loadLibrary web

if {"test-log" ni [core::native::names]} {
    core::registerNative test-log  -arity 1 -impl testLogImpl
    core::registerNative test-tick -arity 0 -impl testTickImpl

    # A second validator type on str, to combine evidence with Emailish.
    core::type::register NonEmpty -base str \
        -validator {apply {{v} {expr {[string length [core::value::strOf $v]] > 0}}}}
    core::type::definePredicate NonEmpty

    # A native that breaks its declared contract: it claims to return a
    # UriQueryValue but returns a plain string.
    core::registerNative test-fake-escape -arity 1 \
        -impl {apply {{v} {return $v}}} \
        -param-types {str} -result-type UriQueryValue

    # A native whose implementation does not enforce its declared parameter.
    core::registerNative test-lax-param -arity 1 \
        -impl {apply {{v} {core::value::int 1}}} \
        -param-types {Emailish} -result-type int
}
