# backend-time.tcl -- FOLD-VIRTUAL-STRUCT-STATE-CENSUS-1.md's backend
# compile time: per program, the driver's own compilation time of its NIR
# (Cranelift: the `timing` line's COMPILE-US of `botlish-native bench 1`,
# best of RUNS processes) for the compiler's NIR and for the NIR
# experiment's field-register rewrite (tools/nir-sra.tcl over every
# function).
#
#   tclsh9.0 audit/fold-virtual-struct-state/tools/backend-time.tcl ?-runs N? FILE.bot ...
#
# Scratch files live in a `file tempdir` directory.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set runs 5
set files {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    switch -- $arg {
        -runs { set runs [lindex $argv [incr i]] }
        default { lappend files [file normalize $arg] }
    }
}
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
set driver [file join $root native target release botlish-native]

proc compileUs {path} {
    global driver runs
    set best ""
    for {set r 0} {$r < $runs} {incr r} {
        set line [lsearch -inline [split [exec $driver bench 1 $path 2>@1] \n] {timing *}]
        set us [lindex $line 1]
        if {$best eq "" || $us < $best} {
            set best $us
        }
    }
    return $best
}

set work [file tempdir fvssb]
try {
    puts [format "%-24s %12s %12s" program compile-us compile-us*]
    foreach path $files {
        set nir [file join $work program.nir]
        set sra [file join $work program.sra.nir]
        exec tclsh9.0 [file join $here nir.tcl] $path $nir
        exec tclsh9.0 [file join $here nir-sra.tcl] $nir $sra
        puts [format "%-24s %12s %12s" [file tail $path] [compileUs $nir] [compileUs $sra]]
        flush stdout
    }
} finally {
    file delete -force $work
}
