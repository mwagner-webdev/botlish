# coroutines.tcl -- the coroutine performance report (COROUTINES.md,
# "Performance").
#
#   tclsh9.0 bench/coroutines.tcl ?-runs N? ?-n N? ?-native-n N? ?-hold K?
#                                 ?-native-hold K? ?-backends LIST?
#
# Times, on every backend (Tcl interp, Tcl compile, Cranelift), programs that
# each repeat one coroutine operation N times, against a baseline program
# doing the same work without coroutines, and reports the difference per
# operation:
#
#   create    N constructions of a coroutine that yields at once (each
#             abandoned suspended); baseline: N ordinary calls building the
#             same struct
#   complete  N constructions run to completion (one resume), then called
#             once more (the cached terminal result); baseline as create
#   resume    one coroutine resumed N times, yielding in a counted loop;
#             baseline: the same loop with no coroutine
#   deep-D    as resume, every yield D frames below the coroutine's root
#             (D = 1, 8, 32); baseline: the same D-deep recursion with no
#             coroutine: what a deep suspension costs per resume
#   exit-K    N constructions each abandoned suspended on an early exit of
#             kind K: a return, a fail, a callee's propagated error, a break
#             (released there, COROUTINES.md "Release on every early exit");
#             baseline: the same function building the struct instead
#
# then, natively, the allocations per construction (the runtime's
# allocation report) and the memory of suspended and terminal coroutines:
# the peak resident set of a process holding K suspended (or completed)
# coroutines at once (each suspended D frames deep) against one holding none,
# per coroutine (K = -hold on the Tcl backends, -native-hold natively);
# for the Tcl backends the same peak of this process (VmHWM, reset through
# /proc/self/clear_refs before each run). Every timed number is best of RUNS
# in-process executions, compilation excluded (bench/bench.tcl's method).

set root [file dirname [file dirname [file normalize [info script]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root bench backends.tcl]
interp recursionlimit {} 200000

set runs 5
set n 20000
set hold 2000
set nativeHold 10000
set nativeN 200000
set backends {interp compile native}
foreach {option value} $args {
    switch -- $option {
        -runs { set runs $value }
        -n { set n $value }
        -hold { set hold $value }
        -native-hold { set nativeHold $value }
        -native-n { set nativeN $value }
        -backends { set backends $value }
        default { error "unknown option $option" }
    }
}

set prelude "import coroutine\nstruct V:\n    n: int\n"

proc program {kind n {depth 1}} {
    return [surface::compile [programText $kind $n $depth] -warnings off]
}

# N repetitions of the statements LINES (`i` counts 0..N-1) as one
# collecting loop whose List nothing reads (the program's value is N), so no
# List is built: a retained List of up to N elements would be live -- and
# marked by every collection the measured operation triggers -- for the
# whole run, a cost of the harness, not of the operation.
proc Repeat {n lines} {
    set text "loop i from 0 to $n:\n"
    foreach line $lines {
        append text "    $line\n"
    }
    append text "$n\n"
    return $text
}

proc programText {kind n {depth 1}} {
    set p $::prelude
    switch -- $kind {
        create {
            append p "fn w(k: int) -> V:\n    yield V {n: k}\n    return V {n: k + 1}\n"
            append p [Repeat $n {"coroutine {first} = w(i)" first.n}]
        }
        create-alloc {
            append p "fn w(k: int) -> V:\n    yield V {n: k}\n    return V {n: k + 1}\n"
            append p "fn go(i: int, m: int) -> int:\n    if i == m:\n        return 0\n    coroutine {first} = w(i)\n    first.n + go(i + 1, m)\n"
            append p "go(0, $n)\n"
        }
        create-base {
            append p "fn w(k: int) -> V:\n    V {n: k}\n"
            append p [Repeat $n {w(i).n}]
        }
        complete {
            append p "fn w(k: int) -> V:\n    yield V {n: k}\n    return V {n: k + 1}\n"
            append p [Repeat $n {"coroutine {step, first} = w(i)" "last = step()" "again = step()" "first.n + last.n + again.n"}]
        }
        complete-base {
            append p "fn w(k: int) -> V:\n    V {n: k}\n"
            append p [Repeat $n {"w(i).n + w(i + 1).n + w(i + 1).n"}]
        }
        resume {
            append p "fn counter(m: int) -> V:\n    loop i from 0 to m:\n        yield V {n: i}\n    return V {n: m}\n"
            append p "coroutine {step, first} = counter($n)\n" [Repeat $n {step().n}]
        }
        resume-base {
            append p "fn make(i: int) -> V:\n    V {n: i}\n"
            append p [Repeat $n {make(i).n}]
        }
        deep {
            append p "fn down(d: int, i: int) -> int:\n    if d == 0:\n        yield V {n: i}\n        return 0\n    down(d - 1, i) + 1\n"
            append p "fn counter(m: int) -> V:\n    loop i from 0 to m:\n        down($depth, i)\n    return V {n: m}\n"
            append p "coroutine {step, first} = counter($n)\n" [Repeat $n {step().n}]
        }
        deep-base {
            append p "fn down(d: int, i: int) -> int:\n    if d == 0:\n        return 0\n    down(d - 1, i) + 1\n"
            append p "fn make(i: int) -> V:\n    V {n: i + down($depth, i)}\n"
            append p [Repeat $n {make(i).n}]
        }
        hold {
            append p "fn down(d: int, k: int) -> int:\n    if d == 0:\n        yield V {n: k}\n        return k\n    down(d - 1, k) + 1\n"
            append p "fn w(k: int) -> V:\n    return V {n: down($depth, k)}\n"
            append p "fn hold(k: int) -> int:\n    if k == 0:\n        return 0\n    coroutine {step, first} = w(k)\n    x = hold(k - 1)\n    if coroutine::done?(step):\n        return x\n    x + first.n\n"
            append p "hold($n)\n"
        }
        exit-return {
            append p "fn w(k: int) -> V:\n    yield V {n: k}\n    return V {n: k + 1}\n"
            append p "fn f(k: int) -> int:\n    coroutine {step, first} = w(k)\n    if k >= 0:\n        return first.n\n    step().n\n"
            append p [Repeat $n {f(i)}]
        }
        exit-return-base {
            append p "fn w(k: int) -> V:\n    V {n: k}\n"
            append p "fn f(k: int) -> int:\n    first = w(k)\n    if k >= 0:\n        return first.n\n    first.n + 1\n"
            append p [Repeat $n {f(i)}]
        }
        exit-fail {
            append p "error Boom\nfn w(k: int) -> V:\n    yield V {n: k}\n    return V {n: k + 1}\n"
            append p "fn g(k: int) -> int errors Boom:\n    coroutine {step, first} = w(k)\n    if k >= 0:\n        fail Boom\n    step().n\n"
            append p "fn f(k: int) -> int:\n    g(k):\n        on Boom:\n            k\n"
            append p [Repeat $n {f(i)}]
        }
        exit-fail-base {
            append p "error Boom\nfn w(k: int) -> V:\n    V {n: k}\n"
            append p "fn g(k: int) -> int errors Boom:\n    first = w(k)\n    if k >= 0:\n        fail Boom\n    first.n\n"
            append p "fn f(k: int) -> int:\n    g(k):\n        on Boom:\n            k\n"
            append p [Repeat $n {f(i)}]
        }
        exit-error {
            append p "error Boom\nfn w(k: int) -> V:\n    yield V {n: k}\n    return V {n: k + 1}\n"
            append p "fn bad(k: int) -> int errors Boom:\n    if k >= 0:\n        fail Boom\n    k\n"
            append p "fn g(k: int) -> int errors Boom:\n    coroutine {step, first} = w(k)\n    x = bad(k)\n    step().n + x\n"
            append p "fn f(k: int) -> int:\n    g(k):\n        on Boom:\n            k\n"
            append p [Repeat $n {f(i)}]
        }
        exit-error-base {
            append p "error Boom\nfn w(k: int) -> V:\n    V {n: k}\n"
            append p "fn bad(k: int) -> int errors Boom:\n    if k >= 0:\n        fail Boom\n    k\n"
            append p "fn g(k: int) -> int errors Boom:\n    first = w(k)\n    x = bad(k)\n    first.n + x\n"
            append p "fn f(k: int) -> int:\n    g(k):\n        on Boom:\n            k\n"
            append p [Repeat $n {f(i)}]
        }
        exit-break {
            append p "fn w(k: int) -> V:\n    yield V {n: k}\n    return V {n: k + 1}\n"
            append p "fn f(k: int) -> int:\n    xs = loop j from 0 to 2:\n        coroutine {step, first} = w(j + k)\n        if j >= 0:\n            break\n        step().n\n    k\n"
            append p [Repeat $n {f(i)}]
        }
        exit-break-base {
            append p "fn w(k: int) -> V:\n    V {n: k}\n"
            append p "fn f(k: int) -> int:\n    xs = loop j from 0 to 2:\n        first = w(j + k)\n        if j >= 0:\n            break\n        first.n\n    k\n"
            append p [Repeat $n {f(i)}]
        }
        terminal {
            append p "fn w(k: int) -> V:\n    yield V {n: k}\n    return V {n: k + 1}\n"
            append p "fn hold(k: int) -> int:\n    if k == 0:\n        return 0\n    coroutine {step, first} = w(k)\n    last = step()\n    x = hold(k - 1)\n    if coroutine::done?(step):\n        return x + last.n\n    x\n"
            append p "hold($n)\n"
        }
    }
    return $p
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

proc perOp {kind base backend {depth 1}} {
    set n [expr {$backend eq "native" ? $::nativeN : $::n}]
    set t [timeOn $backend [program $kind $n $depth]]
    set b [timeOn $backend [program $base $n $depth]]
    return [list [expr {($t - $b) * 1000.0 / $n}] [expr {$t * 1000.0 / $n}]]
}

proc ns {x} {
    return [format "%.0f ns" $x]
}

puts "Coroutine performance (n = $n operations per program on the Tcl backends, $nativeN natively; best of $runs runs)\n"
puts [bench::backends::manifest $backends]
puts ""
puts "Time per operation (program time minus its baseline's, divided by n; the whole program's time per iteration in parentheses):\n"
puts "| operation | [join [lmap b $backends {bench::backends::displayName $b}] { | }] |"
puts "|---|[string repeat ---:| [llength $backends]]"
foreach {label kind base depth} {
    "construction (to the first yield)" create create-base 1
    "construction + resume to completion + one cached call" complete complete-base 1
    "resume (yield in the root)" resume resume-base 1
    "resume, yield 1 frame deep" deep deep-base 1
    "resume, yield 8 frames deep" deep deep-base 8
    "resume, yield 32 frames deep" deep deep-base 32
    "construction, abandoned on an early return" exit-return exit-return-base 1
    "construction, abandoned on a fail" exit-fail exit-fail-base 1
    "construction, abandoned on a callee's propagated error" exit-error exit-error-base 1
    "construction, abandoned on a break" exit-break exit-break-base 1
} {
    set cells {}
    foreach backend $backends {
        lassign [perOp $kind $base $backend $depth] delta whole
        lappend cells "[ns $delta] ([ns $whole])"
    }
    puts "| $label | [join $cells { | }] |"
}

# Allocations per construction, natively.
if {"native" ni $backends} {
    exit 0
}
puts "\nNative allocations of $n constructions (allocation report, summary; a recursion, so that no List is built):\n"
set report [native::allocationReport [program create-alloc $n] summary]
puts "| kind | allocations | bytes | per construction |"
puts "|---|---:|---:|---:|"
dict for {kind info} [dict get $report byKind] {
    set count [dict get $info allocations]
    if {$count == 0} continue
    set bytes [dict get $info allocatedBytes]
    puts "| $kind | $count | $bytes | [format %.2f [expr {double($count) / $n}]] objects, [format %.0f [expr {double($bytes) / $n}]] B |"
}

# Peak resident memory.
proc nativePeakKiB {hir} {
    set text [native::nir $hir]
    lassign [file tempfile path botlish-bench.nir] channel
    puts -nonewline $channel $text
    close $channel
    try {
        set out [exec python3 -c {
import resource, subprocess, sys
subprocess.run(sys.argv[1:], stdout=subprocess.DEVNULL, check=True)
print(resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss)
} [native::binary] run $path]
    } finally {
        file delete $path
    }
    return [string trim $out]
}

# The peak resident set (KiB) of a fresh tclsh9.0 compiling and running
# program TEXT on BACKEND (a fresh process: Tcl's allocator keeps what it
# freed, so an earlier run in this process would hide the growth).
proc tclPeakKiB {backend text} {
    lassign [file tempfile source botlish-bench.bot] channel
    fconfigure $channel -encoding utf-8
    puts -nonewline $channel $text
    close $channel
    lassign [file tempfile script botlish-bench.tcl] channel
    puts $channel [list set ::argv {}]
    puts $channel [list source [file join $::root tests helpers.tcl]]
    puts $channel [list source [file join $::root surface surface.tcl]]
    puts $channel {interp recursionlimit {} 200000}
    puts $channel [list core::useBackend $backend]
    puts $channel "core::evalProgram \[hir::lower \[surface::readProgramFile [list $source] -warnings off\]\]"
    puts $channel {set f [open /proc/self/status r]; regexp -line {^VmHWM:\s+(\d+) kB} [read $f] -> peak; puts $peak}
    close $channel
    try {
        set out [exec [info nameofexecutable] $script]
    } finally {
        file delete $source $script
    }
    return [lindex [split [string trim $out] \n] end]
}

puts "\nResident memory per coroutine held at once (peak RSS with K coroutines alive minus with K = 0, divided by K; K = $hold on the Tcl backends, $nativeHold natively):\n"
puts "| state | [join [lmap b $backends {bench::backends::displayName $b}] { | }] |"
puts "|---|[string repeat ---:| [llength $backends]]"
foreach {label kind depth} {
    "suspended, yield in the first frame below the root" hold 0
    "suspended, yield 32 frames deep" hold 32
    "completed (stack released, result cached)" terminal 0
} {
    set cells {}
    foreach backend $backends {
        if {$backend eq "native"} {
            set k $nativeHold
            set with [nativePeakKiB [program $kind $k $depth]]
            set without [nativePeakKiB [program $kind 0 $depth]]
        } else {
            set k $hold
            set with [tclPeakKiB $backend [programText $kind $k $depth]]
            set without [tclPeakKiB $backend [programText $kind 0 $depth]]
        }
        lappend cells "[format %.1f [expr {($with - $without) / double($k)}]] KiB"
    }
    puts "| $label | [join $cells { | }] |"
}
