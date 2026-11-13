# exhaustive-match.tcl -- the performance report of exhaustive matches
# (PORTABILITY-EXHAUSTIVE-MATCH-MILESTONE-1.md, "Performance and
# allocations").
#
#   tclsh9.0 bench/exhaustive-match.tcl ?-runs N? ?-n N? ?-native-n N?
#                                       ?-backends LIST? ?-only {KIND ...}?
#
# bench/enums.tcl's method: programs that each repeat one operation N times
# inside a collecting loop, reported as time per operation over the
# program's baseline, (program - baseline) / N, the whole program per
# operation in parentheses. The match operations are measured apart from
# the construction of the value they select from (their baseline makes the
# same value and keeps it): a match over a payload-free enum beside the
# if/== chain it replaces; over a payload enum whose value is a payload-free
# case; selecting a payload-bearing case and binding its fields, binding
# nothing, binding the whole payload; the last of 32 cases (the chain's
# length); a scrutinee known to be one case; a payload holding a
# MutableVector, a function value; and the kernel's own shape -- a Kind and
# three generic fields of a struct, selected by == -- beside it. A second
# table gives natively, for each program, the number of heap allocations
# (Cranelift's counters): a selection allocates nothing, a payload-free
# match no EnumCase.
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

set many "enum Many:\n"
for {set i 0} {$i < 32} {incr i} {
    append many "    M$i \{v: int\},\n"
}
set manyArms ""
for {set i 0} {$i < 32} {incr i} {
    append manyArms "        case Many::M$i \{v\}:\n            v + $i\n"
}

set prelude "import std::list
import std::mutable_vector

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

fn free_match(k: Kind) -> int:
    match k:
        case Kind::Boat:
            1
        case Kind::Car:
            2
        case Kind::Truck:
            3
        case Kind::Tank:
            4

fn free_chain(k: Kind) -> int:
    if k == Kind::Boat:
        1
    elif k == Kind::Car:
        2
    elif k == Kind::Truck:
        3
    else:
        4

fn free_keep(k: Kind) -> int:
    1

enum Expr:
    Num {value: int},
    Param,
    Add {left: int, right: int},
    Call {f: int},

fn mk(i: int) -> Expr:
    Expr::Add {left: i, right: i}

fn bind_fields(e: Expr) -> int:
    match e:
        case Expr::Num {value}:
            value
        case Expr::Param:
            0
        case Expr::Add {left, right}:
            left + right
        case Expr::Call {f}:
            f

fn bind_nothing(e: Expr) -> int:
    match e:
        case Expr::Num:
            1
        case Expr::Param:
            2
        case Expr::Add:
            3
        case Expr::Call:
            4

fn bind_whole(e: Expr) -> int:
    match e:
        case Expr::Num p:
            p.value
        case Expr::Param:
            0
        case Expr::Add p:
            p.left + p.right
        case Expr::Call p:
            p.f

fn keep(e: Expr) -> int:
    1

enum K:
    Num,
    Param,
    Add,
    Call,

struct Node:
    kind: K
    a: int
    b: int

fn smk(i: int) -> Node:
    Node {kind: K::Add, a: i, b: i}

fn struct_select(n: Node) -> int:
    k = n.kind
    if k == K::Num:
        n.a
    elif k == K::Param:
        0
    elif k == K::Add:
        n.a + n.b
    else:
        n.a

fn skeep(n: Node) -> int:
    1

${many}
fn many_match(m: Many) -> int:
    match m:
${manyArms}
fn mmk(i: int) -> Many:
    Many::M31 {v: i}

fn mkeep(m: Many) -> int:
    1

enum Holder:
    Items {v: MutableVector\[int\]},
    Fun {f: Fn{args: \[int\], return: int}},
    Empty,

fn hold(i: int, v: MutableVector\[int\]) -> Holder:
    Holder::Items {v: v}

fn twice(x: int) -> int:
    x * 2

fn fun(i: int) -> Holder:
    Holder::Fun {f: twice}

fn holder_match(h: Holder, i: int) -> int:
    match h:
        case Holder::Items {v}:
            v.length()
        case Holder::Fun {f}:
            f(i)
        case Holder::Empty:
            0

fn hkeep(h: Holder, i: int) -> int:
    1

"

proc Fn {n body} {
    set text "fn f(n: int) -> int errors IndexNotFound:\n"
    foreach line $body {
        append text "    $line\n"
    }
    append text "r = f($n):\n    on IndexNotFound:\n        -1\nr\n"
    return $text
}

proc Each {lines} {
    return [concat [list "xs = loop i from 0 to n:"] [lmap line $lines {string cat "    " $line}] [list "std::list::length(xs)"]]
}

proc programText {kind n} {
    set p $::prelude
    switch -- $kind {
        loop-base      { append p [Fn $n [Each {i}]] }
        free-keep      { append p [Fn $n [Each {"free_keep(pick(i))"}]] }
        free-match     { append p [Fn $n [Each {"free_match(pick(i))"}]] }
        free-chain     { append p [Fn $n [Each {"free_chain(pick(i))"}]] }
        mixed-keep     { append p [Fn $n [Each {"keep(Expr::Param)"}]] }
        mixed-free     { append p [Fn $n [Each {"bind_fields(Expr::Param)"}]] }
        payload-keep   { append p [Fn $n [Each {"keep(mk(i))"}]] }
        payload-fields { append p [Fn $n [Each {"bind_fields(mk(i))"}]] }
        payload-none   { append p [Fn $n [Each {"bind_nothing(mk(i))"}]] }
        payload-whole  { append p [Fn $n [Each {"bind_whole(mk(i))"}]] }
        struct-keep    { append p [Fn $n [Each {"skeep(smk(i))"}]] }
        struct-select  { append p [Fn $n [Each {"struct_select(smk(i))"}]] }
        many-keep      { append p [Fn $n [Each {"mkeep(mmk(i))"}]] }
        many-last      { append p [Fn $n [Each {"many_match(mmk(i))"}]] }
        known-base     { append p [Fn $n [Each {"x = Expr::Add {left: i, right: i}" "1"}]] }
        known-case     { append p [Fn $n [Each {"x = Expr::Add {left: i, right: i}" "match x:" "    case Expr::Num:" "        1" "    case Expr::Param:" "        2" "    case Expr::Add {left}:" "        left" "    case Expr::Call:" "        4"}]] }
        vector-keep    { append p [Fn $n [concat {"v = std::mutable_vector::from_list(\[1, 2\])"} [Each {"hkeep(hold(i, v), i)"}]]] }
        vector-match   { append p [Fn $n [concat {"v = std::mutable_vector::from_list(\[1, 2\])"} [Each {"holder_match(hold(i, v), i)"}]]] }
        fn-keep        { append p [Fn $n [Each {"hkeep(fun(i), i)"}]] }
        fn-match       { append p [Fn $n [Each {"holder_match(fun(i), i)"}]] }
        default { error "unknown program $kind" }
    }
    return $p
}

proc program {kind n} {
    return [surface::compile [programText $kind $n] -warnings off]
}

proc timeOn {backend hir} {
    if {$backend eq "native"} {
        lassign [native::measure $hir $::runs] lower compile best collections value
        return $best
    }
    if {$backend eq "compile"} {
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
    "match over a payload-free enum (4 cases)" free-match free-keep
    "... the if/== chain it replaces" free-chain free-keep
    "match over a payload enum, a payload-free case's value" mixed-free mixed-keep
    "match selecting a payload-bearing case, binding its fields" payload-fields payload-keep
    "... binding nothing" payload-none payload-keep
    "... binding the whole payload" payload-whole payload-keep
    "the kernel's shape: a struct's Kind selected by ==" struct-select struct-keep
    "match selecting the last of 32 cases" many-last many-keep
    "match of a scrutinee known to be one case" known-case known-base
    "match binding a payload's MutableVector" vector-match vector-keep
    "match binding and calling a payload's function value" fn-match fn-keep
}

puts "Exhaustive match: performance (n = $n operations per program on the Tcl backends, $nativeN natively; best of $runs runs)\n"
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
    puts "| program | allocations | Lists | Structs | EnumCases | bytes |"
    puts "|---|---:|---:|---:|---:|---:|"
    set seen {}
    foreach {label kind base} $operations {
        foreach k [list $base $kind] {
            if {$k in $seen} continue
            lappend seen $k
            set report [native::allocationReport [program $k $nativeN] summary]
            set cases [expr {[dict exists $report byKind EnumCase] ? [dict get $report byKind EnumCase allocations] : 0}]
            set structs [expr {[dict exists $report byKind Struct] ? [dict get $report byKind Struct allocations] : 0}]
            set lists [expr {[dict exists $report byKind List] ? [dict get $report byKind List allocations] : 0}]
            puts "| $k | [dict get $report total allocations] | $lists | $structs | $cases | [dict get $report total allocatedBytes] |"
        }
    }
}
