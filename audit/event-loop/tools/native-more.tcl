# native-more.tcl -- check.tcl's SDL3 and composition claims
# (EVENT-LOOP-EXPLORATION.md, Experiments B and C). Sourced by native.tcl.
#
# SDL3 is the package-owned headless build of tests/cffi/sdl3.tcl (events
# only: no window); without it these claims are reported as skipped.

source [file join $::projectRoot tests cffi sdl3.tcl]
set ::sdlDir [cffi::sdl3Dir]
set ::sdlInclude [file join [cffi::SdlCacheDir] c-header-src sdl3 include]

proc sdlBuild {} {
    set cc [expr {[info exists ::env(CC)] ? $::env(CC) : "cc"}]
    foreach lib {evsdl evsdlhost} {
        exec $cc -O2 -Wall -Wextra -fPIC -I$::sdlInclude -c [file join $::evRoot native $lib.c] -o [file join $::evBuild $lib.o]
        file delete [file join $::evBuild lib$lib.a]
        exec ar rcs [file join $::evBuild lib$lib.a] [file join $::evBuild $lib.o]
    }
}

proc sdlRun {name} {
    set saved [expr {[info exists ::env(LD_LIBRARY_PATH)] ? $::env(LD_LIBRARY_PATH) : ""}]
    set ::env(LD_LIBRARY_PATH) $::sdlDir
    try {
        return [nativeRun $name cranelift [list $::sdlDir]]
    } finally {
        set ::env(LD_LIBRARY_PATH) $saved
    }
}

if {$::sdlDir eq "" || ![file isdirectory $::sdlInclude]} {
    puts "  skip  sdl3               the package-owned SDL3 is not built (tclsh9.0 tests/cffi/sdl3.tcl)"
} elseif {[catch sdlBuild message]} {
    claim sdl3 "the SDL adapters build" 0 $message
} else {
    claim sdl3 "the SDL adapters build against SDL [file tail $::sdlDir]" 1
    set results [dict create]
    foreach mode {wakeup pump hybrid naive sdlwait host60 hostwait} {
        if {![string match $::only b-sdl-$mode] && ![string match $::only b-sdl]} continue
        set t [sdlRun b-sdl-$mode]
        if {$t eq ""} continue
        set r [dict create]
        foreach key {{sdl received} {sdl max latency us} {sdl later than 5 ms} {posts received} {posts max latency us}
                     {posts later than 5 ms} {timer worst lateness us} {timer missed intervals} {idle blocks} {idle cpu us}
                     {sdl callbacks on a foreign thread} {sdl callbacks nested in a task's C call} {sdl events dropped by policy}
                     {pusher pushes in turn} {pushed event received in turn} {host iterations} {host max gap us}
                     {host events on a foreign thread} {host needed a kick event to start} {turns}} {
            dict set r $key [num $t "^t=\\d+: $key (-?\\d+)"]
        }
        dict set results $mode $r
        set ok [expr {[dict get $r {sdl received}] == 260 && [dict get $r {posts received}] == 200}]
        claim b-sdl-$mode "every SDL event (260) and post (200) arrives" $ok
        claim b-sdl-$mode "an event a task pushes inside its segment reaches the program in a later turn" \
            [expr {[dict get $r {pushed event received in turn}] > [dict get $r {pusher pushes in turn}]}]
        if {$mode ni {host60 hostwait}} {
            claim b-sdl-$mode "SDL's callbacks ran on foreign threads ([dict get $r {sdl callbacks on a foreign thread}]) and once nested in a task's C call, running no Botlish code; the policy dropped 50 at once" \
                [expr {[dict get $r {sdl callbacks on a foreign thread}] > 250 && [dict get $r {sdl callbacks nested in a task's C call}] == 1 && [dict get $r {sdl events dropped by policy}] == 50}]
        }
        puts [format "        %-18s sdl max %s us (%s late) | posts max %s us | timer late %s us, missed %s | idle %s blocks %s us cpu" \
            b-sdl-$mode [dict get $r {sdl max latency us}] [dict get $r {sdl later than 5 ms}] [dict get $r {posts max latency us}] \
            [dict get $r {timer worst lateness us}] [dict get $r {timer missed intervals}] [dict get $r {idle blocks}] [dict get $r {idle cpu us}]]
    }
    proc r {mode key} { dict get [dict get $::sdlResults $mode] $key }
    set ::sdlResults $results
    if {[dict exists $results wakeup]} {
        claim b-sdl-wakeup "wakeup protocol: SDL events from other threads wake the sleeping loop ([r wakeup {sdl later than 5 ms}]/260 later than 5 ms, max [r wakeup {sdl max latency us}] us), one wakeup per idle sleep" \
            [expr {[r wakeup {sdl later than 5 ms}] <= 13 && [r wakeup {sdl max latency us}] < 50000 && [r wakeup {idle blocks}] <= 2}]
    }
    if {[dict exists $results hybrid]} {
        claim b-sdl-hybrid "hybrid (watch wakes, pump copies): [r hybrid {sdl later than 5 ms}]/260 SDL events later than 5 ms (max [r hybrid {sdl max latency us}] us), one wakeup per idle sleep" \
            [expr {[r hybrid {sdl later than 5 ms}] <= 13 && [r hybrid {sdl max latency us}] < 50000 && [r hybrid {idle blocks}] <= 2}]
    }
    if {[dict exists $results pump]} {
        claim b-sdl-pump "pump protocol without a wakeup: latency bounded by its 10 ms cap ([r pump {sdl max latency us}] us), paid for in idle wakeups ([r pump {idle blocks}] per 200 ms)" \
            [expr {[r pump {sdl max latency us}] < 30000 && [r pump {idle blocks}] >= 15}]
    }
    if {[dict exists $results naive]} {
        claim b-sdl-naive "negative control: pumping only when something else wakes the loop delays SDL events to the heartbeat ([r naive {sdl max latency us}] us)" \
            [expr {[r naive {sdl max latency us}] > 50000}]
    }
    if {[dict exists $results sdlwait]} {
        claim b-sdl-sdlwait "SDL as the only wait: SDL events stay fast, everything else is noticed only when SDL wakes or a deadline passes (posts max [r sdlwait {posts max latency us}] us vs [r hybrid {posts max latency us}] us under hybrid)" \
            [expr {[r sdlwait {sdl later than 5 ms}] <= 13}]
    }
    if {[dict exists $results host60]} {
        claim b-sdl-host60 "host-driven at 60 Hz: one turn per host iteration ([r host60 {turns}] turns); a 7 ms timer gets its intervals coalesced ([r host60 {timer missed intervals}] missed, worst [r host60 {timer worst lateness us}] us late); SDL events wait for an iteration (max [r host60 {sdl max latency us}] us), all dispatched on the loop thread" \
            [expr {[r host60 {timer missed intervals}] > 0 && [r host60 {sdl max latency us}] < 40000 && [r host60 {sdl later than 5 ms}] > 50 && [r host60 {host events on a foreign thread}] == 0}]
    }
    if {[dict exists $results hostwait]} {
        claim b-sdl-hostwait "host-driven \"waitevent\": the host needs a kick to start and postpones a pending deadline until an SDL event ([r hostwait {host max gap us}] us gap)" \
            [expr {[r hostwait {host needed a kick event to start}] == 1 && [r hostwait {host max gap us}] > 800000}]
    }
}
