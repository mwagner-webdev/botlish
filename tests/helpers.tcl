# helpers.tcl -- shared test setup.

package require tcltest 2.5
namespace import -force ::tcltest::*

set ::projectRoot [file dirname [file dirname [file normalize [info script]]]]
source [file join $::projectRoot compiler compiler.tcl]
source [file join $::projectRoot native native.tcl]

# ---------------------------------------------------------------------------
# Test-only native backends (DIRECT-HIR-NATIVE-PATH.md).
#
# core::registerBackend backends run core IR: the Tcl interpreter and the Tcl
# compiler. Native compilation starts from HIR (native::evalHir) and has no
# core IR entry point, so native/ registers no backend. Most tests are written
# as core IR text -- or lower a source/HIR program with hir::lower to get the
# text -- and run on every backend through core::evalProgram; to keep native
# coverage of them, the *test harness* registers "cranelift" and
# "cranelift-generic" here. Native compiles HIR, so:
#
#   * a program that hir::lower produced is compiled from the very HIR it was
#     lowered from (remembered below by the lowered text): the differential
#     "HIR -> core IR -> interpreter" against "HIR -> NIR -> native" of one
#     HIR. Native never sees, and never rebuilds HIR from, that core IR;
#   * any other program is hand-written core IR text (a test of core IR, or
#     the frozen bench/*.ir): hir::build reads it into HIR -- the same
#     builder that gives the compile backend its HIR: reading core IR text is
#     HIR construction, not native compilation of core IR.
#
# Tests that start from source or HIR and are about native behavior should
# call outcomeUnderHir (below) with the HIR itself.
set ::hirOfLowered [dict create]
proc ::RecordLowered {command code result args} {
    dict set ::hirOfLowered $result [lindex $command 1]
}
trace add execution hir::lower leave ::RecordLowered

proc ::testNativeHir {exprs} {
    if {[dict exists $::hirOfLowered $exprs]} {
        return [dict get $::hirOfLowered $exprs]
    }
    return [hir::build $exprs -strict 0]
}

proc ::testNativeProgram {specialize exprs env} {
    set options [expr {$specialize eq "" ? {} : [list -specialize $specialize]}]
    return [core::completion::normal [native::evalHir [testNativeHir $exprs] {*}$options]]
}

proc ::testNativeSequence {exprs env} {
    set message "native backend: only checked programs can run natively; code run in an existing environment (core::evalIn) is not supported"
    lappend native::unsupported [list {NATIVE UNSUPPORTED sequence-mode} $message]
    throw {NATIVE UNSUPPORTED sequence-mode} $message
}

core::registerBackend cranelift ::testNativeSequence {::testNativeProgram {}}
core::registerBackend cranelift-generic ::testNativeSequence {::testNativeProgram 0}

# Compiler warnings (hir/warnings.tcl, WARNINGS-SAME-RETURN.md): a test that is
# not about warnings must not write them to stderr (tcltest counts that as a
# test-file error, and `exec main.tcl` fails on it), so the harness's process
# default is `off`. It is only the *default* for a compilation given no
# -warnings option -- and, through the environment, for the main.tcl children
# the executable tests spawn. tests/warnings.test passes its policy explicitly
# on every compile, so it exercises default, off and error regardless; the
# user-facing default mode is also exercised by its main.tcl cases (which pass
# -warnings explicitly) and by CI's plain `main.tcl` corpus runs.
if {![info exists ::env(BOTLISH_WARNINGS)]} {
    set ::env(BOTLISH_WARNINGS) off
}

# The backend under test: CORE_BACKEND=interp (default), compile or cranelift.
if {[info exists ::env(CORE_BACKEND)]} {
    core::useBackend $::env(CORE_BACKEND)
}

# Core IR scoping. The interpreter's scopes declare every name they bind on
# entry (core/evaluator.tcl), so a name denotes its scope's binding even
# before that bind runs, and a closure may read a binding made later in its
# scope (recursion between later bindings). HIR resolves sequentially (a
# binding is visible from where it is established, hir/resolve.tcl;
# STRICT-REFERENCE-DETERMINISM.md), so the backends compiled from HIR do not
# implement these Core IR behaviors: a reference to a binding not established
# yet is an unbound-name error there. Tests of the Core IR semantics
# themselves run on the interpreter only.
testConstraint coreScoping [expr {[core::useBackend] eq "interp"}]

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
# where LOG is what test-log recorded. V includes the full representation
# of a value of an opaque struct (core::value::show's REVEAL: this is internal
# differential tooling, not user-facing text, OPAQUE-STRUCTS.md).
#
# cranelift-generic (native -specialize 0) compiles every function once, so it
# has no slot for a struct projection that only a semantic instance proves
# (`fn first(x): x.value`; STRUCTS.md, "Known limitations"): it reports
# {NATIVE UNSUPPORTED struct-shape}. For such a program the unspecialized
# baseline is undefined rather than wrong, and the outcome of `cranelift`
# stands in for it; ::genericBaselineStandIns counts the substitutions, and
# tests/structs.test pins which corpus programs are in that class.
set genericBaselineStandIns 0
proc GenericBaselineUndefined {backend outcome} {
    return [expr {$backend eq "cranelift-generic" && [lindex $outcome 0] eq "error"
        && [lindex $outcome 1] eq "NATIVE UNSUPPORTED struct-shape"}]
}

proc outcomeUnder {backend exprs} {
    set saved [core::useBackend]
    core::useBackend $backend
    resetEffects
    try {
        if {[catch {core::evalProgram $exprs} result options]} {
            set outcome [list error [dict get $options -errorcode] $result $::testLog]
            if {[GenericBaselineUndefined $backend $outcome]} {
                incr ::genericBaselineStandIns
                return [outcomeUnder cranelift $exprs]
            }
            return $outcome
        }
        return [list value [core::value::show $result 1 1] $::testLog]
    } finally {
        core::useBackend $saved
    }
}

# Outcome of the HIR program HIR under BACKEND, in outcomeUnder's shape. The
# native backends compile the HIR itself; interp and compile run the core IR
# it lowers to (the reference branch), so a program's HIR feeds each consumer
# directly and native never sees core IR.
proc outcomeUnderHir {backend hir} {
    if {$backend ni {cranelift cranelift-generic}} {
        return [outcomeUnder $backend [hir::lower $hir]]
    }
    set options [expr {$backend eq "cranelift-generic" ? {-specialize 0} : {}}]
    resetEffects
    if {[catch {native::evalHir $hir {*}$options} result options]} {
        set outcome [list error [dict get $options -errorcode] $result $::testLog]
        if {[GenericBaselineUndefined $backend $outcome]} {
            incr ::genericBaselineStandIns
            return [outcomeUnderHir cranelift $hir]
        }
        return $outcome
    }
    return [list value [core::value::show $result 1 1] $::testLog]
}

# The HIR native lowering compiles for a program written as core IR text
# EXPRS: hir::build reads the text (HIR construction, as for the compile
# backend) and native::prepareHir prepares it as every native entry point does.
# For tests of native behavior on hand-written core IR; a source or HIR
# program passes its own HIR to native instead.
proc nativeHirOfIR {exprs} {
    return [native::prepareHir [hir::build $exprs -strict 0]]
}

# The outcome (outcomeUnderHir's shape, minus the test log) of the Botlish
# source program SOURCE, compiled once, on every backend of BACKENDS -- or a
# Tcl error naming every backend's outcome when they do not all agree. A
# compile error is the outcome {error ERRORCODE MESSAGE} on every backend.
proc sourceAgree {source {backends {interp compile cranelift-generic cranelift}}} {
    if {[catch {surface::compile $source -warnings off} hir options]} {
        return [list error [dict get $options -errorcode] $hir]
    }
    set outcomes [lmap b $backends {lrange [outcomeUnderHir $b $hir] 0 end-1}]
    if {[llength [lsort -unique $outcomes]] != 1} {
        error "mismatch across $backends: $outcomes"
    }
    return [lindex $outcomes 0]
}

# The HIR of bench/refined-checks.bot, the canonical repeated-refinement-
# predicate workload (REFINEMENT-VALUES.md), as every backend compiles it.
proc refinedChecksSourceHir {} {
    return [surface::readProgramFile [file join $::projectRoot bench refined-checks.bot] -warnings off]
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

if {"test-log" ni [core::native::names]} {
    core::registerNative test-log  -arity 1 -impl testLogImpl
    core::registerNative test-tick -arity 0 -impl testTickImpl

    # A validator type on str for the type-lattice and contract tests (a
    # structural, runtime-checked named type: core/type.tcl), with its
    # type-test predicate NonEmpty?.
    core::type::register NonEmpty -base str \
        -validator {apply {{v} {expr {[string length [core::value::strOf $v]] > 0}}}}
    core::type::definePredicate NonEmpty

    # A native that breaks its declared contract: it claims to return a
    # NonEmpty but returns its argument, which may be "".
    core::registerNative test-fake-nonempty -arity 1 \
        -impl {apply {{v} {return $v}}} \
        -param-types {str} -result-type NonEmpty

    # A native whose implementation does not enforce its declared parameter.
    core::registerNative test-lax-param -arity 1 \
        -impl {apply {{v} {core::value::int 1}}} \
        -param-types {NonEmpty} -result-type int
}

# SOURCE with an `import NS` header line for every standard namespace it
# qualifies a name with (and does not already import). For tests about proofs
# and code generation, which build many small programs from fragments and care
# about the program's behavior, not its header (tests/imports.test covers the
# header itself).
proc withImports {source} {
    set header ""
    foreach ns {abi::x86_64 abi ascii byte char immutable_set list mutable_array str web} {
        if {[regexp -- "(^|\[^A-Za-z0-9_:\])${ns}::" $source] && ![regexp -- "(^|\n)import ${ns}(\n|\$)" $source]} {
            append header "import $ns\n"
        }
    }
    return $header$source
}
