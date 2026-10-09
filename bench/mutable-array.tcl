# mutable-array.tcl -- the performance report of MutableArray[T] as a value
# (MUTABLE-ARRAY.md, "Performance").
#
#   tclsh9.0 bench/mutable-array.tcl ?-runs N? ?-n N? ?-native-n N?
#                                    ?-backends LIST?
#
# Three tables, on every backend (Tcl interp, Tcl compile, Cranelift):
#
#   * operations: programs that each repeat one operation N times, reported
#     as time per operation, (program - baseline) / N, the whole program per
#     operation in parentheses (bench/mutable-vector.tcl's method): repeated
#     and factory construction, indexed read and write, swap, the affine
#     factory construction, drop and consuming iteration of an array of
#     coroutines (natively at most N = 20 000: each suspended coroutine maps
#     a native stack), nested MutableVector[MutableArray[int]] and
#     MutableVector[MutableArray[Coroutine]], and the same operations on a
#     MutableVector and a MutableBytes store for comparison;
#   * copy-on-write complexity: K logical copies of an S-element array (a
#     read-out of a mutated binding: one header, no element copied), K
#     copies each written once (the first write detaches: S element words),
#     and natively the counters (shares, detaches, elements copied by
#     detaches) for each S -- the copy is O(1), the first write O(S), later
#     writes of the now-unique backing O(1); the same for a vector;
#   * a scheduler-shaped construction: N workers made by a factory
#     (mutable_array::generate), each resumed K times through swap, and the
#     array consumed by a loop.
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

set C "Coroutine{args: \[Cmd\], return: Ev}"
set prelude "import coroutine
import list
import mutable_array
import mutable_byte_store
import mutable_vector

struct Cmd:
    v: int

struct Ev:
    v: int

fn idle(k: int, resume Cmd) -> Ev:
    c = yield Ev {v: k}
    return Ev {v: k + c.v}

fn steps(k: int, resume Cmd) -> Ev:
    loop i from 0 to k:
        c = yield Ev {v: i}
    return Ev {v: k}

fn make(k: int) -> $C:
    coroutine {step} = idle(k)
    step

fn worker(k: int) -> $C:
    coroutine {step} = steps(8)
    step

fn tens(i: int) -> int:
    i * 10

fn range(n: int) -> List\[int\]:
    loop i from 0 to n:
        i

fn ints_of(n: int) -> MutableVector\[int\]:
    mutable_vector::from_list(range(n))

fn pair(i: int) -> MutableArray\[int\]:
    mutable_array::create(2, i)

fn pair_co(i: int) -> MutableArray\[$C\]:
    mutable_array::generate(2, make)

fn arrays() -> MutableVector\[MutableArray\[int\]\]:
    mutable_vector::from_list(\[\])

fn co_arrays() -> MutableVector\[MutableArray\[$C\]\]:
    mutable_vector::from_list(\[\])

fn fill_bytes(s, i: int, n: int):
    if i >= n:
        return s
    fill_bytes(mutable_byte_store::replace(s, i, 1), i + 1, n)

"

# A function `f(n: int) -> int ?errors IndexNotFound?` of BODY lines (one
# indentation level), called with N under a handler.
proc Fn {n body {errors 0}} {
    set text "fn f(n: int) -> int[expr {$errors ? " errors IndexNotFound" : ""}]:\n"
    foreach line $body {
        append text "    $line\n"
    }
    append text "r = f($n):\n    on IndexNotFound:\n        -1\nr\n"
    return $text
}

# BODY lines as a loop `i from 0 to n` (one more indentation level).
proc Each {lines} {
    return [concat [list "xs = loop i from 0 to n:"] [lmap line $lines {string cat "    " $line}]]
}

proc programText {kind n} {
    set p $::prelude
    switch -- $kind {
        loop-base {
            append p [Fn $n [concat [Each {i}] {n}]]
        }
        list-build {
            append p [Fn $n {"xs = range(n)" "list::length(xs)"}]
        }
        create {
            append p [Fn $n {"a = mutable_array::create(n, 0)" "a.capacity()"}]
        }
        from-list {
            append p [Fn $n {"a = mutable_array::from_list(range(n))" "a.capacity()"}]
        }
        generate {
            append p [Fn $n {"a = mutable_array::generate(n, tens)" "a.capacity()"}]
        }
        array-base {
            append p [Fn $n {"a = mutable_array::create(n, 0)" "a.set(0, 1)" "a.capacity()"} 1]
        }
        set {
            append p [Fn $n [concat {"a = mutable_array::create(n, 0)" "a.set(0, 1)"} [Each {"a.set(i, i)"}] {"a.capacity()"}] 1]
        }
        at {
            append p [Fn $n [concat {"a = mutable_array::create(n, 0)" "a.set(0, 1)"} [Each {"mutable_array::at(a, i)"}] {"a.capacity()"}] 1]
        }
        swap {
            append p [Fn $n [concat {"a = mutable_array::create(n, 0)" "a.set(0, 1)"} [Each {"a.swap(i, i)"}] {"a.capacity()"}] 1]
        }
        iterate {
            append p [Fn $n {"a = mutable_array::create(n, 0)" "a.set(0, 1)" "ys = loop x in a:" "    x" "list::length(ys)"} 1]
        }
        vector-base {
            append p [Fn $n {"v = ints_of(n)" "v.push(0)" "v.length()"} 1]
        }
        vector-at {
            append p [Fn $n [concat {"v = ints_of(n)" "v.push(0)"} [Each {"mutable_vector::at(v, i)"}] {"v.length()"}] 1]
        }
        vector-swap {
            append p [Fn $n [concat {"v = ints_of(n)" "v.push(0)"} [Each {"v.swap(i, 0)"}] {"v.length()"}] 1]
        }
        bytes-base {
            append p [Fn $n {"s = mutable_byte_store::zeroed(n)" "mutable_byte_store::count(s)"}]
        }
        bytes-replace {
            append p [Fn $n {"s = fill_bytes(mutable_byte_store::zeroed(n), 0, n)" "mutable_byte_store::count(s)"}]
        }
        make-drop {
            append p [Fn $n [concat [Each {"c = make(i)" "1"}] {n}]]
        }
        affine-generate {
            append p [Fn $n {"q = mutable_array::generate(n, make)" "q.capacity()"}]
        }
        affine-swap {
            append p [Fn $n [concat {"q = mutable_array::generate(1, make)"} [Each {"old = q.swap(0, make(i))" "1"}] {"q.capacity()"}] 1]
        }
        affine-consume {
            append p [Fn $n {"q = mutable_array::generate(n, make)" "ys = loop c in q:" "    1" "list::length(ys)"}]
        }
        nested-base {
            append p [Fn $n {"v = arrays()" "v.length()"}]
        }
        nested-push-pop {
            append p [Fn $n [concat {"v = arrays()"} [Each {"v.push(pair(i))" "a = v.pop()" "a.capacity()"}] {"v.length()"}] 1]
        }
        nested-copy-out {
            append p [Fn $n [concat {"v = arrays()" "v.push(pair(1))"} [Each {"a = v.at(0)" "a.set(0, i)" "a.capacity()"}] {"v.length()"}] 1]
        }
        nested-co-push-pop {
            append p [Fn $n [concat {"v = co_arrays()"} [Each {"v.push(pair_co(i))" "a = v.pop()" "a.capacity()"}] {"v.length()"}] 1]
        }
        default {
            if {[regexp {^(copy|copy-write|copy-base|vcopy|vcopy-write|vcopy-base)-([0-9]+)$} $kind -> what size]} {
                # N logical copies of a SIZE-element array (or vector) held
                # by a mutated binding: every read-out is a copy.
                if {[string match v* $what]} {
                    set body [list "v = ints_of($size)" "v.push(0)"]
                    switch -- $what {
                        vcopy-base { lappend body {*}[Each {"v.length()"}] }
                        vcopy { lappend body {*}[Each {"w = v" "w.length()"}] }
                        vcopy-write { lappend body {*}[Each {"w = v" "w.push(i)" "w.length()"}] }
                    }
                    lappend body "v.length()"
                } else {
                    set body [list "a = mutable_array::create($size, 0)" "a.set(0, 1)"]
                    switch -- $what {
                        copy-base { lappend body {*}[Each {"a.capacity()"}] }
                        copy { lappend body {*}[Each {"b = a" "b.capacity()"}] }
                        copy-write { lappend body {*}[Each {"b = a" "b.set(0, i)" "b.capacity()"}] }
                    }
                    lappend body "a.capacity()"
                }
                append p [Fn $n $body 1]
            } elseif {[regexp {^sched-([0-9]+)$} $kind -> k]} {
                # N workers of 8 resume steps each, made by a factory; each
                # step is a swap out and back of one slot.
                append p "fn step_all(q: MutableArray\[$::C\], i: int, n: int) -> MutableArray\[$::C\] errors IndexNotFound:\n"
                append p "    if i >= n:\n        return q\n"
                append p "    w = q.swap(i, make(0))\n    e = w(Cmd {v: 1})\n    old = q.swap(i, w)\n"
                append p "    step_all(q, i + 1, n)\n"
                append p "fn rounds(q: MutableArray\[$::C\], r: int, n: int) -> MutableArray\[$::C\] errors IndexNotFound:\n"
                append p "    if r >= $k:\n        return q\n    rounds(step_all(q, 0, n), r + 1, n)\n"
                append p "fn f(n: int) -> int errors IndexNotFound:\n    q = rounds(mutable_array::generate(n, worker), 0, n)\n"
                append p "    done = loop w in q:\n        coroutine::done?(w)\n    list::length(done)\n"
                append p "r = f($n):\n    on IndexNotFound:\n        -1\nr\n"
            } else {
                error "unknown program $kind"
            }
        }
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

# {DELTA WHOLE} nanoseconds per operation of KIND over BASE (or 0) with N
# operations (the backend's default).
proc perOp {kind base backend {n ""}} {
    if {$n eq ""} {
        set n [nOf $backend]
    }
    set t [timeOn $backend [program $kind $n]]
    set b [expr {$base eq "" ? 0 : [timeOn $backend [program $base $n]]}]
    return [list [expr {($t - $b) * 1000.0 / $n}] [expr {$t * 1000.0 / $n}]]
}

proc ns {x} {
    return [format "%.0f ns" $x]
}

proc header {first} {
    puts "| $first | baseline | [join [lmap b $::backends {bench::backends::displayName $b}] { | }] |"
    puts "|---|---|[string repeat ---:| [llength $::backends]]"
}

puts "MutableArray\[T\]: performance (n = $n operations per program on the Tcl backends, $nativeN natively; best of $runs runs)\n"
puts [bench::backends::manifest $backends]
puts ""

puts "## Operations\n"
header operation
foreach {label kind base} {
    "List construction (collecting loop), per element, for comparison" list-build ""
    "create(n, 0): one repeated unrestricted value, per slot" create ""
    "from_list, per element" from-list list-build
    "generate(n, tens): one factory call per slot" generate ""
    "at (indexed read)" at array-base
    "set on a unique array (no detach)" set array-base
    "swap (unrestricted)" swap array-base
    "iterate an unrestricted array (snapshot), per element" iterate array-base
    "MutableVector at, for comparison" vector-at vector-base
    "MutableVector swap, for comparison" vector-swap vector-base
    "MutableBytes replace on a unique store (threaded), for comparison" bytes-replace bytes-base
    "create and release a coroutine (no array)" make-drop ""
    "generate(n, make): affine factory construction, per slot (the array dropped whole)" affine-generate ""
    "swap a coroutine in, the displaced one released" affine-swap make-drop
    "consume an affine array in a loop, per element" affine-consume affine-generate
    "MutableVector\[MutableArray\[int\]\]: push a 2-slot array, pop it" nested-push-pop nested-base
    "MutableVector\[MutableArray\[int\]\]: copy an element out, write it" nested-copy-out nested-base
    "MutableVector\[MutableArray\[Coroutine\]\]: push a generated 2-slot array, pop it (dropped)" nested-co-push-pop nested-base
} {
    set cells {}
    foreach backend $backends {
        # Programs keeping N coroutines suspended at once map N native stacks
        # (each one a mapping plus a guard page): at most 20 000 of them,
        # well inside the kernel's default vm.max_map_count (65 530). The
        # threaded MutableBytes fill recurses N deep.
        set count [nOf $backend]
        if {$kind in {affine-generate affine-consume make-drop affine-swap nested-co-push-pop}} {
            set count [expr {min($count, 20000)}]
        }
        if {$kind eq "bytes-replace"} {
            set count [expr {min($count, 2000)}]
        }
        lassign [perOp $kind $base $backend $count] delta whole
        lappend cells "[ns $delta] ([ns $whole])"
    }
    puts "| $label | [expr {$base eq "" ? "--" : $base}] | [join $cells { | }] |"
}

puts "\n## Copy-on-write complexity\n"
puts "K = 200 copies of an S-element array (or vector) per program; per copy.\n"
header "operation, S"
set sizes {10 1000 10000}
foreach size $sizes {
    foreach {label kind base} [list \
        "array copy (read-out of a mutated binding)" copy-$size copy-base-$size \
        "array copy, then its first write (detach)" copy-write-$size copy-$size \
        "vector copy, for comparison" vcopy-$size vcopy-base-$size \
        "vector copy, then its first write (detach)" vcopy-write-$size vcopy-$size] {
        set cells {}
        foreach backend $backends {
            lassign [perOp $kind $base $backend 200] delta whole
            lappend cells "[ns $delta] ([ns $whole])"
        }
        puts "| $label, S = $size | $base | [join $cells { | }] |"
    }
}
if {"native" in $backends} {
    puts "\nNative counters (Cranelift), per program of K = 200 copies:\n"
    puts "| program | shares | detaches | elements copied by detaches |"
    puts "|---|---:|---:|---:|"
    foreach size $sizes {
        foreach kind [list copy-$size copy-write-$size] {
            set ma [dict get [native::allocationReport [program $kind 200] summary] mutableArray]
            puts "| $kind | [dict get $ma shares] | [dict get $ma detaches] | [dict get $ma detachElements] |"
        }
        foreach kind [list vcopy-$size vcopy-write-$size] {
            set mv [dict get [native::allocationReport [program $kind 200] summary] mutableVector]
            puts "| $kind | [dict get $mv shares] | [dict get $mv detaches] | [dict get $mv detachElements] |"
        }
    }
    set ma [dict get [native::allocationReport [program set $nativeN] summary] mutableArray]
    puts "| set, $nativeN writes to one unique array | [dict get $ma shares] | [dict get $ma detaches] | [dict get $ma detachElements] |"
}

puts "\n## Scheduler-shaped construction\n"
puts "N workers from mutable_array::generate(n, worker), 8 rounds over the array (swap a slot out, resume it, swap it back), then a consuming loop; time per resume.\n"
header "program"
set cells {}
foreach backend $backends {
    set count [expr {min([nOf $backend] / 8, 2000)}]
    set t [timeOn $backend [program sched-8 $count]]
    lappend cells [ns [expr {$t * 1000.0 / ($count * 8)}]]
}
puts "| sched-8 | -- | [join $cells { | }] |"
if {"native" in $backends} {
    set count [expr {min($nativeN / 8, 2000)}]
    set report [native::allocationReport [program sched-8 $count] summary]
    set co [dict get $report coroutines]
    set ma [dict get $report mutableArray]
    puts "\nNative counters (Cranelift), N = $count workers: stacks mapped [dict get $co stacksMapped], reused [dict get $co stacksReused], released [dict get $co released], swept [dict get $co sweptSuspended]; array shares [dict get $ma shares], detaches [dict get $ma detaches]."
}
