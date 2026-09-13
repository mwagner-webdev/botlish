# bench.tcl -- compares backends on the programs in bench/*.ir.
#
#   tclsh bench/bench.tcl [-runs N] [FILE.ir ...]
#
# Each program runs once untimed per backend (so compilation is excluded
# from the measurement), then N timed runs; the best run is reported.

set root [file dirname [file dirname [file normalize [info script]]]]
source [file join $root compiler compiler.tcl]

set runs 5
set files {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    switch -- [lindex $argv $i] {
        -runs   { set runs [lindex $argv [incr i]] }
        default { lappend files [lindex $argv $i] }
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
puts [format "%-20s %s" program [join [lmap b $backends {format "%14s" $b}] ""]]
foreach path $files {
    set program [core::readProgramFile $path]
    set cells {}
    set values {}
    foreach backend $backends {
        core::useBackend $backend
        lassign [best $program $runs] micros value
        lappend cells [format "%11.1f ms" [expr {$micros / 1000.0}]]
        lappend values $value
    }
    set agree [expr {[llength [lsort -unique $values]] == 1 ? "" : "  VALUES DIFFER: $values"}]
    puts [format "%-20s %s%s" [file tail $path] [join $cells ""] $agree]
}
