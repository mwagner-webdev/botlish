# native.tcl -- check.tcl's native part (EVENT-LOOP-EXPLORATION.md,
# Experiments B and C): builds the C adapters, runs their C-level tests, and
# runs the b-*.bot programs on the native backend against real epoll,
# eventfd, sockets and threads (and SDL3, when tests/cffi/sdl3.tcl built it).
# Sourced by check.tcl (claim, strings, matches, first, ::src, ::outDir).
#
# The claims here are about time on a shared machine: each states a bound
# generous enough to hold on a loaded 4-core container, and the measured
# value is printed with it.

set ::evRoot [file dirname $::src]
set ::evBuild [file join $::evRoot build]
file mkdir $::evBuild

proc nativeBuild {} {
    set cc [expr {[info exists ::env(CC)] ? $::env(CC) : "cc"}]
    set flags {-O2 -Wall -Wextra -fPIC}
    exec $cc {*}$flags -c [file join $::evRoot native evn.c] -o [file join $::evBuild evn.o]
    file delete [file join $::evBuild libevn.a]
    exec ar rcs [file join $::evBuild libevn.a] [file join $::evBuild evn.o]
    exec $cc {*}$flags [file join $::evRoot native evn_test.c] [file join $::evBuild libevn.a] -o [file join $::evBuild evn_test] -lpthread
}

# The value of the native program NAME (a List[str]) as a list of lines.
proc nativeRun {name {backend cranelift} {dirs {}}} {
    set path [file join $::src $name.bot]
    set started [clock milliseconds]
    if {[catch {surface::readProgramFile $path -warnings error} hir options]} {
        claim $name "compiles (-warnings error)" 0 [string range $hir 0 400]
        return ""
    }
    if {$dirs ne ""} {
        set o [native::withLinkDirs $dirs {outcomeUnderHir $backend $hir}]
    } else {
        set o [outcomeUnderHir $backend $hir]
    }
    if {[lindex $o 0] ne "value"} {
        claim $name "runs on $backend" 0 [string range $o 0 600]
        return ""
    }
    set trace [strings [lindex $o 1]]
    set f [open [file join $::outDir $name.$backend.trace] w]
    puts $f [join $trace \n]
    close $f
    puts [format "        %-18s %s: %d lines, %.1f s" $name $backend [llength $trace] [expr {([clock milliseconds] - $started) / 1000.0}]]
    return $trace
}

proc num {trace re} {
    set m [first $trace $re]
    if {$m eq ""} { return "" }
    return [lindex $m 1]
}

if {[catch nativeBuild message]} {
    claim native "the C adapter builds" 0 $message
    return
}
claim native "the C adapter builds (cc, ar)" 1

set out [exec [file join $::evBuild evn_test]]
foreach line [split $out \n] {
    claim evn_test [string range $line 5 end] [string match "ok *" $line]
}

# --- wakeups, sleeping, idle (section 7)
foreach {name broken} {b-wake 0 b-wake-broken 1} {
    if {![string match $::only $name]} continue
    set t [nativeRun $name]
    if {$t eq ""} continue
    set received [lmap m [matches $t {received (\d+)}] {lindex $m 1}]
    set lateCounts [lmap m [matches $t {posts later than 5 ms (\d+)}] {lindex $m 1}]
    set maxes [lmap m [matches $t {max latency us (\d+)}] {lindex $m 1}]
    set late [tcl::mathop::+ {*}$lateCounts]
    if {!$broken} {
        claim $name "every post arrives (300 + 40)" [expr {$received eq "300 40"}] $received
        claim $name "no post waits for the heartbeat: none later than 5 ms (max [join $maxes /] us)" [expr {$late == 0}] "late $lateCounts"
        foreach observed {0 1} {
            set cpu [num $t "idle observed=$observed cpu us (\\d+)"]
            set wall [num $t "idle observed=$observed wall us (\\d+)"]
            set turns [num $t "idle observed=$observed turns (\\d+)"]
            claim $name "a 300 ms sleep (observer registered: $observed) takes one turn and < 2% CPU ($cpu us of $wall)" \
                [expr {$turns == 1 && $cpu < 6000}] "turns $turns"
        }
    } else {
        claim $name "positive control: the racy wakeup protocol delays posts to the heartbeat ($late posts > 5 ms, max [join $maxes /] us)" \
            [expr {$late > 0 && [tcl::mathfunc::max {*}$maxes] > 10000}]
    }
}

# --- the game server on real sockets, beside a flooding source
if {[string match $::only b-gameserver]} {
    set t [nativeRun b-gameserver]
    if {$t ne ""} {
        set replies [lmap c {1 2 3 4} {num $t "client $c replies (\\d+)"}]
        claim b-gameserver "every client gets every reply (22 51 51 3001)" [expr {$replies eq "22 51 51 3001"}] $replies
        claim b-gameserver "the independent telemetry source delivers all 20000 records" [expr {[num $t {telemetry records (\d+)}] == 20000}]
        set quiet {}
        set flood ""
        foreach m [matches $t {conn (\d+) lines (\d+)}] {
            lassign $m - conn lines
            set lag [num $t "conn $conn max lag us (\\d+)"]
            if {$lines == 3001} { set flood $lag } else { lappend quiet $lag }
        }
        claim b-gameserver "quiet connections stay responsive beside the flood and the telemetry (max lags [join $quiet /] us < 50 ms; flood $flood us)" \
            [expr {[llength $quiet] == 3 && [tcl::mathfunc::max {*}$quiet] < 50000}]
        set ring [num $t {adapter ring max (\d+)}]
        set pauses [num $t {adapter pauses for credit (\d+)}]
        claim b-gameserver "the flood is read on demand: $pauses pauses for credit, ring bounded ($ring <= 512)" \
            [expr {$pauses > 1000 && $ring <= 512}]
        claim b-gameserver "the world timer ticks 15 times and advances its AI coroutine directly" \
            [expr {[llength [matches $t {world tick}]] == 15}]
    }
}

source [file join [file dirname [info script]] native-more.tcl]
