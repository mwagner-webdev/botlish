# consumed-folds.tcl -- the performance report of
# CONSUMED-FOLD-INTERMEDIATES-MILESTONE-1.md: what consuming a fold's
# intermediate saves, natively, and what deciding it costs the compiler.
#
#   tclsh9.0 bench/consumed-folds.tcl ?-part run|compile|all? ?-sizes LIST?
#       ?-runs N? ?-idioms LIST? ?-programs FILES?
#
# run: for each idiom and size, the program compiled with the consumption
# on and off (hir::mutvec::consumedFolds: off is the elaboration before
# the milestone), its value checked, then natively: the best of RUNS
# in-process executions (native::measure: no process start), the best of
# RUNS whole driver processes (native::evalHir, start-up included, as
# audit/construct-binding-mutation/tools/fold-cost.tcl measures), and one
# instrumented run's counters (native::allocationReport): MutableVector and
# MutableArray shares, detaches and elements copied, heap allocations,
# vector growths and the backing bytes they allocated, collections. The
# first three idioms are the census's (corpus a02, a03, a04, with their
# inputs); the others are this milestone's:
#
#   fold-intermediate  push and complete with it (a02)        consumed
#   outer-local        an outer local pushed in a loop (a03)  no fold
#   threaded-copy      a working copy threaded through calls  no fold
#   fold-struct        a struct of two vectors, one pushed    consumed
#   fold-skip-first    `continue` before the push             consumed
#   fold-skip-after    `continue` after the push (c08)        copied: its
#                      exit needs the iteration's starting value
#   fold-map           MutableMap.set on the intermediate     consumed
#
# compile: the front end (surface::compile) of each program of -programs
# (by default the census corpus's programs, the fold-loops golden suite and
# the mutable-vector one), best of RUNS, with the consumption on and off.

set here [file dirname [file normalize [info script]]]
set root [file dirname $here]
set options [dict create -part all -sizes {1000 4000 16000 32000} -runs 3 -idioms "" -programs ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} {
        puts stderr "consumed-folds.tcl: unknown option $option"
        exit 2
    }
    dict set options $option $value
}
set argv {}
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
source [file join $root examples stdlib corpus.tcl]

set corpus [file join $root audit construct-binding-mutation corpus]
set ints {import std::mutable_vector

fn ints() -> MutableVector[int]:
    std::mutable_vector::from_list([])

}
# NAME {SOURCE CALL EXPECTED}: SOURCE's CALL with N for its size, whose
# value is EXPECTED (with N).
set idioms [dict create \
    fold-intermediate [list [core::ReadFile [file join $corpus a02-fold-push-return.bot]] {f(1000)} {int N}] \
    outer-local [list [core::ReadFile [file join $corpus a03-outer-local.bot]] {f(1000)} {int N}] \
    threaded-copy [list [core::ReadFile [file join $corpus a04-recursion-threaded.bot]] {fill(ints(), 0, 1000)} {int N}] \
    fold-struct [list "${ints}struct Acc:
    evens: MutableVector\[int\]
    odds: MutableVector\[int\]

fn split(n: int) -> int:
    t = fold i from 0 to n with intermediate a Acc {evens: ints(), odds: ints()}:
        if i < n - i:
            a.evens.push(i)
        else:
            a.odds.push(i)
        a
    t.evens.length() + t.odds.length()

split(1000)
" {split(1000)} {int N}] \
    fold-skip-first [list "${ints}fn f(n: int) -> int:
    w = fold i from 0 to n with intermediate acc ints():
        if i < 0:
            continue
        acc.push(i)
        acc
    w.length()

f(1000)
" {f(1000)} {int N}] \
    fold-skip-after [list "${ints}fn f(n: int) -> int:
    w = fold i from 0 to n with intermediate acc ints():
        acc.push(i)
        if i < 0:
            continue
        acc
    w.length()

f(1000)
" {f(1000)} {int N}] \
    fold-map [list {import std::mutable_map

fn f(n: int) -> int:
    m = fold i from 0 to n with intermediate acc std::mutable_map::create[int, int]():
        acc.set(i, i)
        acc
    m.length()

f(1000)
} {f(1000)} {int N}]]

proc hirOf {text on} {
    set saved $::hir::mutvec::consumedFolds
    set ::hir::mutvec::consumedFolds $on
    try {
        return [surface::compile $text -warnings off]
    } finally {
        set ::hir::mutvec::consumedFolds $saved
    }
}

proc runPart {} {
    global idioms options
    set selected [dict get $options -idioms]
    if {$selected eq ""} {
        set selected [dict keys $idioms]
    }
    set runs [dict get $options -runs]
    puts [format "%-18s %6s %4s %10s %10s %7s %7s %10s %6s %6s %11s %5s" \
        idiom n on "in-proc us" "proc us" shares detach elements allocs growth "growth B" gcs]
    # (proc us: a whole driver process -- lowering the HIR to NIR, code
    # generation, start-up and the run.)
    foreach idiom $selected {
        lassign [dict get $idioms $idiom] text call expected
        foreach n [dict get $options -sizes] {
            set source [string map [list $call [string map [list 1000 $n] $call]] $text]
            foreach on {1 0} {
                set hir [hirOf $source $on]
                lassign [native::measure $hir $runs] - - best collections value
                if {$value ne [string map [list N $n] $expected]} {
                    error "$idiom n=$n on=$on: value $value"
                }
                set process ""
                for {set k 0} {$k < $runs} {incr k} {
                    set t0 [clock microseconds]
                    native::evalHir $hir
                    set t [expr {[clock microseconds] - $t0}]
                    if {$process eq "" || $t < $process} {
                        set process $t
                    }
                }
                set report [native::allocationReport $hir summary]
                set copies {0 0 0}
                foreach kind {mutableVector mutableArray} {
                    if {![dict exists $report $kind]} continue
                    set i 0
                    foreach field {shares detaches detachElements} {
                        lset copies $i [expr {[lindex $copies $i] + [dict getdef $report $kind $field 0]}]
                        incr i
                    }
                }
                puts [format "%-18s %6d %4d %10.0f %10ld %7ld %7ld %10ld %6ld %6ld %11ld %5ld" $idiom $n $on $best $process \
                    {*}$copies [dict get $report total allocations] \
                    [dict get $report mutableVector growths] [dict get $report mutableVector growthBytes] \
                    [dict get $report gc cycles]]
            }
        }
    }
}

proc compilePart {} {
    global options root corpus
    set programs [dict get $options -programs]
    if {$programs eq ""} {
        set programs [lsort [glob -directory $corpus *.bot]]
        lappend programs [file join $root tests golden fold-loops.bot] [file join $root tests golden mutable-vector.bot]
    }
    set runs [dict get $options -runs]
    puts [format "%-44s %12s %12s %8s" program "on us" "off us" "on/off"]
    set totals {0 0}
    foreach path $programs {
        set times {}
        foreach on {1 0} {
            set best ""
            for {set k 0} {$k < $runs} {incr k} {
                set saved $::hir::mutvec::consumedFolds
                set ::hir::mutvec::consumedFolds $on
                try {
                    set t [lindex [time {catch {surface::readProgramFile $path -warnings off}}] 0]
                } finally {
                    set ::hir::mutvec::consumedFolds $saved
                }
                if {$best eq "" || $t < $best} {
                    set best $t
                }
            }
            lappend times $best
        }
        lset totals 0 [expr {[lindex $totals 0] + [lindex $times 0]}]
        lset totals 1 [expr {[lindex $totals 1] + [lindex $times 1]}]
        puts [format "%-44s %12ld %12ld %8.3f" [file tail $path] {*}$times [expr {double([lindex $times 0]) / [lindex $times 1]}]]
    }
    puts [format "%-44s %12ld %12ld %8.3f" total {*}$totals [expr {double([lindex $totals 0]) / [lindex $totals 1]}]]
}

if {[dict get $options -part] in {run all}} {
    runPart
}
if {[dict get $options -part] in {compile all}} {
    compilePart
}
