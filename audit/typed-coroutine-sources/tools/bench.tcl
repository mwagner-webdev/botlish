# bench.tcl -- what the conflation costs a consumer natively, and what a
# materialized tagged outcome would cost
# (EMISSION-TYPED-COROUTINE-SOURCE-CENSUS-MILESTONE-1.md, section 12).
#
#   tclsh9.0 audit/typed-coroutine-sources/tools/bench.tcl ?-n N? ?-runs R?
#       ?-out FILE?
#
# Programs, each a byte source of N symbols (yield 65 + i mod 26: a value
# hir::range proves in [65, 90]) whose result is N, and a consumer that
# folds every symbol into a checksum:
#
#   plain      the consumer uses each symbol as the int it receives
#   narrowed   the consumer needs a Byte (a Byte parameter): it narrows each
#              symbol first (`if b < 0 or b > 255: fail`), as export.bot does
#   enum       the source yields a payload-bearing enum case per symbol and
#              returns another case: the shape a tagged outcome
#              (Yielded {value} | Completed {value}) would have if it were an
#              ordinary payload enum value built per segment; the consumer
#              only counts segments (no program can read a payload today)
#
# each on cranelift (coroutine fusion on) and cranelift-unfused (the
# general runtime): the best of R runs' time (native::measure, compile time
# excluded) and the allocations of one run (native::allocationReport).
set here [file dirname [file normalize [info script]]]
set audit [file dirname $here]
set options [dict merge [list -n 200000 -runs 7 -out [file join $audit results bench.md]] $argv]
set argv {}
source [file join [file dirname [file dirname $audit]] tests helpers.tcl]
source [file join $::projectRoot surface surface.tcl]

set common {import std::coroutine
import std::byte
import std::int
import std::mutable_array

error NotByte

fn mix(h: int, c: int) -> int:
    (h * 31 + c + 1).mod(2147483647)

fn take(b: std::byte::Byte) -> int:
    b

}

set programs [dict create]
dict set programs plain [string cat $common {
fn source(n: int) -> int:
    loop i from 0 to n:
        yield 65 + i.mod(26)
        continue
    n

fn digest(n: int) -> int:
    coroutine {step, first} = source(n)
    state = std::mutable_array::create(2, 0)
    state.set(1, first)
    loop:
        if std::coroutine::done?(step):
            break
        b = state.at(1)
        state.set(0, state.at(0).mix(b))
        state.set(1, step())
    state.at(0)

digest(@N@)
}]
dict set programs narrowed [string cat $common {
fn source(n: int) -> int:
    loop i from 0 to n:
        yield 65 + i.mod(26)
        continue
    n

fn digest(n: int) -> int errors NotByte:
    coroutine {step, first} = source(n)
    state = std::mutable_array::create(2, 0)
    state.set(1, first)
    loop:
        if std::coroutine::done?(step):
            break
        b = state.at(1)
        if b < 0 or b > 255:
            fail NotByte
        state.set(0, state.at(0).mix(take(b)))
        state.set(1, step())
    state.at(0)

digest(@N@):
    on NotByte:
        -1
}]
dict set programs enum [string cat $common {
enum Step:
    Yielded {value: int},
    Completed {value: int},

fn source(n: int) -> Step:
    loop i from 0 to n:
        yield Step::Yielded {value: 65 + i.mod(26)}
        continue
    Step::Completed {value: n}

fn digest(n: int) -> int:
    coroutine {step, first} = source(n)
    state = std::mutable_array::create(1, 0)
    loop:
        if std::coroutine::done?(step):
            break
        state.set(0, state.at(0) + 1)
        step()
    state.at(0)

digest(@N@)
}]

set n [dict get $options -n]
set runs [dict get $options -runs]
set lines [list "# Typed coroutine sources: consumer costs (bench.tcl)" "" \
    "N = $n symbols per run; best of $runs runs (native::measure, compile excluded); allocations of one run." "" \
    "| program | backend | best (ms) | ns / symbol | allocations | value |" "|---|---|---:|---:|---:|---|"]
foreach name {plain narrowed enum} {
    set hir [surface::compile [string map [list @N@ $n] [dict get $programs $name]] -warnings off]
    foreach backend {cranelift cranelift-unfused} {
        set script {
            lassign [native::measure $hir $runs] lower compile best collections value
            set report [native::allocationReport $hir summary]
        }
        if {$backend eq "cranelift-unfused"} {
            withoutCoroutineFusion $script
        } else {
            eval $script
        }
        set allocs ?
        regexp {allocations (\d+)} $report -> allocs
        set row [format "| %s | %s | %.2f | %.1f | %s | %s |" $name $backend [expr {$best / 1000.0}] \
            [expr {$best * 1000.0 / $n}] $allocs $value]
        lappend lines $row
        puts $row
        flush stdout
    }
}
set f [open [dict get $options -out] w]
fconfigure $f -encoding utf-8
puts $f [join $lines \n]
close $f
