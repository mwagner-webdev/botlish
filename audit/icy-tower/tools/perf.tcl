# perf.tcl -- the Icy Tower vertical slice's performance and allocation
# report (ICY-TOWER-VERTICAL-SLICE-1.md, "Performance and allocation").
#
#   tclsh9.0 audit/icy-tower/tools/perf.tcl ?-executable PATH? ?-sdl DIR?
#
# 1. Allocation in the rules: headless.bot's simulation (the autopilot, no
#    SDL) run for 300 and 1500 frames under the native runtime's allocation
#    accounting (native::allocationReport, README section 22); the
#    difference divided by 1200 is the steady state per frame, by kind,
#    and the 600-frame run's allocating sites are listed.
# 2. The whole frame, through callgrind (valgrind; the in-process
#    accounting does not run a program that calls C): an unstripped
#    executable profiled over 60 and 240 frames, headless and on the dummy
#    driver, the difference per frame -- instructions by object and, in
#    the program, by kind of code; the C calls into SDL; malloc and free;
#    the Float64 boxes and DecimalRounded roundings.
# 3. Time: the executable (default audit/icy-tower/artifacts/icy-tower)
#    headless for 6000 frames and on the dummy driver for 3000 frames,
#    wall-clock per frame (best of three).
#
# SDL_DIR (default: tests/cffi/sdl3.tcl's) holds libSDL3.so. Scratch files
# live in a `file tempdir` directory, removed at the end (AGENTS.md).

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
source [file join $root examples games icy-tower run.tcl]
source [file join $root tests cffi sdl3.tcl]

set options [dict create -executable [file join $root audit icy-tower artifacts icy-tower] -sdl [cffi::sdl3Dir]]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set gameDir [file join $root examples games icy-tower]
set sdl [dict get $options -sdl]
set ::env(LD_LIBRARY_PATH) $sdl
set ::env(SDL_VIDEO_DRIVER) dummy

# headless.bot playing FRAMES frames.
proc headlessHir {frames} {
    set text [core::ReadFile [file join $::gameDir headless.bot]]
    set text [string map [list simulate(600) simulate($frames) "summary(world, 600)" "summary(world, $frames)"] $text]
    return [surface::compile $text [file join $::gameDir headless.bot] -warnings off -root $::gameDir]
}

proc kinds {report} {
    set result {}
    foreach kind [dict keys [dict get $report byKind]] {
        set k [dict get $report byKind $kind]
        lappend result $kind [dict get $k allocations] [dict get $k allocatedBytes]
    }
    return $result
}

# The per-frame difference between the reports of two runs FRAMES apart.
proc perFrame {small large frames} {
    set lines {}
    set a [dict get $small total]
    set b [dict get $large total]
    lappend lines [format "  per frame: %.1f objects, %.0f bytes; GC cycles %d -> %d (max pause %.2f ms)" \
        [expr {([dict get $b allocations] - [dict get $a allocations]) / double($frames)}] \
        [expr {([dict get $b allocatedBytes] - [dict get $a allocatedBytes]) / double($frames)}] \
        [dict get $small gc cycles] [dict get $large gc cycles] [expr {[dict get $large gc maxPauseUs] / 1000.0}]]
    foreach {kind n1 b1} [kinds $small] {kind2 n2 b2} [kinds $large] {
        if {$n2 == $n1} continue
        lappend lines [format "    %-12s %7.1f objects  %7.0f bytes" $kind [expr {($n2 - $n1) / double($frames)}] [expr {($b2 - $b1) / double($frames)}]]
    }
    lappend lines [format "  peak live: %d objects, %d bytes" [dict get $large total peakLiveObjects] [dict get $large total peakLiveBytes]]
    return $lines
}

proc sites {report count} {
    set lines {}
    set rows [lsort -integer -decreasing -index 0 [lmap site [dict get $report sites] {
        set location [dict get $site location]
        set where [expr {[dict exists $location file] ? "[file tail [dict get $location file]]:[dict get $location line] [dict get $location node]" : "?"}]
        list [dict get $site allocations] [dict get $site allocatedBytes] [dict get $site objectKind]/[dict get $site operation] $where
    }]]
    foreach row [lrange $rows 0 [expr {$count - 1}]] {
        lassign $row n bytes op where
        lappend lines [format "    %8d  %9d B  %-22s %s" $n $bytes $op $where]
    }
    return $lines
}

proc best {command runs} {
    set times {}
    for {set i 0} {$i < $runs} {incr i} {
        set start [clock microseconds]
        exec {*}$command
        lappend times [expr {[clock microseconds] - $start}]
    }
    return [lindex [lsort -integer $times] 0]
}

puts "== 1. The rules (headless.bot, the autopilot, no SDL)"
set small [native::allocationReport [headlessHir 300] summary]
set large [native::allocationReport [headlessHir 1500] summary]
puts [join [perFrame $small $large 1200] \n]
puts "  allocating sites of a 600-frame run (top 15):"
puts [join [sites [native::allocationReport [headlessHir 600] sites] 15] \n]

# 2. The whole frame. A program that calls C runs as a linked executable,
# which the in-process allocation accounting does not reach; callgrind
# does: an unstripped build profiled over 60 and 240 frames, headless and
# on the dummy driver (audit/icy-tower/tools/callgrind-frame.py and
# callgrind-split.py read the profiles).
if {$sdl ne "" && [auto_execok valgrind] ne "" && [auto_execok python3] ne ""} {
    puts "\n== 2. The whole frame (callgrind: the executable, unstripped)"
    set work [file tempdir botlish-icy-perf]
    try {
        set stage [file join $work app]
        exec [info nameofexecutable] [file join $root tools c-bindgen.tcl] stage sdl3 -target linux-x86_64 -app $gameDir -into $stage
        exec [info nameofexecutable] [file join $root main.tcl] -warnings off -emit-native-executable -L $sdl [file join $stage main.bot]
        foreach {mode arguments} {headless {--headless} {dummy driver} {--autopilot --fixed-step}} {
            set profiles {}
            foreach n {60 240} {
                set out [file join $work [string map {" " -} $mode].$n.out]
                exec valgrind --tool=callgrind --callgrind-out-file=$out [file join $stage main] {*}$arguments --frames $n --seed 7 2>@1
                lappend profiles $out $n
            }
            puts "-- $mode"
            puts [exec python3 [file join $here callgrind-frame.py] {*}$profiles]
            puts [exec python3 [file join $here callgrind-split.py] {*}$profiles]
        }
    } finally {
        file delete -force $work
    }
}

set executable [dict get $options -executable]
if {[file executable $executable]} {
    puts "\n== 3. Time (the executable, best of 3)"
    set t [best [list $executable --headless --frames 6000 --seed 7] 3]
    puts [format "  headless, 6000 frames: %.1f ms, %.1f us a frame" [expr {$t / 1000.0}] [expr {$t / 6000.0}]]
    set t [best [list $executable --autopilot --fixed-step --frames 3000 --seed 7] 3]
    puts [format "  dummy driver, 3000 frames: %.1f ms, %.1f us a frame (software renderer, no display)" [expr {$t / 1000.0}] [expr {$t / 3000.0}]]
}
