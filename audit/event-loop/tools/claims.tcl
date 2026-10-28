# claims.tcl -- the claims check.tcl checks on each deterministic scenario's
# trace (EVENT-LOOP-EXPLORATION.md, "Testing"). Each proc takes the trace
# (a list of "t=TURN: text" lines) and calls `claim` per claim.
namespace eval claims {}

proc claims::a-smoke {trace} {
    claim a-smoke "two workers interleave one step per turn" \
        [expr {[join [concat {*}[lmap m [matches $trace {^t=(\d+): w=(\d) step (\d)}] {lrange $m 1 end}]] ,] eq "0,1,0,0,2,0,1,1,1,1,2,1,2,1,2"}]
    claim a-smoke "run returns when no live work remains" [expr {[lindex $trace end] eq "t=3: no live work"}]
}

proc claims::a-fairness {trace} {
    set budget 8
    set over [lmap m [matches $trace {^t=\d+: collect timers \d+ records (\d+)}] {
        expr {[lindex $m 1] > $budget ? [lindex $m 1] : [continue]}
    }]
    claim a-fairness "no turn collects more than the budget ($budget) of records" [expr {$over eq ""}] $over
    set greedy [lindex [first $trace {greedy id (\d+)}] 1]
    set perTurn [dict create]
    foreach m [matches $trace "^t=(\\d+): run task $greedy reason"] {
        dict incr perTurn [lindex $m 1]
    }
    set max [tcl::mathfunc::max {*}[dict values $perTurn]]
    claim a-fairness "continuous activity (greedy) runs at most once per turn" [expr {$max == 1}] "max $max"
    set ready [lindex [first $trace {bystander ready at (\d+)}] 1]
    set ran [lindex [first $trace {bystander ran at (\d+)}] 1]
    claim a-fairness "a bystander made ready runs in the next turn despite the saturation" \
        [expr {$ran == $ready + 1}] "ready $ready ran $ran"
    set gens [lmap m [matches $trace {^t=(\d+): storm generation (\d+)}] {lindex $m 1}]
    set steps [lsort -unique [lmap a [lrange $gens 0 end-1] b [lrange $gens 1 end] {expr {$b - $a}}]]
    claim a-fairness "a self-replenishing ready queue (storm, 61 generations) advances one generation per turn" \
        [expr {$steps eq "1" && [llength $gens] == 61}] "steps $steps"
    set firstRecords [turnOf [lindex [lsearch -inline -all -regexp $trace {records [1-9]}] 0]]
    set quiet [lindex [first $trace {quiet record at (\d+)}] 1]
    set bound [expr {$firstRecords + (400 + $budget - 1) / $budget}]
    claim a-fairness "a record queued behind a 400-record burst is delivered within burst/budget turns" \
        [expr {$quiet <= $bound}] "quiet at $quiet, bound $bound"
    set drained [lindex [first $trace {drainer got all at (\d+)}] 1]
    set read [lindex [first $trace {reader got all at (\d+)}] 1]
    claim a-fairness "a task that drains its queue per wake (try_take) keeps up with the collection rate; one event per wake does not" \
        [expr {$drained < $read && $drained <= $firstRecords + 400 / $budget + 1}] "drainer $drained reader $read"
    set late [lmap m [matches $trace {timer \d+ fires late (\d+)}] {lindex $m 1}]
    claim a-fairness "the ticker's timers fire on time (late 0) after the busy phase" [expr {[lsort -unique $late] eq "0"}] $late
}

proc claims::a-observers {trace} {
    set a [lmap m [matches $trace {obs-a run in turn (\d+)}] {lindex $m 1}]
    claim a-observers "obs-a runs once per turn from the first turn, and not after revoking itself in its 6th run" \
        [expr {$a eq "1 2 3 4 5 6"}] $a
    set reg [lindex [first $trace {worker registered obs-b in turn (\d+)}] 1]
    set b [lmap m [matches $trace {obs-b run in turn (\d+)}] {lindex $m 1}]
    claim a-observers "obs-b, registered during a dispatch phase, runs in that same turn's observer phase" \
        [expr {[lindex $b 0] == $reg}] "registered $reg first run [lindex $b 0]"
    set empty [lmap m [matches $trace {^t=(\d+): collect timers 0 records 0 ready 0}] {lindex $m 1}]
    set ranInEmpty [lmap t $empty {expr {$t in $b || $t in $a ? $t : [continue]}}]
    claim a-observers "no observer runs in an empty turn (a wakeup for nothing)" \
        [expr {[llength $empty] >= 1 && $ranInEmpty eq ""}] "empty turns $empty"
    set busy [lsort -unique -integer [lmap line [lsearch -all -inline -regexp $trace {: run task}] {turnOf $line}]]
    set missing [lmap t $busy {expr {$t >= $reg && $t ni $b ? $t : [continue]}}]
    claim a-observers "obs-b runs in every non-empty turn after its registration" [expr {$missing eq ""}] "missing $missing"
    claim a-observers "obs-c (registered inside an observer phase, revoked before its first opportunity) never runs" \
        [expr {[matches $trace {obs-c run}] eq "" && [first $trace {obs-c woke not for a turn: reason 3}] ne ""}]
    claim a-observers "an observer does not keep the loop alive: run returns while obs-b still waits" \
        [expr {[first $trace {no live work}] ne "" && [first $trace {observer runs 15}] ne ""}]
}

proc claims::a-timers {trace} {
    set metro [lmap m [matches $trace {metro at (\d+)}] {lindex $m 1}]
    set missed [lmap m [matches $trace {metro missed (\d+)}] {lindex $m 1}]
    claim a-timers "a slow segment makes the repeating timer report 2 missed intervals once, coalesced" \
        [expr {$missed eq "0 0 0 2 0"}] $missed
    set onGrid [lmap t $metro {expr {$t % 100 == 0 ? $t : [continue]}}]
    claim a-timers "the repeating timer stays on its 100 us grid (no drift)" \
        [expr {[llength $onGrid] == 4 && [lindex $metro end] == 700}] $metro
    set later [lsearch -regexp $trace {later fired}]
    set sooner [lsearch -regexp $trace {sooner fired}]
    claim a-timers "equal deadlines fire in registration order" [expr {$later >= 0 && $later < $sooner}]
    claim a-timers "a 10 s jump of a 10 us timer: one wake, 999999 missed (no per-interval loop)" \
        [expr {[first $trace {jump missed 999999}] ne ""}]
    claim a-timers "an unwatched repeating timer coalesces: its late waiter is ready at once with the count" \
        [expr {[first $trace {idler coalesced missed 19}] ne ""}]
    set frames [lindex [first $trace {frames (\d+)}] 1]
    set fturns [lindex [first $trace {frame turns (\d+)}] 1]
    claim a-timers "frame work follows elapsed time, not the turn rate" \
        [expr {$frames == 6 && $fturns > 10 * $frames}] "frames $frames turns $fturns"
    claim a-timers "a bounded queue with no consumer drops the excess and counts it" \
        [expr {[first $trace {dropped 96}] ne ""}]
}

proc claims::a-revocation {trace} {
    set victim [lindex [first $trace {victim id (\d+)}] 1]
    claim a-revocation "a wake queued before the revocation is suppressed at dispatch (no event data)" \
        [expr {[first $trace "suppress wake of task $victim"] ne "" && [first $trace {victim woke with reason 3}] ne "" && [first $trace {victim event value 0}] ne ""}]
    claim a-revocation "revoking discards every queued event (5)" \
        [expr {[first $trace {s2 pending 5}] ne "" && [first $trace {revoke \d+ discarding 5}] ne ""}]
    claim a-revocation "revoking twice, or a stale copy, does nothing" \
        [expr {[first $trace {revoke s2 again: 0}] ne "" && [first $trace {stale copy of s2: 0}] ne ""}]
    set h [lsearch -regexp $trace {handler revokes its own}]
    set c [lsearch -regexp $trace {handler continues after revoking}]
    claim a-revocation "a handler revoking its own registration completes its invocation; its next wait sees the revocation" \
        [expr {$h >= 0 && $c > $h && [first $trace {handler's next wait: reason 3}] ne ""}]
    claim a-revocation "records still tagged with a revoked generation are dropped as stale (3 of them)" \
        [expr {[llength [matches $trace {stale record for}]] == 3 && [first $trace {stale records 3}] ne ""}]
    claim a-revocation "the reused slot's new registration gets only its own record" \
        [expr {[first $trace {s5 waiter woke with value 555}] ne "" && [first $trace {s5 reuses slot (\d+)}] ne ""}]
    set rev [lsearch -regexp $trace {listener revokes s6}]
    set w1 [lsearch -regexp $trace {worker finished for event 61}]
    set w2 [lsearch -regexp $trace {worker finished for event 62}]
    claim a-revocation "revocation is not cancellation: tasks the listener started finish after it is revoked" \
        [expr {$rev >= 0 && $w1 > $rev && $w2 > $rev}]
    set names [lmap m [matches $trace {channel waiter woke, name (\d)}] {lindex $m 1}]
    claim a-revocation "revoking wakes every waiter, in the order they waited" [expr {$names eq "0 1 2"}] $names
}

proc claims::a-errors {trace} {
    claim a-errors "a task's declared failure is recorded; the loop goes on" \
        [expr {[first $trace {task \d+ failed 7}] ne "" && [first $trace {result -1000007}] ne ""}]
    claim a-errors "an IndexNotFound inside a task is recorded as that task's failure" \
        [expr {[first $trace {failed IndexNotFound}] ne ""}]
    claim a-errors "a failure in the first segment reaches the spawner (eager construction), never the loop" \
        [expr {[first $trace {spawner caught a failure at construction, code 8}] ne ""}]
    claim a-errors "a nested turn from inside a task is refused (LoopReentered)" \
        [expr {[first $trace {nested turn refused}] ne "" && [first $trace {reentered 1}] ne ""}]
    claim a-errors "a waiter on a non-keepalive source does not keep the loop alive" \
        [expr {[first $trace {first run turns 2}] ne ""}]
    claim a-errors "stop ends run after the current turn" \
        [expr {[first $trace {stopped}] ne "" && [first $trace {second run turns 2}] ne ""}]
    claim a-errors "shutdown wakes waiters with woke_revoked (they finish) and abandons what never ends" \
        [expr {[first $trace {optional woke with reason 3}] ne "" && [first $trace {sleeper woke with reason 3}] ne "" && [first $trace {abandoned 1}] ne ""}]
}

proc claims::a-gameserver {trace} {
    set talks [matches $trace {^t=(\d+): conn ([23]) cmd 2 in turn}]
    set late {}
    foreach m $talks {
        set t [lindex $m 1]
        if {[lsearch -regexp $trace "^t=$t: collect timers \\d+ records \[1-9\]"] < 0} { lappend late $t }
    }
    claim a-gameserver "connections 2 and 3: every line is handled in the turn it is collected (16 lines)" \
        [expr {[llength $talks] == 16 && $late eq ""}] "late $late"
    set path [turnOf [lindex [lsearch -inline -regexp $trace {conn 1 path found}] 0]]
    set during [lmap m $talks {expr {[lindex $m 1] < $path ? 1 : [continue]}}]
    claim a-gameserver "other connections keep being served while pathfinding runs (yielding)" \
        [expr {[llength $during] >= 6}] "[llength $during] lines before turn $path"
    set c1 [turnOf [lindex [lsearch -inline -regexp $trace {conn 1 cmd 2}] 0]]
    claim a-gameserver "one session handles its own lines in order: conn 1's TALK waits for its path" \
        [expr {$c1 > $path}] "talk $c1 path $path"
    set sent [lmap m [matches $trace {sent (-?\d+)}] {lindex $m 1}]
    set by [dict create]
    foreach {c v} $sent { dict lappend by $c $v }
    set want2 [list 1002 {*}[lmap k {0 1 2 3 4 5 6 7} {expr {3000020 + $k}}] -1]
    set want3 [list 1003 {*}[lmap k {0 1 2 3 4 5 6 7} {expr {3000030 + $k}}] -1]
    claim a-gameserver "each connection's replies are sent in order" \
        [expr {[dict get $by 1] eq "1001 2000600 3000011 -1" && [dict get $by 2] eq $want2 && [dict get $by 3] eq $want3}] $by
    set flushes [lmap m [matches $trace {flush \d+ in turn (\d+)}] {lindex $m 1}]
    claim a-gameserver "output is flushed at most once per turn (the observer)" \
        [expr {[llength $flushes] == [llength [lsort -unique $flushes]]}]
    set ticks [llength [matches $trace {world tick}]]
    claim a-gameserver "the world's timer advances its AI coroutine directly, 5 ticks" [expr {$ticks == 5 && [first $trace {agent at 5}] ne ""}]
}

proc claims::composition {} {
    set w {}
    foreach v {alone quiet-before quiet-after busy} {
        if {![info exists ::traces(a-compose-$v)]} return
        lappend w [lsearch -all -inline $::traces(a-compose-$v) {*W: *}]
    }
    claim a-compose "W's trace (turns included) is identical alone and with an inactive library initialized before or after it" \
        [expr {[lindex $w 0] eq [lindex $w 1] && [lindex $w 0] eq [lindex $w 2] && [llength [lindex $w 0]] == 12}]
    claim a-compose "W's trace is identical beside an active library (a spinning task and a 300-record flood)" \
        [expr {[lindex $w 0] eq [lindex $w 3]}]
}
