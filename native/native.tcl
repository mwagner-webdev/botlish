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
#                                       BEST-US is fractional (nanosecond-
#                                       derived) microseconds, not truncated
#                                       to a whole number
#   native::object HIR PATH ?OPTIONS?   writes an object file (AOT smoke test)
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
if {[info commands ::surface::modules::LoadNamespaces] eq ""} {
    source [file join [file dirname [file dirname [file normalize [info script]]]] surface surface.tcl]
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
    # Set by ExpandNativeBodies, consumed by runProgram: IR-PATH (the path a
    # substituted call node has, before and after substitution -- see
    # ExpandNativeBodiesIn) -> the native's own registered -result-type, for
    # every call ExpandNativeBodies substituted a body into. Passed to
    # hir::build as -native-result-overrides so the substituted call keeps
    # its native's declared result type (hir::ApplyNativeResultOverrides).
    variable nativeResultOverrides [dict create]
    # Also set by ExpandNativeBodies's traversal (a call's native's registry
    # metadata is checked there either way): IR-PATH -> native NAME, for
    # every call of a native whose registry carries a -module-fn (currently
    # only uriEscape, -module-fn {web uri_escape_text}) -- the module-native
    # bridge's own input; see buildProgramHir and ModuleNativeBridge below.
    variable moduleNativeCalls [dict create]
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
    foreach kind {String List MutableArray BigInt Result Block Cell Native} {
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

# ---------------------------------------------------------------------------
# Backend entry points (core::registerBackend)

# The HIR the native backend actually lowers for a program's raw core IR
# EXPRS: ExpandNativeBodies's substitution, the module-native bridge
# (ModuleNativeBridge, below) prepending whatever modules it needs, then
# hir::buildSyntax with the overrides and module-native targets
# ExpandNativeBodies/ModuleNativeBridge collected -- runProgram's own steps,
# factored out so every other caller that needs this same HIR (the
# scalar-asm-audit generator, explain-native.tcl, bench.tcl's Cranelift
# column) shares one implementation instead of separately reproducing it.
# That reproduction is exactly how this diverged before: the scalar-asm-
# audit generator's own hand-copied version fell out of sync with
# -native-result-overrides and reported a false NATIVE UNSUPPORTED for
# bench/refined-checks.ir until it was fixed to match runProgram's steps
# again (see git history) -- bench.tcl's Cranelift column had the same
# hand-copied omission and is fixed here by switching it to this instead.
proc native::buildProgramHir {exprs args} {
    variable nativeResultOverrides
    set expanded [ExpandNativeBodies $exprs]
    set bridge [ModuleNativeBridge]
    set nodes {}
    set index 0
    foreach expr $expanded {
        lappend nodes [hir::syntax::fromIR $expr [list $index]]
        incr index
    }
    return [hir::buildSyntax $nodes -strict 0 -origin {ir {}} \
        -files [dict get $bridge files] -modules [dict get $bridge sections] \
        -native-result-overrides $nativeResultOverrides \
        -module-native-targets [dict get $bridge targets] \
        -type-decls [dict get $bridge typeDecls] {*}$args]
}

# The module-native bridge: loads (surface/modules.tcl), once per program
# build, every module a native call the preceding ExpandNativeBodies
# traversal recorded in moduleNativeCalls actually needs (a native whose
# registry carries -module-fn -- currently only uriEscape, -module-fn {web
# uri_escape_text}; core/native.tcl), and returns
#
#   {sections SECTIONS files FILES targets TARGETS typeDecls TYPEDECLS}
#
# ready for hir::buildSyntax: SECTIONS (the modules' own function
# definitions, compiled once, dependencies first) as -modules; TYPEDECLS
# (those modules' own "type ..." declarations, surface/lower.tcl's
# TypeDeclOf dicts) as -type-decls, so a bridged native's module function
# can itself use a source-declared type (hir/sourcetypes.tcl) exactly as an
# ordinary cross-file caller would; FILES to
# merge into -files; TARGETS (flat native NAME NAMESPACE FUNCTION-NAME
# triples) as -module-native-targets, so hir::types::BindingType
# (hir/types.tcl) types every reference to that native as a call of the
# already-resolved NAMESPACE::FUNCTION-NAME instead. This is the only
# caller of surface::modules' namespace-name-only entry point
# (surface::modules::LoadNamespaces): every other user of the module
# system (an ordinary .bot program's own mod::name references) goes
# through surface::modules::compileProgramFile instead, driven by source
# syntax rather than native registry metadata.
proc native::ModuleNativeBridge {} {
    variable moduleNativeCalls
    set namespaces {}
    set targets {}
    foreach name [lsort -unique [dict values $moduleNativeCalls]] {
        lassign [dict get [core::native::metadata $name] moduleFn] ns fn
        if {$ns ni $namespaces} {
            lappend namespaces $ns
        }
        lappend targets $name $ns $fn
    }
    if {$namespaces eq ""} {
        return [dict create sections {} files {} targets {} typeDecls {}]
    }
    set loaded [surface::modules::LoadNamespaces $namespaces]
    return [dict create sections [dict get $loaded sections] files [dict get $loaded files] \
        targets $targets typeDecls [dict get $loaded typeDecls]]
}

proc native::runProgram {exprs env {specialize ""}} {
    variable cache
    set options [expr {$specialize eq "" ? {} : [list -specialize $specialize]}]
    set key [list $exprs $options [expr {[info exists ::env(BOTLISH_NATIVE_SPECIALIZE)] ? $::env(BOTLISH_NATIVE_SPECIALIZE) : ""}]]
    if {![dict exists $cache $key]} {
        dict set cache $key [nir [buildProgramHir $exprs] {*}$options]
    }
    return [core::completion::normal [Outcome [Driver run [dict get $cache $key]]]]
}

# Rewrites EXPRS (a program's raw core IR, before hir::build) so that every
# direct call of a root name -- (call (ref NAME) ARG...) -- whose native
# carries a -native-body (core/native.tcl's registry field) has that body
# substituted in place of (ref NAME). After the rewrite the call is an
# ordinary call of an inline (block PARAMS BODY...) literal: it needs no
# entry in native/lower.tcl's own `natives` op whitelist, and compiles
# through the same specialize/escape/range/lowering machinery any other
# block call already does. Applied only here, at the native (Cranelift)
# backend's own program entry point -- never by interp or the Tcl compiler
# -- so a native whose Tcl -impl does something ordinary Botlish cannot
# (attach evidence for an opaque refined result type, for example: see
# core::type.tcl and core/native.tcl's nativeBody doc) keeps that behavior
# on every other backend. -impl stays authoritative there; a -native-body
# is authoritative only for what this backend executes.
#
# Purely syntactic and root-only: it does not resolve names against local
# scope, so it substitutes NAME's native body even where a local `bind`
# would shadow NAME before this call point. No program in this repository
# does that for a native carrying -native-body today. A future iteration
# that needs shadowing to win should run this after hir::build's own
# resolution instead, keyed on a call's resolved `target` field rather than
# the raw `ref` text -- a larger change, deliberately not made here.
proc native::ExpandNativeBodies {exprs} {
    variable nativeResultOverrides
    variable moduleNativeCalls
    set nativeResultOverrides [dict create]
    set moduleNativeCalls [dict create]
    set out {}
    set index 0
    foreach expr $exprs {
        lappend out [ExpandNativeBodiesIn $expr [list $index]]
        incr index
    }
    return $out
}

# Rewrites NODE (see ExpandNativeBodies), recursively, tracking PATH: the IR
# path hir::syntax::fromIR (hir/syntax.tcl) will assign the corresponding
# built node -- computed the same way, index for index, so it stays correct
# whether or not this specific node was substituted (substitution only ever
# replaces a call's callee sub-node in place; it never inserts or removes a
# sibling, so a call's own path is the same before and after). Every native
# call substituted here records its PATH and its native's own registered
# -result-type in nativeResultOverrides, for native::runProgram to pass to
# hir::build as -native-result-overrides.
proc native::ExpandNativeBodiesIn {node path} {
    variable nativeResultOverrides
    variable moduleNativeCalls
    switch -- [core::ir::op $node] {
        const - ref - continue {
            return $node
        }
        bind {
            return [list bind [lindex $node 1] \
                [ExpandNativeBodiesIn [lindex $node 2] [concat $path 2]]]
        }
        block {
            set body {}
            set index 2
            foreach expr [core::ir::blockBody $node] {
                lappend body [ExpandNativeBodiesIn $expr [concat $path $index]]
                incr index
            }
            return [list block [lindex $node 1] {*}$body]
        }
        call {
            set callee [lindex $node 1]
            set nativeBody ""
            if {[core::ir::op $callee] eq "ref" && [lindex $callee 1] in [core::native::names]} {
                set meta [core::native::metadata [lindex $callee 1]]
                set nativeBody [dict get $meta nativeBody]
                if {$nativeBody ne ""} {
                    dict set nativeResultOverrides $path [dict get $meta resultType]
                }
                if {[dict get $meta moduleFn] ne ""} {
                    dict set moduleNativeCalls $path [lindex $callee 1]
                    dict set nativeResultOverrides $path [dict get $meta resultType]
                }
            }
            if {$nativeBody ne ""} {
                set callee $nativeBody
            }
            set callee [ExpandNativeBodiesIn $callee [concat $path 1]]
            set args {}
            set index 2
            foreach expr [lrange $node 2 end] {
                lappend args [ExpandNativeBodiesIn $expr [concat $path $index]]
                incr index
            }
            return [list call $callee {*}$args]
        }
        if {
            return [list if [ExpandNativeBodiesIn [lindex $node 1] [concat $path 1]] \
                [ExpandNativeBodiesIn [lindex $node 2] [concat $path 2]] \
                [ExpandNativeBodiesIn [lindex $node 3] [concat $path 3]]]
        }
        loop {
            return [list loop [ExpandNativeBodiesIn [lindex $node 1] [concat $path 1]]]
        }
        return - ok - error-value {
            return [list [core::ir::op $node] \
                [ExpandNativeBodiesIn [lindex $node 1] [concat $path 1]]]
        }
        break {
            if {[llength $node] == 2} {
                return [list break [ExpandNativeBodiesIn [lindex $node 1] [concat $path 1]]]
            }
            return $node
        }
    }
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
