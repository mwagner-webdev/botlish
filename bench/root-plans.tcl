# root-plans.tcl -- GC roots in native frames against the fallback plan's
# shadow stack, on one host with one compiler build
# (WINDOWS-X86-64-MILESTONE-3.md, section 8).
#
#   tclsh9.0 bench/root-plans.tcl -fallback BINARY ?-runs N? ?-rounds R?
#                                 ?-stress-runs N? ?-executables 0|1? ?-name NAME?
#
# BINARY is a driver built from this checkout with the `fallback-roots`
# feature (cargo build --release --features fallback-roots --target-dir
# DIR): the same compiler and runtime, the root plan of a host without
# native-frame roots (shadow-stack roots, the shadow stack's depth check,
# leaf frames published, no frame walk). Both drivers run the same NIR --
# this checkout's front end lowers each program once -- and decide every
# root and call effect themselves (codegen::roots, nir's call effects), so
# only the root plan differs.
#
# For each workload -- a call-bound recursion (fib), a loop of calls, the
# URI workload, the 2048 engine's benchmark, a string-allocating loop and a
# list-building recursion -- prints:
#
#   * the JIT's median per-run time on each driver, the median of R rounds
#     of N runs each, the drivers alternating within a round, and their
#     ratio, with each driver's best run;
#   * with -executables 1 (the default), the same for the program's
#     standalone executable (its own timing: BOTLISH_NATIVE_RUNS);
#   * under BOTLISH_NATIVE_GC_STRESS=1 (a collection before every
#     allocation), the JIT's median of -stress-runs runs and its
#     collections, and the cost of one collection above the plain run's
#     time ((stress - plain) / collections): what finding the roots costs,
#     a frame walk against the shadow stack's scan;
#   * each driver's machine code size (botlish-native size), and the
#     program object's unwind information (.pdata and .xdata, Windows'
#     COFF object only).
#
# Times are observations of one machine at one moment: read the ratios
# against each round's spread, never as a limit.
#
# -name names BINARY in the report (default "fallback"), for comparing a
# driver of another build -- a probe's (audit/windows-unwind) -- the same
# way.

set root [file dirname [file dirname [file normalize [info script]]]]
set args $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]
source [file join $root tests binary-header.tcl]

set options [dict create -fallback "" -runs 20 -rounds 5 -stress-runs 3 -executables 1 -name fallback]
foreach {option value} $args {
    if {![dict exists $options $option]} {
        puts stderr "usage: tclsh9.0 bench/root-plans.tcl -fallback BINARY ?-runs N? ?-rounds R? ?-stress-runs N? ?-executables 0|1? ?-name NAME?"
        exit 2
    }
    dict set options $option $value
}
set runs [dict get $options -runs]
set rounds [dict get $options -rounds]
set stressRuns [dict get $options -stress-runs]
set executables [dict get $options -executables]
set fallback [dict get $options -fallback]
set otherName [dict get $options -name]
if {$fallback eq "" || ![file isfile $fallback]} {
    puts stderr "usage: tclsh9.0 bench/root-plans.tcl -fallback BINARY ...: BINARY is a fallback-roots driver"
    exit 2
}
set native [native::binary]
set drivers [dict create native $native fallback [file normalize $fallback]]

set workloads [dict create \
    fib [list source {fn fib(n: int) -> int:
    if n < 2:
        return n
    fib(n - 1) + fib(n - 2)

fib(25)
}] \
    calls [list source {fn count(i: int, acc: int) -> int:
    if i == 0:
        return acc
    1 + count(i - 1, acc + 3) - 1

count(100000, 0)
}] \
    uri [list file [file join $root bench uri-steady.bot]] \
    2048 [list file [file join $root examples games 2048 bench.bot]] \
    strings [list source {import str
fn churn(i: int, total: int) -> int:
    if i == 0:
        return total
    s = str::concat("ab", "cd")
    churn(i - 1, total + str::length(s))

churn(200000, 0)
}] \
    lists [list source {import list
fn build(n: int) -> List[int]:
    if n == 0:
        return []
    rest = build(n - 1)
    list::append(rest, n)

fn sum(i: int, acc: int) -> int:
    if i == 0:
        return acc
    sum(i - 1, acc + list::length(build(200)))

sum(200, 0)
}]]

# The report's name of driver WHICH (native or fallback).
proc label {which} {
    if {$which eq "native"} {
        return native
    }
    return $::otherName
}

proc median {values} {
    set sorted [lsort -real $values]
    return [lindex $sorted [expr {[llength $sorted] / 2}]]
}

# Runs SCRIPT with the environment variables of ENV ({NAME VALUE ...}) set.
proc withEnv {env script} {
    set saved {}
    foreach {name value} $env {
        lappend saved $name [array get ::env $name]
        set ::env($name) $value
    }
    try {
        uplevel 1 $script
    } finally {
        foreach {name old} $saved {
            unset -nocomplain ::env($name)
            if {$old ne ""} { set ::env($name) [lindex $old 1] }
        }
    }
}

# {times COLLECTIONS} of RUNS runs of NIR text TEXT on DRIVER (nanoseconds).
proc jitRuns {driver text runs {env {}}} {
    withEnv [list BOTLISH_NATIVE_BIN $driver {*}$env] {
        set lines [native::Driver bench $text $runs]
    }
    native::Outcome $lines
    set times [lrange [lsearch -inline $lines {times *}] 1 end]
    set collections [lindex [lsearch -inline $lines {timing *}] 4]
    return [list $times $collections]
}

# The per-run nanoseconds of RUNS runs of EXECUTABLE (its driver protocol).
proc executableRuns {executable runs} {
    set result [file join $::work result.txt]
    withEnv [list BOTLISH_NATIVE_RESULT $result BOTLISH_NATIVE_RUNS $runs] {
        exec $executable
    }
    set channel [open $result r]
    set lines [split [string trim [read $channel]] \n]
    close $channel
    native::Outcome $lines
    return [lrange [lsearch -inline $lines {times *}] 1 end]
}

# Alternates the two drivers over ROUNDS rounds of MEASURE (a command
# prefix taking a driver name, returning per-run times): {driver {medians
# of the rounds} best ...}.
proc compare {measure} {
    global rounds
    set samples [dict create native {} fallback {}]
    set best [dict create native Inf fallback Inf]
    for {set round 0} {$round < $rounds} {incr round} {
        set order [expr {$round % 2 ? {fallback native} : {native fallback}}]
        foreach which $order {
            set times [{*}$measure $which]
            dict lappend samples $which [median $times]
            dict set best $which [expr {min([dict get $best $which], [tcl::mathfunc::min {*}$times])}]
        }
    }
    return [list $samples $best]
}

proc row {label samples best} {
    set n [expr {[median [dict get $samples native]] / 1000.0}]
    set f [expr {[median [dict get $samples fallback]] / 1000.0}]
    set spread [lmap which {native fallback} {
        set values [lmap v [dict get $samples $which] {expr {$v / 1000.0}}]
        format "%.0f-%.0f" [tcl::mathfunc::min {*}$values] [tcl::mathfunc::max {*}$values]
    }]
    set other $::otherName
    puts [format "  %-10s native %9.1f us (best %9.1f, rounds %s)   %s %9.1f us (best %9.1f, rounds %s)   native/%s %.3f" \
        $label $n [expr {[dict get $best native] / 1000.0}] [lindex $spread 0] \
        $other $f [expr {[dict get $best fallback] / 1000.0}] [lindex $spread 1] $other [expr {$n / $f}]]
}

set work [file tempdir botlish-root-plans]
puts "root plans on [core::cabi::hostTarget] ($::tcl_platform(os) $::tcl_platform(machine)): $runs runs x $rounds rounds, $stressRuns runs under GC stress"
puts "  native:   $native"
puts "  $otherName: $fallback"
try {
    dict for {name workload} $workloads {
        lassign $workload kind what
        if {$kind eq "file"} {
            set hir [surface::readProgramFile $what -warnings off]
        } else {
            set hir [surface::compile $what $name.bot -warnings off]
        }
        set text [native::nir $hir]
        puts "$name:"
        lassign [compare [list apply {{text runs which} {
            lindex [jitRuns [dict get $::drivers $which] $text $runs] 0
        }} $text $runs]] samples best
        row jit $samples $best
        set plain [dict create native [expr {[median [dict get $samples native]]}] fallback [expr {[median [dict get $samples fallback]]}]]
        if {$executables} {
            set paths [dict create]
            foreach which {native fallback} {
                withEnv [list BOTLISH_NATIVE_BIN [dict get $drivers $which]] {
                    dict set paths $which [native::executable $hir [file join $work $name-$which]]
                }
            }
            lassign [compare [list apply {{paths runs which} {
                executableRuns [dict get $paths $which] $runs
            }} $paths $runs]] samples best
            row executable $samples $best
        }
        set line "  gc stress "
        foreach which {native fallback} {
            lassign [jitRuns [dict get $drivers $which] $text $stressRuns {BOTLISH_NATIVE_GC_STRESS 1}] times collections
            set perRun [median $times]
            # The driver counts its Vm's collections over every run.
            set collectionsPerRun [expr {$collections / double([llength $times])}]
            set perCollection [expr {$collectionsPerRun > 0 ? ($perRun - [dict get $plain $which]) / $collectionsPerRun : 0}]
            append line [format "%s %.1f ms, %.0f collections, %.2f us each   " [label $which] [expr {$perRun / 1e6}] $collectionsPerRun [expr {$perCollection / 1000.0}]]
        }
        puts $line
        set line "  size      "
        foreach which {native fallback} {
            withEnv [list BOTLISH_NATIVE_BIN [dict get $drivers $which]] {
                lassign [native::codeSize $hir] total
                set object [file join $work $name-$which.obj]
                native::object $hir $object
            }
            set unwind ""
            if {[lindex [binaryHeader $object] 0] eq "coff"} {
                set sizes [dict get [coffFacts $object] sizes]
                set unwind [format ", .pdata %d + .xdata %d bytes" [dict getdef $sizes .pdata 0] [dict getdef $sizes .xdata 0]]
            }
            append line [format "%s code %d bytes%s   " [label $which] $total $unwind]
        }
        puts $line
    }
} finally {
    file delete -force $work
}
