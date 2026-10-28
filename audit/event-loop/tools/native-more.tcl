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

# --- the Win32 probe, cross-compiled and run under Wine: a development aid,
# never Windows evidence (AGENTS.md). Skipped without MinGW-w64, Wine and
# xvfb-run.
if {[string match $::only win32] || $::only eq "*"} {
    set mingw [auto_execok x86_64-w64-mingw32-gcc]
    set wine [auto_execok wine]
    set xvfb [auto_execok xvfb-run]
    if {$mingw eq "" || $wine eq "" || $xvfb eq ""} {
        puts "  skip  win32              MinGW-w64, Wine or xvfb-run missing (the probe is for Windows: native/win32/README.md)"
    } else {
        set exe [file join $::evBuild evwin32.exe]
        exec {*}$mingw -O2 -Wall -Wno-array-bounds [file join $::evRoot native win32 evwin32.c] -o $exe -lws2_32 -luser32
        catch {exec {*}$mingw -O2 -Wall -Wno-array-bounds -DEVW_SDL3 -I$::sdlInclude -c [file join $::evRoot native win32 evwin32.c] -o [file join $::evBuild evwin32-sdl.o]} sdlCompile
        claim win32 "the Win32 probe cross-compiles (MinGW-w64), also with EVW_SDL3" [file exists [file join $::evBuild evwin32-sdl.o]] $sdlCompile
        set prefix [file tempdir evwine]
        foreach mode {direct inverted} {
            catch {exec env WINEPREFIX=$prefix WINEDEBUG=-all {*}$xvfb -a {*}$wine $exe $mode 2>@1} out
            set lines [lsearch -all -inline -not [split $out \n] {X connection*}]
            set kv [join $lines "; "]
            regexp {turns_during_modal (\d+) timer_turns_in_modal (\d+)} $out -> during timerTurns
            set ok [expr {[lsearch $lines ok] >= 0}]
            if {$mode eq "direct"} {
                claim win32-wine "direct (Wine, development aid): a modal loop on the loop's stack stops every turn; WM_CLOSE contained by policy" $ok $kv
            } else {
                claim win32-wine "inverted (Wine, development aid): the pump on a host fiber keeps turns running inside the modal loop ($timerTurns timer turns)" $ok $kv
            }
            puts "        win32 $mode: $kv"
        }
        file delete -force $prefix
    }
}

# --- every native source in one process, in both initialization orders
if {$::sdlDir ne "" && [file isdirectory $::sdlInclude] && ([string match $::only b-mixed] || $::only eq "*")} {
    set mixed [dict create]
    foreach order {sdl net} {
        set t [sdlRun b-mixed-$order-first]
        if {$t eq ""} continue
        dict set mixed $order $t
        set replies [lmap c {1 2 3} {num $t "client $c replies (\\d+)"}]
        claim b-mixed-$order-first "every source delivers: SDL [num $t {sdl received (\d+)}]/260, posts [num $t {posts received (\d+)}]/200, replies [join $replies /] (41/41/2001)" \
            [expr {[num $t {sdl received (\d+)}] == 260 && [num $t {posts received (\d+)}] == 200 && $replies eq "41 41 2001"}]
        set quiet {}
        foreach m [matches $t {conn (\d+) lines 41}] {
            lappend quiet [num $t "conn [lindex $m 1] max lag us (\\d+)"]
        }
        claim b-mixed-$order-first "beside the flood, SDL, posts and timers stay responsive (quiet conns [join $quiet /] us, SDL [num $t {sdl max latency us (\d+)}] us, timer [num $t {timer worst lateness us (\d+)}] us late)" \
            [expr {[llength $quiet] == 2 && [tcl::mathfunc::max {*}$quiet] < 50000 && [num $t {sdl max latency us (\d+)}] < 50000}]
    }
    if {[dict size $mixed] == 2} {
        set w [lmap order {sdl net} {
            lmap line [lsearch -all -inline [dict get $mixed $order] {*W: *}] {regsub {^t=\d+: } [regsub {slept until \d+} $line {slept}] {}}
        }]
        claim b-mixed "the base workload's own order is the same whichever adapter is initialized first" \
            [expr {[lindex $w 0] eq [lindex $w 1] && [llength [lindex $w 0]] == 12}]
    }
}

# --- the lifecycle barrier: a callback that must be answered by
# application work before it returns (Experiment C)
if {$::sdlDir ne "" && [file isdirectory $::sdlInclude] && ([string match $::only b-sdl-lifecycle] || $::only eq "*")} {
    set t [sdlRun b-sdl-lifecycle]
    if {$t ne ""} {
        set saves [lmap m [matches $t {state saved, turn \d+ at (\d+)}] {lindex $m 1}]
        set returned [num $t {last reporting thread returned at (\d+)}]
        set hold [num $t {barrier max hold us (\d+)}]
        claim b-sdl-lifecycle "both lifecycle events were handled on the loop's thread, in a turn, before their reporting threads returned (no timeout)" \
            [expr {[llength $saves] == 2 && [num $t {barrier acked (\d+)}] == 2 && [num $t {barrier timeouts (\d+)}] == 0 && $returned > [lindex $saves end]}]
        claim b-sdl-lifecycle "a task's 300 ms segment that never yields holds the reporting thread that long ($hold us): the cooperative limit, measured" \
            [expr {$hold > 100000}]
    }
}
