# mutable-map.tcl -- the performance report of std::mutable_map and
# std::mutable_set (ORDERED-MUTABLE-MAP-SET.md, "Performance").
#
#   tclsh9.0 bench/mutable-map.tcl ?-keys LIST? ?-sizes LIST? ?-modes LIST?
#       ?-ops M? ?-runs R? ?-passes P? ?-build-passes B? ?-out FILE?
#       ?-allocations 0|1? ?-stdlib DIR? ?-instructions 0|1?
#
# For every key kind, one Botlish program (the driver below, typed for the
# kind), compiled and lowered once; then one native run per size and mode,
# argv MODE N M REPS [POOL...], the best of R runs in one process. Like the
# hash-table experiment's tools/bench.tcl (audit/hash-table/), whose key
# kinds, query order and subtraction it reuses (SPEC.md sections 5 and 6),
# so its rows compare with that experiment's `lp` and `cd` and with the Rust
# reference's (`std` is std::collections::HashMap with its own SipHash-1-3,
# the keyed hash's algorithm):
#
#   build, presized  (T[B REPS] - T[REPS]) / ((B - 1) REPS N) per insertion,
#                    growing from an empty map / into with_capacity(N)
#   hit, miss        (T[1 + P passes] - T[1 pass]) / (P M) per lookup (at: a
#                    miss raises KeyNotFound, which the loop handles)
#   has-hit, has-miss  the same, per contains of a present / an absent key
#   member           the same, per contains of a present and an absent key
#   replace          the same, per set of a present key
#   remove           (T[remove, B REPS] - T[remove, REPS]
#                     - T[build, B REPS] + T[build, REPS]) / ((B - 1) REPS N),
#                    per removal in insertion order
#   iterate          (T[1 + P passes] - T[1 pass]) / (P N) per entry visited,
#                    P = max(PASSES, 20 OPS / N): 4 million visits
#   mixed            per operation: 80% lookups, 10% insertions of fresh
#                    keys, 10% removals of the key inserted before
#   churn            per insertion-and-removal pair: a fresh key set, the key
#                    set 8 operations earlier removed
#   copy             (T[B R] - T[R]) / ((B - 1) R), R = max(10, OPS / N): a
#                    copy of the built map and one insertion into it (the
#                    copy's first write detaches the vectors it writes: O(N))
#   set-build, set-hit, set-miss   a MutableSet's add / contains
#   iset-build, iset-hit, iset-miss   std::immutable_set's from_list (per
#                    element) / contains, for comparison (not in the
#                    default modes)
#
# B is -build-passes (4) and P -passes (10): the differences cancel the key
# Lists and the builds exactly, and are large enough that one run's noise
# does not rival them. REPS is max(1, OPS / N), M is OPS.
#
# Allocation accounting (-allocations 1): per size, the allocations of a
# lookup, replacement, loop, mixed or churn run beyond its build's own, per
# operation (three passes against one), from native::allocationReport.
# Rows (TSV) to stdout and -out:
#
#   keys n mode m reps best-us per-op-ns checksum
#
# -instructions 1 counts instructions (valgrind's callgrind, one run each)
# instead of timing: the per-op column is then instructions per operation
# (use a smaller -ops, as audit/hash-table/tools/instructions.tcl does).
#
# -stdlib DIR compiles against another copy of the standard library (a policy
# variant: ORDERED-MUTABLE-MAP-SET.md, "Growth").

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root core core.tcl]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

set options [dict create -keys {int-dense int-sparse str-short str-medium point nested int-collide} \
    -sizes {16 256 4096 65536 262144} \
    -modes {build presized hit miss has-hit has-miss replace remove iterate mixed churn copy set-build set-hit set-miss} \
    -ops 200000 -runs 5 -out "" -allocations 0 -stdlib "" -passes 10 -build-passes 4 -instructions 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "bench/mutable-map.tcl: unknown option $option" }
    dict set options $option $value
}

# ---------------------------------------------------------------------------
# The driver

# Key kind -> {TYPE KEY-BODY MISS-BODY}: the key of id i and the absent key
# of id i (SPEC.md section 5; `nested` is this report's: a struct holding a
# struct, a String and a List). int-collide's keys come from POOL.
set kinds {
    int-dense {int {i} {i + 1099511627776}}
    int-sparse {int {(i * 2654435761).mod(4294967296)} {(i * 2654435761).mod(4294967296) + 4294967296}}
    str-short {str {hex_after("id_", i)} {hex_after("no_", i)}}
    str-medium {str {hex_after("/usr/share/doc/package-", i).concat("/index.html")} {hex_after("/usr/share/doc/missing-", i).concat("/index.html")}}
    point {Point {Point {x: bit_and(i, 1023), y: shift_right(i, 10)}} {Point {x: bit_and(i, 1023), y: shift_right(i, 10) + 1048576}}}
    nested {Tagged {Tagged {at: Point {x: bit_and(i, 1023), y: shift_right(i, 10)}, name: hex_after("n", i), tags: [i, 7]}} {Tagged {at: Point {x: bit_and(i, 1023), y: shift_right(i, 10)}, name: hex_after("m", i), tags: [i, 7]}}}
    int-collide {int {i} {i}}
}

proc driver {kind} {
    lassign [dict get $::kinds $kind] t keyBody missBody
    set pooled [expr {$kind eq "int-collide"}]
    set map "std::mutable_map::MutableMap\[$t, int\]"
    set set "std::mutable_set::MutableSet\[$t\]"
    return [string map [list @T@ $t @KEY@ $keyBody @MISS@ $missBody @MAP@ $map @SET@ $set @POOLED@ $pooled] {import std::list
import std::str
import std::int
import std::mutable_map
import std::mutable_set
import std::mutable_array
import std::immutable_set

struct Point:
    x: int
    y: int

struct Tagged:
    at: Point
    name: str
    tags: List[int]

digit_chars = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f']

fn hex_after(prefix: str, i: int) -> str:
    if i < 16:
        return prefix.append_char(std::list::get(digit_chars, i, '0'))
    hex_after(prefix, shift_right(i, 4)).append_char(std::list::get(digit_chars, bit_and(i, 15), '0'))

fn key(i: int) -> @T@:
    @KEY@

fn miss(i: int) -> @T@:
    @MISS@

fn arg(args: List[str], i: int) -> int:
    text = std::list::at(args, i):
        on IndexNotFound:
            return 0
    n = std::int::from_string(text):
        on InvalidIntegerText:
            return 0
    n

# The keys: N of them, from POOL (argv after REPS) when pooled.
fn keys(args: List[str], n: int, from: int) -> List[@T@]:
    if @POOLED@ == 1:
        return loop i from 0 to n:
            key(arg(args, from + i))
    loop i from 0 to n:
        key(i)

fn smaller(a: int, b: int) -> int:
    if a < b:
        return a
    b

fn larger(a: int, b: int) -> int:
    if a > b:
        return a
    b

# M absent keys: a pool of max(N, 4096) of them (at most M), cycled.
fn misses(args: List[str], n: int, m: int, from: int) -> List[@T@]:
    if @POOLED@ == 1:
        pool = loop i from 0 to n:
            miss(arg(args, from + n + i))
        return loop j from 0 to m:
            std::list::get(pool, j.mod(n), miss(0))
    count = smaller(m, larger(n, 4096))
    pool = loop j from 0 to count:
        miss(j)
    loop j from 0 to m:
        std::list::get(pool, j.mod(count), miss(0))

# M present keys in SPEC.md's query order.
fn queries(ks: List[@T@], m: int) -> List[@T@]:
    n = std::list::length(ks)
    loop j from 0 to m:
        std::list::get(ks, (j * 40503 + 7).mod(n), key(0))

# ---------------------------------------------------------------------------
# Maps

fn insert_from(place t: @MAP@, ks: List[@T@], i: int) -> unit:
    if i < 0 or i >= std::list::length(ks):
        return unit
    t.set(std::list::at(ks, i), i)
    insert_from(t, ks, i + 1)

fn built(ks: List[@T@], capacity: int) -> @MAP@:
    t = std::mutable_map::with_capacity[@T@, int](capacity)
    insert_from(t, ks, 0)
    t

fn builds(ks: List[@T@], reps: int, capacity: int, acc: int) -> int:
    if reps <= 0:
        return acc
    builds(ks, reps - 1, capacity, acc + built(ks, capacity).length())

fn gets(t: @MAP@, qs: List[@T@], j: int, acc: int) -> int:
    if j < 0 or j >= std::list::length(qs):
        return acc
    v = t.at(std::list::at(qs, j)):
        on std::mutable_map::KeyNotFound:
            1
    gets(t, qs, j + 1, acc + v)

fn get_passes(t: @MAP@, qs: List[@T@], passes: int, acc: int) -> int:
    if passes <= 0:
        return acc
    get_passes(t, qs, passes - 1, gets(t, qs, 0, acc))

fn bit(b: bool) -> int:
    if b:
        return 1
    0

fn members(t: @MAP@, qs: List[@T@], ms: List[@T@], d: @T@, j: int, acc: int) -> int:
    if j < 0 or j >= std::list::length(qs):
        return acc
    members(t, qs, ms, d, j + 1, acc + bit(t.contains(std::list::at(qs, j))) + bit(t.contains(std::list::get(ms, j, d))))

fn member_passes(t: @MAP@, qs: List[@T@], ms: List[@T@], passes: int, acc: int) -> int:
    if passes <= 0:
        return acc
    member_passes(t, qs, ms, passes - 1, members(t, qs, ms, miss(0), 0, acc))

fn has(t: @MAP@, qs: List[@T@], j: int, acc: int) -> int:
    if j < 0 or j >= std::list::length(qs):
        return acc
    has(t, qs, j + 1, acc + bit(t.contains(std::list::at(qs, j))))

fn has_passes(t: @MAP@, qs: List[@T@], passes: int, acc: int) -> int:
    if passes <= 0:
        return acc
    has_passes(t, qs, passes - 1, has(t, qs, 0, acc))

fn replace_from(place t: @MAP@, qs: List[@T@], j: int) -> unit:
    if j < 0 or j >= std::list::length(qs):
        return unit
    t.set(std::list::at(qs, j), j)
    replace_from(t, qs, j + 1)

fn replace_passes(place t: @MAP@, qs: List[@T@], passes: int) -> unit:
    if passes <= 0:
        return unit
    replace_from(t, qs, 0)
    replace_passes(t, qs, passes - 1)

fn remove_from(place t: @MAP@, ks: List[@T@], i: int) -> unit:
    if i < 0 or i >= std::list::length(ks):
        return unit
    r = t.remove(std::list::at(ks, i)):
        on std::mutable_map::KeyNotFound:
            0
    remove_from(t, ks, i + 1)

fn removes(ks: List[@T@], reps: int, acc: int) -> int:
    if reps <= 0:
        return acc
    t = built(ks, 0)
    remove_from(t, ks, 0)
    removes(ks, reps - 1, acc + 1 + t.length())

# The sum of T's values: a loop over the map that collects nothing.
fn visit(t: @MAP@) -> int:
    acc = std::mutable_array::create(1, 0)
    loop e in t:
        a = acc.at(0):
            on IndexNotFound:
                0
        acc.set(0, a + e.value):
            on IndexNotFound:
                unit
    total = acc.at(0):
        on IndexNotFound:
            0
    total

fn visit_passes(t: @MAP@, passes: int, acc: int) -> int:
    if passes <= 0:
        return acc
    visit_passes(t, passes - 1, acc + visit(t))

# Operation J of the mixed workload on T: 8 in 10 lookups of present keys,
# 1 an insertion of absent key J, 1 the removal of the key inserted at J-1.
fn mixed_from(place t: @MAP@, qs: List[@T@], ms: List[@T@], d: @T@, j: int, acc: int) -> int:
    if j < 0 or j >= std::list::length(qs):
        return acc
    r = j.mod(10)
    if r == 8:
        t.set(std::list::get(ms, j, d), j)
        return mixed_from(t, qs, ms, d, j + 1, acc + 1)
    if r == 9:
        v = t.remove(std::list::get(ms, j - 1, d)):
            on std::mutable_map::KeyNotFound:
                0
        return mixed_from(t, qs, ms, d, j + 1, acc + v)
    v = t.at(std::list::at(qs, j)):
        on std::mutable_map::KeyNotFound:
            1
    mixed_from(t, qs, ms, d, j + 1, acc + v)

fn mixed_passes(place t: @MAP@, qs: List[@T@], ms: List[@T@], passes: int, acc: int) -> int:
    if passes <= 0:
        return acc
    a = mixed_from(t, qs, ms, miss(0), 0, acc)
    mixed_passes(t, qs, ms, passes - 1, a)

# Step J of churn: absent key J set, absent key J-8 removed (dead entries
# accumulate until the garbage rule compacts them).
fn churn_from(place t: @MAP@, ms: List[@T@], d: @T@, j: int, acc: int) -> int:
    if j < 0 or j >= std::list::length(ms):
        return acc
    t.set(std::list::at(ms, j), j)
    v = t.remove(std::list::get(ms, j - 8, d)):
        on std::mutable_map::KeyNotFound:
            0
    churn_from(t, ms, d, j + 1, acc + v)

fn churn_passes(place t: @MAP@, ms: List[@T@], passes: int, acc: int) -> int:
    if passes <= 0:
        return acc
    a = churn_from(t, ms, miss(0), 0, acc)
    churn_passes(t, ms, passes - 1, a)

# REPS times: a copy of T and one insertion into the copy.
fn copies(t: @MAP@, k: @T@, reps: int, acc: int) -> int:
    if reps <= 0:
        return acc
    c = t
    c.set(k, reps)
    copies(t, k, reps - 1, acc + c.length())

# ---------------------------------------------------------------------------
# Sets

fn add_from(place s: @SET@, ks: List[@T@], i: int) -> unit:
    if i < 0 or i >= std::list::length(ks):
        return unit
    s.add(std::list::at(ks, i))
    add_from(s, ks, i + 1)

fn set_built(ks: List[@T@]) -> @SET@:
    s = std::mutable_set::create[@T@]()
    add_from(s, ks, 0)
    s

fn set_builds(ks: List[@T@], reps: int, acc: int) -> int:
    if reps <= 0:
        return acc
    set_builds(ks, reps - 1, acc + set_built(ks).length())

fn set_members(s: @SET@, qs: List[@T@], j: int, acc: int) -> int:
    if j < 0 or j >= std::list::length(qs):
        return acc
    set_members(s, qs, j + 1, acc + bit(s.contains(std::list::at(qs, j))))

fn set_passes(s: @SET@, qs: List[@T@], passes: int, acc: int) -> int:
    if passes <= 0:
        return acc
    set_passes(s, qs, passes - 1, set_members(s, qs, 0, acc))

# ImmutableSet, for comparison: built from the List, queried with contains.
fn iset_builds(ks: List[@T@], reps: int, acc: int) -> int:
    if reps <= 0:
        return acc
    s = std::immutable_set::from_list(ks)
    iset_builds(ks, reps - 1, acc + bit(s.contains(key(0))))

fn iset_members(s: ImmutableSet[@T@], qs: List[@T@], j: int, acc: int) -> int:
    if j < 0 or j >= std::list::length(qs):
        return acc
    iset_members(s, qs, j + 1, acc + bit(s.contains(std::list::at(qs, j))))

fn iset_passes(s: ImmutableSet[@T@], qs: List[@T@], passes: int, acc: int) -> int:
    if passes <= 0:
        return acc
    iset_passes(s, qs, passes - 1, iset_members(s, qs, 0, acc))

# ---------------------------------------------------------------------------

fn run(mode: int, n: int, m: int, reps: int, args: List[str]) -> int:
    ks = keys(args, n, 5)
    if mode == 0:
        qs = queries(ks, m)
        ms = misses(args, n, m, 5)
        return std::list::length(ks) + std::list::length(qs) + std::list::length(ms)
    if mode == 1:
        return builds(ks, reps, 0, 0)
    if mode == 2:
        return builds(ks, reps, n, 0)
    if mode == 3:
        return get_passes(built(ks, 0), queries(ks, m), reps, 0)
    if mode == 4:
        return get_passes(built(ks, 0), misses(args, n, m, 5), reps, 0)
    if mode == 5:
        return member_passes(built(ks, 0), queries(ks, m), misses(args, n, m, 5), reps, 0)
    if mode == 6:
        t = built(ks, 0)
        replace_passes(t, queries(ks, m), reps)
        return t.length()
    if mode == 7:
        return removes(ks, reps, 0)
    if mode == 8:
        return visit_passes(built(ks, 0), reps, 0)
    if mode == 9:
        t = built(ks, 0)
        return mixed_passes(t, queries(ks, m), misses(args, n, m, 5), reps, 0)
    if mode == 10:
        t = built(ks, 0)
        return churn_passes(t, misses(args, n, m, 5), reps, 0)
    if mode == 11:
        return copies(built(ks, 0), miss(1), reps, 0)
    if mode == 12:
        return set_builds(ks, reps, 0)
    if mode == 13:
        return set_passes(set_built(ks), queries(ks, m), reps, 0)
    if mode == 14:
        return set_passes(set_built(ks), misses(args, n, m, 5), reps, 0)
    if mode == 15:
        return has_passes(built(ks, 0), queries(ks, m), reps, 0)
    if mode == 16:
        return has_passes(built(ks, 0), misses(args, n, m, 5), reps, 0)
    if mode == 17:
        return iset_builds(ks, reps, 0)
    if mode == 18:
        return iset_passes(std::immutable_set::from_list(ks), queries(ks, m), reps, 0)
    if mode == 19:
        return iset_passes(std::immutable_set::from_list(ks), misses(args, n, m, 5), reps, 0)
    0

args = argv():
    on InvalidArgumentEncoding:
        []
run(arg(args, 1), arg(args, 2), arg(args, 3), arg(args, 4), args)
}]
}

# Mode name -> {driver mode number, how its per-operation time is derived}.
set modeNumbers {
    keys 0 build 1 presized 2 hit 3 miss 4 member 5 replace 6 remove 7 iterate 8
    mixed 9 churn 10 copy 11 set-build 12 set-hit 13 set-miss 14 has-hit 15 has-miss 16
    iset-build 17 iset-hit 18 iset-miss 19
}

set reference [file join $root audit hash-table reference target release hash-table-reference]

proc pool {kind n} {
    if {$kind ne "int-collide"} {
        return {}
    }
    return [concat [split [string trim [exec $::reference collide $n 0]] \n] \
                   [split [string trim [exec $::reference collide $n 512]] \n]]
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
        error "bench/mutable-map.tcl: a run ended with [core::formatValue $value]"
    }
    return [list [expr {$best / 1000.0}] [lindex $value 1]]
}

# With -instructions 1: the instructions callgrind counts for one native run
# with ARGS (deterministic: no machine noise), as `timed` returns times --
# {COUNT CHECKSUM} -- so every formula above applies to them unchanged
# (audit/hash-table/tools/instructions.tcl's method; callgrind sees no cache
# misses or branch costs).
proc counted {text args} {
    set dir [file tempdir botlish-mm-instructions]
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
        error "bench/mutable-map.tcl: no instruction count: $out"
    }
    # (in thousands, so that the formulas' * 1000.0 gives instructions)
    return [list [expr {$n / 1000.0}] -]
}

proc allocations {hir args} {
    core::process::withArgv [argvOf {*}$args] {
        set report [native::allocationReport $hir summary]
    }
    return [dict get $report total allocations]
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

if {[dict get $options -stdlib] ne ""} {
    set ::core::libraryDir [file normalize [dict get $options -stdlib]]
}
set ops [dict get $options -ops]
set passes [dict get $options -passes]
set buildPasses [dict get $options -build-passes]
foreach kind [dict get $options -keys] {
    set hir [surface::compile [driver $kind] bench.bot -warnings off]
    set text [native::nir $hir]
    foreach n [dict get $options -sizes] {
        if {$kind eq "int-collide" && $n > 1024} continue
        set p [pool $kind $n]
        set reps [expr {max(1, $ops / $n)}]
        set m $ops
        foreach mode [dict get $options -modes] {
            set number [dict get $modeNumbers $mode]
            switch -- $mode {
                build - presized - set-build - iset-build {
                    lassign [timed $text $number $n $m $reps {*}$p] t1 sum
                    lassign [timed $text $number $n $m [expr {$buildPasses * $reps}] {*}$p] t2
                    set per [expr {($t2 - $t1) * 1000.0 / (($buildPasses - 1) * $reps * $n)}]
                }
                copy {
                    set r [expr {max(10, $reps)}]
                    lassign [timed $text $number $n $m $r {*}$p] t1 sum
                    lassign [timed $text $number $n $m [expr {$buildPasses * $r}] {*}$p] t2
                    set per [expr {($t2 - $t1) * 1000.0 / (($buildPasses - 1) * $r)}]
                }
                remove {
                    lassign [timed $text 7 $n $m $reps {*}$p] t1 sum
                    lassign [timed $text 7 $n $m [expr {$buildPasses * $reps}] {*}$p] t2
                    lassign [timed $text 1 $n $m $reps {*}$p] b1
                    lassign [timed $text 1 $n $m [expr {$buildPasses * $reps}] {*}$p] b2
                    set per [expr {(($t2 - $t1) - ($b2 - $b1)) * 1000.0 / (($buildPasses - 1) * $reps * $n)}]
                }
                iterate {
                    set p8 [expr {max($passes, (20 * $ops) / $n)}]
                    lassign [timed $text 8 $n $m 1 {*}$p] t1 sum
                    lassign [timed $text 8 $n $m [expr {1 + $p8}] {*}$p] t3
                    set per [expr {($t3 - $t1) * 1000.0 / ($p8 * $n)}]
                }
                default {
                    lassign [timed $text $number $n $m 1 {*}$p] t1 sum
                    lassign [timed $text $number $n $m [expr {1 + $passes}] {*}$p] t3
                    set per [expr {($t3 - $t1) * 1000.0 / ($passes * $m * ($mode eq "member" ? 2 : 1))}]
                }
            }
            row [list $kind $n $mode $m $reps [format %.1f $t1] [format %.2f $per] $sum]
            if {[dict get $options -allocations] && $mode in {hit miss has-hit has-miss member replace iterate mixed churn set-hit set-miss}} {
                set a1 [allocations $hir $number $n $m 1 {*}$p]
                set a3 [allocations $hir $number $n $m 3 {*}$p]
                row [list $kind $n $mode-allocations $m 2 [expr {$a3 - $a1}] [format %.4f [expr {($a3 - $a1) / double(2 * $m)}]] -]
            }
        }
    }
}
if {$out ne ""} {
    close $out
}
