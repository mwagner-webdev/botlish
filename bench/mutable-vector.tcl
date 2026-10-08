# mutable-vector.tcl -- the performance report of MutableVector[T]
# (MUTABLE-VECTOR.md, "Performance").
#
#   tclsh9.0 bench/mutable-vector.tcl ?-runs N? ?-n N? ?-native-n N?
#                                     ?-backends LIST?
#
# Three tables, on every backend (Tcl interp, Tcl compile, Cranelift):
#
#   * operations: programs that each repeat one operation N times, reported
#     as time per operation, (program - baseline) / N, the whole program per
#     operation in parentheses (bench/affine.tcl's method); natively the
#     coroutine rows use N = 20 000 (a program holding N suspended
#     coroutines maps N native stacks at once);
#   * copy-on-write complexity: K logical copies of an S-element vector (a
#     read-out of a mutated binding: one header, no element copied), K
#     copies each written once (the first write of a copy detaches its
#     backing: S element words), and the native counters (shares, detaches,
#     elements copied by detaches) for each S -- the copy is O(1), the first
#     write O(S), later writes of the now-unique backing amortized O(1);
#   * a scheduler: N coroutines of K steps each, pushed into one vector and
#     run round-robin (take(0), push back unless done) or LIFO (pop), and in
#     batches of 32 (each batch released before the next is created): time
#     per resume step, and natively the allocations, vector growths, stacks
#     mapped and reused, peak live heap bytes and releases.
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
import mutable_vector

struct P:
    x: int
    y: int

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

fn ints() -> MutableVector\[int\]:
    mutable_vector::from_list(\[\])

fn points() -> MutableVector\[P\]:
    mutable_vector::from_list(\[\])

fn queue() -> MutableVector\[$C\]:
    mutable_vector::from_list(\[\])

fn range(n: int) -> List\[int\]:
    loop i from 0 to n:
        i

fn ints_of(n: int) -> MutableVector\[int\]:
    mutable_vector::from_list(range(n))

fn queue_of(n: int) -> MutableVector\[$C\]:
    q = queue()
    loop i from 0 to n:
        q.push(make(i))
    q

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
        list-iterate {
            append p [Fn $n {"xs = range(n)" "ys = loop x in xs:" "    x" "list::length(ys)"}]
        }
        from-list {
            append p [Fn $n {"v = mutable_vector::from_list(range(n))" "v.length()"}]
        }
        vector-iterate {
            append p [Fn $n {"v = ints_of(n)" "ys = loop x in v:" "    x" "list::length(ys)"}]
        }
        push-int {
            append p [Fn $n [concat {"v = ints()"} [Each {"v.push(i)"}] {"v.length()"}]]
        }
        array-set {
            append p [Fn $n [concat {"a = mutable_array::create(n, 0)"} \
                [Each {"mutable_array::set(a, i, i):" "    on IndexNotFound:" "        unit"}] {n}]]
        }
        push-struct {
            append p [Fn $n [concat {"v = points()"} [Each {"v.push(P {x: i, y: i})"}] {"v.length()"}]]
        }
        vector-base {
            append p [Fn $n {"v = ints_of(n)" "v.push(0)" "v.length()"} 1]
        }
        at {
            append p [Fn $n [concat {"v = ints_of(n)" "v.push(0)"} [Each {"mutable_vector::at(v, i)"}] {"v.length()"}] 1]
        }
        pop {
            append p [Fn $n [concat {"v = ints_of(n)" "v.push(0)"} [Each {"v.pop()"}] {"v.length()"}] 1]
        }
        take-end {
            append p [Fn $n [concat {"v = ints_of(n)" "v.push(0)"} [Each {"v.take(n - i)"}] {"v.length()"}] 1]
        }
        take-front {
            append p [Fn $n [concat {"v = ints_of(n)" "v.push(0)"} [Each {"v.take(0)"}] {"v.length()"}] 1]
        }
        swap {
            append p [Fn $n [concat {"v = ints_of(n)" "v.push(0)"} [Each {"v.swap(i, 0)"}] {"v.length()"}] 1]
        }
        make-drop {
            append p [Fn $n [concat [Each {"c = make(i)" "1"}] {n}]]
        }
        affine-push-pop {
            append p [Fn $n [concat {"q = queue()"} [Each {"q.push(make(i))" "c = q.pop()" "1"}] {"q.length()"}] 1]
        }
        affine-drop {
            append p [Fn $n {"q = queue_of(n)" "q.length()"}]
        }
        affine-clear {
            append p [Fn $n {"q = queue_of(n)" "q.clear()" "q.length()"}]
        }
        affine-consume {
            append p [Fn $n {"q = queue_of(n)" "ys = loop c in q:" "    1" "list::length(ys)"}]
        }
        default {
            if {[regexp {^(copy|copy-write|copy-base)-([0-9]+)$} $kind -> what size]} {
                # N logical copies of a SIZE-element vector (a mutated binding:
                # every read-out is a copy).
                set body [list "v = ints_of($size)" "v.push(0)"]
                switch -- $what {
                    copy-base { lappend body {*}[Each {"v.length()"}] }
                    copy { lappend body {*}[Each {"w = v" "w.length()"}] }
                    copy-write { lappend body {*}[Each {"w = v" "w.push(i)" "w.length()"}] }
                }
                lappend body "v.length()"
                append p [Fn $n $body]
            } elseif {[regexp {^sched-(fifo|lifo|batch)-([0-9]+)$} $kind -> how k]} {
                # N coroutines of K resume steps each.
                set take [expr {$how eq "lifo" ? "queue.pop()" : "queue.take(0)"}]
                append p "fn run(queue: MutableVector\[$::C\]) -> int errors IndexNotFound:\n"
                append p "    done = loop:\n        if queue.empty?():\n            break\n"
                append p "        step = $take\n        e = step(Cmd {v: 1})\n"
                append p "        if not coroutine::done?(step):\n            queue.push(step)\n    1\n"
                append p "fn spawn(n: int, k: int) -> MutableVector\[$::C\]:\n    q = queue()\n"
                append p "    loop i from 0 to n:\n        coroutine {step} = steps(k)\n        q.push(step)\n    q\n"
                if {$how eq "batch"} {
                    set batches [expr {max(1, $n / 32)}]
                    append p "fn f(n: int) -> int errors IndexNotFound:\n    xs = loop b from 0 to $batches:\n        run(spawn(32, $k))\n    n\n"
                } else {
                    append p "fn f(n: int) -> int errors IndexNotFound:\n    run(spawn(n, $k))\n    n\n"
                }
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

puts "MutableVector\[T\]: performance (n = $n operations per program on the Tcl backends, $nativeN natively; best of $runs runs)\n"
puts [bench::backends::manifest $backends]
puts ""

puts "## Operations\n"
header operation
foreach {label kind base} {
    "List construction (collecting loop), per element" list-build ""
    "List iteration, per element" list-iterate list-build
    "construct from a List (from_list), per element" from-list list-build
    "iterate an unrestricted vector (snapshot), per element" vector-iterate from-list
    "push an Int into a unique vector" push-int loop-base
    "MutableArray set (preallocated), for comparison" array-set loop-base
    "push a struct into a unique vector" push-struct loop-base
    "at" at vector-base
    "pop" pop vector-base
    "take from the end" take-end vector-base
    "take from the front" take-front vector-base
    "swap" swap vector-base
    "create and release a coroutine (no vector)" make-drop ""
    "push a coroutine and pop it again" affine-push-pop make-drop
    "push N coroutines, the vector dropped whole (N stacks live at once)" affine-drop make-drop
    "clear an affine vector, per element" affine-clear affine-drop
    "consume an affine vector in a loop, per element" affine-consume affine-drop
} {
    set cells {}
    foreach backend $backends {
        # Programs keeping N coroutines suspended at once map N native stacks
        # (each one a mapping plus a guard page): at most 20 000 of them,
        # well inside the kernel's default vm.max_map_count (65 530).
        set count [nOf $backend]
        if {$kind in {affine-drop affine-clear affine-consume} || ($kind eq "make-drop" && $count > 20000)} {
            set count [expr {min($count, 20000)}]
        }
        lassign [perOp $kind $base $backend $count] delta whole
        lappend cells "[ns $delta] ([ns $whole])"
    }
    puts "| $label | [expr {$base eq "" ? "--" : $base}] | [join $cells { | }] |"
}

puts "\n## Copy-on-write complexity\n"
puts "K = 200 copies of an S-element vector per program; per copy.\n"
header "operation, S"
set sizes {10 1000 10000}
foreach size $sizes {
    foreach {label kind base} [list \
        "copy (read-out of a mutated binding)" copy-$size copy-base-$size \
        "copy, then its first write (detach)" copy-write-$size copy-$size] {
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
    puts "| program | shares | detaches | elements copied by detaches | growths |"
    puts "|---|---:|---:|---:|---:|"
    foreach size $sizes {
        foreach kind [list copy-$size copy-write-$size] {
            set mv [dict get [native::allocationReport [program $kind 200] summary] mutableVector]
            puts "| $kind | [dict get $mv shares] | [dict get $mv detaches] | [dict get $mv detachElements] | [dict get $mv growths] |"
        }
    }
    set mv [dict get [native::allocationReport [program push-int $nativeN] summary] mutableVector]
    puts "| push-int, $nativeN pushes into one unique vector | [dict get $mv shares] | [dict get $mv detaches] | [dict get $mv detachElements] | [dict get $mv growths] ([dict get $mv growthBytes] bytes) |"
}

puts "\n## Scheduler\n"
puts "N coroutines of K = 8 resume steps each; time per resume step (take or pop, resume, push back unless done)."
puts "Operations per coroutine: 1 construction, 1 push, 8 takes (or pops), 8 resumes, 7 pushes back, 1 release.\n"
header "discipline"
foreach {label kind} {
    "round-robin: take(0), push back" sched-fifo-8
    "LIFO: pop, push back" sched-lifo-8
    "round-robin in batches of 32 (the native stack pool size)" sched-batch-8
} {
    set cells {}
    foreach backend $backends {
        set count [expr {[nOf $backend] / 8}]
        set t [timeOn $backend [program $kind $count]]
        lappend cells [ns [expr {$t * 1000.0 / ($count * 8)}]]
    }
    puts "| $label | -- | [join $cells { | }] |"
}
if {"native" in $backends} {
    set count [expr {$nativeN / 8}]
    puts "\nNative counters (Cranelift), N = $count coroutines of 8 steps:\n"
    puts "| program | allocations per coroutine | vector growths (bytes) | stacks mapped | stacks reused | peak live heap bytes | released |"
    puts "|---|---:|---:|---:|---:|---:|---:|"
    foreach kind {sched-fifo-8 sched-lifo-8 sched-batch-8} {
        set report [native::allocationReport [program $kind $count] summary]
        set total [dict get $report total]
        set co [dict get $report coroutines]
        set mv [dict get $report mutableVector]
        puts "| $kind | [format %.1f [expr {[dict get $total allocations] / double($count)}]] | [dict get $mv growths] ([dict get $mv growthBytes]) | [dict get $co stacksMapped] | [dict get $co stacksReused] | [dict get $total peakLiveBytes] | [dict get $co released] |"
    }
}
