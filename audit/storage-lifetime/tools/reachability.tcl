# reachability.tcl -- hir/lifetime.tcl's confinement claims against the
# native backend's reachability under GC stress
# (STORAGE-LIFETIME-FACTS-MILESTONE-1.md, "Differential comparison with
# native GC-stress reachability").
#
#   tclsh9.0 audit/storage-lifetime/tools/reachability.tcl ?-small 6?
#       ?-large 30? ?-shapes GLOB?
#
# Each shape is a program whose one allocation per iteration of a fold in
# `run` is the String `s` (std::int::to_string), disposed of in one way:
# dropped, kept by a vector of the iteration, pushed into a vector made
# before the fold, carried by a String intermediate, stored in context
# state, captured, sent through a helper, held across a coroutine's
# suspension... For each, the analysis gives the producer's verdict for the
# fold's iteration, and the native backend runs the program twice, N small
# and N large, under BOTLISH_NATIVE_GC_STRESS=1 (a collection before every
# allocation, precise roots), reporting the peak of reachable objects.
#
#   * confined, and the peak does not grow with N: consistent;
#   * confined, and the peak grows: CONTRADICTED -- an object the analysis
#     says dies with its iteration is still reachable iterations later (exit
#     status 1);
#   * escapes or unknown, and the peak grows: confirmed dynamically;
#   * escapes or unknown, and the peak does not grow: the claim is
#     conservative here (a carried intermediate replaced every iteration
#     escapes its iteration and still dies one later).
#
# A run observes the paths it executes and the roots the native backend
# keeps: it can contradict a claim, never prove one.
set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set options [dict create -small 6 -large 30 -shapes *]
foreach {k v} $argv {
    if {![dict exists $options $k]} {
        error "unknown option $k"
    }
    dict set options $k $v
}
set argv {}
source [file join $root native native.tcl]
source [file join $root surface surface.tcl]
set env(LANG) C.utf8
set env(LC_ALL) C.utf8

# NAME -> {expected-iteration-verdict PROGRAM}, the program with N for the
# size; the producer is the line holding `s = `.
set shapes {
    dropped {confined {
import std::int
import std::str

fn run(n: int) -> int:
    fold i from 0 to n with intermediate acc 0:
        s = std::int::to_string(i)
        acc + std::str::length(s)

run(N)
}}
    iteration-vector {confined {
import std::int
import std::str
import std::mutable_vector

fn run(n: int) -> int:
    fold i from 0 to n with intermediate acc 0:
        s = std::int::to_string(i)
        v = std::mutable_vector::from_list([s])
        v.push(s)
        acc + std::mutable_vector::length(v)

run(N)
}}
    outer-vector {escapes {
import std::int
import std::str
import std::mutable_vector

fn run(n: int) -> int:
    v = std::mutable_vector::from_list([""])
    f = fold i from 0 to n with intermediate acc 0:
        s = std::int::to_string(i)
        v.push(s)
        acc + 1
    f + std::mutable_vector::length(v)

run(N)
}}
    outer-vector-some {escapes {
import std::int
import std::str
import std::mutable_vector

fn run(n: int) -> int:
    v = std::mutable_vector::from_list([""])
    f = fold i from 0 to n with intermediate acc 0:
        s = std::int::to_string(i)
        if i.mod(3) == 0:
            v.push(s)
        acc + 1
    f + std::mutable_vector::length(v)

run(N)
}}
    carried {escapes {
import std::int
import std::str

fn run(n: int) -> int:
    t = fold i from 0 to n with intermediate acc "":
        s = std::int::to_string(i)
        acc.concat(s)
    std::str::length(t)

run(N)
}}
    struct-dropped {confined {
import std::int
import std::str

struct Box:
    text: str
    n: int

fn run(n: int) -> int:
    fold i from 0 to n with intermediate acc 0:
        s = std::int::to_string(i)
        b = Box {text: s, n: i}
        acc + std::str::length(b.text)

run(N)
}}
    helper-alias {confined {
import std::int
import std::str

fn keep(x: str) -> str:
    x

fn run(n: int) -> int:
    fold i from 0 to n with intermediate acc 0:
        s = std::int::to_string(i)
        k = keep(s)
        acc + std::str::length(k)

run(N)
}}
    helper-place {escapes {
import std::int
import std::str
import std::mutable_vector

fn stash(place v: MutableVector[str], x: str):
    v.push(x)

fn run(n: int) -> int:
    v = std::mutable_vector::from_list([""])
    f = fold i from 0 to n with intermediate acc 0:
        s = std::int::to_string(i)
        stash(v, s)
        acc + 1
    f + std::mutable_vector::length(v)

run(N)
}}
    closure-dropped {confined {
import std::int
import std::str

fn run(n: int) -> int:
    fold i from 0 to n with intermediate acc 0:
        s = std::int::to_string(i)
        fn measure() -> int:
            std::str::length(s)
        acc + measure()

run(N)
}}
    context-state {escapes {
import std::int
import std::str
import std::mutable_vector

context struct Log:
    lines: MutableVector[str]

fn note(x: str, context l: Log):
    l.lines.push(x)

fn run(n: int, context l: Log) -> int:
    fold i from 0 to n with intermediate acc 0:
        s = std::int::to_string(i)
        note(s)
        acc + 1

with context Log {lines: std::mutable_vector::from_list([""])}
run(N)
}}
    coroutine-iteration {confined {
import std::coroutine
import std::int
import std::str

fn worker(seed: int) -> int:
    kept = std::int::to_string(seed).concat("!")
    yield 1
    std::str::length(kept)

fn run(n: int) -> int:
    fold i from 0 to n with intermediate acc 0:
        s = std::int::to_string(i)
        coroutine {step, first} = worker(i)
        acc + first + step() + std::str::length(s)

run(N)
}}
    returned-each {confined {
import std::int
import std::str

fn make(i: int) -> str:
    std::int::to_string(i)

fn run(n: int) -> int:
    fold i from 0 to n with intermediate acc 0:
        s = make(i)
        acc + std::str::length(s)

run(N)
}}
}

proc Peak {source n} {
    set hir [surface::compile [string map [list N $n] $source] -warnings off]
    set ::env(BOTLISH_NATIVE_GC_STRESS) 1
    try {
        set report [native::allocationReport $hir summary]
    } finally {
        unset -nocomplain ::env(BOTLISH_NATIVE_GC_STRESS)
    }
    return [dict get $report total peakLiveObjects]
}

set contradictions 0
set rows {}
dict for {name shape} $shapes {
    if {![string match [dict get $options -shapes] $name]} continue
    lassign $shape expected source
    set hir [surface::compile [string map {N 3} $source] -warnings off]
    set facts [hir::lifetime::analyze $hir]
    set verdict ""
    foreach id [hir::lifetime::units $facts] {
        set u [hir::lifetime::unit $facts $id]
        if {![string match run<* [dict get $u label]]} continue
        dict for {site p} [dict get $u producers] {
            set e [dict get $p expr]
            # The producer bound to `s`.
            set bind ""
            dict for {x node} [dict get $hir exprs] {
                if {[dict get $node kind] eq "bind" && [dict get $node value] eq $e} {
                    set bind $x
                }
            }
            if {$bind eq "" || [hir::semantic::SourceName $hir [dict get $hir exprs $bind binding]] ne "s"} continue
            dict for {region v} [dict get $u verdicts $site] {
                if {[lindex $region 0] eq "iteration"} {
                    set verdict [dict get $v verdict]
                }
            }
        }
    }
    set small [Peak $source [dict get $options -small]]
    set large [Peak $source [dict get $options -large]]
    set grew [expr {$large > $small}]
    if {$verdict eq "confined"} {
        set outcome [if {$grew} {string cat CONTRADICTED} else {string cat consistent}]
    } elseif {$grew} {
        set outcome "confirmed"
    } else {
        set outcome "conservative here"
    }
    if {$outcome eq "CONTRADICTED"} {
        incr contradictions
    }
    set flag [if {$verdict ne $expected} {string cat " (expected $expected)"} else {string cat ""}]
    lappend rows [format "%-20s iteration %-9s peak %3d -> %3d  %s%s" $name $verdict $small $large $outcome $flag]
}
puts [join $rows \n]
puts "contradictions $contradictions"
exit [expr {$contradictions > 0}]
