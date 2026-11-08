# aot-run.tcl -- what -aot-run costs (AOT-RUN-MILESTONE-1.md, "Performance
# measurements").
#
#   tclsh9.0 bench/aot-run.tcl ?-runs N?
#
# Two programs: `hello` (a line through the host's std::io) and `2048`
# (examples/games/2048/bench.bot and its engine: 365 lines, 200 moves).
# Times in milliseconds, the best of N runs (default 7):
#
# 1. Phases, in this process (the compiler loaded once, as main.tcl has it
#    after its own startup): the front end (surface::readProgramFile), NIR
#    lowering (native::ExecutableText: what -aot-run and
#    -emit-native-executable compile), the driver's object of that NIR
#    (its process, Cranelift, the object file), the link (the driver's
#    executable of the same NIR less its object), native::executable
#    (lowering, the object, the link) and native::aotRun (the same, and the
#    run), with the driver's own report of aotRun's best run: its time to a
#    linked executable and to the started child (`timing BUILD START`).
# 2. Commands, each a fresh process (main.tcl's own startup included):
#      interp      main.tcl FILE: the front end and the interpreter's run
#                  (2048 only: hello's IO is native only)
#      emit        main.tcl -emit-native-executable FILE
#      exe         the emitted executable run alone
#      explicit    emit + exe: compiling first, then running
#      aot-run     main.tcl -aot-run FILE
#      jit         main.tcl -backend cranelift FILE, where the native
#                  backend has its JIT
#    and the time to the program's first instruction, as near as a reader
#    sees it: from starting the command to hello's line on its standard
#    output, for -aot-run, the emitted executable and the JIT.
# The host and its processors are printed first; nothing here is a claim
# about another machine.
set root [file dirname [file dirname [file normalize [info script]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]

set options [dict create -runs 7]
foreach {option value} $args {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
set runs [dict get $options -runs]
set work [file normalize [file tempdir botlish-aot-run-bench]]
set main [file join $root main.tcl]
set tclsh [info nameofexecutable]

proc writeFile {path text} {
    set f [open $path w]; fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text; close $f
    return $path
}
# Milliseconds SCRIPT takes, best of RUNS.
proc timed {script} {
    set best ""
    for {set i 0} {$i < $::runs} {incr i} {
        set t [clock microseconds]
        uplevel 1 $script
        set ms [expr {([clock microseconds] - $t) / 1000.0}]
        if {$best eq "" || $ms < $best} { set best $ms }
    }
    return [format %.1f $best]
}
# COMMAND run to its end, its output discarded (it must succeed).
proc quiet {command} {
    exec {*}$command >[file join $::work out.txt] 2>[file join $::work err.txt]
}
# Milliseconds from starting COMMAND to the program's first line of output,
# "hello" (main.tcl's default run prints its own header line first), best
# of RUNS (the rest read to the end).
proc firstLine {command} {
    set best ""
    for {set i 0} {$i < $::runs} {incr i} {
        set t [clock microseconds]
        set pipe [open |[concat $command [list 2>[file join $::work err.txt]]] rb]
        while {[gets $pipe line] >= 0 && [string trimright $line \r] ne "hello"} {}
        set ms [expr {([clock microseconds] - $t) / 1000.0}]
        read $pipe
        close $pipe
        if {$best eq "" || $ms < $best} { set best $ms }
    }
    return [format %.1f $best]
}

set io [switch -- [dict get [core::cabi::target [core::cabi::hostTarget]] os] {
    macos { set _ std::darwin::io }
    windows { set _ std::windows::io }
    default { set _ std::linux::io }
}]
set hello [writeFile [file join $work hello.bot] [join [list \
    "import std::io" "import $io" "" "with context $io\::create()" "" \
    "std::io::print_line(\"hello\"):" "    on std::io::WriteFailed:" "        unit" ""] \n]]
set game [file join $work 2048]
file mkdir $game
foreach file {bench.bot game2048.bot} {
    file copy [file join $root examples games 2048 $file] $game
}
set programs [list hello $hello 2048 [file join $game bench.bot]]

set cpu [expr {[file readable /proc/cpuinfo]
    ? [lindex [regexp -inline -line {^model name\s*:\s*(.*)$} [core::ReadFile /proc/cpuinfo]] 1] : ""}]
if {$cpu eq "" && $::tcl_platform(os) eq "Darwin"} {
    catch {set cpu [exec sysctl -n machdep.cpu.brand_string]}
}
if {$cpu eq "" && [info exists ::env(PROCESSOR_IDENTIFIER)]} {
    set cpu $::env(PROCESSOR_IDENTIFIER)
}
set processors [if {[info exists ::env(NUMBER_OF_PROCESSORS)]} {set ::env(NUMBER_OF_PROCESSORS)} else {
    expr {[catch {exec nproc} n] ? ([catch {exec sysctl -n hw.ncpu} n] ? "?" : $n) : $n}
}]
set jit [native::jitAvailable]
puts "host: [core::cabi::hostTarget], $::tcl_platform(os) $::tcl_platform(osVersion), $cpu, $processors processors"
puts "linker: [expr {[info exists ::env(BOTLISH_NATIVE_LINKER)] ? $::env(BOTLISH_NATIVE_LINKER) : "rustc (the checkout's default)"}]; native JIT: [expr {$jit ? "available" : "unavailable"}]; best of $runs"
puts ""

puts "1. Phases in this process, ms"
puts [format "   %-8s %9s %9s %9s %9s %9s %9s %9s %9s" program frontend lowering object link exe aotRun build start]
foreach {name path} $programs {
    set hir [surface::readProgramFile $path -warnings off]
    set frontend [timed {surface::readProgramFile $path -warnings off}]
    set lowering [timed {native::ExecutableText $hir}]
    # The driver on the same NIR: the object alone (Cranelift and the
    # object's file), then the executable (the object and the link).
    set text [native::ExecutableText $hir]
    set objectPath [file join $work $name.o]
    set object [timed {native::Driver object $text $objectPath --startup worker}]
    set exePath [file join $work $name-exe]
    set driverExe [timed {native::Driver executable $text $exePath --startup worker}]
    set exe [timed {native::executable $hir [file join $work $name-exe]}]
    # (aotRun's child writes to this process's output: hello's line.)
    set best ""
    foreach i [lrepeat $runs x] {
        set t [clock microseconds]
        set result [core::process::withArgv [list [encoding convertto utf-8 $path]] {native::aotRun $hir $name}]
        set ms [expr {([clock microseconds] - $t) / 1000.0}]
        if {$best eq "" || $ms < $best} {
            set best $ms
            lassign [dict get $result timing] build start
        }
    }
    puts [format "   %-8s %9s %9s %9s %9.1f %9s %9.1f %9.1f %9.1f" $name $frontend $lowering $object \
        [expr {$driverExe - $object}] $exe $best [expr {$build / 1000.0}] [expr {$start / 1000.0}]]
}
puts "   (object: the driver's process, Cranelift and the object file, from the NIR; link: the driver's executable"
puts "   less its object; exe: native::executable, lowering included; aotRun: native::aotRun, lowering, build and"
puts "   the run included; build and start: the driver's own report, from its start, of aotRun's best run)"
puts ""

puts "2. Commands, ms (fresh processes)"
puts [format "   %-8s %9s %9s %9s %9s %9s %9s" program interp emit exe explicit aot-run jit]
foreach {name path} $programs {
    # (hello's IO is Linux's raw syscalls, or libSystem's or kernel32's C
    # calls: native only.)
    set interp [if {$name eq "hello"} {set _ -} else {timed {quiet [list $tclsh $main -warnings off $path]}}]
    # (Beside its source, its extension removed.)
    set emitted [native::executableFile [file rootname $path]]
    set emit [timed {quiet [list $tclsh $main -warnings off -emit-native-executable $path]}]
    set exe [timed {quiet [list $emitted]}]
    set aot [timed {quiet [list $tclsh $main -warnings off -aot-run $path]}]
    set jitTime [if {$jit} {timed {quiet [list $tclsh $main -warnings off -backend cranelift $path]}} else {set _ -}]
    puts [format "   %-8s %9s %9s %9s %9.1f %9s %9s" $name $interp $emit $exe [expr {$emit + $exe}] $aot $jitTime]
}
puts ""
puts "3. Time to the program's first line of output (hello), ms"
set emitted [native::executableFile [file rootname $hello]]
puts "   -aot-run                    [firstLine [list $tclsh $main -warnings off -aot-run $hello]]"
puts "   the emitted executable      [firstLine [list $emitted]]"
if {$jit} {
    puts "   -backend cranelift (JIT)    [firstLine [list $tclsh $main -warnings off -backend cranelift $hello]]"
}
file delete -force $work
