# enums.tcl -- the performance report of enums (ENUMS.md, "Performance";
# PORTABILITY-PAYLOAD-ENUMS-MILESTONE-1.md, "Performance and allocations").
#
#   tclsh9.0 bench/enums.tcl ?-runs N? ?-n N? ?-native-n N? ?-backends LIST?
#                            ?-only {KIND ...}?
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
# Payload-bearing cases (PORTABILITY-PAYLOAD-ENUMS-MILESTONE-1.md) are
# measured beside a named struct with the same fields: a construction, a
# payload-free case of an enum with payload-bearing cases, ==, hash, a pass
# and return, MutableArray set, MutableVector push/pop, and a larger nested
# payload; the allocation table counts their EnumCase objects too.
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
# -only {KIND ...}: only the operations whose program is one of these.
set only {}
foreach {option value} $args {
    switch -- $option {
        -runs { set runs $value }
        -n { set n $value }
        -native-n { set nativeN $value }
        -backends { set backends $value }
        -only { set only $value }
        default { error "unknown option $option" }
    }
}

set prelude "import std::list
import std::mutable_array
import std::mutable_vector
import std::immutable_set

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

enum Expr:
    Num {value: int},
    Param,
    Add {left: int, right: int},
    Call {args: List\[int\], f: Pair},

struct Pair:
    left: int
    right: int

struct CallTwin:
    args: List\[int\]
    f: Pair

fn mk(i: int) -> Expr:
    Expr::Add {left: i, right: i}

fn smk(i: int) -> Pair:
    Pair {left: i, right: i}

fn eid(e: Expr) -> Expr:
    e

fn sid(p: Pair) -> Pair:
    p

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
    return [concat [list "xs = loop i from 0 to n:"] [lmap line $lines {string cat "    " $line}] [list "std::list::length(xs)"]]
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
        list-base   { append p [Fn $n {"xs = kinds(n)" "std::list::length(xs)"}] }
        list-iterate { append p [Fn $n {"xs = kinds(n)" "ys = loop x in xs:" "    x == Kind::Car" "std::list::length(ys)"}] }
        int-list-base { append p [Fn $n {"xs = ints(n)" "std::list::length(xs)"}] }
        int-list-iterate { append p [Fn $n {"xs = ints(n)" "ys = loop x in xs:" "    x == 1" "std::list::length(ys)"}] }
        array-base  { append p [Fn $n {"a = std::mutable_array::create(n, Kind::Car)" "a.capacity()"}] }
        array-at    { append p [Fn $n [concat {"a = std::mutable_array::create(n, Kind::Car)"} [Each {"a.at(i)"}]]] }
        array-set   { append p [Fn $n [concat {"a = std::mutable_array::create(n, Kind::Car)"} [Each {"a.set(i, Kind::Boat)"}]]] }
        array-swap  { append p [Fn $n [concat {"a = std::mutable_array::create(n, Kind::Car)"} [Each {"a.swap(i, Kind::Tank)"}]]] }
        int-array-base { append p [Fn $n {"a = std::mutable_array::create(n, 1)" "a.capacity()"}] }
        int-array-at   { append p [Fn $n [concat {"a = std::mutable_array::create(n, 1)"} [Each {"a.at(i)"}]]] }
        int-array-set  { append p [Fn $n [concat {"a = std::mutable_array::create(n, 1)"} [Each {"a.set(i, 0)"}]]] }
        int-array-swap { append p [Fn $n [concat {"a = std::mutable_array::create(n, 1)"} [Each {"a.swap(i, 3)"}]]] }
        vector-base { append p [Fn $n {"v = std::mutable_vector::from_list(kinds(0))" "v.length()"}] }
        vector-push-pop { append p [Fn $n [concat {"v = std::mutable_vector::from_list(kinds(0))"} [Each {"v.push(pick(i))" "v.pop()"}]]] }
        int-vector-base { append p [Fn $n {"v = std::mutable_vector::from_list(ints(0))" "v.length()"}] }
        int-vector-push-pop { append p [Fn $n [concat {"v = std::mutable_vector::from_list(ints(0))"} [Each {"v.push(ipick(i))" "v.pop()"}]]] }
        set-base    { append p [Fn $n [concat {"s = std::immutable_set::from_list(\[Kind::Boat, Kind::Car, Kind::Truck\])"} [Each {"pick(i)"}]]] }
        set-contains { append p [Fn $n [concat {"s = std::immutable_set::from_list(\[Kind::Boat, Kind::Car, Kind::Truck\])"} [Each {"std::immutable_set::contains(s, pick(i))"}]]] }
        int-set-base { append p [Fn $n [concat {"s = std::immutable_set::from_list(\[0, 1, 2\])"} [Each {"ipick(i)"}]]] }
        int-set-contains { append p [Fn $n [concat {"s = std::immutable_set::from_list(\[0, 1, 2\])"} [Each {"std::immutable_set::contains(s, ipick(i))"}]]] }
        payload-construct { append p [Fn $n [Each {"Expr::Add {left: i, right: i}"}]] }
        struct-construct  { append p [Fn $n [Each {"Pair {left: i, right: i}"}]] }
        mixed-free-case   { append p [Fn $n [Each {Expr::Param}]] }
        mk                { append p [Fn $n [Each {"mk(i)"}]] }
        smk               { append p [Fn $n [Each {"smk(i)"}]] }
        payload-compare   { append p [Fn $n [Each {"mk(i) == mk(i)"}]] }
        struct-compare    { append p [Fn $n [Each {"smk(i) == smk(i)"}]] }
        mk2               { append p [Fn $n [Each {"a = mk(i)" "b = mk(i)" "a"}]] }
        smk2              { append p [Fn $n [Each {"a = smk(i)" "b = smk(i)" "a"}]] }
        payload-hash      { append p [Fn $n [Each {"hash(mk(i))"}]] }
        struct-hash       { append p [Fn $n [Each {"hash(smk(i))"}]] }
        payload-pass      { append p [Fn $n [Each {"eid(mk(i))"}]] }
        struct-pass       { append p [Fn $n [Each {"sid(smk(i))"}]] }
        payload-array-base { append p [Fn $n {"a = std::mutable_array::create(n, Expr::Param)" "a.capacity()"}] }
        payload-array-set  { append p [Fn $n [concat {"a = std::mutable_array::create(n, Expr::Param)"} [Each {"a.set(i, mk(i))"}]]] }
        struct-array-base  { append p [Fn $n {"a = std::mutable_array::create(n, smk(0))" "a.capacity()"}] }
        struct-array-set   { append p [Fn $n [concat {"a = std::mutable_array::create(n, smk(0))"} [Each {"a.set(i, smk(i))"}]]] }
        payload-vector-base { append p [Fn $n {"v = std::mutable_vector::from_list(\[Expr::Param\])" "v.length()"}] }
        payload-vector-push-pop { append p [Fn $n [concat {"v = std::mutable_vector::from_list(\[Expr::Param\])"} [Each {"v.push(mk(i))" "v.pop()"}]]] }
        struct-vector-base { append p [Fn $n {"v = std::mutable_vector::from_list(\[smk(0)\])" "v.length()"}] }
        struct-vector-push-pop { append p [Fn $n [concat {"v = std::mutable_vector::from_list(\[smk(0)\])"} [Each {"v.push(smk(i))" "v.pop()"}]]] }
        payload-large     { append p [Fn $n [Each {"Expr::Call {args: \[i, i, i, i\], f: Pair {left: i, right: i}}"}]] }
        struct-large      { append p [Fn $n [Each {"CallTwin {args: \[i, i, i, i\], f: Pair {left: i, right: i}}"}]] }
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
    if {$backend eq "compile"} {
        # The Tcl compiler compiles the HIR itself, once.
        set unit [core::compiler::compileHir $hir]
        set run {core::compiler::evalUnit $unit}
    } else {
        set program [hir::lower $hir]
        core::useBackend $backend
        set run {core::evalProgram $program}
    }
    eval $run
    set best ""
    for {set i 0} {$i < $::runs} {incr i} {
        set micros [lindex [time $run] 0]
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
    "payload-bearing case construction (Expr::Add {left, right})" payload-construct loop-base
    "... a named struct with the same fields" struct-construct loop-base
    "payload-free case of an enum with payloads (Expr::Param)" mixed-free-case loop-base
    "== of two payload-bearing values (equal payloads)" payload-compare mk2
    "... of two structs with the same fields" struct-compare smk2
    "hash of a payload-bearing value" payload-hash mk
    "... of a struct with the same fields" struct-hash smk
    "pass and return a payload-bearing value" payload-pass mk
    "... a struct with the same fields" struct-pass smk
    "MutableArray[Expr] set (a payload-bearing value)" payload-array-set payload-array-base
    "... MutableArray[Pair] set" struct-array-set struct-array-base
    "MutableVector[Expr] push then pop" payload-vector-push-pop payload-vector-base
    "... MutableVector[Pair] push then pop" struct-vector-push-pop struct-vector-base
    "larger nested payload (List of 4, nested struct)" payload-large loop-base
    "... a struct with the same fields" struct-large loop-base
}

puts "Enums: performance (n = $n operations per program on the Tcl backends, $nativeN natively; best of $runs runs)\n"
puts [bench::backends::manifest $backends]
puts ""
puts "## Operations\n"
puts "| operation | baseline | [join [lmap b $backends {bench::backends::displayName $b}] { | }] |"
puts "|---|---|[string repeat ---:| [llength $backends]]"
if {$only ne {}} {
    set operations [concat {*}[lmap {label kind base} $operations {
        expr {$kind in $only ? [list $label $kind $base] : [continue]}
    }]]
}
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
    puts "| program | allocations | Lists | Structs | EnumCases | MutableArrays | bytes |"
    puts "|---|---:|---:|---:|---:|---:|---:|"
    set seen {}
    foreach {label kind base} $operations {
        foreach k [list $base $kind] {
            if {$k in $seen} continue
            lappend seen $k
            set report [native::allocationReport [program $k $nativeN] summary]
            set cases [expr {[dict exists $report byKind EnumCase] ? [dict get $report byKind EnumCase allocations] : 0}]
            puts "| $k | [dict get $report total allocations] | [dict get $report byKind List allocations] | [dict get $report byKind Struct allocations] | $cases | [dict get $report byKind MutableArray allocations] | [dict get $report total allocatedBytes] |"
        }
    }
}
