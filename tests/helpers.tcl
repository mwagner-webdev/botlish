# helpers.tcl -- shared test setup.

package require tcltest 2.5
namespace import -force ::tcltest::*

set ::projectRoot [file dirname [file dirname [file normalize [info script]]]]
source [file join $::projectRoot compiler compiler.tcl]
source [file join $::projectRoot native native.tcl]

# ---------------------------------------------------------------------------
# Test-only backends that compile HIR (DIRECT-HIR-NATIVE-PATH.md).
#
# core::registerBackend backends run core IR: the Tcl interpreter, and the
# Tcl compiler for core IR *text*. Both compilers compile HIR: native has no
# core IR entry point at all (native::evalHir; native/ registers no backend),
# and the Tcl compiler compiles a front end's HIR itself
# (core::compiler::evalHir). Most tests are written as core IR text -- or
# lower a source/HIR program with hir::lower to get the text -- and run on
# every backend through core::evalProgram; to keep that coverage, the *test
# harness* registers "cranelift" and "cranelift-generic" here and replaces
# "compile" with an adapter. Both compilers compile HIR, so:
#
#   * a program that hir::lower produced is compiled from the very HIR it was
#     lowered from (remembered below by the lowered text): the differential
#     "HIR -> core IR -> interpreter" against "HIR -> Tcl" and "HIR -> NIR ->
#     native" of one HIR. Neither compiler sees, or rebuilds HIR from, that
#     core IR;
#   * any other program is hand-written core IR text (a test of core IR, or
#     the frozen bench/*.ir): hir::build reads it into HIR, which is HIR
#     construction from an input notation, not a rebuild.
#
# Tests that start from source or HIR should call outcomeUnderHir (below)
# with the HIR itself.
set ::hirOfLowered [dict create]
proc ::RecordLowered {command code result args} {
    dict set ::hirOfLowered $result [lindex $command 1]
}
trace add execution hir::lower leave ::RecordLowered

proc ::testCompileProgram {exprs env} {
    if {[dict exists $::hirOfLowered $exprs]} {
        set hir [dict get $::hirOfLowered $exprs]
        if {[hir::mode $hir] eq "program"} {
            return [core::compiler::runUnit [core::compiler::compileHir $hir] $env]
        }
    }
    return [core::compiler::runProgram $exprs $env]
}

core::registerBackend compile core::compiler::runSequence ::testCompileProgram

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

# The front-end cache (surface/cache.tcl, HIR-INTERCHANGE.md) is a host's
# opt-in: a developer's BOTLISH_HIR_CACHE must not decide what a test
# compiles (build counts, warnings printed, a stale fixture), here or in the
# main.tcl children tests spawn. tests/hir-cache.test passes -cache itself.
unset -nocomplain ::env(BOTLISH_HIR_CACHE)

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

# Standalone executables (native::executable) are linked by
# BOTLISH_NATIVE_LINKER (native/src/codegen/aot.rs, SINGLE-EXECUTABLE.md):
# `rustc` (the default) or `stub`. A rustc-linked executable carries the
# program's machine code as an ELF section with a botlish_fn_N symbol per
# function, which tests disassemble (objdump) or find in stack traces
# (strace -k); a stub-linked one maps that code at startup and has no such
# symbols. Those tests, and tests of rustc's own invocation, need rustcLinker.
# CI's stub-linker job runs every executable test with the stub linker.
testConstraint rustcLinker [expr {![info exists ::env(BOTLISH_NATIVE_LINKER)] ||
    $::env(BOTLISH_NATIVE_LINKER) in {"" rustc}}]

# Native coroutines (runtime/coroutine.rs, MACOS-AARCH64-MILESTONE-3.md): the
# native backend switches stacks on Linux x86-64 and AArch64 and on macOS
# AArch64. A capability, not an operating system: a test that needs coroutines
# or the native collector and runtime evidence around them carries this one;
# a test that needs Linux syscalls keeps nativeLinux.
testConstraint nativeCoroutines [native::hostSupports coroutines]

# The native stack guard (runtime/platform/, MACOS-AARCH64-MILESTONE-4.md,
# WINDOWS-X86-64-MILESTONE-4.md): the runtime knows the bounds of the
# thread's stack and of every coroutine stack, and a native run that
# exhausts one -- the thread's or a coroutine's, in Botlish code, the
# runtime or C -- ends in NATIVE LIMIT STACK, with stack probes and no
# shadow-stack depth token. A capability, not an operating system: Linux
# x86-64 and AArch64, macOS AArch64 and Windows x86-64 (a coroutine's stack
# only where nativeCoroutines is true too).
testConstraint nativeStackGuard [native::hostSupports stackGuard]

# GC roots in native frames (runtime/framewalk.rs's NATIVE_FRAME_ROOTS,
# WINDOWS-X86-64-MILESTONE-1.md, section 3; -3.md): stack maps and the frame
# walk on Linux x86-64 and AArch64, macOS AArch64 and Windows x86-64 (there
# with Windows' unwinder across Rust frames); the fallback plan's shadow stack
# where a `fallback-roots` driver runs. A test of the root plan expects the
# host's plan by it.
testConstraint nativeFrameRoots [native::hostSupports frameRoots]

# A depth check bounds Botlish recursion (runtime::native_stack::depth_checked):
# unless native frames hold the roots and the stack guard reports an exhausted
# stack -- on the fallback plan, where the shadow stack's end is the bound
# (on Windows until WINDOWS-X86-64-MILESTONE-4.md, also a check of the stack
# pointer). Every function with a Botlish call then fails with NATIVE LIMIT
# STACK from its prologue, which nir's call effects record as may_error: a
# test of a call's effects expects it by this.
testConstraint nativeDepthChecked [expr {!([testConstraint nativeFrameRoots] && [testConstraint nativeStackGuard])}]

# Standalone executables (native::executable, native/src/codegen/aot.rs): the
# native backend links them on Linux x86-64 and AArch64 (ELF), on macOS
# AArch64 (Mach-O, MACOS-AARCH64-MILESTONE-5.md) and on Windows x86-64 with
# MSVC's toolchain (PE, named NAME.exe: WINDOWS-X86-64-MILESTONE-1.md), with
# the rustc linker everywhere and the stub linker on Linux x86-64 too. A
# capability, not an operating system: a test that builds and runs an
# executable of a portable program carries this one (and runs the file
# native::executable returns); one whose program needs Linux syscalls keeps
# nativeLinux, one that reads ELF or needs the stub linker its own
# constraint, one that starts the executable through a Unix shell
# (`exec -a`, `env -i`) unixShell, and a program that calls C carries
# nativeCCalls.
testConstraint executableAot [native::hostSupports executables]

# A Unix shell for scripts the tests write and run (`#!/bin/sh` wrappers, `sh
# -c`): a test that needs one carries this, never an operating system.
testConstraint unixShell [expr {$::tcl_platform(platform) eq "unix" && [auto_execok sh] ne ""}]

# Runs the standalone executable linked for PATH (native::executableFile:
# PATH.exe on Windows) with PATH empty -- no toolchain or interpreter
# launcher on it -- and the extra environment NAME VALUE ..., as `exec env
# PATH= NAME=VALUE ... PATH` runs it on Unix, on any host (Windows has no
# env): its standard output, as exec returns it. The environment is this
# process's again afterwards.
proc runStandalone {path args} {
    set names [concat PATH [dict keys $args]]
    set saved [dict create]
    foreach name $names {
        if {[info exists ::env($name)]} { dict set saved $name $::env($name) }
    }
    try {
        set ::env(PATH) ""
        foreach {name value} $args { set ::env($name) $value }
        return [exec [native::executableFile $path]]
    } finally {
        foreach name $names { unset -nocomplain ::env($name) }
        dict for {name value} $saved { set ::env($name) $value }
    }
}

# Evaluates SCRIPT in the caller with the environment variables NAME VALUE
# ... of PAIRS set, as `env NAME=VALUE ... COMMAND` runs a command on Unix,
# on any host (Windows has no env): its result; the environment is this
# process's again afterwards.
proc withEnvironment {pairs script} {
    set saved [dict create]
    foreach {name value} $pairs {
        if {![dict exists $saved $name]} { dict set saved $name [array get ::env $name] }
        set ::env($name) $value
    }
    try {
        return [uplevel 1 $script]
    } finally {
        dict for {name value} $saved {
            if {$value eq ""} { unset -nocomplain ::env($name) } else { set ::env($name) [lindex $value 1] }
        }
    }
}

# Runs the executable FILE (the path native::executable returned) with no
# environment and nothing to find on PATH -- `env -i PATH=/nonexistent FILE`
# on Unix; on Windows, which has no env, with PATH empty (runStandalone):
# its standard output, as exec returns it.
proc runBare {file} {
    if {$::tcl_platform(platform) eq "windows"} {
        return [runStandalone $file]
    }
    return [exec env -i PATH=/nonexistent $file]
}

# C calls (extern c fn, C-FFI.md): the native backends link a program that
# calls C with the system linker and its declared libraries and run it, on
# Linux x86-64 and AArch64 (GNU ld's link plan, the SysV and AAPCS64 C ABIs),
# on macOS AArch64 (Apple's ld, the Apple arm64 C ABI,
# MACOS-AARCH64-MILESTONE-6.md) and on Windows x86-64 (link.exe, the Win64 C
# ABI, WINDOWS-X86-64-MILESTONE-2.md): codegen/aot.rs's C_CALLS. A
# capability, not an operating system: a test that links and runs a C
# fixture carries this one (and its fixture's own constraint: the host's C
# toolchain, cToolchain below, and the rustc linker).
testConstraint nativeCCalls [native::hostSupports cCalls]

# Variadic C calls (VARIADICS-VERTICAL-SLICE-1.md): lowered for the System V
# and Apple AArch64 C conventions only; on Windows x86-64 a variadic call is
# a codegen error. A test that compiles one to machine code, or runs one,
# carries this beside nativeCCalls.
testConstraint nativeCVariadics [native::hostSupports cVariadics]

# The host's own C toolchain, the one C fixtures are built with
# (tests/ctoolchain.tcl): cc and ar on Linux and macOS, MSVC's cl, ml64 and
# lib on Windows (found through vswhere, used in vcvars64's environment for
# those tools alone -- never for Botlish's own link).
source [file join $::projectRoot tests ctoolchain.tcl]
testConstraint cToolchain [ctool::available]

# The host target's C data model is LP64 (a C long and a pointer 64 bits:
# Linux, macOS), not Windows' LLP64 (a 32-bit long): a C oracle whose record
# layout holds a long (native-view's, native-edit's) is LP64's.
testConstraint lp64Target [expr {[core::cabi::hostTarget] ne ""
    && [dict get [core::cabi::target [core::cabi::hostTarget]] model] eq "LP64"}]

# The system C library is a dynamic library an executable imports its
# functions from (glibc, libSystem): a test that reads an executable's
# imports of it carries this. On Windows the C runtime is linked into every
# executable (codegen/aot.rs's crt_args): nothing is imported from one.
testConstraint dynamicSystemCLibrary [expr {$::tcl_platform(platform) ne "windows"}]

# Darwin I/O (stdlib/darwin.bot, stdlib/darwin/io.bot, MACOS-AARCH64-MILESTONE-8.md):
# the std::darwin namespace is this host's platform interface (core/cabi.tcl's
# platforms designates it macOS's) and the native backend links C calls here,
# so libSystem's read and write run: macOS arm64 today. A capability read from
# the target table, never from the operating system's name: a test that runs
# a program importing std::darwin::* carries it.
testConstraint darwinIO [expr {[core::cabi::hostTarget] ne "" && [testConstraint nativeCCalls]
    && [core::cabi::platformOf std::darwin] eq [dict get [core::cabi::target [core::cabi::hostTarget]] os]}]

# Windows I/O (stdlib/windows.bot, stdlib/windows/io.bot, WINDOWS-X86-64-MILESTONE-2.md):
# the std::windows namespace is this host's platform interface (core/cabi.tcl's
# platforms designates it Windows') and the native backend links C calls
# here, so kernel32's GetStdHandle and WriteFile run: Windows x86-64 today. A
# capability read from the target table, never from the operating system's
# name: a test that runs a program importing std::windows::* carries it.
testConstraint windowsIO [expr {[core::cabi::hostTarget] ne "" && [testConstraint nativeCCalls]
    && [core::cabi::platformOf std::windows] eq [dict get [core::cabi::target [core::cabi::hostTarget]] os]}]

# binaryHeader PATH and hostBinaryHeader KIND: what a program object or an
# executable is, and what this host's are.
source [file join $::projectRoot tests binary-header.tcl]

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

# Local runs (tests/local.tcl; AGENTS.md, "Running the tests locally"):
# BOTLISH_SKIP_GOLDEN_DUPLICATES=1 skips every Tcl test whose whole theorem a
# golden test carries -- the manifest's freeze class FROZEN-DUPLICATE-ORACLE
# (tests/golden/manifest.tsv; LARGE-SCALE-GOLDEN-MIGRATION.md, "Freeze
# classification") -- because the golden suites run in its place. Such a
# test is reported skipped, by the constraint goldenDuplicate. A test is
# skipped only when every manifest row of it (its file and name) is in that
# class. CI never sets the variable: every Tcl test runs there
# (tests/golden-duplicates.test pins both).

# The skipped tests: a dict {FILE NAME} -> 1, FILE a test file's tail.
proc ::GoldenDuplicates {} {
    set channel [open [file join $::projectRoot tests golden manifest.tsv] r]
    fconfigure $channel -encoding utf-8
    set header [split [gets $channel] \t]
    set text [read $channel]
    close $channel
    set fileColumn [lsearch -exact $header old_file]
    set nameColumn [lsearch -exact $header old_test]
    set freezeColumn [lsearch -exact $header freeze]
    set duplicated [dict create]
    set active [dict create]
    foreach line [split $text \n] {
        if {$line eq ""} continue
        set row [split $line \t]
        set key [list [file tail [lindex $row $fileColumn]] [lindex $row $nameColumn]]
        if {[lindex $row $freezeColumn] eq "FROZEN-DUPLICATE-ORACLE"} {
            dict set duplicated $key 1
        } else {
            dict set active $key 1
        }
    }
    foreach key [dict keys $active] {
        dict unset duplicated $key
    }
    return $duplicated
}
if {[info exists ::env(BOTLISH_SKIP_GOLDEN_DUPLICATES)]
        && $::env(BOTLISH_SKIP_GOLDEN_DUPLICATES) ni {"" 0}
        && [info commands ::GoldenDuplicateTest] eq ""} {
    testConstraint goldenDuplicate 0
    # (Read at the first test.)
    unset -nocomplain ::goldenDuplicates
    # The test command the others go to (the coverage wrapper's, when on).
    set ::goldenDuplicateNext [expr {[info commands ::CoverageTest] ne ""
        ? "::CoverageTest" : "::tcltest::test"}]
    proc ::GoldenDuplicateTest {name args} {
        if {![info exists ::goldenDuplicates]} {
            set ::goldenDuplicates [::GoldenDuplicates]
        }
        # (info script: the test file being run, standalone or sourced.)
        if {[dict exists $::goldenDuplicates [list [file tail [info script]] $name]]} {
            return [uplevel 1 [list ::tcltest::test $name "ported to a golden test" \
                -constraints goldenDuplicate -body {}]]
        }
        return [uplevel 1 [list $::goldenDuplicateNext $name {*}$args]]
    }
    rename ::test {}
    interp alias {} ::test {} ::GoldenDuplicateTest
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
# Tcl compiler and the native backends compile the HIR itself; the
# interpreter runs the core IR it lowers to (the reference branch), so a
# program's HIR feeds each consumer directly and neither compiler sees core IR.
proc outcomeUnderHir {backend hir} {
    if {$backend eq "interp"} {
        return [outcomeUnder $backend [hir::lower $hir]]
    }
    set options [expr {$backend eq "cranelift-generic" ? {-specialize 0} : {}}]
    resetEffects
    if {[catch {
        if {$backend eq "compile"} {
            core::compiler::evalHir $hir
        } else {
            native::evalHir $hir {*}$options
        }
    } result options]} {
        set outcome [list error [dict get $options -errorcode] $result $::testLog]
        if {[GenericBaselineUndefined $backend $outcome]} {
            incr ::genericBaselineStandIns
            return [outcomeUnderHir cranelift $hir]
        }
        return $outcome
    }
    return [list value [core::value::show $result 1 1] $::testLog]
}

# The C ABI target a test compiles a Linux program for -- one that imports the
# Linux platform's namespaces (linux::*), which a compilation for a target of
# another operating system refuses (UNSUPPORTED-PLATFORM): on a Linux host
# the host's own target, exactly the default; on another host (macOS arm64)
# the Linux target of its architecture (core::cabi::systemTarget). There the
# program runs on the Tcl backends only (backendsFor).
proc linuxTarget {} {
    return [core::cabi::systemTarget linux]
}

# Of BACKENDS (default all four), the ones that run a program built for
# TARGET on this host: every one for the host's own target (or ""), the Tcl
# backends only for another (a native backend refuses a program built for a
# target other than its host's: NATIVE TARGET).
proc backendsFor {target {backends {interp compile cranelift-generic cranelift}}} {
    if {$target eq "" || $target eq [core::cabi::hostTarget]} {
        return $backends
    }
    return [lmap b $backends {expr {$b in {interp compile} ? $b : [continue]}}]
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
    # structural, runtime-checked named type: core/type.tcl), and a native
    # registered as its type test, non_empty? (-tests-type: the mechanism of
    # ok?/error?). The test is a registration of its own: a type never
    # brings a predicate (ELIMINATE-AUTOMATIC-TYPE-PREDICATES.md).
    core::type::register NonEmpty -base str \
        -validator {apply {{v} {expr {[string length [core::value::strOf $v]] > 0}}}}
    core::registerNative non_empty? -arity 1 \
        -impl {apply {{v} {core::value::bool [core::type::validate NonEmpty $v]}}} \
        -param-types str -tests-type NonEmpty

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
    foreach ns {std::abi::x86_64 std::abi std::ascii std::byte std::char std::immutable_set std::list std::mutable_array std::str std::web} {
        if {[regexp -- "(^|\[^A-Za-z0-9_:\])${ns}::" $source] && ![regexp -- "(^|\n)import ${ns}(\n|\$)" $source]} {
            append header "import $ns\n"
        }
    }
    return $header$source
}

# Runs SCRIPT in the caller's scope with $::core::libraryDir pointed at a
# private copy of the library (every module and subdirectory of the current
# one), restoring it afterwards. A test that needs a throwaway module next to
# the standard ones writes it there, never into the real stdlib/: runs in one
# checkout share stdlib/, so a fixed module name there makes concurrent runs
# delete each other's module, and a run cut short leaves it behind. The copy
# is a tcltest temporary directory, named per process so runs that share a
# -tmpdir do not collide either.
proc withPrivateLibrary {script} {
    set saved $::core::libraryDir
    set name private-lib-[pid]-[incr ::privateLibraryCounter]
    set dir [makeDirectory $name]
    foreach entry [glob -nocomplain -directory $saved *] {
        file copy -force $entry $dir
    }
    set ::core::libraryDir $dir
    try {
        uplevel 1 $script
    } finally {
        set ::core::libraryDir $saved
        removeDirectory $name
    }
}
set ::privateLibraryCounter 0
