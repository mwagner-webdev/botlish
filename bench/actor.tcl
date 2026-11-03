# actor.tcl -- the performance report of SAME-THREAD-ACTORS-MILESTONE-1.md:
# std::actor over std::event_loop on the Linux driver (packages/
# event_loop_linux, real clock), natively, beside the bare channel baseline
# -- the census's Probe F workloads (THREAD-ACTOR-ARCHITECTURE-CENSUS.md,
# section 12.6) and the milestone's own.
#
#   tclsh9.0 bench/actor.tcl ?-runs N? ?-backend cranelift|cranelift-generic?
#
# The workloads are bench/actor/main.bot, built into a private application
# directory (bench/actor/meter.c archived into native/, the Linux driver
# package installed under .bot_modules) and run N times (default 3), each in
# a fresh process. For every phase it prints the per-operation wall and CPU
# time, the best and the worst run, and the memory lines of the last run.
# Times are a shared container's: compare them with each other and with the
# census's numbers as relative costs, never as absolutes.
set here [file dirname [file normalize [info script]]]
set root [file dirname $here]
set options [dict create -runs 3 -backend cranelift]
foreach {k v} $argv {
    if {![dict exists $options $k]} {
        puts stderr "unknown option $k"
        exit 2
    }
    dict set options $k $v
}
source [file join $root tools event-loop-linux.tcl]
set env(LANG) C.utf8
set env(LC_ALL) C.utf8

set dir [file tempdir actor-bench]
try {
    file mkdir [file join $dir native]
    foreach f [glob -directory [file join $root bench actor] *.bot] {
        file copy $f $dir
    }
    eventLoopLinux::install $dir
    set obj [file join $dir native meter.o]
    exec cc -O2 -Wall -Wextra -Werror -fPIC -c [file join $root bench actor meter.c] -o $obj
    exec ar rcs [file join $dir native libmeter.a] $obj
    file delete $obj

    # phase -> {wall cpu ops} per run
    set phases {}
    set order {}
    set notes {}
    for {set run 1} {$run <= [dict get $options -runs]} {incr run} {
        set out [exec [info nameofexecutable] [file join $root main.tcl] -warnings off \
            -backend [dict get $options -backend] [file join $dir main.bot] 2>@1]
        set value ""
        foreach line [split $out \n] {
            if {[regexp {^\s+value: (.*)$} $line -> v]} { set value $v }
        }
        if {$value eq ""} {
            error "no value:\n[string range $out 0 4000]"
        }
        set notes {}
        foreach {- line} [regexp -all -inline {"((?:[^"\\]|\\.)*)"} $value] {
            regsub {^t=\d+: } $line {} line
            if {[regexp {^(.*) (ops|wall us|cpu us) (\d+)$} $line -> name what n]} {
                if {$name ni $order} { lappend order $name }
                dict set current $name $what $n
            } else {
                lappend notes $line
            }
        }
        dict for {name m} $current {
            dict lappend phases $name [list [dict get $m {wall us}] [dict get $m {cpu us}] [dict get $m ops]]
        }
    }
    puts [format "%-58s %8s  %-23s %-23s" phase ops "wall us/op (best-worst)" "cpu us/op (best-worst)"]
    foreach name $order {
        set walls {}
        set cpus {}
        foreach r [dict get $phases $name] {
            lassign $r wall cpu ops
            lappend walls [expr {double($wall) / $ops}]
            lappend cpus [expr {double($cpu) / $ops}]
        }
        set walls [lsort -real $walls]
        set cpus [lsort -real $cpus]
        puts [format "%-58s %8d  %-23s %-23s" $name $ops \
            [format "%.2f (%.2f-%.2f)" [lindex $walls 0] [lindex $walls 0] [lindex $walls end]] \
            [format "%.2f (%.2f-%.2f)" [lindex $cpus 0] [lindex $cpus 0] [lindex $cpus end]]]
    }
    puts ""
    foreach line $notes {
        puts $line
    }
    puts "-- [dict get $options -backend], [dict get $options -runs] run(s)"
} finally {
    file delete -force $dir
}
