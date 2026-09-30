# native.tcl -- the Cranelift backend.
#
#   source native/native.tcl        ;# also loads compiler, hir and core
#   native::evalHir $hir            ;# the JIT: run a program
#
# Pipeline (DIRECT-HIR-NATIVE-PATH.md):
#
#   source --surface--> resolved + analyzed HIR
#       --native::prepareHir--> HIR with native implementations attached
#       --native::lowered (native::lower::program, lower.tcl)--> NIR
#       --botlish-native--> Cranelift IR --> machine code (JIT / object /
#                                            standalone executable) --> value
#
# HIR is the semantic representation and NIR the executable one. Core IR is
# never on this path: it is the Tcl reference interpreter's representation
# (hir::lower --> core::evalProgram), a sibling consumer of the same HIR, and
# no native entry point calls hir::lower or accepts Core IR. A native entry
# point takes HIR that a front end has already built (surface::readProgramFile,
# surface::compile, hir::readFile, or hir::build for a program written in core
# IR text -- reading that text is HIR construction, not native compilation),
# and it never rebuilds, re-resolves or re-types that HIR: types, semantic
# instances, contracts and refinements are the front end's (hir::check, run by
# hir::buildSyntax); specialization, ranges, escape, string-region, block-
# escape, traversal and construction analyses are run once by
# native::lower::program on that HIR. See "Analysis ownership" in
# DIRECT-HIR-NATIVE-PATH.md. The one exception is native::prepareHir, which
# adds a native's module implementation to the HIR and re-checks it.
#
# The Rust driver native/target/release/botlish-native does the rest (build
# it with `cargo build --release` in native/). Each run is one process: the
# NIR goes in as a file, the value (as a core/value.tcl runtime value) or the
# error comes back on standard output. Only program mode is supported: a
# native program cannot run in, or return, a Tcl environment.
#
#   native::prepareHir HIR              HIR with native implementations attached
#   native::lowered HIR ?OPTIONS?       HIR -> NIR, the one HIR->NIR entry point
#                                       (a dict: text, functions, statistics)
#   native::evalHir HIR ?OPTIONS?       runs a program-mode HIR program
#   native::nir HIR ?OPTIONS?           its NIR text
#   native::clif HIR ?OPTIONS?          the Cranelift IR of its functions
#   native::measure HIR RUNS ?OPTIONS?  {LOWER-US COMPILE-US BEST-US COLLECTIONS VALUE}
#                                       BEST-US is fractional (nanosecond-
#                                       derived) microseconds, not truncated
#                                       to a whole number
#   native::object HIR PATH ?OPTIONS?   writes an object file (AOT smoke test)
#   native::executable HIR PATH ?OPTIONS?  links a standalone Linux x86_64/glibc
#                                         executable; rejects non-closed HIR
#   native::report HIR                  guard accounting and instance counts
#   native::codeSize HIR ?OPTIONS?      {TOTAL-BYTES {FUNCTION-BYTES ...}} of
#                                       the machine code
#   native::allocationReport HIR MODE ?RUNS? ?OPTIONS?
#                                       allocation instrumentation report (a
#                                       dict; runtime/src/runtime/metrics.rs's
#                                       Metrics::to_tcl); MODE is summary or
#                                       sites. native::allocationText REPORT
#                                       renders it for humans.
#                                       native::assertAllocations HIR N
#                                       ?OPTIONS?, assertAllocationsAtMost,
#                                       assertBytesAtMost and
#                                       assertKindAllocations HIR KIND N
#                                       ?OPTIONS? are test helpers built on it.
#
# OPTIONS are native::lower::program's: -specialize 0 lowers generic
# functions only (the guarded baseline; also BOTLISH_NATIVE_SPECIALIZE=0);
# -repr-opt 0 disables local unboxing of proven-small Int arithmetic
# (hir/range.tcl, native/lower.tcl's "Representation" section; also
# BOTLISH_NATIVE_REPR_OPT=0).
#
# No backend is registered with core::registerBackend: core::evalProgram runs
# Core IR, and Core IR has no native path. (tests/helpers.tcl registers the
# test-only "cranelift" backends, which read a test's core IR text into HIR
# with hir::build and then call native::evalHir.)
#
# Errors: Botlish errors keep their {CORE SEMANTIC KIND} codes. The backend's
# own failures are {NATIVE UNSUPPORTED ...} (a construct native lowering does
# not support, with its source location and HIR node), {NATIVE INVALID-NIR},
# {NATIVE CODEGEN} (Cranelift rejected the code), {NATIVE BUG},
# {NATIVE LIMIT STACK} and {NATIVE NOT-BUILT}.

if {[info commands ::core::compiler::evalHir] eq ""} {
    source [file join [file dirname [file dirname [file normalize [info script]]]] compiler compiler.tcl]
}
if {[info commands ::surface::modules::LoadNamespaces] eq ""} {
    source [file join [file dirname [file dirname [file normalize [info script]]]] surface surface.tcl]
}
source [file join [file dirname [file normalize [info script]]] lower.tcl]
source [file join [file dirname [file normalize [info script]]] prepare.tcl]

namespace eval native {
    variable home [file dirname [file normalize [info script]]]
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

# HIR -> NIR: native::lower::program's result for the resolved, analyzed
# program-mode HIR program HIR (after native::prepareHir attached the native
# implementations it calls), recording unsupported constructs. This is the one
# HIR-to-NIR entry point: every JIT, object, executable, benchmark, audit and
# test consumer reaches native lowering through it (native::nir and everything
# built on that), so they cannot diverge. It never touches Core IR.
proc native::lowered {hir args} {
    variable unsupported
    try {
        return [native::lower::program [prepareHir $hir] {*}$args]
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
    return [Outcome [Driver run [nir $hir {*}$args]]]
}

# Compile closed, specialized HIR to a standalone Linux x86_64/glibc ELF.
# Readiness is the public -aot-spec contract, checked before expanding native
# implementations (which are runtime support, like the Rust helpers). Never
# run the program while compiling it, and never fall back to another backend.
proc native::executable {hir path args} {
    set analysisOptions [dict create -specialize 1]
    foreach {option variable} {
        -call-facts-opt BOTLISH_NATIVE_CALL_FACTS_OPT
        -closed-caller-facts-opt BOTLISH_NATIVE_CLOSED_CALLER_FACTS_OPT
    } {
        dict set analysisOptions $option [expr {![info exists ::env($variable)] || $::env($variable) ne "0"}]
    }
    foreach {option value} $args {
        if {[dict exists $analysisOptions $option]} { dict set analysisOptions $option $value }
    }
    set analysis [hir::specialize::analyze $hir {*}$analysisOptions]
    set failures {}
    dict for {id region} [hir::specialize::regions $hir $analysis] {
        if {[dict get $region status] eq "closed"} continue
        lappend failures "[dict get $region label]: [dict get $region status]"
        foreach blocker [dict get $region blockers] {
            lappend failures "  [hir::aot::LocationText [dict get $blocker location]]: [dict get $blocker message]"
        }
    }
    if {$failures ne ""} {
        throw {NATIVE AOT NOT-READY} "program is not AOT-ready:\n[join $failures \n]"
    }
    set text [nir $hir {*}$args {*}$analysisOptions]
    set lines [Driver executable $text [file normalize $path]]
    foreach line $lines {
        if {[lindex $line 0] eq "error"} { Outcome $lines }
    }
    if {[llength $lines] != 1 || [lindex [lindex $lines 0] 0] ne "executable"} {
        throw {NATIVE BUG} "native backend produced no executable result:\n[join $lines \n]"
    }
    return [lindex [lindex $lines 0] 1]
}

proc native::clif {hir args} {
    set lines [Driver clif [nir $hir {*}$args]]
    if {[regexp {^error } [lindex $lines 0]]} {
        Outcome $lines
    }
    return [join $lines \n]
}

# The pre-regalloc Cranelift VCode of the program-mode HIR program HIR.
proc native::vcode {hir args} {
    set lines [Driver vcode [nir $hir {*}$args]]
    if {[regexp {^error } [lindex $lines 0]]} {
        Outcome $lines
    }
    return [join $lines \n]
}

# The GC-root report of every NIR function of the program-mode HIR program
# HIR (codegen::roots's per-function diagnostics: register counts,
# safepoints, root candidates, max simultaneous live roots, shadow slots).
# Never compiles: parses and analyzes the NIR only.
proc native::roots {hir args} {
    set lines [Driver roots [nir $hir {*}$args]]
    if {[regexp {^error } [lindex $lines 0]]} {
        Outcome $lines
    }
    return [join $lines \n]
}

proc native::measure {hir runs args} {
    set lower [lindex [time {set text [nir $hir {*}$args]}] 0]
    set lines [Driver bench $text $runs]
    set timing [lsearch -inline $lines {timing *}]
    set times [lsearch -inline $lines {times *}]
    set value [Outcome $lines]
    if {$timing eq ""} {
        throw {NATIVE BUG} "native backend produced no timing:\n[join $lines \n]"
    }
    lassign $timing _ compile best _ collections
    # BEST-US: the fastest run, in fractional microseconds. The "timing"
    # line's own BEST-US (still parsed above, for COMPILE-US/COLLECTIONS)
    # is Rust's Duration::as_micros() -- an integer, truncated to whole
    # microseconds, so every sub-1.5us run reads as a flat "1" or "2". The
    # "times" line (native/src/main.rs's per-run Duration::as_nanos(), full
    # precision) is emitted alongside it purely as additional diagnostic
    # detail today; recomputing BEST-US from it here, instead, keeps the
    # same best-of-RUNS execution time this always measured, just without
    # discarding precision main.rs already computed and sent. Falls back to
    # the truncated integer only if a "times" line is ever absent (bench.tcl
    # and the other bench/*.tcl scripts' own display formatting -- "%.2f
    # us" -- already expects a possibly-fractional value).
    if {$times ne ""} {
        set nanos [lrange $times 1 end]
        if {[llength $nanos]} {
            set bestNanos [lindex $nanos 0]
            foreach n [lrange $nanos 1 end] {
                if {$n < $bestNanos} {
                    set bestNanos $n
                }
            }
            set best [expr {$bestNanos / 1000.0}]
        }
    }
    return [list $lower $compile $best $collections $value]
}

# Runs the program-mode HIR program HIR RUNS times in one process
# (Vm::reset between runs) under allocation instrumentation (MODE: summary
# or sites; runtime/src/runtime/metrics.rs) and returns the report as a
# dict -- runtime/metrics.rs's Metrics::to_tcl, RUNS > 1's report
# reflecting the last run only, like native::measure's timing (Vm::reset
# isolates one run's counters from the previous run's). ARGS are
# native::lower::program's. In "sites" mode, each entry of the report's
# "sites" list gains a "location" key: {file line column} resolved from its
# "hirExpr" via hir::aot::Location, since the backend itself never
# interprets that id (see codegen/mod.rs's Site doc comment) -- "" if
# unattributed or the id no longer resolves (e.g. a synthetic expression).
proc native::allocationReport {hir mode {runs 1} args} {
    if {[hir::mode $hir] ne "program"} {
        error "native::allocationReport: expected a program-mode HIR"
    }
    if {$mode ni {summary sites}} {
        error "native::allocationReport: mode must be summary or sites, got $mode"
    }
    set text [nir $hir {*}$args]
    if {$runs > 1} {
        set lines [Driver bench $text $runs --alloc $mode]
    } else {
        set lines [Driver run $text --alloc $mode]
    }
    set line [lsearch -inline $lines {alloc *}]
    Outcome $lines
    if {$line eq ""} {
        throw {NATIVE BUG} "native backend produced no allocation report:\n[join $lines \n]"
    }
    set report [lrange $line 1 end]
    if {$mode eq "sites"} {
        dict set report sites [ResolveSites $hir [dict get $report sites]]
    }
    return $report
}

# SITES (native::allocationReport's "sites" list) with each entry's
# "hirExpr" resolved to a "location" key: {file line column}, or {} if
# unattributed or unresolvable. Kept separate from the Rust report so the
# backend never has to understand HIR: see codegen/mod.rs's Site.
proc native::ResolveSites {hir sites} {
    set resolved {}
    foreach site $sites {
        # nir.rs strips HIR's "e" id-namespace prefix when it parses the
        # NIR text's "@eN" origin annotation (Site::hir_expr is opaque
        # there): reattach it to look the expression back up here, where
        # HIR's id convention is the caller's to know.
        set e [dict get $site hirExpr]
        set location {}
        if {$e ne ""} {
            set e "e$e"
            if {[dict exists $hir exprs $e]} {
                set location [hir::aot::Location $hir [hir::get $hir $e origin]]
            }
        }
        dict set site location $location
        lappend resolved $site
    }
    return $resolved
}

# N as a human-scaled byte count ("820 B", "12.3 KB", "94.3 MB").
proc native::FormatBytes {n} {
    if {$n >= 1000000} {
        return [format "%.1f MB" [expr {$n / 1000000.0}]]
    }
    if {$n >= 1000} {
        return [format "%.1f KB" [expr {$n / 1000.0}]]
    }
    return "$n B"
}

# A concise developer-readable rendering of REPORT (native::allocationReport's
# result). The dict is the canonical representation (tests and tooling read
# it); this text is derived from it, never the other way around. Shows the
# top TOPSITES allocation sites by bytes when REPORT has a "sites" list
# (sites mode).
proc native::allocationText {report {topSites 10}} {
    set total [dict get $report total]
    set lines [list "Botlish managed heap allocation report" ""]
    lappend lines "allocated:" "    [dict get $total allocations] objects" "    [FormatBytes [dict get $total allocatedBytes]]" ""
    lappend lines "peak live:" "    [dict get $total peakLiveObjects] objects" "    [FormatBytes [dict get $total peakLiveBytes]]" ""
    set gc [dict get $report gc]
    lappend lines "GC:" "    [dict get $gc cycles] cycles" \
        "    [FormatBytes [dict get $gc reclaimedBytes]] reclaimed" \
        "    [format %.1f [expr {[dict get $gc totalTimeUs] / 1000.0}]] ms total" \
        "    [format %.1f [expr {[dict get $gc maxPauseUs] / 1000.0}]] ms max" ""
    lappend lines "by kind:"
    foreach kind {String List MutableArray BigInt Result Block Native} {
        set k [dict get $report byKind $kind]
        if {[dict get $k allocations] == 0} continue
        lappend lines [format "    %-8s %8d   %s" $kind [dict get $k allocations] [FormatBytes [dict get $k allocatedBytes]]]
    }
    set copies [dict get $report copies]
    lappend lines "" "copies:" "    String       [FormatBytes [dict get $copies stringBytes]]" \
        "    List         [dict get $copies listElements] elements" \
        "    MutableArray [dict get $copies mutableArrayElements] elements"
    set mutations [dict get $report mutableArray]
    lappend lines "" "mutable array:" \
        "    [dict get $mutations reads] reads, [dict get $mutations writes] writes"
    set static [dict get $report static]
    lappend lines "" "static (constant table, excluded from GC/live/peak):" \
        "    [dict get $static allocations] objects, [FormatBytes [dict get $static bytes]]"
    set sites [dict get $report sites]
    if {$sites ne ""} {
        set bySite [lsort -command {apply {{a b} {
            expr {[dict get $b allocatedBytes] - [dict get $a allocatedBytes]}
        }}} $sites]
        lappend lines "" "top allocation sites by bytes:"
        set n 0
        foreach s $bySite {
            if {[incr n] > $topSites} break
            set loc [dict get $s location]
            set where [expr {[dict exists $loc file] ? "[dict get $loc file]:[dict get $loc line]" : "func [dict get $s func]"}]
            lappend lines [format "    %2d. %-32s %-12s %8d allocations  %s" \
                $n $where [dict get $s operation] [dict get $s allocations] [FormatBytes [dict get $s allocatedBytes]]]
        }
    }
    lappend lines "" "excluded: num-bigint limb buffers, the shadow stack (fixed ~32 MB), Cranelift/JIT code, process bookkeeping."
    return [join $lines \n]
}

# ---------------------------------------------------------------------------
# Allocation assertions (for future collection/optimizer tests, e.g. "this
# steady-state lookup allocates zero objects"). Errors (rather than
# returning a boolean) so they read like tcltest's own assertions.

proc native::assertAllocations {hir n args} {
    set got [dict get [allocationReport $hir summary 1 {*}$args] total allocations]
    if {$got != $n} {
        error "expected $n allocation(s), got $got"
    }
}

proc native::assertAllocationsAtMost {hir n args} {
    set got [dict get [allocationReport $hir summary 1 {*}$args] total allocations]
    if {$got > $n} {
        error "expected at most $n allocation(s), got $got"
    }
}

proc native::assertBytesAtMost {hir n args} {
    set got [dict get [allocationReport $hir summary 1 {*}$args] total allocatedBytes]
    if {$got > $n} {
        error "expected at most $n allocated byte(s), got $got"
    }
}

proc native::assertKindAllocations {hir kind n args} {
    set got [dict get [allocationReport $hir summary 1 {*}$args] byKind $kind allocations]
    if {$got != $n} {
        error "expected $n $kind allocation(s), got $got"
    }
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
