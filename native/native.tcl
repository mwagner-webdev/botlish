# native.tcl -- the Cranelift backend.
#
#   source native/native.tcl        ;# also loads compiler, hir and core
#   core::useBackend cranelift
#
# Pipeline:
#
#   HIR --native::lower (lower.tcl)--> NIR --botlish-native--> Cranelift IR
#       --> machine code (JIT) --> value
#
# The Rust driver native/target/release/botlish-native does the rest (build
# it with `cargo build --release` in native/). Each run is one process: the
# NIR goes in as a file, the value (as a core/value.tcl runtime value) or the
# error comes back on standard output. Only program mode is supported: a
# native program cannot run in, or return, a Tcl environment.
#
#   native::evalHir HIR ?OPTIONS?       runs a program-mode HIR program
#   native::nir HIR ?OPTIONS?           its NIR text
#   native::clif HIR ?OPTIONS?          the Cranelift IR of its functions
#   native::measure HIR RUNS ?OPTIONS?  {LOWER-US COMPILE-US BEST-US COLLECTIONS VALUE}
#   native::object HIR PATH ?OPTIONS?   writes an object file (AOT smoke test)
#   native::report HIR                  guard accounting and instance counts
#   native::codeSize HIR ?OPTIONS?      {TOTAL-BYTES {FUNCTION-BYTES ...}} of
#                                       the machine code
#
# OPTIONS are native::lower::program's: -specialize 0 lowers generic
# functions only (the guarded baseline; also BOTLISH_NATIVE_SPECIALIZE=0);
# -repr-opt 0 disables local unboxing of proven-small Int arithmetic
# (hir/range.tcl, native/lower.tcl's "Representation" section; also
# BOTLISH_NATIVE_REPR_OPT=0).
# Two backends are registered: cranelift (specializing, unless the
# environment variable says otherwise) and cranelift-generic (never
# specializing), so the suite and the corpus can run on both.
#
# Errors: Botlish errors keep their {CORE SEMANTIC KIND} codes. The backend's
# own failures are {NATIVE UNSUPPORTED ...} (a construct native lowering does
# not support, with its source location and HIR node), {NATIVE INVALID-NIR},
# {NATIVE CODEGEN} (Cranelift rejected the code), {NATIVE BUG},
# {NATIVE LIMIT STACK} and {NATIVE NOT-BUILT}.

if {[info commands ::core::compiler::evalHir] eq ""} {
    source [file join [file dirname [file dirname [file normalize [info script]]]] compiler compiler.tcl]
}
source [file join [file dirname [file normalize [info script]]] lower.tcl]

namespace eval native {
    variable home [file dirname [file normalize [info script]]]
    # EXPRS -> NIR text, for programs run through core::evalProgram.
    variable cache [dict create]
    # Unsupported-construct errors raised so far: {ERRORCODE MESSAGE}, and
    # the number of native runs (for coverage reports, tests/native-coverage.tcl).
    variable unsupported {}
    variable runs 0
}

proc native::binary {} {
    variable home
    set path [file join $home target release botlish-native]
    if {$::tcl_platform(platform) eq "windows"} {
        append path .exe
    }
    if {![file exists $path]} {
        throw {NATIVE NOT-BUILT} "native backend not built: run \"cargo build --release\" in $home"
    }
    return $path
}

# The NIR text of the program-mode HIR program HIR.
proc native::nir {hir args} {
    return [dict get [lowered $hir {*}$args] text]
}

# native::lower::program's result for HIR, recording unsupported constructs.
proc native::lowered {hir args} {
    variable unsupported
    try {
        return [native::lower::program $hir {*}$args]
    } trap {NATIVE UNSUPPORTED} {message options} {
        lappend unsupported [list [dict get $options -errorcode] $message]
        return -options $options $message
    }
}

# Runs the driver: botlish-native COMMAND NIR-FILE ARGS... Returns its output
# lines.
proc native::Driver {command nirText args} {
    variable runs
    set binary [binary]
    incr runs
    lassign [file tempfile path botlish.nir] channel
    fconfigure $channel -encoding utf-8 -translation lf
    puts -nonewline $channel $nirText
    close $channel
    try {
        set pipe [open |[list $binary $command {*}$args $path 2>@1] r]
        fconfigure $pipe -encoding utf-8 -translation lf
        set output [read $pipe]
        if {[catch {close $pipe} closeMessage]} {
            if {![regexp -line {^(value|error) } $output]} {
                throw {NATIVE BUG} "native backend failed: $closeMessage\n$output"
            }
        }
    } finally {
        file delete $path
    }
    return [split [string trimright $output \n] \n]
}

# The value of a run's output lines, or the error they report, raised.
proc native::Outcome {lines} {
    foreach line [lreverse $lines] {
        if {[catch {lindex $line 0} tag]} {
            continue
        }
        switch -- $tag {
            value {
                return [lindex $line 1]
            }
            error {
                lassign $line _ code message
                if {[lrange $code 0 1] eq {NATIVE UNSUPPORTED}} {
                    variable unsupported
                    lappend unsupported [list $code $message]
                }
                throw $code $message
            }
        }
    }
    throw {NATIVE BUG} "native backend produced no result:\n[join $lines \n]"
}

proc native::evalHir {hir args} {
    if {[hir::mode $hir] ne "program"} {
        error "native::evalHir: expected a program-mode HIR"
    }
    foreach expr [hir::lower $hir] {
        core::ir::check $expr
    }
    return [Outcome [Driver run [nir $hir {*}$args]]]
}

proc native::clif {hir args} {
    set lines [Driver clif [nir $hir {*}$args]]
    if {[regexp {^error } [lindex $lines 0]]} {
        Outcome $lines
    }
    return [join $lines \n]
}

proc native::measure {hir runs args} {
    set lower [lindex [time {set text [nir $hir {*}$args]}] 0]
    set lines [Driver bench $text $runs]
    set timing [lsearch -inline $lines {timing *}]
    set value [Outcome $lines]
    if {$timing eq ""} {
        throw {NATIVE BUG} "native backend produced no timing:\n[join $lines \n]"
    }
    lassign $timing _ compile best _ collections
    return [list $lower $compile $best $collections $value]
}

proc native::codeSize {hir args} {
    set lines [Driver size [nir $hir {*}$args]]
    set line [lsearch -inline $lines {size *}]
    if {$line eq ""} {
        Outcome $lines
    }
    return [lrange $line 1 2]
}

proc native::object {hir path args} {
    set lines [Driver object [nir $hir {*}$args] $path]
    if {[regexp {^error } [lindex $lines 0]]} {
        Outcome $lines
    }
    return [lindex $lines 0]
}

# Guard accounting for the program-mode HIR program HIR, specialized and
# generic. Returns a dict:
#
#   genericBlockers      representation blockers of the semantic analysis
#                        (hir::aot::analyze), over every region
#   generic              {blockers N guards N functions N} of the
#                        -specialize 0 lowering: its emitted functions'
#                        blockers and the kind guards emitted for them
#   specialized          {blockers N guards N functions N generic N
#                        specialized N perFunction {NAME {generic 0|1
#                        specializations N}}} of the specializing lowering
#   nirGuards            guard and guardbool instructions in the specialized
#                        NIR text, of which knownErrorGuards always fail
#
# Kind guards are emitted exactly for representation blockers, so for each
# lowering blockers == guards, and nirGuards == specialized guards +
# knownErrorGuards; a mismatch raises {NATIVE BUG}.
proc native::report {hir} {
    set result [dict create]
    set generic 0
    dict for {id region} [dict get [hir::aot::analyze $hir] regions] {
        foreach blocker [dict get $region blockers] {
            if {[dict get $blocker class] eq "representation"} {
                incr generic
            }
        }
    }
    dict set result genericBlockers $generic
    foreach {mode flag} {generic 0 specialized 1} {
        set lowered [lowered $hir -specialize $flag]
        set statistics [dict get $lowered statistics]
        if {[dict get $statistics blockers] != [dict get $statistics guards]} {
            throw {NATIVE BUG} "native::report: $mode lowering emitted [dict get $statistics guards] kind guard(s) for [dict get $statistics blockers] blocker(s)"
        }
        set knownErrorGuards 0
        foreach info [dict get $lowered functions] {
            incr knownErrorGuards [dict get $info knownErrorGuards]
        }
        set nirGuards [regexp -all -line {^\s+guard(bool)? } [dict get $lowered text]]
        if {$nirGuards != [dict get $statistics guards] + $knownErrorGuards} {
            throw {NATIVE BUG} "native::report: $mode NIR has $nirGuards guard(s), lowering counted [dict get $statistics guards] + $knownErrorGuards"
        }
        dict set result $mode $statistics
        if {$flag} {
            dict set result nirGuards $nirGuards
            dict set result knownErrorGuards $knownErrorGuards
        }
    }
    return $result
}

# ---------------------------------------------------------------------------
# Backend entry points (core::registerBackend)

proc native::runProgram {exprs env {specialize ""}} {
    variable cache
    set options [expr {$specialize eq "" ? {} : [list -specialize $specialize]}]
    set key [list $exprs $options [expr {[info exists ::env(BOTLISH_NATIVE_SPECIALIZE)] ? $::env(BOTLISH_NATIVE_SPECIALIZE) : ""}]]
    if {![dict exists $cache $key]} {
        dict set cache $key [nir [hir::build $exprs -strict 0] {*}$options]
    }
    return [core::completion::normal [Outcome [Driver run [dict get $cache $key]]]]
}

proc native::runSequence {exprs env} {
    variable unsupported
    set message "native backend: only checked programs can run natively; code run in an existing environment (core::evalIn) is not supported"
    lappend unsupported [list {NATIVE UNSUPPORTED sequence-mode} $message]
    throw {NATIVE UNSUPPORTED sequence-mode} $message
}

core::registerBackend cranelift native::runSequence native::runProgram
core::registerBackend cranelift-generic native::runSequence {native::runProgramWith 0}

proc native::runProgramWith {specialize exprs env} {
    return [runProgram $exprs $env $specialize]
}
