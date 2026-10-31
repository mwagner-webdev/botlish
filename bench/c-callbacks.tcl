# c-callbacks.tcl -- what a synchronous C callback costs natively
# (C-CALLBACK-MILESTONE-1.md, "Performance").
#
#   tclsh9.0 bench/c-callbacks.tcl ?-runs N? ?-n N? ?-backends LIST? ?-gc-stress 0|1?
#
# Every scenario is a program of the callback test fixture
# (tests/cffi/callback-fixture.c, compiled here with the host C compiler
# into a private static archive; tests/cffi/cbx.bot its binding), run as the
# linked executable a program that calls C is, best of RUNS executions,
# compilation and linking excluded. N is the number of calls a scenario
# makes. C's loops are in C (cbx_sum, cbx_filter_sum, cbx_bench_*): each
# iteration one call of the callback through its function pointer, its
# result used; a Botlish loop's per-call cost is the loop with the call
# minus the same loop without it.
#
#   botlish-call      a Botlish function's call in a Botlish loop (the
#                     internal-call baseline)
#   c-plain           a C call with no callback (cbx_plain) in a Botlish loop:
#                     the existing FFI's cost
#   transition        a call of a C function that may call back (a noescape
#                     FnPtr parameter) and does not (cbx_tick(f, 0)): the
#                     transition shim's rt_ffi_open and rt_ffi_close
#   callback-int      C calls an identity callback of an int (cbx_sum): C ABI
#                     entry, activation, an Int argument and result (small:
#                     no allocation)
#   callback-decision C acts on a callback's int answer (cbx_filter_sum)
#   raw-float-in      a callback receiving a RawFloat (returns an int)
#   raw-double-in     a callback receiving a RawDouble (returns an int)
#   raw-float-trip    a RawFloat in and out (cbx_bench_floats: identity)
#   raw-double-trip   a RawDouble in and out (cbx_bench_doubles: identity)
#   raw-inspect       a RawDouble's bits classified (double_nan?)
#   raw-admit         a RawDouble admitted to a Float64 explicitly
#                     (double_to_float64) and compared
#   nested-2          a callback that calls C, which calls a second callback
#                     (two callback levels per outer call)
#   allocating        a callback that allocates a String per call
#
# For each: calls, the best run's total time, ns per call, and from one run
# with the runtime's allocation counters on (`--alloc summary` of the linked
# run: runtime::metrics, the same counters the JIT's reports use; no
# instrumentation of its own) the allocations and bytes per call, the
# FloatObj allocations per call by kind (Float64, RawFloat, RawDouble), and
# the collections. A line per backend of BACKENDS; GC stress
# (BOTLISH_NATIVE_GC_STRESS=1: a collection at every allocation) with
# -gc-stress 1.

set root [file dirname [file dirname [file normalize [info script]]]]
set options [dict create -runs 5 -n 200000 -backends {cranelift cranelift-generic} -gc-stress 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set ::argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

set runs [dict get $options -runs]
set n [dict get $options -n]
if {![testConstraint nativeCCalls] || ![testConstraint nativeCCallbacks] || [catch {native::binary}]} {
    puts "this host does not run C callbacks (or the native backend is not built): nothing to measure"
    exit 0
}

set scratch [file tempdir botlish-callback-bench]
ctool::staticLibrary $scratch botlish_callback_fixture [file join $root tests cffi callback-fixture.c]
file copy [file join $root tests cffi cbx.bot] [file join $scratch cbx.bot]
if {[dict get $options -gc-stress]} {
    set ::env(BOTLISH_NATIVE_GC_STRESS) 1
}

proc writeFile {path text} {
    set channel [open $path w]
    fconfigure $channel -encoding utf-8 -translation lf
    puts -nonewline $channel $text
    close $channel
}

set ::programs 0
proc compileApp {text} {
    set path [file join $::scratch main-[incr ::programs].bot]
    writeFile $path $text
    return [surface::readProgramFile $path -warnings off -cache ""]
}

set prelude {import std::ffi::c
import std::ffi::c::raw
import std::int
import std::list
import std::str
import cbx

fn add_one(x: int) -> int:
    x + 1

callback c fn identity(x: std::ffi::c::Int) -> std::ffi::c::Int:
    x

callback c fn keep_thirds(x: std::ffi::c::Int) -> std::ffi::c::Int:
    if mod(x, 3) == 0:
        return 1
    0

callback c fn nothing() -> unit:
    unit

callback c fn float_in(x: std::ffi::c::RawFloat) -> std::ffi::c::Int:
    0

callback c fn double_in(x: std::ffi::c::RawDouble) -> std::ffi::c::Int:
    0

callback c fn float_trip(x: std::ffi::c::RawFloat) -> std::ffi::c::RawFloat:
    x

callback c fn double_trip(x: std::ffi::c::RawDouble) -> std::ffi::c::RawDouble:
    x

callback c fn inspect(x: std::ffi::c::RawDouble) -> std::ffi::c::Int:
    if std::ffi::c::raw::double_nan?(x):
        return 1
    0

callback c fn admit(x: std::ffi::c::RawDouble) -> std::ffi::c::Int:
    f = std::ffi::c::raw::double_to_float64(x):
        on NonFiniteFloat:
            return -1
    if f > 1.0:
        return 1
    0

callback c fn inner(x: std::ffi::c::Int) -> std::ffi::c::Int:
    x

callback c fn outer(x: std::ffi::c::Int) -> std::ffi::c::Int:
    cb = std::ffi::c::callback(inner)
    cbx::apply(cb, x)

callback c fn allocating(x: std::ffi::c::Int) -> std::ffi::c::Int:
    s = std::str::concat("callback-", std::int::to_string(x))
    if std::str::length(s) > 100:
        return 0
    1

}

# A Botlish loop of N iterations whose body is BODY.
proc loopProgram {setup body} {
    return "$::prelude\nfn f() -> int:\n    $setup\n    xs = loop i from 0 to $::n:\n        $body\n    std::list::length(xs)\n\nf()\n"
}

# A program whose value is EXPRESSION after SETUP.
proc callProgram {setup expression} {
    return "$::prelude\nfn f():\n    $setup\n    $expression\n\nf()\n"
}

# {BEST-US ALLOCATION-REPORT} of program TEXT on BACKEND.
proc measure {text backend} {
    set hir [compileApp $text]
    set options [expr {$backend eq "cranelift-generic" ? {-specialize 0} : {}}]
    native::withLinkDirs [list $::scratch] {
        lassign [native::measure $hir $::runs {*}$options] lower compile best
        set report [native::allocationReport $hir summary 1 {*}$options]
    }
    return [list $best $report]
}

# The allocations of KIND (a byKind key, or "total") in REPORT.
proc allocations {report kind} {
    if {$kind eq "total"} {
        set sum 0
        dict for {k counts} [dict get $report byKind] { incr sum [dict get $counts allocations] }
        return $sum
    }
    if {![dict exists $report byKind $kind]} { return 0 }
    return [dict get $report byKind $kind allocations]
}
proc allocatedBytes {report} {
    set sum 0
    dict for {k counts} [dict get $report byKind] { incr sum [dict get $counts allocatedBytes] }
    return $sum
}

# One row: NAME, CALLS, total ms, ns/call, and per call: allocations, bytes,
# Float64, RawFloat, RawDouble allocations; collections.
proc row {name calls best report {baseline ""}} {
    set ns [expr {1000.0 * $best / $calls}]
    if {$baseline ne ""} {
        lassign $baseline baseBest baseReport
        set ns [expr {1000.0 * ($best - $baseBest) / $calls}]
        set perCall [lmap kind {total Float RawFloat RawDouble} {
            expr {double([allocations $report $kind] - [allocations $baseReport $kind]) / $calls}
        }]
        set bytes [expr {double([allocatedBytes $report] - [allocatedBytes $baseReport]) / $calls}]
    } else {
        set perCall [lmap kind {total Float RawFloat RawDouble} {expr {double([allocations $report $kind]) / $calls}}]
        set bytes [expr {double([allocatedBytes $report]) / $calls}]
    }
    lassign $perCall total float raw32 raw64
    set gc [dict getdef [dict get $report gc] cycles [dict getdef [dict get $report gc] collections "?"]]
    return [format "  %-18s %9d %9.2f %8.2f %8.2f %8.1f %7.2f %7.2f %7.2f %6s" $name $calls [expr {$best / 1000.0}] $ns $total $bytes $float $raw32 $raw64 $gc]
}

try {
    set machine $::tcl_platform(machine)
    puts "C callbacks (C-CALLBACK-MILESTONE-1.md): best of $runs runs, N = $n, [core::cabi::hostTarget] ($machine), release build[expr {[dict get $options -gc-stress] ? ", GC stress" : ""}]"
    foreach backend [dict get $options -backends] {
        puts "\n$backend"
        puts [format "  %-18s %9s %9s %8s %8s %8s %7s %7s %7s %6s" scenario calls "total ms" ns/call allocs bytes Float64 RawFlt RawDbl gc]
        set emptyLoop [measure [loopProgram {x = 0} i] $backend]
        set botlishCall [measure [loopProgram {x = 0} {add_one(i)}] $backend]
        puts [row botlish-call $n [lindex $botlishCall 0] [lindex $botlishCall 1] $emptyLoop]
        set plain [measure [loopProgram {x = 0} {cbx::plain(i)}] $backend]
        puts [row c-plain $n [lindex $plain 0] [lindex $plain 1] $emptyLoop]
        set transition [measure [loopProgram {t = std::ffi::c::callback(nothing)} {cbx::tick(t, 0)}] $backend]
        puts [row transition $n [lindex $transition 0] [lindex $transition 1] $emptyLoop]
        foreach {name setup expression calls} [list \
            callback-int {cb = std::ffi::c::callback(identity)} "cbx::sum(cb, $n)" $n \
            callback-decision {cb = std::ffi::c::callback(keep_thirds)} "cbx::filter_sum(cb, $n)" $n \
            raw-float-in {cb = std::ffi::c::callback(float_in)} "cbx::bench_float_in(cb, $n)" $n \
            raw-double-in {cb = std::ffi::c::callback(double_in)} "cbx::bench_double_in(cb, $n)" $n \
            raw-float-trip {cb = std::ffi::c::callback(float_trip)} "cbx::bench_floats(cb, $n)" $n \
            raw-double-trip {cb = std::ffi::c::callback(double_trip)} "cbx::bench_doubles(cb, $n)" $n \
            raw-inspect {cb = std::ffi::c::callback(inspect)} "cbx::bench_double_in(cb, $n)" $n \
            raw-admit {cb = std::ffi::c::callback(admit)} "cbx::bench_double_in(cb, $n)" $n \
            nested-2 {cb = std::ffi::c::callback(outer)} "cbx::sum(cb, $n)" $n \
            allocating {cb = std::ffi::c::callback(allocating)} "cbx::sum(cb, $n)" $n \
        ] {
            lassign [measure [callProgram $setup $expression] $backend] best report
            puts [row $name $calls $best $report]
        }
    }
} finally {
    file delete -force $scratch
}
