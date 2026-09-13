# bench.tcl -- compares backends on the programs in bench/*.ir.
#
#   tclsh bench/bench.tcl [-runs N] [-markdown] [FILE.ir ...]
#
# Each program runs once untimed per backend (so compilation is excluded
# from the measurement), then N timed runs; the best run is reported.
# -markdown prints a Markdown table (e.g. for a CI job summary).
# Exits with status 1 if the backends disagree on any program's value.

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root compiler compiler.tcl]

set runs 5
set markdown 0
set files {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    switch -- [lindex $argv $i] {
        -runs     { set runs [lindex $argv [incr i]] }
        -markdown { set markdown 1 }
        default   { lappend files [lindex $argv $i] }
    }
}
if {$files eq ""} {
    set files [lsort [glob -directory [file join $root bench] *.ir]]
}

# Recursion depth in the benchmarks exceeds Tcl's default nesting limit.
interp recursionlimit {} 20000

proc best {program runs} {
    core::evalProgram $program
    set best ""
    for {set i 0} {$i < $runs} {incr i} {
        set micros [lindex [time {set value [core::evalProgram $program]}] 0]
        if {$best eq "" || $micros < $best} {
            set best $micros
        }
    }
    return [list $best [core::formatValue $value]]
}

set backends [core::backends]
if {$markdown} {
    puts "Tcl [info patchlevel], best of $runs runs, compilation excluded.\n"
    puts "| program | [join $backends { | }] | speedup | values |"
    puts "|---|[string repeat ---:| [llength $backends]]---:|---|"
} else {
    puts [format "%-20s %s %9s" program [join [lmap b $backends {format "%14s" $b}] ""] speedup]
}

set disagreements 0
foreach path $files {
    set program [core::loadProgramFile $path]
    set times {}
    set values {}
    foreach backend $backends {
        core::useBackend $backend
        lassign [best $program $runs] micros value
        lappend times $micros
        lappend values $value
    }
    set agree [expr {[llength [lsort -unique $values]] == 1}]
    if {!$agree} {
        incr disagreements
    }
    set speedup [format "%.1fx" [expr {double([lindex $times 0]) / max(1, [lindex $times end])}]]
    set cells [lmap micros $times {format "%.1f ms" [expr {$micros / 1000.0}]}]
    set shown [string range [join [lsort -unique $values] " / "] 0 40]
    if {$markdown} {
        puts "| [file tail $path] | [join $cells { | }] | $speedup | [expr {$agree ? "✅" : "❌ DIFFER"}] `$shown` |"
    } else {
        puts [format "%-20s %s %9s%s" [file tail $path] \
            [join [lmap c $cells {format "%14s" $c}] ""] $speedup \
            [expr {$agree ? "" : "  VALUES DIFFER: $values"}]]
    }
}
exit [expr {$disagreements > 0}]
