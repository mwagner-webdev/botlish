# variadics.tcl -- what a Botlish variadic call costs
# (VARIADICS-VERTICAL-SLICE-1.md, "Performance").
#
#   tclsh9.0 bench/variadics.tcl ?-runs N? ?-n N? ?-sites N?
#
# 1. Per call, ns (cranelift, specialized; best of RUNS executions of N
#    iterations, compilation excluded): a loop calling a variadic function
#    with K trailing Ints (K = 0, 1, 3, 8), beside the same function given
#    the List literal explicitly (`sum_list([i, 1, 2])`: what the call is),
#    a fixed-arity function of the same arguments where one exists, and the
#    loop alone. A variadic call is its List construction and the call: the
#    variadic and the explicit-List columns should agree within noise.
# 2. The interpreter and the Tcl compiler, the same K = 3 calls, us per call
#    (best of RUNS of N / 100 iterations): the Tcl backends' view of the same
#    equality.
# 3. Compile cost, ms (best of RUNS): the front end (surface::readProgramFile)
#    and native lowering (native::nir) of a program of SITES variadic call
#    sites beside the same program with explicit List arguments.

set root [file dirname [file dirname [file normalize [info script]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

set runs 5
set n 1000000
set sites 200
foreach {option value} $args {
    switch -- $option {
        -runs { set runs $value }
        -n { set n $value }
        -sites { set sites $value }
        default { error "unknown option $option" }
    }
}

set scratch [file tempdir botlish-bench-variadics-]

proc writeFile {path text} {
    set channel [open $path w]
    fconfigure $channel -encoding utf-8 -translation lf
    puts -nonewline $channel $text
    close $channel
}

set prelude {import std::list

fn sum_from(xs: List[int], i: int, acc: int) -> int:
    if i == xs.length():
        acc
    else:
        x = xs.at(i):
            on IndexNotFound:
                0
        xs.sum_from(i + 1, acc + x)

fn sum(variadic xs: List[int]) -> int:
    xs.sum_from(0, 0)

fn sum_list(xs: List[int]) -> int:
    xs.sum_from(0, 0)

fn first(variadic xs: List[int]) -> int:
    xs.length()

fn first_list(xs: List[int]) -> int:
    xs.length()

fn add3(a: int, b: int, c: int) -> int:
    a + b + c

}

proc compileApp {text} {
    set path [file join $::scratch main-[incr ::programs].bot]
    writeFile $path $text
    return [surface::readProgramFile $path -warnings off -cache ""]
}
set programs 0

proc program {body n} {
    return "$::prelude\nfn f() -> int:\n    xs = loop i from 0 to $n:\n        $body\n    std::list::length(xs)\n\nf()\n"
}

proc nativeBest {body} {
    set hir [compileApp [program $body $::n]]
    lassign [native::measure $hir $::runs] lower compile best
    return [expr {1000.0 * $best / $::n}]
}

proc tclBest {backend body} {
    set count [expr {max(1000, $::n / 100)}]
    set hir [compileApp [program $body $count]]
    set times {}
    for {set r 0} {$r < $::runs} {incr r} {
        lappend times [lindex [time {outcomeUnderHir $backend $hir}] 0]
    }
    return [expr {double([tcl::mathfunc::min {*}$times]) / $count}]
}

try {
    set loop [nativeBest 0]
    puts "1. cranelift, ns per iteration (best of $runs runs of $n iterations); the loop alone: [format %.1f $loop]"
    puts [format "  %-22s %12s %12s %12s" "" variadic "explicit List" fixed]
    foreach {label variadic explicit fixed} {
        "0 trailing (length)" {first()} {first_list([])} {}
        "1 trailing (length)" {first(i)} {first_list([i])} {}
        "3 trailing (sum)" {sum(i, 1, 2)} {sum_list([i, 1, 2])} {add3(i, 1, 2)}
        "8 trailing (sum)" {sum(i, 1, 2, 3, 4, 5, 6, 7)} {sum_list([i, 1, 2, 3, 4, 5, 6, 7])} {}
    } {
        set v [expr {[nativeBest $variadic] - $loop}]
        set e [expr {[nativeBest $explicit] - $loop}]
        set f [expr {$fixed eq "" ? "--" : [format %.1f [expr {[nativeBest $fixed] - $loop}]]}]
        puts [format "  %-22s %12.1f %12.1f %12s" $label $v $e $f]
    }
    puts ""
    puts "2. the Tcl backends, us per iteration of sum(i, 1, 2) and sum_list(\[i, 1, 2\]) (best of $runs runs of [expr {max(1000, $n / 100)}] iterations)"
    foreach backend {interp compile} {
        puts [format "  %-8s variadic %8.2f   explicit List %8.2f" $backend \
            [tclBest $backend {sum(i, 1, 2)}] [tclBest $backend {sum_list([i, 1, 2])}]]
    }
    puts ""
    puts "3. compile cost, ms (best of $runs): $sites call sites"
    foreach {label call} {variadic {sum(K, 1, 2, 3)} "explicit List" {sum_list([K, 1, 2, 3])}} {
        set lines {}
        for {set k 0} {$k < $sites} {incr k} {
            lappend lines "r$k = [string map [list K $k] $call]"
        }
        set text "$::prelude[join $lines \n]\n\[r0, r[expr {$sites - 1}]\]\n"
        set front {}
        set lower {}
        for {set r 0} {$r < $runs} {incr r} {
            lappend front [expr {[lindex [time {set hir [compileApp $text]}] 0] / 1000.0}]
            lappend lower [expr {[lindex [time {native::nir $hir}] 0] / 1000.0}]
        }
        puts [format "  %-14s front end %8.1f   native lowering %8.1f" $label \
            [tcl::mathfunc::min {*}$front] [tcl::mathfunc::min {*}$lower]]
    }
} finally {
    file delete -force $scratch
}
