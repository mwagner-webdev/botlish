# coroutines.tcl -- the coroutine performance report (COROUTINES.md,
# "Performance").
#
#   tclsh9.0 bench/coroutines.tcl ?-runs N? ?-n N? ?-hold K?
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
#
# then, natively, the allocations per construction (the runtime's
# allocation report) and the memory of suspended and terminal coroutines:
# the peak resident set of a process holding K suspended coroutines at once
# (each suspended D frames deep) against one holding none, per coroutine;
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
set hold 10000
foreach {option value} $args {
    switch -- $option {
        -runs { set runs $value }
        -n { set n $value }
        -hold { set hold $value }
        default { error "unknown option $option" }
    }
}

set prelude "import coroutine\nstruct V:\n    n: int\n"

proc program {kind n {depth 1}} {
    return [surface::compile [programText $kind $n $depth] -warnings off]
}

proc programText {kind n {depth 1}} {
    set p $::prelude
    switch -- $kind {
        create {
            append p "fn w(k: int) -> V:\n    yield V {n: k}\n    return V {n: k + 1}\n"
            append p "xs = loop i from 0 to $n:\n    coroutine {first} = w(i)\n    first.n\nlist::length(xs)\n"
        }
        create-base {
            append p "fn w(k: int) -> V:\n    V {n: k}\n"
            append p "xs = loop i from 0 to $n:\n    w(i).n\nlist::length(xs)\n"
        }
        complete {
            append p "fn w(k: int) -> V:\n    yield V {n: k}\n    return V {n: k + 1}\n"
            append p "xs = loop i from 0 to $n:\n    coroutine {step, first} = w(i)\n    last = step()\n    again = step()\n    first.n + last.n + again.n\nlist::length(xs)\n"
        }
        complete-base {
            append p "fn w(k: int) -> V:\n    V {n: k}\n"
            append p "xs = loop i from 0 to $n:\n    w(i).n + w(i + 1).n + w(i + 1).n\nlist::length(xs)\n"
        }
        resume {
            append p "fn counter(m: int) -> V:\n    loop i from 0 to m:\n        yield V {n: i}\n    return V {n: m}\n"
            append p "coroutine {step, first} = counter($n)\nxs = loop i from 0 to $n:\n    step().n\nlist::length(xs)\n"
        }
        resume-base {
            append p "fn make(i: int) -> V:\n    V {n: i}\n"
            append p "xs = loop i from 0 to $n:\n    make(i).n\nlist::length(xs)\n"
        }
        deep {
            append p "fn down(d: int, i: int) -> int:\n    if d == 0:\n        yield V {n: i}\n        return 0\n    down(d - 1, i) + 1\n"
            append p "fn counter(m: int) -> V:\n    loop i from 0 to m:\n        down($depth, i)\n    return V {n: m}\n"
            append p "coroutine {step, first} = counter($n)\nxs = loop i from 0 to $n:\n    step().n\nlist::length(xs)\n"
        }
        deep-base {
            append p "fn down(d: int, i: int) -> int:\n    if d == 0:\n        return 0\n    down(d - 1, i) + 1\n"
            append p "fn make(i: int) -> V:\n    V {n: i + down($depth, i)}\n"
            append p "xs = loop i from 0 to $n:\n    make(i).n\nlist::length(xs)\n"
        }
        hold {
            append p "fn down(d: int, k: int) -> int:\n    if d == 0:\n        yield V {n: k}\n        return k\n    down(d - 1, k) + 1\n"
            append p "fn w(k: int) -> V:\n    return V {n: down($depth, k)}\n"
            append p "fn hold(k: int) -> int:\n    if k == 0:\n        return 0\n    coroutine {step, first} = w(k)\n    x = hold(k - 1)\n    if coroutine::done?(step):\n        return x\n    x + first.n\n"
            append p "hold($n)\n"
        }
        terminal {
            append p "fn w(k: int) -> V:\n    yield V {n: k}\n    return V {n: k + 1}\n"
            append p "fn hold(k: int) -> int:\n    if k == 0:\n        return 0\n    coroutine {step, first} = w(k)\n    last = step()\n    x = hold(k - 1)\n    if coroutine::done?(step):\n        return x + last.n\n    x\n"
            append p "hold($n)\n"
        }
    }
    if {[string match *list::length* $p]} {
        set p "import list\n$p"
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
    set t [timeOn $backend [program $kind $::n $depth]]
    set b [timeOn $backend [program $base $::n $depth]]
    return [list [expr {($t - $b) * 1000.0 / $::n}] [expr {$t * 1000.0 / $::n}]]
}

proc ns {x} {
    return [format "%.0f ns" $x]
}

set backends {interp compile native}
puts "Coroutine performance (n = $n operations per program, best of $runs runs)\n"
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
} {
    set cells {}
    foreach backend $backends {
        lassign [perOp $kind $base $backend $depth] delta whole
        lappend cells "[ns $delta] ([ns $whole])"
    }
    puts "| $label | [join $cells { | }] |"
}

# Allocations per construction, natively.
puts "\nNative allocations of $n constructions (allocation report, summary):\n"
set report [native::allocationReport [program create $n] summary]
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

puts "\nResident memory per coroutine held at once (peak RSS with K = $hold coroutines alive minus with K = 0, divided by K):\n"
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
            set with [nativePeakKiB [program $kind $hold $depth]]
            set without [nativePeakKiB [program $kind 0 $depth]]
        } else {
            set with [tclPeakKiB $backend [programText $kind $hold $depth]]
            set without [tclPeakKiB $backend [programText $kind 0 $depth]]
        }
        lappend cells "[format %.1f [expr {($with - $without) * 1024.0 / $hold / 1024.0}]] KiB"
    }
    puts "| $label | [join $cells { | }] |"
}
