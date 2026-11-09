# parity.tcl -- the 2048 library built for android-aarch64, played in an
# Android process, against the interpreter
# (ANDROID-AARCH64-TARGET-SUPPORT-MILESTONE-1.md, "2048 integration").
#
#   tclsh9.0 parity.tcl -app DIR ?-steps N? ?-target T? ?-botlish CMD? -run COMMAND...
#
# DIR is the application whose engine.bot (audit/external-tools/2048) the
# library was built from (its .bot_modules holds the game2048 package);
# COMMAND... runs the Android host (host/host2048.c) with its library in
# `play` mode: an Android launcher such as tools/android-run.sh ROOT HOST
# LIB play. The script is PM-7A's (tests/external-tools.test's et2048Script):
# a new game, two spawns, N moves and spawns from a fixed linear
# congruential sequence, then score, over, first_empty and the four
# declared errors. The interpreter (-backend interp) plays the same steps
# with the same engine module, compiled for the same target (-target,
# default android-aarch64: the application's package view of the library's
# target; the reference interpreter runs a program of any target). Prints a summary line per check and exits 1
# on any difference.
set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set app ""
set run {}
set steps 160
set target android-aarch64
set botlish [list [info nameofexecutable] [file join $root main.tcl]]
set i 0
while {$i < $argc} {
    set option [lindex $argv $i]
    switch -- $option {
        -app { set app [lindex $argv [incr i]] }
        -steps { set steps [lindex $argv [incr i]] }
        -target { set target [lindex $argv [incr i]] }
        -botlish { set botlish [lindex $argv [incr i]] }
        -run { set run [lrange $argv [expr {$i + 1}] end]; set i $argc; continue }
        default { puts stderr "parity.tcl: unknown option $option"; exit 2 }
    }
    incr i
}
if {$app eq "" || ![llength $run]} {
    puts stderr "usage: parity.tcl -app DIR ?-steps N? ?-botlish CMD? -run COMMAND..."
    exit 2
}

proc Steps {count} {
    set x 12345
    set out {}
    for {set i 0} {$i < $count} {incr i} {
        set x [expr {($x * 1103515245 + 12345) % 2147483648}]
        lappend out [list [expr {($x >> 16) % 4}] [expr {(($x >> 8) % 10) == 0 ? 4 : 2}]]
    }
    return $out
}

proc Script {steps} {
    set lines [list new_game "spawn_first\t@\t2" "spawn_first\t@\t4"]
    foreach step $steps {
        lappend lines "move\t@\t[lindex $step 0]" "spawn_first\t@\t[lindex $step 1]"
    }
    lappend lines "score\t@" "over\t@" "first_empty\t@" "move\tnot a state\t0" "move\t@\t9" \
        "spawn\t0 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0\t0\t0\t2" "spawn\t0 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0\t0\t1\t3"
    return [join $lines \n]\n
}

# The interpreter's states for STEPS: the start, then each moved and spawned
# state, and its score, over and first_empty of the last one.
proc Oracle {app steps botlish target} {
    set literal "\[[join [lmap s $steps {string cat \[ [lindex $s 0] ", " [lindex $s 1] \]}] {, }]\]"
    set file [file join $app android-parity-oracle.bot]
    set channel [open $file w]
    puts -nonewline $channel [string map [list @STEPS@ $literal] {import std::list
import engine

fn play(state: str, steps: List[List[int]], i: int, states: List[str]) -> List[str] errors engine::InvalidState, engine::InvalidDirection, engine::InvalidSpawn:
    if i >= std::list::length(steps):
        return states
    step = std::list::get(steps, i, [0, 2])
    moved = engine::move(state, std::list::get(step, 0, 0))
    next = engine::spawn_first(moved, std::list::get(step, 1, 2))
    play(next, steps, i + 1, std::list::append(std::list::append(states, moved), next))

fn game(steps: List[List[int]]) -> List[str] errors engine::InvalidState, engine::InvalidDirection, engine::InvalidSpawn:
    start = engine::spawn_first(engine::spawn_first(engine::new_game(), 2), 4)
    play(start, steps, 0, [start])

states = game(@STEPS@):
    on engine::InvalidState:
        []
    on engine::InvalidDirection:
        []
    on engine::InvalidSpawn:
        []
last = std::list::get(states, std::list::length(states) - 1, "")
score = engine::score(last):
    on engine::InvalidState:
        -1
empty = engine::first_empty(last):
    on engine::InvalidState:
        -1
over = engine::over(last):
    on engine::InvalidState:
        false
[states, [score, empty], over]
}]
    close $channel
    set pwd [pwd]
    cd $app
    try {
        set out [exec {*}$botlish -warnings off -backend interp -target $target android-parity-oracle.bot 2>@1]
    } finally {
        cd $pwd
        file delete $file
    }
    if {![regexp -line {^   value: (.*)$} $out -> value]} {
        error "the oracle failed: $out"
    }
    set states [lmap {- s} [regexp -all -inline {"([0-9 ]*)"} $value] {set s}]
    regexp {\[(\d+), (-?\d+)\], (true|false)\]$} $value -> score empty over
    return [list $states $score $empty [expr {$over eq "true"}]]
}

set steps [Steps $steps]
lassign [Oracle $app $steps $botlish $target] states score empty over
set script [Script $steps]
set started [clock milliseconds]
set output [exec {*}$run << $script 2>@1]
set elapsed [expr {[clock milliseconds] - $started}]
set lines [lmap line [split $output \n] {
    if {![regexp {^(STATE|INT|BOOL|ERROR|FAIL)\t} $line]} continue
    set line
}]
set got [lmap line $lines {if {[string match STATE\t* $line]} {string range $line 6 end} else continue}]
set got [lrange $got 1 end]
set failures 0
proc Check {name ok detail} {
    global failures
    puts [format "%s %s%s" [expr {$ok ? "PASS" : "FAIL"}] $name [expr {$ok ? "" : ": $detail"}]]
    if {!$ok} { incr failures }
}
set expectedCount [expr {1 + 2 * [llength $steps]}]
set played [lrange $got 1 [expr {$expectedCount}]]
Check "states equal the interpreter's ($expectedCount states)" [expr {$played eq $states}] \
    "[llength $played] states, first difference at [apply {{a b} {for {set i 0} {$i < [llength $a]} {incr i} {if {[lindex $a $i] ne [lindex $b $i]} {return "$i: [lindex $a $i] / [lindex $b $i]"}}; return none}} $played $states]"
set tail [lrange $lines end-6 end]
Check "score, over and first_empty equal the interpreter's ($score, $over, $empty)" \
    [expr {[lrange $tail 0 2] eq [list "INT\t$score" "BOOL\t$over" "INT\t$empty"]}] [lrange $tail 0 2]
Check "declared errors cross the C ABI with their identities" \
    [expr {[lrange $tail 3 end] eq [list "ERROR\t1\tInvalidState" "ERROR\t1\tInvalidDirection" "ERROR\t1\tgame2048::CellOccupied" "ERROR\t1\tInvalidSpawn"]}] [lrange $tail 3 end]
Check "the final score is positive (tiles merged)" [expr {$score > 0}] $score
puts "parity: [llength $steps] steps, $expectedCount states, score $score, host run ${elapsed} ms"
exit [expr {$failures > 0}]
