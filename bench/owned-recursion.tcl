# owned-recursion.tcl -- the scaling report of the recursive-ownership
# analysis (OWNED-RECURSION-DECLARATION-SUMMARY-MILESTONE-1.md,
# "Performance").
#
#   tclsh9.0 bench/owned-recursion.tcl ?-sizes {8 16 32 64 96 128}?
#       ?-reference 1? ?-frontend 1? ?-baseline DIR? ?-runs 3?
#
# Seven specimen families at every size N, each answered by
# hir::structs::OwnedRecursion from fresh facts:
#
#   chain     a chain of N plain structs, the last holding a coroutine handle
#             (a finite affine type N fields deep: accepted)
#   node      Node[Box^N[C]] of `children: List[Node[T]]` (rejected)
#   phantom   HW[List^N[C]] of `c: T, w: W[T]`, W phantom and growing
#             (accepted)
#   grow      GrowA[List^N[C]] of GrowA/GrowB (rejected, non-uniform)
#   ring      R0[C] of a ring of N declarations nesting their slot in a List
#             for the next, the last holding it and List[R0[T]] (rejected)
#   wide      Wide[C, int, ...] of one declaration of N slots, each held,
#             recursing on the slots rotated (rejected: N states)
#   repeated  N different applications Box[List^i[C]], then all of them
#             again (accepted; the second time read from the verdicts)
#
# For each: the verdict, wall time (milliseconds), declaration states
# visited, edges, walks, through-fact and edge computations, components and
# remembered verdicts read. With -reference 1, the old walk
# (audit/owned-recursion/tools/reference.tcl) on the same query: its verdict
# and time ("diverges" where it would exhaust memory). With -frontend 1, the
# whole front end's cost on real programs (golden suites holding affine
# values, actors, parameterized structs, maps, Hashable, trees, coroutines,
# C ABI types), median of -runs compilations in a fresh process each, here
# and in the checkout -baseline DIR (the revision before this milestone).

set root [file dirname [file dirname [file normalize [info script]]]]
array set opt {-sizes {8 16 32 64 96 128} -reference 1 -frontend 1 -baseline "" -runs 3}
array set opt $argv
set ::argv0 bench
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root audit owned-recursion tools reference.tcl]

set C {Coroutine{args: [], return: int}}
set cType [hir::types::MakeCoroutineType {} int {}]

proc wrap {id t n} {
    for {set i 0} {$i < $n} {incr i} {
        if {$id eq "List"} {
            set t [hir::types::MakeList $t]
        } else {
            set t [hir::types::MakeApplied $id [list $t]]
        }
    }
    return $t
}

# {SOURCE QUERIES} of family FAMILY at size N.
proc specimen {family n} {
    global C cType
    switch -- $family {
        chain {
            set decls ""
            for {set i 0} {$i < $n} {incr i} {
                append decls "struct S$i:\n    next: S[expr {$i + 1}]\n"
            }
            append decls "struct S$n:\n    c: $C\n"
            return [list $decls [list {nstruct S0}]]
        }
        node {
            return [list "struct Node\[T\]:\n    value: T\n    children: List\[Node\[T\]\]\nstruct Box\[T\]:\n    value: T\n" \
                [list [hir::types::MakeApplied Node [list [wrap Box $cType $n]]]]]
        }
        phantom {
            return [list "struct W\[T\]:\n    next: List\[W\[List\[T\]\]\]\nstruct HW\[T\]:\n    c: T\n    w: W\[T\]\n" \
                [list [hir::types::MakeApplied HW [list [wrap List $cType $n]]]]]
        }
        grow {
            return [list "struct GrowA\[T\]:\n    b: List\[GrowB\[List\[T\]\]\]\nstruct GrowB\[T\]:\n    a: GrowA\[T\]\n    value: T\n" \
                [list [hir::types::MakeApplied GrowA [list [wrap List $cType $n]]]]]
        }
        ring {
            set decls ""
            for {set i 0} {$i < $n - 1} {incr i} {
                append decls "struct R$i\[T\]:\n    next: R[expr {$i + 1}]\[List\[T\]\]\n"
            }
            append decls "struct R[expr {$n - 1}]\[T\]:\n    value: T\n    back: List\[R0\[T\]\]\n"
            return [list $decls [list [hir::types::MakeApplied R0 [list $cType]]]]
        }
        wide {
            set slots [lmap i [lseq $n] {string cat T$i}]
            set decls "struct Wide\[[join $slots {, }]\]:\n"
            foreach s $slots {
                append decls "    f$s: $s\n"
            }
            append decls "    next: List\[Wide\[[join [concat [lrange $slots 1 end] [lindex $slots 0]] {, }]\]\]\n"
            return [list $decls [list [hir::types::MakeApplied Wide [concat [list $cType] [lrepeat [expr {$n - 1}] int]]]]]
        }
        repeated {
            set queries {}
            for {set i 1} {$i <= $n} {incr i} {
                lappend queries [hir::types::MakeApplied Box [list [wrap List $cType $i]]]
            }
            return [list "struct Box\[T\]:\n    value: T\n" [concat $queries $queries]]
        }
    }
}

proc counter {c name} {
    return [dict getdef $c ownership.$name 0]
}

puts "== the verdict, from fresh facts (ms; states, edges, walks, through/edge computations, components, verdicts read)"
puts [format "%-9s %5s  %-9s %9s %7s %7s %7s %9s %6s %6s   %s" family N verdict ms states edges walks thr/edg comps hits old]
foreach family {chain node phantom grow ring wide repeated} {
    foreach n $opt(-sizes) {
        if {$family eq "wide" && $n > 32} continue
        # (The declarations first: an application is built against the
        # registry, which bounds it by its affinity.)
        set decls [lindex [specimen $family $n] 0]
        set hir [surface::compile "import std::coroutine\n${decls}1\n" -warnings off]
        hir::activate $hir
        set queries [lindex [specimen $family $n] 1]
        hir::structs::ForgetAffinity
        hir::summaries::ResetCounters
        set start [clock microseconds]
        set verdicts {}
        foreach q $queries {
            lappend verdicts [expr {[hir::structs::OwnedRecursion $q] eq "" ? "ok" : "recursive"}]
        }
        set ms [expr {([clock microseconds] - $start) / 1000.0}]
        set c [hir::summaries::counters]
        set old ""
        if {$opt(-reference)} {
            set start [clock microseconds]
            set r [::reference::owned::OwnedRecursion [lindex $queries 0]]
            set old "[expr {$r eq "" ? "ok" : [lindex $r 0]}] [format %.1f [expr {([clock microseconds] - $start) / 1000.0}]] ms"
        }
        puts [format "%-9s %5d  %-9s %9.1f %7d %7d %7d %9s %6d %6d   %s" $family $n [lindex [lsort -unique $verdicts] 0] $ms \
            [counter $c states] [counter $c edges] [counter $c walks] \
            "[counter $c throughComputations]/[counter $c edgeComputations]" [counter $c components] [counter $c verdictHits] $old]
    }
}

if {!$opt(-frontend)} {
    exit 0
}

# The front end's cost on real programs: each suite compiled RUNS times in a
# fresh process of ROOT's compiler (no cache), the median.
set suites {}
foreach name {affinity coroutines mutable-map mutable-array mutable-vector hashable tree-struct trait-constrained-types collections value-identity immutable-map c-abi-types actor} {
    set path [file join $root tests golden $name.bot]
    if {[file exists $path]} {
        lappend suites $path
    }
}
lappend suites [file join $root examples games icy-tower golden.bot]

proc frontend {checkout suites runs} {
    set script [file join [file tempdir botlish-owned-bench] measure.tcl]
    set f [open $script w]
    puts $f [string map [list @ROOT@ $checkout] {
        set ::argv0 bench
        source [file join {@ROOT@} compiler compiler.tcl]
        source [file join {@ROOT@} surface surface.tcl]
        set path [lindex $argv 0]
        set start [clock microseconds]
        if {[catch {surface::readProgramFile $path -warnings off} m]} {
            puts "error [string range $m 0 80]"
        } else {
            puts [expr {([clock microseconds] - $start) / 1000.0}]
        }
    }]
    close $f
    set result [dict create]
    foreach suite $suites {
        set times {}
        for {set i 0} {$i < $runs} {incr i} {
            lappend times [exec [info nameofexecutable] $script $suite]
        }
        dict set result [file tail $suite] [lindex [lsort -real $times] [expr {$runs / 2}]]
    }
    file delete -force [file dirname $script]
    return $result
}

puts "\n== the front end on real programs (ms, median of $opt(-runs))"
set here [frontend $root $suites $opt(-runs)]
set base ""
if {$opt(-baseline) ne ""} {
    set base [frontend [file normalize $opt(-baseline)] $suites $opt(-runs)]
}
puts [format "%-30s %10s %10s %8s" suite this baseline change]
set totalHere 0
set totalBase 0
dict for {suite ms} $here {
    if {$base ne ""} {
        set b [dict get $base $suite]
        set totalHere [expr {$totalHere + $ms}]
        set totalBase [expr {$totalBase + $b}]
        puts [format "%-30s %10.1f %10.1f %7.1f%%" $suite $ms $b [expr {100.0 * ($ms - $b) / $b}]]
    } else {
        puts [format "%-30s %10.1f" $suite $ms]
    }
}
if {$base ne ""} {
    puts [format "%-30s %10.1f %10.1f %7.1f%%" total $totalHere $totalBase [expr {100.0 * ($totalHere - $totalBase) / $totalBase}]]
}
