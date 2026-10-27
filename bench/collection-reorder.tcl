# collection-reorder.tcl -- the performance report of proven collection
# reordering (PROVEN-COLLECTION-REORDERING.md, "Performance").
#
#   tclsh9.0 bench/collection-reorder.tcl ?-keys LIST? ?-sizes LIST?
#       ?-modes LIST? ?-runs R? ?-reps LIST? ?-work W? ?-out FILE?
#       ?-instructions 0|1? ?-allocations 0|1? ?-hash-calls 0|1?
#
# One Botlish driver per key kind (the driver below), compiled and lowered
# once; one native run per size, mode and repetition count, argv MODE N
# REPS, the best of R runs in one process (bench/mutable-map.tcl's method).
# Every mode builds its map of N keys (and its candidates) once and then
# repeats one operation REPS times; the cost per operation is the
# difference of two repetition counts, (T[R2] - T[R1]) / (R2 - R1), which
# cancels the build and the process's start. The repetition counts are
# -reps (default {2 6}) times a scale that keeps every run's work about W
# entries (-work, default 65536): max(1, W / N) for the O(N) modes, W for
# `order` (O(1)), so the difference is never lost in the start's noise:
#
#   order            m.order(): a MutableSet sharing m's table, O(1)
#   validate         m.validate_order(c) of a valid candidate (the keys
#                    reversed): O(n) probes by c's stored hashes
#   validate-bad     the same of a candidate of n keys, one of them absent:
#                    O(n), the declared OrderMismatch handled
#   reorder          a proven m.reorder(o), alternately by the keys
#                    reversed and by the original order (both proven: the
#                    relation survives a reorder)
#   reorder-set      the same for a MutableSet of the keys
#   reorder-dead     a reorder of a map with n live and n/2 dead entries
#                    (removed, not yet compacted: the reorder drops them);
#                    each repetition removes and reinserts first, so its
#                    cost is the difference with mode dead-base
#   reorder-reserved a reorder of a map made with_capacity(8n) (its index
#                    kept at 8n/0.7 slots: the reorder rebuilds it as is)
#   reorder-shared   a copy of the map, then a reorder of the copy (its
#                    first write: every vector it rewrites is shared)
#   copy-base        the copy alone (reorder-shared's difference)
#
# -instructions 1 counts instructions (valgrind's callgrind) instead of
# timing. -allocations 1 adds, per mode, the managed objects, the vector
# shares and detaches (native::allocationReport) per operation; -hash-calls
# 1 the keyed-hash computations per operation, counted on the Tcl compiler's
# backend (core::hashing::tableHash called), for the smallest size and the
# unscaled repetition counts (a count has no noise to outgrow). Rows
# (TSV) to stdout and -out:
#
#   keys n mode reps best-us per-op-ns checksum

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root core core.tcl]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

set options [dict create -keys {int str} -sizes {16 1024 65536 262144} \
    -modes {order validate validate-bad reorder reorder-set reorder-dead dead-base reorder-reserved reorder-shared copy-base} \
    -runs 5 -reps {2 6} -work 65536 -out "" -instructions 0 -allocations 0 -hash-calls 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "bench/collection-reorder.tcl: unknown option $option" }
    dict set options $option $value
}

set kinds {
    int {int {(i * 2654435761).mod(4294967296)}}
    str {str {std::str::concat("key-", std::int::to_string(i))}}
}

set modeNumbers {
    order 1 validate 2 validate-bad 3 reorder 4 reorder-set 5 reorder-dead 6 dead-base 7
    reorder-reserved 8 reorder-shared 9 copy-base 10
}

proc driver {kind} {
    lassign [dict get $::kinds $kind] t keyBody
    return [string map [list @T@ $t @KEY@ $keyBody] {import std::list
import std::str
import std::int
import std::mutable_map
import std::mutable_set
import std::mutable_array

fn key(i: int) -> @T@:
    @KEY@

fn arg(args: List[str], i: int) -> int:
    text = std::list::at(args, i):
        on IndexNotFound:
            return 0
    n = std::int::from_string(text):
        on InvalidIntegerText:
            return 0
    n

fn build(n: int, capacity: int) -> std::mutable_map::MutableMap[@T@, int]:
    m = std::mutable_map::with_capacity[@T@, int](capacity)
    loop i from 0 to n:
        m.set(key(i), i)
    m

# The keys 0..N-1 reversed, as a set; with BAD, key 0 replaced by key N.
fn candidate(n: int, bad: bool) -> std::mutable_set::MutableSet[@T@]:
    c = std::mutable_set::create[@T@]()
    loop j from 0 to n:
        i = n - 1 - j
        if bad and i == 0:
            c.add(key(n))
            continue
        c.add(key(i))
    c

fn sum(m: std::mutable_map::MutableMap[@T@, int], k: int) -> int:
    v = m.at(key(k)):
        on std::mutable_map::KeyNotFound:
            0
    m.length() + v

fn orders(m: std::mutable_map::MutableMap[@T@, int], reps: int) -> int:
    acc = std::mutable_array::create(1, 0)
    loop r from 0 to reps:
        o = m.order()
        a = acc.at(0):
            on IndexNotFound:
                0
        acc.set(0, a + o.length()):
            on IndexNotFound:
                unit
    total = acc.at(0):
        on IndexNotFound:
            0
    total

fn validations(m: std::mutable_map::MutableMap[@T@, int], c: std::mutable_set::MutableSet[@T@], reps: int) -> int:
    acc = std::mutable_array::create(1, 0)
    loop r from 0 to reps:
        n = m.validate_order(c):
            on std::mutable_map::OrderMismatch:
                std::mutable_set::create[@T@]()
        a = acc.at(0):
            on IndexNotFound:
                0
        acc.set(0, a + n.length()):
            on IndexNotFound:
                unit
    total = acc.at(0):
        on IndexNotFound:
            0
    total

# REPS proven reorders of M, alternately by the keys reversed and back.
fn reorders(place m: std::mutable_map::MutableMap[@T@, int], n: int, reps: int) -> int:
    back = m.order()
    there = m.validate_order(candidate(n, false)):
        on std::mutable_map::OrderMismatch:
            return -1
    loop r from 0 to reps:
        if r.mod(2) == 0:
            m.reorder(there)
        else:
            m.reorder(back)
    sum(m, n - 1)

fn set_reorders(n: int, reps: int) -> int:
    s = std::mutable_set::create[@T@]()
    loop i from 0 to n:
        s.add(key(i))
    back = s.order()
    there = s.validate_order(candidate(n, false)):
        on std::mutable_set::OrderMismatch:
            return -1
    loop r from 0 to reps:
        if r.mod(2) == 0:
            s.reorder(there)
        else:
            s.reorder(back)
    s.length()

# REPS times: the last half of M's keys removed and set again (N/2 dead
# entries, fewer than the live ones: no compaction), then, with REORDER, a
# proven reorder by M's own order.
fn dead_reorders(place m: std::mutable_map::MutableMap[@T@, int], n: int, reps: int, again: bool) -> int:
    loop r from 0 to reps:
        loop i from shift_right(n, 1) to n:
            x = m.remove(key(i)):
                on std::mutable_map::KeyNotFound:
                    0
        loop i from shift_right(n, 1) to n:
            m.set(key(i), i)
        if again:
            m.reorder(m.order())
    sum(m, n - 1)

# REPS times: a copy of M and, with REORDER, a proven reorder of the copy.
fn shared_reorders(m: std::mutable_map::MutableMap[@T@, int], n: int, reps: int, again: bool) -> int:
    acc = std::mutable_array::create(1, 0)
    loop r from 0 to reps:
        c = m
        if again:
            c.reorder(c.order())
        a = acc.at(0):
            on IndexNotFound:
                0
        acc.set(0, a + c.length()):
            on IndexNotFound:
                unit
    total = acc.at(0):
        on IndexNotFound:
            0
    total

fn run(mode: int, n: int, reps: int) -> int:
    if mode == 1:
        return orders(build(n, 0), reps)
    if mode == 2:
        return validations(build(n, 0), candidate(n, false), reps)
    if mode == 3:
        return validations(build(n, 0), candidate(n, true), reps)
    if mode == 4:
        m = build(n, 0)
        return reorders(m, n, reps)
    if mode == 5:
        return set_reorders(n, reps)
    if mode == 6:
        m = build(n, 0)
        return dead_reorders(m, n, reps, true)
    if mode == 7:
        m = build(n, 0)
        return dead_reorders(m, n, reps, false)
    if mode == 8:
        m = build(n, 8 * n)
        return reorders(m, n, reps)
    if mode == 9:
        return shared_reorders(build(n, 0), n, reps, true)
    if mode == 10:
        return shared_reorders(build(n, 0), n, reps, false)
    0

args = argv():
    on InvalidArgumentEncoding:
        []
run(arg(args, 1), arg(args, 2), arg(args, 3))
}]
}

proc argvOf {args} {
    return [lmap a [linsert $args 0 bench] {encoding convertto utf-8 $a}]
}

# The best time (microseconds) and checksum of a native run with ARGS.
proc timed {text args} {
    if {[dict get $::options -instructions]} {
        return [counted $text {*}$args]
    }
    core::process::withArgv [argvOf {*}$args] {
        set lines [native::Driver bench $text [dict get $::options -runs]]
    }
    set value [native::Outcome $lines]
    set best ""
    foreach n [lrange [lsearch -inline $lines {times *}] 1 end] {
        if {$best eq "" || $n < $best} { set best $n }
    }
    if {[lindex $value 0] ne "int"} {
        error "bench/collection-reorder.tcl: a run ended with [core::formatValue $value]"
    }
    return [list [expr {$best / 1000.0}] [lindex $value 1]]
}

# With -instructions 1: callgrind's instruction count of one native run, in
# thousands (bench/mutable-map.tcl's `counted`).
proc counted {text args} {
    set dir [file tempdir botlish-cr-instructions]
    try {
        set nirPath [file join $dir run.nir]
        set f [open $nirPath w]
        fconfigure $f -encoding utf-8 -translation lf
        puts -nonewline $f $text
        close $f
        set argvPath [file join $dir run.argv]
        core::process::withArgv [argvOf {*}$args] {
            set f [open $argvPath w]
            puts $f [core::process::driverArgv]
            close $f
        }
        set out [exec valgrind --tool=callgrind --smc-check=all-non-file --callgrind-out-file=/dev/null \
            [native::binary] bench 1 --argv-file $argvPath $nirPath 2>@1]
    } finally {
        file delete -force $dir
    }
    if {![regexp {Collected : (\d+)} $out -> n]} {
        error "bench/collection-reorder.tcl: no instruction count: $out"
    }
    return [list [expr {$n / 1000.0}] -]
}

proc report {hir args} {
    core::process::withArgv [argvOf {*}$args] {
        set report [native::allocationReport $hir summary]
    }
    return [list [dict get $report total allocations] [dict get $report mutableVector shares] \
        [dict get $report mutableVector detaches] [dict get $report mutableVector growths]]
}

proc hashCalls {hir args} {
    set ::crHashCalls 0
    set trace [list ::apply {{args} {incr ::crHashCalls}}]
    trace add execution core::hashing::tableHash enter $trace
    try {
        core::process::withArgv [argvOf {*}$args] {
            core::compiler::evalHir $hir
        }
    } finally {
        trace remove execution core::hashing::tableHash enter $trace
    }
    return $::crHashCalls
}

set out ""
if {[dict get $options -out] ne ""} {
    set out [open [dict get $options -out] w]
}
proc row {fields} {
    puts [join $fields \t]
    flush stdout
    if {$::out ne ""} {
        puts $::out [join $fields \t]
        flush $::out
    }
}

# The repetition scale of MODE at size N (the header).
proc scale {mode n} {
    set work [dict get $::options -work]
    if {$mode eq "order"} {
        return $work
    }
    return [expr {max(1, $work / $n)}]
}

foreach kind [dict get $options -keys] {
    set hir [surface::compile [driver $kind] bench.bot -warnings off]
    set text [native::nir $hir]
    foreach n [dict get $options -sizes] {
        set times [dict create]
        foreach mode [dict get $options -modes] {
            set number [dict get $modeNumbers $mode]
            lassign [dict get $options -reps] r1 r2
            set r1 [expr {$r1 * [scale $mode $n]}]
            set r2 [expr {$r2 * [scale $mode $n]}]
            lassign [timed $text $number $n $r1] t1 sum
            lassign [timed $text $number $n $r2] t2
            set per [expr {($t2 - $t1) * 1000.0 / ($r2 - $r1)}]
            dict set times $mode $per
            row [list $kind $n $mode $r2 [format %.1f $t2] [format %.1f $per] $sum]
            if {[dict get $options -allocations]} {
                set a1 [report $hir $number $n $r1]
                set a2 [report $hir $number $n $r2]
                set d [lmap x $a1 y $a2 {format %.2f [expr {($y - $x) / double($r2 - $r1)}]}]
                row [list $kind $n $mode-allocations $r2 [join $d /] objects/shares/detaches/growths -]
            }
            if {[dict get $options -hash-calls] && $n == [lindex [dict get $options -sizes] 0]} {
                # (Counts are exact: the unscaled repetitions suffice.)
                lassign [dict get $options -reps] b1 b2
                set h1 [hashCalls $hir $number $n $b1]
                set h2 [hashCalls $hir $number $n $b2]
                row [list $kind $n $mode-hash-calls $b2 [expr {$h2 - $h1}] [format %.2f [expr {($h2 - $h1) / double($b2 - $b1)}]] -]
            }
        }
        foreach {derived mode base} {reorder-dead-net reorder-dead dead-base reorder-shared-net reorder-shared copy-base} {
            if {[dict exists $times $mode] && [dict exists $times $base]} {
                row [list $kind $n $derived - - [format %.1f [expr {[dict get $times $mode] - [dict get $times $base]}]] -]
            }
        }
    }
}
if {$out ne ""} {
    close $out
}
