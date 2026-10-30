# value-identity.tcl -- the performance report of semantic value identity
# and std::immutable_map (REPRESENTATION-INDEPENDENT-VALUE-IDENTITY.md,
# "Performance").
#
#   tclsh9.0 bench/value-identity.tcl ?-keys LIST? ?-sizes LIST?
#       ?-modes LIST? ?-ops M? ?-runs R? ?-passes P? ?-out FILE?
#       ?-allocations 0|1? ?-instructions 0|1?
#
# For every key kind, one Botlish program (the driver below, typed for the
# kind), compiled and lowered once; then one native run per size and mode,
# argv MODE N M PASSES, the best of R runs in one process. Every map is
# ImmutableMap[K, int], key id i holding the value i, built by inserting
# the ids into a MutableMap in a given order and freezing it; "reversed" is
# the same associations inserted last to first. Each row's per-operation
# time is a difference of two runs, (T[1 + P] - T[1]) / (P UNITS), so the
# setup (key Lists, the maps compared) cancels:
#
#   freeze           per entry: MutableMap.freeze of the built map
#   mbuild           per entry: building the MutableMap itself, for scale
#   hit, miss        per lookup: `at` of a present key / `contains` of an
#                    absent one (M lookups, SPEC.md's query order)
#   mhit, mmiss      the same on the MutableMap, for comparison
#   iterate          per entry visited: a loop over the map
#   eq-same          per entry: == of two equal maps built in the same order
#                    (the positional prefix matches every entry)
#   eq-reordered     per entry: == of two equal maps in opposite orders
#                    (every entry matched through hash buckets)
#   neq-early        per entry: == of a map and a reversed one whose first
#                    association (in the left map's order) has another value
#   neq-late         the same, the left map's last association changed
#   neq-length       per comparison: == of maps of N and N - 1 entries
#   hash             per entry: the public hash of a map
#   table-hash       per entry: the keyed table hash of a map (a fixture
#                    module of a private copy of the standard library, as
#                    the standard library's own hash structures call it)
#   list-eq          per element: == of two equal Lists of the keys, for
#                    scale (positional equality)
#   set-eq, set-hash per member: == of two ImmutableSets of the keys built
#                    in opposite orders, and a set's public hash
#
# Rows (TSV) to stdout and -out:
#
#   keys n mode m passes best-us per-op-ns checksum
#
# Allocation accounting (-allocations 1): for every mode but mbuild and the
# baseline, the allocations of three passes against one, per operation
# (native::allocationReport): a row MODE-allocations.
#
# -instructions 1 counts instructions (valgrind's callgrind, one run each)
# instead of timing: the per-op column is then instructions per operation
# (bench/mutable-map.tcl's method; use a smaller -ops).

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root core core.tcl]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

set options [dict create -keys {int str struct} -sizes {16 1024 65536} \
    -modes {freeze mbuild hit miss mhit mmiss iterate eq-same eq-reordered neq-early neq-late neq-length hash table-hash list-eq set-eq set-hash} \
    -ops 200000 -runs 5 -passes 10 -out "" -allocations 0 -instructions 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "bench/value-identity.tcl: unknown option $option" }
    dict set options $option $value
}

# Key kind -> {TYPE KEY-BODY MISS-BODY}: the key of id i and the absent key
# of id i.
set kinds {
    int {int {i} {i + 1099511627776}}
    str {str {hex_after("id_", i)} {hex_after("no_", i)}}
    struct {Point {Point {x: bit_and(i, 1023), y: shift_right(i, 10)}} {Point {x: bit_and(i, 1023), y: shift_right(i, 10) + 1048576}}}
}

proc driver {kind} {
    lassign [dict get $::kinds $kind] t keyBody missBody
    return [string map [list @T@ $t @KEY@ $keyBody @MISS@ $missBody \
        @MAP@ "std::mutable_map::MutableMap\[$t, int\]" @IMAP@ "std::immutable_map::ImmutableMap\[$t, int\]"] {import std::list
import std::str
import std::int
import std::mutable_map
import std::immutable_map
import std::immutable_set
import std::mutable_array
import std::hashfix

struct Point:
    x: int
    y: int

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

fn bit(b: bool) -> int:
    if b:
        return 1
    0

fn ids(n: int) -> List[int]:
    loop i from 0 to n:
        i

fn rids(n: int) -> List[int]:
    loop i down from n - 1 through 0:
        i

fn keys(n: int) -> List[@T@]:
    loop i from 0 to n:
        key(i)

fn rkeys(n: int) -> List[@T@]:
    loop i down from n - 1 through 0:
        key(i)

# M present keys in SPEC.md's query order, and M absent ones.
fn queries(n: int, m: int) -> List[@T@]:
    loop j from 0 to m:
        key((j * 40503 + 7).mod(n))

fn misses(n: int, m: int) -> List[@T@]:
    loop j from 0 to m:
        miss((j * 40503 + 7).mod(n))

# The value of key id ID: ID, or ID + 1 for the id CHANGED.
fn value_of(id: int, changed: int) -> int:
    if id == changed:
        return id + 1
    id

fn insert_ids(place t: @MAP@, order: List[int], j: int, changed: int) -> unit:
    if j < 0 or j >= std::list::length(order):
        return unit
    id = std::list::at(order, j)
    t.set(key(id), value_of(id, changed))
    insert_ids(t, order, j + 1, changed)

fn built(order: List[int], changed: int) -> @MAP@:
    t = std::mutable_map::create[@T@, int]()
    insert_ids(t, order, 0, changed)
    t

fn frozen(order: List[int], changed: int) -> @IMAP@:
    built(order, changed).freeze()

fn freezes(t: @MAP@, passes: int, acc: int) -> int:
    if passes <= 0:
        return acc
    freezes(t, passes - 1, acc + t.freeze().length())

fn mbuilds(order: List[int], passes: int, acc: int) -> int:
    if passes <= 0:
        return acc
    mbuilds(order, passes - 1, acc + built(order, -1).length())

fn gets(t: @IMAP@, qs: List[@T@], j: int, acc: int) -> int:
    if j < 0 or j >= std::list::length(qs):
        return acc
    v = t.at(std::list::at(qs, j)):
        on std::immutable_map::KeyNotFound:
            1
    gets(t, qs, j + 1, acc + v)

fn get_passes(t: @IMAP@, qs: List[@T@], passes: int, acc: int) -> int:
    if passes <= 0:
        return acc
    get_passes(t, qs, passes - 1, gets(t, qs, 0, acc))

fn has(t: @IMAP@, qs: List[@T@], j: int, acc: int) -> int:
    if j < 0 or j >= std::list::length(qs):
        return acc
    has(t, qs, j + 1, acc + bit(t.contains(std::list::at(qs, j))))

fn has_passes(t: @IMAP@, qs: List[@T@], passes: int, acc: int) -> int:
    if passes <= 0:
        return acc
    has_passes(t, qs, passes - 1, has(t, qs, 0, acc))

fn mgets(t: @MAP@, qs: List[@T@], j: int, acc: int) -> int:
    if j < 0 or j >= std::list::length(qs):
        return acc
    v = t.at(std::list::at(qs, j)):
        on std::mutable_map::KeyNotFound:
            1
    mgets(t, qs, j + 1, acc + v)

fn mget_passes(t: @MAP@, qs: List[@T@], passes: int, acc: int) -> int:
    if passes <= 0:
        return acc
    mget_passes(t, qs, passes - 1, mgets(t, qs, 0, acc))

fn mhas(t: @MAP@, qs: List[@T@], j: int, acc: int) -> int:
    if j < 0 or j >= std::list::length(qs):
        return acc
    mhas(t, qs, j + 1, acc + bit(t.contains(std::list::at(qs, j))))

fn mhas_passes(t: @MAP@, qs: List[@T@], passes: int, acc: int) -> int:
    if passes <= 0:
        return acc
    mhas_passes(t, qs, passes - 1, mhas(t, qs, 0, acc))

fn visit(t: @IMAP@) -> int:
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

fn visit_passes(t: @IMAP@, passes: int, acc: int) -> int:
    if passes <= 0:
        return acc
    visit_passes(t, passes - 1, acc + visit(t))

fn eq_passes(a: @IMAP@, b: @IMAP@, passes: int, acc: int) -> int:
    if passes <= 0:
        return acc
    eq_passes(a, b, passes - 1, acc + bit(a == b))

fn hash_passes(a: @IMAP@, passes: int, acc: int) -> int:
    if passes <= 0:
        return acc
    hash_passes(a, passes - 1, bit_xor(acc, hash(a)))

fn table_hash_passes(a: @IMAP@, passes: int, acc: int) -> int:
    if passes <= 0:
        return acc
    table_hash_passes(a, passes - 1, bit_xor(acc, std::hashfix::keyed(a)))

fn list_eq_passes(a: List[@T@], b: List[@T@], passes: int, acc: int) -> int:
    if passes <= 0:
        return acc
    list_eq_passes(a, b, passes - 1, acc + bit(a == b))

fn set_eq_passes(a: ImmutableSet[@T@], b: ImmutableSet[@T@], passes: int, acc: int) -> int:
    if passes <= 0:
        return acc
    set_eq_passes(a, b, passes - 1, acc + bit(a == b))

fn set_hash_passes(a: ImmutableSet[@T@], passes: int, acc: int) -> int:
    if passes <= 0:
        return acc
    set_hash_passes(a, passes - 1, bit_xor(acc, hash(a)))

fn run(mode: int, n: int, m: int, passes: int) -> int:
    if mode == 0:
        return std::list::length(keys(n)) + std::list::length(queries(n, m))
    if mode == 1:
        return freezes(built(ids(n), -1), passes, 0)
    if mode == 2:
        return mbuilds(ids(n), passes, 0)
    if mode == 3:
        return get_passes(frozen(ids(n), -1), queries(n, m), passes, 0)
    if mode == 4:
        return has_passes(frozen(ids(n), -1), misses(n, m), passes, 0)
    if mode == 5:
        return mget_passes(built(ids(n), -1), queries(n, m), passes, 0)
    if mode == 6:
        return mhas_passes(built(ids(n), -1), misses(n, m), passes, 0)
    if mode == 7:
        return visit_passes(frozen(ids(n), -1), passes, 0)
    if mode == 8:
        return eq_passes(frozen(ids(n), -1), frozen(ids(n), -1), passes, 0)
    if mode == 9:
        return eq_passes(frozen(ids(n), -1), frozen(rids(n), -1), passes, 0)
    if mode == 10:
        return eq_passes(frozen(ids(n), -1), frozen(rids(n), 0), passes, 0)
    if mode == 11:
        return eq_passes(frozen(ids(n), -1), frozen(rids(n), n - 1), passes, 0)
    if mode == 12:
        return eq_passes(frozen(ids(n), -1), frozen(ids(n - 1), -1), passes, 0)
    if mode == 13:
        return hash_passes(frozen(ids(n), -1), passes, 0)
    if mode == 14:
        return table_hash_passes(frozen(ids(n), -1), passes, 0)
    if mode == 15:
        return list_eq_passes(keys(n), keys(n), passes, 0)
    if mode == 16:
        return set_eq_passes(std::immutable_set::from_list(keys(n)), std::immutable_set::from_list(rkeys(n)), passes, 0)
    if mode == 17:
        return set_hash_passes(std::immutable_set::from_list(keys(n)), passes, 0)
    0

args = argv():
    on InvalidArgumentEncoding:
        []
run(arg(args, 1), arg(args, 2), arg(args, 3), arg(args, 4))
}]
}

# Mode name -> {driver mode number, the unit its time is divided by}.
set modes {
    keys {0 -} freeze {1 entry} mbuild {2 entry} hit {3 lookup} miss {4 lookup}
    mhit {5 lookup} mmiss {6 lookup} iterate {7 entry} eq-same {8 entry}
    eq-reordered {9 entry} neq-early {10 entry} neq-late {11 entry}
    neq-length {12 comparison} hash {13 entry} table-hash {14 entry}
    list-eq {15 entry} set-eq {16 entry} set-hash {17 entry}
}

# The fixture module that may call the private table hash, in a private copy
# of the standard library (the standard library's hash structures call it
# so; HASHABLE-AND-KEYED-HASH.md).
set library [file tempdir botlish-vi-bench]
foreach entry [glob -directory $::core::libraryDir *] {
    file copy $entry $library
}
set f [open [file join $library hashfix.bot] w]
puts -nonewline $f "import std::table_hash\n\nfn keyed(x: Hashable) -> int:\n    std::table_hash::of(x)\n"
close $f
set ::core::libraryDir $library

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
        error "bench/value-identity.tcl: a run ended with [core::formatValue $value]"
    }
    return [list [expr {$best / 1000.0}] [lindex $value 1]]
}

# With -instructions 1: the instructions callgrind counts for one native run
# with ARGS, in thousands, as `timed` returns microseconds, so the formulas
# apply unchanged.
proc counted {text args} {
    set dir [file tempdir botlish-vi-instructions]
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
        error "bench/value-identity.tcl: no instruction count: $out"
    }
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

set passes [dict get $options -passes]
set m [dict get $options -ops]
try {
    foreach kind [dict get $options -keys] {
        set hir [surface::compile [driver $kind] bench.bot -warnings off]
        set text [native::nir $hir]
        foreach n [dict get $options -sizes] {
            foreach mode [dict get $options -modes] {
                lassign [dict get $modes $mode] number unit
                # Enough passes that the measured work is well above the
                # noise of the setup it is the difference from (building the
                # maps compared costs a few hundred ns per entry): PASSES
                # passes of OPS lookups; at least 10 PASSES passes of a
                # per-entry operation, and 20 OPS entries in all; OPS of an
                # O(1) comparison (at a large N its setup still dominates:
                # the small sizes are its measurement).
                switch -- $unit {
                    lookup { set p $passes }
                    entry { set p [expr {max(10 * $passes, (20 * $m) / $n)}] }
                    default { set p $m }
                }
                lassign [timed $text $number $n $m 1] t1 sum
                if {$unit eq "-"} {
                    row [list $kind $n $mode $m 1 [format %.1f $t1] - $sum]
                    continue
                }
                lassign [timed $text $number $n $m [expr {1 + $p}]] t2
                set units [switch -- $unit {
                    entry { expr {$p * $n} }
                    lookup { expr {$p * $m} }
                    comparison { set p }
                }]
                row [list $kind $n $mode $m $p [format %.1f $t1] [format %.2f [expr {($t2 - $t1) * 1000.0 / $units}]] $sum]
                if {[dict get $options -allocations] && $mode ne "mbuild"} {
                    set a1 [allocations $hir $number $n $m 1]
                    set a3 [allocations $hir $number $n $m 3]
                    set per [expr {$unit eq "entry" ? 2 * $n : ($unit eq "lookup" ? 2 * $m : 2)}]
                    row [list $kind $n $mode-allocations $m 2 [expr {$a3 - $a1}] [format %.4f [expr {($a3 - $a1) / double($per)}]] -]
                }
            }
        }
    }
} finally {
    file delete -force $library
    if {$out ne ""} {
        close $out
    }
}
