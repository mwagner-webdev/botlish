# event-loop.tcl -- the performance report of EVENT-LOOP-MILESTONE-1.md:
# the production scheduler and Linux driver (std::event_loop,
# packages/event_loop_linux) against the exploration's prototype
# (audit/event-loop: evloop.bot over evn.c), on the same machine, the same
# workloads, in one run.
#
#   tclsh9.0 bench/event-loop.tcl ?-runs N? ?-parts LIST? ?-timers LIST?
#
# Parts (default all):
#   alloc     allocations per dispatch (native allocation report, the
#             deterministic driver; the driver's own allocation sites left
#             out): a yield_now dispatch, a channel event (post + wait), for
#             both schedulers, as the difference between two sizes of the
#             same program;
#   dispatch  CPU per dispatch and per turn on the Linux drivers: 100 tasks x
#             1000 yield_now, channel ping-pong of 100,000 events;
#   timers    N sleeping tasks (N in -timers, default 10 100 1000 10000), each
#             sleeping K times: the prototype finds each expired timer by a
#             scan of every registration, the production scheduler by its
#             deadline heap;
#   extra     production only: registration create + revoke, the observer
#             phase's cost per observer, the flood scenario's throughput
#             and quiet-source latency, wakeup latency and idle cost
#             (tests/event-loop/native/flood.bot and wakeups.bot).
#
# Best of N runs (default 3) for times; each run is a fresh process. Times
# are a shared container's: treat them as orders of magnitude.
set here [file dirname [file normalize [info script]]]
set root [file dirname $here]
cd $root
set options [dict create -runs 3 -parts {alloc dispatch timers extra} -timers {10 100 1000 10000}]
foreach {k v} $argv {
    if {![dict exists $options $k]} {
        puts stderr "unknown option $k"
        exit 2
    }
    dict set options $k $v
}
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root tests event-loop native app.tcl]
set runs [dict get $options -runs]
set parts [dict get $options -parts]

set work [file tempdir evloop-bench]

# --- the two applications --------------------------------------------------

# The prototype: a copy of audit/event-loop/src with evn.c built where its
# modules link it (../build/libevn.a).
set proto [file join $work proto src]
file mkdir [file join $work proto build]
file copy [file join $root audit event-loop src] [file join $work proto]
exec cc -O2 -fPIC -c [file join $root audit event-loop native evn.c] -o [file join $work proto build evn.o]
exec ar rcs [file join $work proto build libevn.a] [file join $work proto build evn.o]

# The production application: the native scenario app plus the bench
# workloads.
set prod [file join $work prod]
eventLoopApp::create $prod
file copy -force [file join $here event-loop benchwork.bot] $prod

proc write {path text} {
    set f [open $path w]
    puts -nonewline $f $text
    close $f
}

# A prototype program running SPAWN under evn, reporting wall, cpu, turns,
# dispatched.
proc protoProgram {name spawn} {
    write [file join $::proto $name.bot] [string map [list %SPAWN% $spawn] {import benchwork
import evloop
import evn

fn main(context ev: evloop::Loop, n: evn::Native) -> List[str] errors IndexNotFound, evloop::LoopReentered:
    evloop::sync()
    %SPAWN%
    started = evn::clock()
    cpu = evn::cpu_us()
    turns = evloop::run()
    evloop::log(evloop::cat("wall us ", evn::clock() - started))
    evloop::log(evloop::cat("cpu us ", evn::cpu_us() - cpu))
    evloop::log(evloop::cat("turns ", turns))
    evloop::log(evloop::cat("dispatched ", evloop::stat(evloop::s_dispatched)))
    evloop::trace()

with context evloop::create(64, 0)
with context evn::create(4096, 16, 0)
main():
    on IndexNotFound:
        ["IndexNotFound"]
    on evloop::LoopReentered:
        ["LoopReentered"]
}]
    return [file join $::proto $name.bot]
}

# The same for the production scheduler and Linux driver.
proc prodProgram {name spawn} {
    write [file join $::prod $name.bot] [string map [list %SPAWN% $spawn] {import benchwork
import elog
import event_loop_linux
import std::event_loop

fn main(context ev: std::event_loop::Loop, d: event_loop_linux::Linux, n: event_loop_linux::Native) -> List[str] errors IndexNotFound, std::event_loop::SchedulerFault, std::event_loop::DriverFault, std::event_loop::LoopReentered:
    std::event_loop::sync()
    %SPAWN%
    started = event_loop_linux::now_us()
    cpu = event_loop_linux::cpu_us()
    turns = std::event_loop::run()
    elog::say("wall us ", event_loop_linux::now_us() - started)
    elog::say("cpu us ", event_loop_linux::cpu_us() - cpu)
    elog::say("turns ", turns)
    elog::say("dispatched ", std::event_loop::stats().dispatched)
    s = event_loop_linux::stats()
    elog::say("kernel polls ", s.poll_syscalls)
    elog::say("skipped polls ", s.polls_skipped)
    std::event_loop::trace()

with context std::event_loop::create(64)
with context event_loop_linux::create()
with context event_loop_linux::native()
main():
    on IndexNotFound:
        ["IndexNotFound"]
    on std::event_loop::SchedulerFault:
        ["SchedulerFault"]
    on std::event_loop::DriverFault:
        ["DriverFault"]
    on std::event_loop::LoopReentered:
        ["LoopReentered"]
}]
    return [file join $::prod $name.bot]
}

proc lines {path} {
    set hir [surface::readProgramFile $path -warnings off]
    set o [outcomeUnderHir cranelift $hir]
    if {[lindex $o 0] ne "value"} {
        error "$path: [string range $o 0 600]"
    }
    return [regexp -all -inline {"[^"]*"} [lindex $o 1]]
}

proc field {lines key} {
    foreach l $lines {
        if {[regexp "$key (-?\\d+)" $l -> v]} {
            return $v
        }
    }
    return ""
}

# Best of $runs (by CPU) of PATH: {cpu wall turns dispatched lines}.
proc best {path} {
    set best ""
    for {set r 0} {$r < $::runs} {incr r} {
        set l [lines $path]
        set cpu [field $l {cpu us}]
        if {$best eq "" || $cpu < [lindex $best 0]} {
            set best [list $cpu [field $l {wall us}] [field $l turns] [field $l dispatched] $l]
        }
    }
    return $best
}

proc row {label variant best} {
    lassign $best cpu wall turns dispatched
    puts [format "  %-32s %-10s %9d dispatches %7d turns %10.0f us cpu %8.2f us/dispatch %9.2f us/turn" \
        $label $variant $dispatched $turns $cpu [expr {double($cpu) / max(1, $dispatched)}] [expr {double($cpu) / max(1, $turns)}]]
}

# --- allocations ------------------------------------------------------------

proc allocations {path driverFile} {
    set hir [surface::readProgramFile $path -warnings off]
    set r [native::allocationReport $hir sites]
    set count 0
    set bytes 0
    foreach site [dict get $r sites] {
        set loc [dict getdef $site location {}]
        if {[string match *$driverFile [dict getdef $loc file {}]]} continue
        incr count [dict getdef $site allocations 0]
        incr bytes [dict getdef $site allocatedBytes 0]
    }
    return [list $count $bytes]
}

proc prodAlloc {name spawn} {
    write [file join $::prod $name.bot] [string map [list %SPAWN% $spawn] {import benchwork
import std::event_loop
import std::event_loop::deterministic

fn main(context ev: std::event_loop::Loop, d: std::event_loop::deterministic::Deterministic) -> int errors IndexNotFound, std::event_loop::SchedulerFault, std::event_loop::DriverFault, std::event_loop::LoopReentered:
    %SPAWN%
    std::event_loop::run()
    std::event_loop::stats().dispatched

with context std::event_loop::create(64)
with context std::event_loop::deterministic::create()
main():
    on IndexNotFound:
        -1
    on std::event_loop::SchedulerFault:
        -2
    on std::event_loop::DriverFault:
        -3
    on std::event_loop::LoopReentered:
        -4
}]
    return [file join $::prod $name.bot]
}

if {"alloc" in $parts} {
    puts "== allocations per dispatch (native, deterministic driver; the driver's own sites excluded)"
    foreach {label small large n} {
        "yield_now dispatch"   {spawn_yielders(10, 5000)} {spawn_yielders(10, 10000)} 50000
        "channel event (post + wait)" {spawn_pair(5000)} {spawn_pair(10000)} 5000
    } {
        # The prototype's own programs (alloc-*.bot) are these sizes.
        set p1 [file join $proto [expr {[string match yield* $label] ? "alloc-yield-1" : "alloc-event-1"}].bot]
        set p2 [file join $proto [expr {[string match yield* $label] ? "alloc-yield-2" : "alloc-event-2"}].bot]
        lassign [allocations $p1 simdrv.bot] c1 b1
        lassign [allocations $p2 simdrv.bot] c2 b2
        # (The larger program has twice the work: its setup is 2*c1 - c2.)
        puts [format "  %-32s %-10s %.3f allocations, %.1f bytes each (setup %d)" $label prototype \
            [expr {double($c2 - $c1) / $n}] [expr {double($b2 - $b1) / $n}] [expr {2 * $c1 - $c2}]]
        lassign [allocations [prodAlloc alloc-a "benchwork::$small"] deterministic.bot] c1 b1
        lassign [allocations [prodAlloc alloc-b "benchwork::$large"] deterministic.bot] c2 b2
        puts [format "  %-32s %-10s %.3f allocations, %.1f bytes each (setup %d)" $label production \
            [expr {double($c2 - $c1) / $n}] [expr {double($b2 - $b1) / $n}] [expr {2 * $c1 - $c2}]]
    }
    # Draining with try_take (production only: the prototype has no such program).
    lassign [allocations [prodAlloc alloc-a "benchwork::spawn_drain(5000)"] deterministic.bot] c1 b1
    lassign [allocations [prodAlloc alloc-b "benchwork::spawn_drain(10000)"] deterministic.bot] c2 b2
    puts [format "  %-32s %-10s %.3f allocations, %.1f bytes each (setup %d)" "event drained (try_take)" production \
        [expr {double($c2 - $c1) / 5000}] [expr {double($b2 - $b1) / 5000}] [expr {2 * $c1 - $c2}]]
}

if {"dispatch" in $parts} {
    puts "== dispatch (native, the Linux drivers, best of $runs)"
    foreach {label spawn} {
        "100 tasks x 1000 yield_now" {spawn_yielders(100, 1000)}
        "channel ping-pong, 100000 events" {spawn_pair(100000)}
    } {
        row $label prototype [best [protoProgram bench-x "benchwork::$spawn"]]
        set b [best [prodProgram bench-x "benchwork::$spawn"]]
        row $label production $b
        puts [format "  %-32s %-10s kernel polls %s, skipped polls %s" "" "" [field [lindex $b 4] {kernel polls}] [field [lindex $b 4] {skipped polls}]]
    }
}

if {"timers" in $parts} {
    puts "== timers (native, the Linux drivers, best of $runs): N tasks x K sleeps"
    foreach n [dict get $options -timers] {
        set k [expr {$n <= 100 ? 200 : ($n <= 1000 ? 20 : 2)}]
        set label "$n tasks x $k sleeps"
        set protoRuns $runs
        if {$n >= 10000} {
            # The prototype's scan is quadratic: one run is enough to show it.
            set saved $runs
            set runs 1
        }
        row $label prototype [best [protoProgram bench-t "benchwork::spawn_sleepers($n, $k)"]]
        if {$n >= 10000} {
            set runs $saved
        }
        row $label production [best [prodProgram bench-t "benchwork::spawn_sleepers($n, $k)"]]
    }
}

if {"extra" in $parts} {
    puts "== production only (native, the Linux driver, best of $runs)"
    write [file join $prod bench-churn.bot] {import benchwork
import elog
import event_loop_linux
import std::event_loop

fn main(context ev: std::event_loop::Loop, d: event_loop_linux::Linux, n: event_loop_linux::Native) -> List[str] errors std::event_loop::SchedulerFault:
    cpu = event_loop_linux::cpu_us()
    benchwork::churn(100000)
    elog::say("cpu us ", event_loop_linux::cpu_us() - cpu)
    std::event_loop::trace()

with context std::event_loop::create(64)
with context event_loop_linux::create()
with context event_loop_linux::native()
main():
    on std::event_loop::SchedulerFault:
        ["SchedulerFault"]
}
    set churn ""
    for {set r 0} {$r < $runs} {incr r} {
        set c [field [lines [file join $prod bench-churn.bot]] {cpu us}]
        if {$churn eq "" || $c < $churn} {
            set churn $c
        }
    }
    puts [format "  %-44s %.3f us per create + revoke" "100000 channel registrations" [expr {double($churn) / 100000}]]
    set base [best [prodProgram bench-o0 "benchwork::spawn_observers(0, 10000)"]]
    set with [best [prodProgram bench-o1 "benchwork::spawn_observers(100, 10000)"]]
    puts [format "  %-44s %.3f us per observer run (100 observers x 10000 turns: %d vs %d us cpu)" "observer phase" \
        [expr {double([lindex $with 0] - [lindex $base 0]) / 1000000}] [lindex $with 0] [lindex $base 0]]
    set f [lines [file join $prod flood.bot]]
    puts [format "  %-44s %s us wall for 40000 records (%.0f records/s), quiet max latency %s us, %s holds, %s refused posts" \
        "two floods + a quiet source (flood.bot)" [field $f {wall us}] [expr {40000.0 / max(1, [field $f {wall us}]) * 1e6}] \
        [field $f {quiet max latency us}] [field $f {held records}] [field $f {producer refusals}]]
    set w [lines [file join $prod wakeups.bot]]
    puts [format "  %-44s stream max %s us, pairs max %s us; idle 300 ms: %s us cpu, %s sleeps" "wakeup latency, idle (wakeups.bot)" \
        [lindex [regexp -all -inline {max latency us (\d+)} $w] 1] [lindex [regexp -all -inline {max latency us (\d+)} $w] 3] \
        [field $w {idle observed=0 cpu us}] [field $w {idle observed=0 sleeps}]]
}

file delete -force $work
