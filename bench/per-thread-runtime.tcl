# per-thread-runtime.tcl -- the performance report of per-VM and per-thread
# runtime state (PER-THREAD-RUNTIME-STATE-MILESTONE-1.md, "Performance").
#
#   tclsh9.0 bench/per-thread-runtime.tcl ?-baseline BIN? ?-runs N? ?-repeat K?
#
# Two tables:
#
#   * Before and after: programs that each repeat one operation the
#     milestone changed -- a context read (the base is now loaded from the
#     Vm, not a data symbol's address), a context installation and run, a
#     coroutine resume on the general runtime (its stack publication now
#     goes to the thread's guard record), hashing an enum and a struct (their
#     names now read from the running Vm's program), an allocation-heavy loop
#     (collections) -- run by this checkout's driver and by BIN, a driver
#     built before the milestone (the NIR text format is unchanged, so both
#     read the same file), as `bench RUNS`: the best and the median of RUNS
#     in-process runs, compilation excluded, the best of K process repeats.
#     Without -baseline only this checkout's column.
#   * Concurrent Vms: `vms N` of a CPU-bound program (no allocation shared,
#     no lock on its path) for N of 1, 2 and 4, the harness's whole process,
#     best of K: the wall time of N Vms at once against one Vm's, which would
#     grow with N if Vms serialized on a process-wide lock; and `vms 1
#     --rounds R` of a trivial program, the cost of making, installing,
#     running and dropping one Vm.
#
# Every number is from this machine at this moment: shared machines scatter,
# so compare columns of one run only.

set root [file dirname [file dirname [file normalize [info script]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
interp recursionlimit {} 200000

set options [dict create -baseline "" -runs 21 -repeat 3]
foreach {option value} $args {
    if {![dict exists $options $option]} { error "unknown option $option (known: [dict keys $options])" }
    dict set options $option $value
}
set runs [dict get $options -runs]
set repeat [dict get $options -repeat]
set current [native::binary]
set baseline [dict get $options -baseline]

set programs [dict create]
dict set programs context-read {
type Small = Int in 0..1000
context struct Config:
    a: Small
    b: Small
fn sum(n: int, context c: Config) -> int:
    fold i from 0 to n with intermediate s 0:
        s + c.a + c.b
with context Config {a: 3, b: 4}
sum(2000000)
}
dict set programs context-collections {
import std::mutable_vector
context struct Log:
    items: MutableVector[int]
fn fill(n: int, context l: Log) -> int:
    loop i from 0 to n:
        l.items.push(i)
    l.items.length()
with context Log {items: std::mutable_vector::from_list([])}
fill(200000)
}
dict set programs coroutine-resume {
import std::coroutine
import std::mutable_array
fn numbers(n: int) -> int:
    loop i from 0 to n:
        yield i
    -1
fn drive(n: int) -> int errors IndexNotFound:
    coroutine {step, first} = numbers(n)
    total = std::mutable_array::create(1, first)
    loop:
        v = step()
        if std::coroutine::done?(step):
            break
        total.set(0, total.at(0) + v)
    total.at(0)
r = drive(200000):
    on IndexNotFound:
        0
r
}
dict set programs hash-enum-struct {
enum Color:
    Red
    Green
    Blue
struct Point:
    x: int
    y: int
fn mix(n: int) -> int:
    fold i from 0 to n with intermediate s 0:
        same = if hash(Color::Green) == hash(Point {x: i, y: 2}):
            0
        else:
            1
        s + same
mix(100000)
}
dict set programs allocation {
import std::list
fn churn(n: int) -> int:
    fold i from 0 to n with intermediate s 0:
        xs = [i, i + 1, [i, s]]
        s + std::list::length(xs)
churn(300000)
}

# The best and the median microseconds of BIN's `bench RUNS` of NIR, the
# best of REPEAT processes.
proc measure {bin nir {env {}}} {
    global runs repeat
    lassign [file tempfile path botlish-ptr.nir] channel
    fconfigure $channel -encoding utf-8 -translation lf
    puts -nonewline $channel $nir
    close $channel
    set best {}
    set median {}
    try {
        for {set k 0} {$k < $repeat} {incr k} {
            set output [withEnvironment $env {exec $bin bench $runs $path 2>@1}]
            if {![regexp -line {^times (.*)$} $output -> times]} { error "no timing from $bin: $output" }
            set times [lsort -integer $times]
            set b [expr {[lindex $times 0] / 1000.0}]
            set m [expr {[lindex $times [expr {[llength $times] / 2}]] / 1000.0}]
            if {$best eq {} || $b < $best} { set best $b; set median $m }
        }
    } finally {
        file delete $path
    }
    list $best $median
}

proc fmt {pair} {
    if {$pair eq {}} { return "--" }
    format "%.0f / %.0f" {*}$pair
}

puts "## Before and after (best / median microseconds per run, `bench $runs`, best of $repeat processes)\n"
puts "| program | before (BIN) | after (this checkout) | best after/before |"
puts "|---|---:|---:|---:|"
dict for {name text} $programs {
    set nir [native::nir [surface::compile $text -warnings off]]
    set env [expr {$name eq "coroutine-resume" ? {BOTLISH_NATIVE_COROUTINE_FUSION 0} : {}}]
    set after [measure $current $nir $env]
    set before [expr {$baseline eq "" ? "" : [measure $baseline $nir $env]}]
    set ratio [expr {$before eq "" ? "--" : [format %.2f [expr {[lindex $after 0] / [lindex $before 0]}]]}]
    puts "| $name | [fmt $before] | [fmt $after] | $ratio |"
}

# The whole process of `vms ARGS` of NIR: milliseconds, best of REPEAT.
proc wall {nir args} {
    global current repeat
    lassign [file tempfile path botlish-ptr.nir] channel
    fconfigure $channel -encoding utf-8 -translation lf
    puts -nonewline $channel $nir
    close $channel
    set best {}
    try {
        for {set k 0} {$k < $repeat} {incr k} {
            set started [clock microseconds]
            exec $current vms {*}$args $path
            set ms [expr {([clock microseconds] - $started) / 1000.0}]
            if {$best eq {} || $ms < $best} { set best $ms }
        }
    } finally {
        file delete $path
    }
    return $best
}

set cpu [native::nir [surface::compile {
fn spin(n: int) -> int:
    fold i from 0 to n with intermediate s 0:
        s + i * 3 + 1
spin(30000000)
} -warnings off]]
set trivial [native::nir [surface::compile "1 + 2\n" -warnings off]]
puts "\n## Concurrent Vms (the harness's whole process, milliseconds, best of $repeat)\n"
puts "| run | wall | per Vm |"
puts "|---|---:|---:|"
foreach n {1 2 4} {
    set ms [wall $cpu $n]
    puts "| vms $n of a CPU-bound program | [format %.1f $ms] | [format %.1f [expr {$ms / $n}]] |"
}
foreach r {1 1000} {
    set ms [wall $trivial 1 --rounds $r]
    puts "| vms 1 --rounds $r of `1 + 2` | [format %.1f $ms] | [format %.3f [expr {$ms / $r}]] |"
}
