# gc-workloads.tcl -- allocation-heavy programs on the native backends, as
# ordinary runs and under BOTLISH_NATIVE_GC_STRESS=1, repeatedly, against
# the Tcl compiler's value (WINDOWS-X86-64-MILESTONE-1.md, section 3).
#
#   tclsh9.0 tests/platform/gc-workloads.tcl ?-repeat N? ?-executables 0|1?
#                                            ?-workloads NAME,...? ?-unwind-check 0|1?
#
# For every workload: its value on the `compile` backend (the oracle: no
# native code), then on cranelift and cranelift-generic once as an
# ordinary run and N times (default 5) under GC stress, and -- with
# -executables 1, the default -- its standalone executable (native::
# executable) run once as it is and N times under GC stress. Every outcome
# must be the oracle's value; the census's two workloads also their recorded
# values (uri 29500, 2048 2002720). The collector's roots are the host's
# (runtime::framewalk's NATIVE_FRAME_ROOTS): native frames where they can be
# walked (on Windows across Rust frames by Windows' unwinder:
# WINDOWS-X86-64-MILESTONE-3.md), the fallback plan's shadow stack
# elsewhere (a `fallback-roots` driver), and a missed root shows here as a
# wrong value, an error or a crash -- on real Windows a frame-pointer walk
# through Rust frames failed the 2048 benchmark even without stress
# (WINDOWS-TOOLCHAIN-CENSUS.md, E13). Repeated, because the failures it
# guards against depend on what the stack happens to hold.
#
# With -unwind-check 1 (Windows) every native run has
# BOTLISH_NATIVE_UNWIND_CHECK=1: Windows' unwinder checks every Botlish
# function's unwind entry and every Botlish frame of every collection
# against the walk, and an executable's account of it (its standard error's
# one line) must name every one of its functions.
#
# The workloads are the census's two (bench/uri-steady.bot and the 2048
# engine's benchmark), the standard-library examples that run on both
# native backends and as executables (closed: -aot-spec) and print nothing
# (programs that print need platform IO), and three coroutine programs
# (tests/platform/programs/coroutine-*.bot: values held only by suspended
# frames while other coroutines allocate, nested coroutines with an error
# crossing a resume, thousands of short coroutines; WINDOWS-X86-64-
# MILESTONE-5.md). The coroutine workloads are compiled with coroutine
# fusion off (BOTLISH_NATIVE_COROUTINE_FUSION=0), so that every coroutine
# runs on a stack of its own, the stacks the collector walks; a driver
# without native coroutines (no host support, or the fallback plan of a
# `fallback-roots` driver, which runs none) skips them, saying so.
#
# Prints one line per run and a summary; exits 1 on any difference. Needs
# the native backend built.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname $here]]
source [file join $root native native.tcl]

set workloads [dict create \
    uri [list [file join $root bench uri-steady.bot] 29500] \
    2048 [list [file join $root examples games 2048 bench.bot] 2002720] \
    csv [list [file join $root examples stdlib csv.bot] ""] \
    csv_geometric [list [file join $root examples stdlib csv_geometric.bot] ""] \
    ai_text_clean [list [file join $root examples stdlib ai_text_clean.bot] ""] \
    string_replace [list [file join $root examples stdlib string_replace.bot] ""] \
    matmul [list [file join $root examples stdlib matmul.bot] ""] \
    coroutine-roots [list [file join $here programs coroutine-roots.bot] "" coroutines] \
    coroutine-nested [list [file join $here programs coroutine-nested.bot] "" coroutines] \
    coroutine-many [list [file join $here programs coroutine-many.bot] 7997 coroutines]]

set options [dict create -repeat 5 -executables 1 -workloads [join [dict keys $workloads] ,] -unwind-check 0]
foreach {option value} $argv {
    if {![dict exists $options $option]} {
        puts stderr "usage: tclsh9.0 tests/platform/gc-workloads.tcl ?-repeat N? ?-executables 0|1? ?-workloads NAME,...? ?-unwind-check 0|1? (workloads: [join [dict keys $workloads] {, }])"
        exit 2
    }
    dict set options $option $value
}
set repeat [dict get $options -repeat]
set unwindCheck [dict get $options -unwind-check]
if {$unwindCheck} {
    set ::env(BOTLISH_NATIVE_UNWIND_CHECK) 1
}
set names [split [dict get $options -workloads] ,]
foreach name $names {
    if {![dict exists $workloads $name]} {
        puts stderr "unknown workload $name (known: [join [dict keys $workloads] {, }])"
        exit 2
    }
}

# The outcome of SCRIPT with BOTLISH_NATIVE_GC_STRESS set to STRESS: {value
# TEXT} or {error CODE MESSAGE}, TEXT the value as main.tcl shows it.
proc outcome {stress script} {
    set saved [array get ::env BOTLISH_NATIVE_GC_STRESS]
    if {$stress} { set ::env(BOTLISH_NATIVE_GC_STRESS) 1 } else { unset -nocomplain ::env(BOTLISH_NATIVE_GC_STRESS) }
    try {
        if {[catch {uplevel 1 $script} result options]} {
            # The whole message: a crashed driver's own report follows its
            # first line (shown shortened per run, whole among the failures).
            return [list error [dict get $options -errorcode] [string trim $result]]
        }
        return [list value $result]
    } finally {
        unset -nocomplain ::env(BOTLISH_NATIVE_GC_STRESS)
        if {$saved ne {}} { set ::env(BOTLISH_NATIVE_GC_STRESS) [lindex $saved 1] }
    }
}

set work [file tempdir botlish-gc-workloads]

# EXECUTABLE's standard output, its standard error empty -- or, with
# -unwind-check 1, the unwind check's account naming at least one function.
proc runExecutable {executable} {
    global work unwindCheck
    set errors [file join $work stderr.txt]
    set value [string trimright [exec $executable 2> $errors] \n]
    set channel [open $errors r]
    set text [string trimright [read $channel] \n]
    close $channel
    if {$unwindCheck} {
        if {![regexp {^native unwind check: (\d+) functions, (\d+) Botlish frames, every one as Windows unwinds it; \d+ walks unwound \d+ other frames$} $text - functions] || $functions == 0} {
            error "no unwind check's account: $text"
        }
        # Its counts: what the walk crossed (WINDOWS-X86-64-MILESTONE-3.md,
        # section 3), printed after the run's line.
        set ::lastAccount $text
    } elseif {$text ne ""} {
        error $text
    }
    return $value
}
set runs 0
set failures {}
proc record {name label expected observed seconds} {
    global runs failures
    incr runs
    set ok [expr {$observed eq $expected}]
    if {!$ok} { lappend failures "$name $label: [join $observed { }]" }
    set text [lindex [split [join $observed " "] \n] 0]
    if {[string length $text] > 60} { set text "[string range $text 0 56]..." }
    puts [format "%-4s %-14s %-30s %6.2f s  %s" [expr {$ok ? "ok" : "FAIL"}] $name $label $seconds $text]
    flush stdout
}

# The root plan this driver compiles a function with a Botlish call to: its
# roots in its native frame (walked) or on the shadow stack (the fallback).
set nativeFrames [string match "*storage: native frame*" [native::roots [surface::compile "fn f(n):\n    if n <= 1:\n        return n\n\n    f(n - 1) + f(n - 2)\n\nf(3)\n" -warnings off]]]
set plan [expr {$nativeFrames ? "native frames, walked" : "the shadow stack (the fallback plan: no frame walk)"}]
# The caller's coroutine fusion setting, which every other workload keeps.
set fusion [array get ::env BOTLISH_NATIVE_COROUTINE_FUSION]
# Whether this driver runs native coroutines: the host's, on native frames.
set coroutines [expr {$nativeFrames && [native::hostSupports coroutines]}]
puts "gc workloads on [core::cabi::hostTarget] ($::tcl_platform(os) $::tcl_platform(machine)), driver [native::binary]; roots of a calling function: $plan[expr {$unwindCheck ? "; every run's unwinding checked against Windows'" : ""}]"
try {
    foreach name $names {
        lassign [dict get $workloads $name] path recorded needs
        if {$needs eq "coroutines"} {
            if {!$coroutines} {
                puts [format "%-4s %-14s %s" skip $name "this driver runs no native coroutines ([expr {$nativeFrames ? "the host has none" : "the fallback plan"}])"]
                continue
            }
            set ::env(BOTLISH_NATIVE_COROUTINE_FUSION) 0
        } elseif {$fusion eq {}} {
            unset -nocomplain ::env(BOTLISH_NATIVE_COROUTINE_FUSION)
        } else {
            set ::env(BOTLISH_NATIVE_COROUTINE_FUSION) [lindex $fusion 1]
        }
        set hir [surface::readProgramFile $path -warnings off]
        set started [clock milliseconds]
        set oracle [outcome 0 {core::formatValue [core::compiler::evalHir $hir]}]
        set expected $oracle
        if {$recorded ne ""} {
            # The census's recorded value, which the oracle must agree with.
            record $name "compile (oracle)" [list value $recorded] $oracle [expr {([clock milliseconds] - $started) / 1000.0}]
        } else {
            record $name "compile (oracle)" $oracle $oracle [expr {([clock milliseconds] - $started) / 1000.0}]
        }
        foreach backend {cranelift cranelift-generic} {
            set backendOptions [expr {$backend eq "cranelift-generic" ? {-specialize 0} : {}}]
            for {set i 0} {$i <= $repeat} {incr i} {
                set stress [expr {$i > 0}]
                set started [clock milliseconds]
                set observed [outcome $stress {core::formatValue [native::evalHir $hir {*}$backendOptions]}]
                record $name "$backend[expr {$stress ? " gc-stress $i" : ""}]" $expected $observed [expr {([clock milliseconds] - $started) / 1000.0}]
            }
        }
        if {[dict get $options -executables]} {
            set started [clock milliseconds]
            set built [outcome 0 {native::executable $hir [file join $work $name]}]
            if {[lindex $built 0] ne "value"} {
                record $name "executable link" {value linked} $built [expr {([clock milliseconds] - $started) / 1000.0}]
                continue
            }
            set executable [lindex $built 1]
            for {set i 0} {$i <= $repeat} {incr i} {
                set stress [expr {$i > 0}]
                set started [clock milliseconds]
                set ::lastAccount ""
                set observed [outcome $stress {runExecutable $executable}]
                record $name "executable[expr {$stress ? " gc-stress $i" : ""}]" $expected $observed [expr {([clock milliseconds] - $started) / 1000.0}]
                if {$::lastAccount ne ""} {
                    puts "     $::lastAccount"
                }
            }
        }
    }
} finally {
    file delete -force $work
}
puts "$runs runs, [llength $failures] failed"
foreach failure $failures {
    puts "FAILED: $failure"
}
exit [expr {[llength $failures] > 0}]
