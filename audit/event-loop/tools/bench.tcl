# bench.tcl -- EVENT-LOOP-EXPLORATION.md's performance numbers.
#
#   tclsh9.0 audit/event-loop/tools/bench.tcl ?-runs N?
#
# 1. Allocations per dispatch (native allocation report, deterministic
#    driver): the difference between two sizes of the same workload, with
#    the deterministic driver's own allocation sites (simdrv.bot) left out --
#    what the scheduler and the tasks allocate.
# 2. Time per dispatch and per turn (native, the epoll driver, real clock):
#    tasks that only yield; a producer/consumer pair through a channel;
#    10, 100 and 1000 sleeping tasks (the prototype's timer scan is linear
#    in the registrations: the cost a production version must remove).
#    Best of N runs (default 3); each run is a fresh process.
#
# Wakeup latency and idle cost are measured by b-wake.bot (check.tcl's
# native part), where they are claims.
set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set ::src [file join $root audit event-loop src]
cd $root
set runs 3
foreach {k v} $argv {
    if {$k eq "-runs"} { set runs $v } else { puts stderr "unknown option $k"; exit 2 }
}
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]

# The build of libevn.a check.tcl's native part makes.
set ::evRoot [file dirname $::src]
set ::evBuild [file join $::evRoot build]
file mkdir $::evBuild
exec cc -O2 -fPIC -c [file join $::evRoot native evn.c] -o [file join $::evBuild evn.o]
file delete [file join $::evBuild libevn.a]
exec ar rcs [file join $::evBuild libevn.a] [file join $::evBuild evn.o]

proc allocations {name} {
    set hir [surface::readProgramFile [file join $::src $name.bot] -warnings off]
    set r [native::allocationReport $hir sites]
    set count 0
    set bytes 0
    set kinds [dict create]
    foreach site [dict get $r sites] {
        set loc [dict getdef $site location {}]
        if {[string match *simdrv.bot [dict getdef $loc file {}]]} continue
        incr count [dict getdef $site allocations 0]
        incr bytes [dict getdef $site allocatedBytes 0]
        set fn [dict getdef $loc node ?]
        dict incr kinds "[file tail [dict getdef $loc file ?]]:[dict getdef $loc line ?] $fn" [dict getdef $site allocations 0]
    }
    return [list $count $bytes $kinds]
}

puts "== allocations (native, deterministic driver; the driver's own sites excluded)"
foreach {label small large n} {
    "yield_now dispatch" alloc-yield-1 alloc-yield-2 50000
    "channel event (post + wait: 2 dispatches)" alloc-event-1 alloc-event-2 5000
} {
    lassign [allocations $small] c1 b1
    lassign [allocations $large] c2 b2 kinds
    set per [expr {double($c2 - $c1) / $n}]
    set perBytes [expr {double($b2 - $b1) / $n}]
    puts [format "  %-44s %.3f allocations, %.1f bytes each" $label $per $perBytes]
    if {$per > 0} {
        dict for {k n} $kinds { if {$n > 100} { puts "      $n at $k" } }
    }
}

proc lines {name} {
    set hir [surface::readProgramFile [file join $::src $name.bot] -warnings off]
    set o [outcomeUnderHir cranelift $hir]
    return [regexp -all -inline {"[^"]*"} [lindex $o 1]]
}
proc field {lines key} {
    foreach l $lines { if {[regexp "$key (-?\\d+)" $l -> v]} { return $v } }
    return ""
}

puts "== time (native, epoll driver, best of $runs)"
foreach {name label} {
    bench-yield     "100 tasks x 1000 yield_now"
    bench-pair      "channel ping-pong, 100000 events"
    bench-sleep10   "10 tasks x 200 sleeps"
    bench-sleep100  "100 tasks x 200 sleeps"
    bench-sleep1000 "1000 tasks x 20 sleeps"
} {
    set best ""
    for {set r 0} {$r < $runs} {incr r} {
        set l [lines $name]
        set cpu [field $l {cpu us}]
        if {$best eq "" || $cpu < [lindex $best 0]} {
            set best [list $cpu [field $l {wall us}] [field $l turns] [field $l dispatched]]
        }
    }
    lassign $best cpu wall turns dispatched
    puts [format "  %-34s %8d dispatches %7d turns  %8.0f us cpu  %6.2f us/dispatch  %6.2f us/turn" \
        $label $dispatched $turns $cpu [expr {double($cpu) / $dispatched}] [expr {double($cpu) / $turns}]]
}
