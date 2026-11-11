# fuzz.tcl -- model-based lifecycle fuzzing of the process_linux package
# (PROCESS-LINUX-PACKAGE-MILESTONE-1.md, "Lifecycle fuzzing").
#
#   tclsh9.0 audit/process-linux/tools/fuzz.tcl ?-seeds 1-20? ?-ops 24? ?-gc-stress 0|1?
#
# For each seed, a random sequence of operations over a few children --
# spawn (five kinds of child), drain, write, close stdin, wait, terminate,
# kill, interrupt, exited?, release, finish, detach -- is generated, run by
# the interpreter tests/process/fuzz.bot (compiled once, against the testing
# archive in a private application: tools/process-linux.tcl app), and its
# lines compared with what the independent state model below predicts. The
# model is written from the package's documented lifecycle (README.md,
# GUIDE.md), not from its code: a child's state (alive, exited with a known
# status, signalled but not yet waited), its owner (held, released, finished,
# detached), its stdin, what it was written; every operation on an identity
# whose owner is gone is StaleChild; at the end nothing is supervised and
# only detached children that still run are left unreaped. The generator
# emits only operations whose outcome the model can know without timing:
# never a signal to a child that may exit on its own meanwhile, never a wait
# on a child that cannot end.
#
# Every run is under a watchdog (a hang fails). After each run every process
# it named is checked from outside: gone, unless detached and still running
# (then killed here). Exits 1 on any difference.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set options [dict create -seeds 1-20 -ops 24 -gc-stress 0 -keep 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
# tests/helpers.tcl configures tcltest from argv: give it none.
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
source [file join $root tools process-linux.tcl]
interp recursionlimit {} 100000
lassign [split [dict get $options -seeds] -] first last
if {$last eq ""} { set last $first }

# --- the model

# A child: kind (e0 e3 e7 t i s c), owner (held released finished detached),
# status ("" while unknown, else the text wait would print), pending (the
# status a signal already decided, before a wait observes it), closed (stdin),
# written (bytes), drained.
proc predictTerm {child} {
    if {[dict get $child status] ne ""} { return [dict get $child status] }
    if {[dict get $child pending] ne ""} { return [dict get $child pending] }
    switch -- [dict get $child kind] {
        t { return "exited 143" }
        i { return "signal 9" }
        s - c { return "signal 15" }
    }
    error "terminate of an unpredictable child"
}

proc exitText {kind} {
    return "exited [string range $kind 1 end]"
}

# A random operation the model can predict for STATE (a list of children);
# {WORD ARG} or "" when none.
proc candidates {children} {
    set ops {}
    if {[llength $children] < 6} {
        foreach k {e0 e3 e7 t i s c} { lappend ops [list spawn $k] }
    }
    set n 0
    foreach c $children {
        set held [expr {[dict get $c owner] eq "held"}]
        set kind [dict get $c kind]
        set known [expr {[dict get $c status] ne ""}]
        set pending [expr {[dict get $c pending] ne ""}]
        if {!$held} {
            # Any operation on a stale identity (the owner gone) is StaleChild.
            lappend ops [list [lindex {drain wait term kill int exited write close} [expr {int(rand() * 8)}]] $n]
            incr n
            continue
        }
        lappend ops [list int $n]
        switch -glob -- $kind {
            e* {
                if {![dict get $c drained]} { lappend ops [list drain $n] }
                lappend ops [list wait $n]
                if {$known} {
                    # Detached before its exit is known, its reaping races
                    # the loop's end (a detached child never keeps the loop
                    # alive): only once it is known.
                    lappend ops [list term $n] [list kill $n] [list exited $n] [list finish $n] [list detach $n]
                }
                lappend ops [list release $n]
            }
            c {
                if {![dict get $c closed] && !$known && !$pending} {
                    lappend ops [list write $n] [list close $n] [list term $n] [list kill $n]
                }
                if {[dict get $c closed] || $known || $pending} {
                    lappend ops [list wait $n]
                }
                if {[dict get $c closed] && !$known && !$pending && ![dict get $c drained]} {
                    lappend ops [list drain $n]
                }
                if {$known || (![dict get $c closed] && !$pending)} {
                    lappend ops [list finish $n]
                }
                if {$known} { lappend ops [list exited $n] }
                lappend ops [list release $n]
                if {!$known && !$pending && ![dict get $c closed]} { lappend ops [list exited $n] }
            }
            default {
                lappend ops [list term $n] [list kill $n] [list finish $n] [list release $n]
                if {$known || $pending} { lappend ops [list wait $n] }
                if {!$pending && !$known} { lappend ops [list exited $n] [list detach $n] }
                if {$known} { lappend ops [list exited $n] }
            }
        }
        incr n
    }
    return $ops
}

# Apply OP to CHILDREN: {CHILDREN LINE}.
proc apply_op {children op} {
    lassign $op word arg
    if {$word eq "spawn"} {
        set n [llength $children]
        lappend children [dict create kind $arg owner held status "" pending "" closed 0 written 0 drained 0 pid 1]
        return [list $children [list "$n spawned" pid]]
    }
    set n $arg
    set c [lindex $children $n]
    if {[dict get $c owner] ne "held"} {
        return [list $children [list "$n stale"]]
    }
    set kind [dict get $c kind]
    switch -- $word {
        drain {
            dict set c drained 1
            set bytes [expr {[string match e* $kind] ? 3 : [dict get $c written]}]
            set line "$n drained $bytes"
        }
        write {
            dict incr c written 4
            set line "$n wrote 4"
        }
        close {
            dict set c closed 1
            set line "$n closed stdin"
        }
        wait {
            if {[dict get $c status] eq ""} {
                if {[dict get $c pending] ne ""} {
                    dict set c status [dict get $c pending]
                } elseif {[string match e* $kind]} {
                    dict set c status [exitText $kind]
                } elseif {$kind eq "c" && [dict get $c closed]} {
                    dict set c status "exited 0"
                } else {
                    error "a wait that cannot end"
                }
            }
            set line "$n [dict get $c status]"
        }
        term {
            dict set c status [predictTerm $c]
            set line "$n [dict get $c status]"
        }
        kill {
            if {[dict get $c status] eq "" && [dict get $c pending] eq ""} {
                dict set c pending "signal 9"
            }
            set line "$n killed"
        }
        int {
            set line "$n interrupted none"
        }
        exited {
            set line "$n exited [expr {[dict get $c status] ne "" ? "yes" : "no"}]"
        }
        release {
            dict set c owner released
            set line "$n released"
        }
        finish {
            set status [predictTerm $c]
            dict set c status $status
            dict set c owner finished
            set line "$n finished $status"
        }
        detach {
            dict set c owner detached
            set line "$n detached"
        }
    }
    lset children $n $c
    return [list $children [list $line]]
}

# The lines a sequence's end reports: nothing supervised; a detached child
# that still runs (t, i, s: they sleep) is unreaped, its pidfd held.
proc endLines {children} {
    set running 0
    foreach c $children {
        if {[dict get $c owner] eq "detached" && [dict get $c status] eq "" && [dict get $c kind] in {t i s}} {
            incr running
        }
    }
    return [list "end owned 0" "end dying 0" "end watches 0" "end children $running" "end descriptors $running"]
}

# --- the runs

set dir [file tempdir botlish-process-fuzz]
processLinux::app $dir 1
foreach f {fuzz.bot kit.bot} {
    file copy [file join $root tests process $f] $dir
}
set helper [processLinux::helper [file join $dir child]]
set hir [surface::readProgramFile [file join $dir fuzz.bot] -warnings off -cache ""]
set exe [native::executable $hir [file join $dir fuzz]]

set runEnv {}
if {[dict get $options -gc-stress]} { set runEnv {BOTLISH_NATIVE_GC_STRESS 1} }
set differences 0
set total 0
for {set seed $first} {$seed <= $last} {incr seed} {
    expr {srand($seed)}
    set children {}
    set ops {}
    set expected {}
    for {set i 0} {$i < [dict get $options -ops]} {incr i} {
        set cands [candidates $children]
        if {$cands eq ""} break
        set op [lindex $cands [expr {int(rand() * [llength $cands])}]]
        lassign [apply_op $children $op] children lines
        lappend ops {*}$op
        foreach l $lines { lappend expected $l }
    }
    lappend expected {*}[endLines $children]
    set count [expr {[llength $ops] / 2}]
    set status ok
    withEnvironment $runEnv {
        if {[catch {exec timeout -k 5 [expr {[dict get $options -gc-stress] ? 300 : 60}] $exe $helper $count {*}$ops 2>@1} out opts]} {
            set status "exit [lindex [dict get $opts -errorcode] end]"
        }
    }
    set lines [split [string trim $out] \n]
    set pids [lmap l $lines {if {![regexp {^pid (\d+)$} $l -> p]} continue; set p}]
    set got [lmap l $lines {if {[string match "pid *" $l]} continue; set l}]
    # Expected "pid" markers are not compared (their values are the run's).
    set want [lmap l $expected {if {$l eq "pid"} continue; set l}]
    after 150
    set leftover {}
    foreach p $pids {
        if {![catch {readFile /proc/$p/stat} stat]} {
            set state [lindex [split [string range $stat [expr {[string last ")" $stat] + 2}] end]] 0]
            if {$state ne "Z"} { lappend leftover $p }
            catch {exec kill -9 $p}
        }
    }
    set detachedRunning [lindex [lindex [endLines $children] 3] end]
    incr total
    if {$status ne "ok" || $got ne $want || [llength $leftover] != $detachedRunning} {
        incr differences
        puts "seed $seed: DIFFERENT ($status; leftover [llength $leftover], detached running $detachedRunning)"
        puts "  ops: $ops"
        foreach w $want g $got {
            puts [format "  %-3s %-28s %s" [expr {$w eq $g ? "" : "!="}] $w $g]
        }
    } else {
        puts "seed $seed: same ($count operations, [llength $children] children)"
    }
}
if {![dict get $options -keep]} { file delete -force $dir }
puts "$total sequences, $differences different"
exit [expr {$differences != 0}]
