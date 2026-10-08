# affine.tcl -- the performance report of general affinity and callable
# abstraction (AFFINE-VALUES.md, "Performance").
#
#   tclsh9.0 bench/affine.tcl ?-runs N? ?-n N? ?-native-n N? ?-backends LIST?
#
# Times, on every backend (Tcl interp, Tcl compile, Cranelift), programs that
# each repeat one operation N times, and reports the time per operation as
# (program - baseline) / N, the whole program per operation in parentheses:
#
#   resume-direct    a coroutine resumed N times by its own binding (the
#                    baseline every other resume row compares with: the
#                    same loop calling an ordinary function)
#   resume-param     the same resumes inside a function whose parameter is
#                    declared Coroutine{...}: what an affine parameter costs
#   resume-generic   the same inside an untyped (generic) function, which
#                    the compiler specializes for the coroutine
#   generic-exact    an untyped HOF given an exact function, against calling
#                    the function directly: the specialization keeps the
#                    direct call
#   move-call        a coroutine moved through one function per step (a
#                    recursion passing it on), against the same recursion
#                    passing an Int
#   move-struct      the same, wrapping it in a struct and destructuring it
#                    at every step
#   drop-struct      N constructions of a struct owning a coroutine, dropped
#                    at once, against N bare constructions dropped
#   drop-list        N/8 Lists of 8 abandoned coroutines, dropped whole,
#                    against the same 8 constructions dropped one by one
#
# Every timed number is best of RUNS in-process executions, compilation
# excluded (bench/coroutines.tcl's method).

set root [file dirname [file dirname [file normalize [info script]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root bench backends.tcl]
interp recursionlimit {} 200000

set runs 5
set n 4000
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

set prelude "import coroutine\nstruct V:\n    n: int\nstruct Box:\n    name: str\n    step: Coroutine{args: \[\], return: V}\n"
append prelude "fn counter(m: int) -> V:\n    loop i from 0 to m:\n        yield V {n: i}\n    return V {n: m}\n"
append prelude "fn idle(k: int) -> V:\n    yield V {n: k}\n    return V {n: k + 1}\n"

proc program {kind n} {
    return [surface::compile [programText $kind $n] -warnings off]
}

# N repetitions of LINES (`i` counts 0..N-1) as one collecting loop whose
# List nothing reads (bench/coroutines.tcl's Repeat).
proc Repeat {n lines} {
    set text "loop i from 0 to $n:\n"
    foreach line $lines {
        append text "    $line\n"
    }
    append text "$n\n"
    return $text
}

proc programText {kind n} {
    set p $::prelude
    switch -- $kind {
        resume-direct {
            append p "coroutine {step} = counter($n)\n" [Repeat $n {step().n}]
        }
        resume-base {
            append p "fn make(i: int) -> V:\n    V {n: i}\n" [Repeat $n {make(i).n}]
        }
        resume-param {
            append p "fn drive(s: Coroutine{args: \[\], return: V}, m: int) -> int:\n    loop i from 0 to m:\n        s().n\n    m\n"
            append p "coroutine {step} = counter($n)\ndrive(step, $n)\n"
        }
        resume-generic {
            append p "fn drive(s, m: int) -> int:\n    loop i from 0 to m:\n        s().n\n    m\n"
            append p "coroutine {step} = counter($n)\ndrive(step, $n)\n"
        }
        generic-exact {
            append p "fn invoke(f, x):\n    f(x)\nfn double(x: int) -> int:\n    x * 2\n" [Repeat $n {invoke(double, i)}]
        }
        generic-exact-base {
            append p "fn double(x: int) -> int:\n    x * 2\n" [Repeat $n {double(i)}]
        }
        move-call {
            append p "fn pass(s: Coroutine{args: \[\], return: V}) -> Coroutine{args: \[\], return: V}:\n    s\n"
            append p "fn chain(s: Coroutine{args: \[\], return: V}, k: int) -> int:\n    if k == 0:\n        x = s()\n        return x.n\n    chain(pass(s), k - 1)\n"
            append p "fn row(i: int) -> int:\n    coroutine {step} = idle(i)\n    chain(step, 64)\n"
            append p [Repeat [expr {$n / 64}] {row(i)}]
        }
        move-call-base {
            append p "fn pass(s: int) -> int:\n    s\n"
            append p "fn chain(s: int, k: int) -> int:\n    if k == 0:\n        return s\n    chain(pass(s), k - 1)\n"
            append p "fn row(i: int) -> int:\n    coroutine {step} = idle(i)\n    x = step()\n    chain(x.n, 64)\n"
            append p [Repeat [expr {$n / 64}] {row(i)}]
        }
        move-struct {
            append p "fn chain(s: Coroutine{args: \[\], return: V}, k: int) -> int:\n    if k == 0:\n        x = s()\n        return x.n\n    b = Box {name: \"b\", step: s}\n    {step} = b\n    chain(step, k - 1)\n"
            append p "fn row(i: int) -> int:\n    coroutine {step} = idle(i)\n    chain(step, 64)\n"
            append p [Repeat [expr {$n / 64}] {row(i)}]
        }
        drop-struct {
            append p [Repeat $n {"coroutine {step} = idle(i)" "b = Box {name: \"b\", step: step}" 1}]
        }
        drop-struct-base {
            append p [Repeat $n {"coroutine {step} = idle(i)" 1}]
        }
        drop-list {
            set elements [join [lrepeat 8 "make(i)"] {, }]
            append p "fn make(k: int) -> Coroutine{args: \[\], return: V}:\n    coroutine {step} = idle(k)\n    step\n"
            append p [Repeat [expr {$n / 8}] [list "xs = \[$elements\]" 1]]
        }
        drop-list-base {
            append p "fn make(k: int) -> Coroutine{args: \[\], return: V}:\n    coroutine {step} = idle(k)\n    step\n"
            append p [Repeat [expr {$n / 8}] [concat [lmap j {0 1 2 3 4 5 6 7} {string cat "s$j = make(i)"}] 1]]
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

proc perOp {kind base backend} {
    set n [expr {$backend eq "native" ? $::nativeN : $::n}]
    set t [timeOn $backend [program $kind $n]]
    set b [timeOn $backend [program $base $n]]
    return [list [expr {($t - $b) * 1000.0 / $n}] [expr {$t * 1000.0 / $n}]]
}

proc ns {x} {
    return [format "%.0f ns" $x]
}

puts "Affine values and callable abstraction: performance (n = $n operations per program on the Tcl backends, $nativeN natively; best of $runs runs)\n"
puts [bench::backends::manifest $backends]
puts ""
puts "| operation | baseline | [join [lmap b $backends {bench::backends::displayName $b}] { | }] |"
puts "|---|---|[string repeat ---:| [llength $backends]]"
foreach {label kind base} {
    "resume, by the handle's own binding" resume-direct resume-base
    "resume, through a Coroutine{...} parameter" resume-param resume-base
    "resume, through an untyped (specialized) parameter" resume-generic resume-base
    "untyped HOF given an exact function" generic-exact generic-exact-base
    "move through one function call" move-call move-call-base
    "move through a struct (wrap + destructure)" move-struct move-call-base
    "drop a struct owning a coroutine" drop-struct drop-struct-base
    "drop a List of 8 coroutines (per coroutine)" drop-list drop-list-base
} {
    set cells {}
    foreach backend $backends {
        lassign [perOp $kind $base $backend] delta whole
        lappend cells "[ns $delta] ([ns $whole])"
    }
    puts "| $label | $base | [join $cells { | }] |"
}
