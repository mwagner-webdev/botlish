# enums.tcl -- the performance report of payload-free enums (ENUMS.md,
# "Performance").
#
#   tclsh9.0 bench/enums.tcl ?-runs N? ?-n N? ?-native-n N? ?-backends LIST?
#
# One table, on every backend (Tcl interp, Tcl compile, Cranelift): programs
# that each repeat one operation N times inside a collecting loop, reported
# as time per operation over the program's baseline, (program - baseline) /
# N, the whole program per operation in parentheses (bench/mutable-
# array.tcl's method). Every enum operation is measured beside the same
# operation on small Ints and, where it means something, Bools: a case
# lookup, a copy, a comparison, a pass and return, iterating a List,
# MutableArray at/set/swap, MutableVector push/pop, and ImmutableSet
# membership. A second table gives natively, for each program, the number
# of heap allocations (Cranelift's allocation counters): an enum program
# allocates exactly what its Int twin does -- nothing per case.
#
# Every timed number is best of RUNS in-process executions, compilation
# excluded.

set root [file dirname [file dirname [file normalize [info script]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root bench backends.tcl]
interp recursionlimit {} 200000

set runs 5
set n 2000
set nativeN 200000
set backends {interp compile native}
foreach {option value} $args {
    switch -- $option {
        -runs { set runs $value }
        -n { set n $value }
        -native-n { set nativeN $value }
        -backends { set backends $value }
        default { error "unknown option $option" }
    }
}

set prelude "import list
import mutable_array
import mutable_vector
import immutable_set

enum Kind:
    Boat,
    Car,
    Truck,
    Tank,

fn pick(i: int) -> Kind:
    if mod(i, 4) == 0:
        Kind::Boat
    elif mod(i, 4) == 1:
        Kind::Car
    elif mod(i, 4) == 2:
        Kind::Truck
    else:
        Kind::Tank

fn ipick(i: int) -> int:
    if mod(i, 4) == 0:
        0
    elif mod(i, 4) == 1:
        1
    elif mod(i, 4) == 2:
        2
    else:
        3

fn bpick(i: int) -> bool:
    mod(i, 2) == 0

fn kid(k: Kind) -> Kind:
    k

fn iid(k: int) -> int:
    k

fn kinds(n: int) -> List\[Kind\]:
    loop i from 0 to n:
        pick(i)

fn ints(n: int) -> List\[int\]:
    loop i from 0 to n:
        ipick(i)

"

# A function `f(n: int) -> int` of BODY lines, called with N under a
# handler (IndexNotFound, for the collection programs).
proc Fn {n body} {
    set text "fn f(n: int) -> int errors IndexNotFound:\n"
    foreach line $body {
        append text "    $line\n"
    }
    append text "r = f($n):\n    on IndexNotFound:\n        -1\nr\n"
    return $text
}

# BODY lines as a collecting loop `i from 0 to n`, then the List's length.
proc Each {lines} {
    return [concat [list "xs = loop i from 0 to n:"] [lmap line $lines {string cat "    " $line}] [list "list::length(xs)"]]
}

proc programText {kind n} {
    set p $::prelude
    switch -- $kind {
        loop-base   { append p [Fn $n [Each {i}]] }
        case        { append p [Fn $n [Each {Kind::Car}]] }
        int-const   { append p [Fn $n [Each {1}]] }
        copy        { append p [Fn $n [Each {"a = pick(i)" "b = a" "c = b" "c"}]] }
        int-copy    { append p [Fn $n [Each {"a = ipick(i)" "b = a" "c = b" "c"}]] }
        pick        { append p [Fn $n [Each {"pick(i)"}]] }
        ipick       { append p [Fn $n [Each {"ipick(i)"}]] }
        bpick       { append p [Fn $n [Each {"bpick(i)"}]] }
        compare     { append p [Fn $n [Each {"pick(i) == Kind::Car"}]] }
        int-compare { append p [Fn $n [Each {"ipick(i) == 1"}]] }
        bool-compare { append p [Fn $n [Each {"bpick(i) == true"}]] }
        pass        { append p [Fn $n [Each {"kid(pick(i))"}]] }
        int-pass    { append p [Fn $n [Each {"iid(ipick(i))"}]] }
        list-base   { append p [Fn $n {"xs = kinds(n)" "list::length(xs)"}] }
        list-iterate { append p [Fn $n {"xs = kinds(n)" "ys = loop x in xs:" "    x == Kind::Car" "list::length(ys)"}] }
        int-list-base { append p [Fn $n {"xs = ints(n)" "list::length(xs)"}] }
        int-list-iterate { append p [Fn $n {"xs = ints(n)" "ys = loop x in xs:" "    x == 1" "list::length(ys)"}] }
        array-base  { append p [Fn $n {"a = mutable_array::create(n, Kind::Car)" "a.capacity()"}] }
        array-at    { append p [Fn $n [concat {"a = mutable_array::create(n, Kind::Car)"} [Each {"a.at(i)"}]]] }
        array-set   { append p [Fn $n [concat {"a = mutable_array::create(n, Kind::Car)"} [Each {"a.set(i, Kind::Boat)"}]]] }
        array-swap  { append p [Fn $n [concat {"a = mutable_array::create(n, Kind::Car)"} [Each {"a.swap(i, Kind::Tank)"}]]] }
        int-array-base { append p [Fn $n {"a = mutable_array::create(n, 1)" "a.capacity()"}] }
        int-array-at   { append p [Fn $n [concat {"a = mutable_array::create(n, 1)"} [Each {"a.at(i)"}]]] }
        int-array-set  { append p [Fn $n [concat {"a = mutable_array::create(n, 1)"} [Each {"a.set(i, 0)"}]]] }
        int-array-swap { append p [Fn $n [concat {"a = mutable_array::create(n, 1)"} [Each {"a.swap(i, 3)"}]]] }
        vector-base { append p [Fn $n {"v = mutable_vector::from_list(kinds(0))" "v.length()"}] }
        vector-push-pop { append p [Fn $n [concat {"v = mutable_vector::from_list(kinds(0))"} [Each {"v.push(pick(i))" "v.pop()"}]]] }
        int-vector-base { append p [Fn $n {"v = mutable_vector::from_list(ints(0))" "v.length()"}] }
        int-vector-push-pop { append p [Fn $n [concat {"v = mutable_vector::from_list(ints(0))"} [Each {"v.push(ipick(i))" "v.pop()"}]]] }
        set-base    { append p [Fn $n [concat {"s = immutable_set::from_list(\[Kind::Boat, Kind::Car, Kind::Truck\])"} [Each {"pick(i)"}]]] }
        set-contains { append p [Fn $n [concat {"s = immutable_set::from_list(\[Kind::Boat, Kind::Car, Kind::Truck\])"} [Each {"immutable_set::contains(s, pick(i))"}]]] }
        int-set-base { append p [Fn $n [concat {"s = immutable_set::from_list(\[0, 1, 2\])"} [Each {"ipick(i)"}]]] }
        int-set-contains { append p [Fn $n [concat {"s = immutable_set::from_list(\[0, 1, 2\])"} [Each {"immutable_set::contains(s, ipick(i))"}]]] }
        default { error "unknown program $kind" }
    }
    return $p
}

proc program {kind n} {
    return [surface::compile [programText $kind $n] -warnings off]
}

# Best-of-RUNS microseconds of HIR on BACKEND (interp, compile, native).
proc timeOn {backend hir} {
    if {$backend eq "native"} {
        lassign [native::measure $hir $::runs] lower compile best collections value
        return $best
    }
    set program [hir::lower $hir]
    core::useBackend $backend
    core::evalProgram $program
    set best ""
    for {set i 0} {$i < $::runs} {incr i} {
        set micros [lindex [time {core::evalProgram $program}] 0]
        if {$best eq "" || $micros < $best} {
            set best $micros
        }
    }
    return $best
}

proc nOf {backend} {
    return [expr {$backend eq "native" ? $::nativeN : $::n}]
}

# {DELTA WHOLE} nanoseconds per operation of KIND over BASE (or 0).
proc perOp {kind base backend} {
    set n [nOf $backend]
    set t [timeOn $backend [program $kind $n]]
    set b [expr {$base eq "" ? 0 : [timeOn $backend [program $base $n]]}]
    return [list [expr {($t - $b) * 1000.0 / $n}] [expr {$t * 1000.0 / $n}]]
}

proc ns {x} {
    return [format "%.1f ns" $x]
}

set operations {
    "case constant (Kind::Car)" case loop-base
    "... Int constant, for comparison" int-const loop-base
    "copy a value through two bindings" copy pick
    "... an Int, for comparison" int-copy ipick
    "compare with a case (==)" compare pick
    "... an Int with an Int" int-compare ipick
    "... a Bool with true" bool-compare bpick
    "pass and return through a typed function" pass pick
    "... an Int, for comparison" int-pass ipick
    "iterate List[Kind] (compare each element)" list-iterate list-base
    "... List[int], for comparison" int-list-iterate int-list-base
    "MutableArray[Kind] at" array-at array-base
    "MutableArray[Kind] set" array-set array-base
    "MutableArray[Kind] swap" array-swap array-base
    "... MutableArray[int] at" int-array-at int-array-base
    "... MutableArray[int] set" int-array-set int-array-base
    "... MutableArray[int] swap" int-array-swap int-array-base
    "MutableVector[Kind] push then pop" vector-push-pop vector-base
    "... MutableVector[int] push then pop" int-vector-push-pop int-vector-base
    "ImmutableSet[Kind] contains (3 members)" set-contains set-base
    "... ImmutableSet[int] contains (3 members)" int-set-contains int-set-base
}

puts "Enums: performance (n = $n operations per program on the Tcl backends, $nativeN natively; best of $runs runs)\n"
puts [bench::backends::manifest $backends]
puts ""
puts "## Operations\n"
puts "| operation | baseline | [join [lmap b $backends {bench::backends::displayName $b}] { | }] |"
puts "|---|---|[string repeat ---:| [llength $backends]]"
foreach {label kind base} $operations {
    set cells {}
    foreach backend $backends {
        lassign [perOp $kind $base $backend] delta whole
        lappend cells "[ns $delta] ([ns $whole])"
    }
    puts "| $label | $base | [join $cells { | }] |"
}

if {"native" in $backends} {
    puts "\n## Native allocations\n"
    puts "Heap allocations of each whole program (Cranelift's counters), N = $nativeN.\n"
    puts "| program | allocations | Lists | Structs | MutableArrays | bytes |"
    puts "|---|---:|---:|---:|---:|---:|"
    set seen {}
    foreach {label kind base} $operations {
        foreach k [list $base $kind] {
            if {$k in $seen} continue
            lappend seen $k
            set report [native::allocationReport [program $k $nativeN] summary]
            puts "| $k | [dict get $report total allocations] | [dict get $report byKind List allocations] | [dict get $report byKind Struct allocations] | [dict get $report byKind MutableArray allocations] | [dict get $report total allocatedBytes] |"
        }
    }
}
