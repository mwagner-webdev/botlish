# kernel-generic.tcl -- the three native kernel versions (../kernel/) built
# specialized and unspecialized (-specialize 0, cranelift-generic's
# lowering): does a Botlish mid-end need specialization to run well
# (PORTABILITY-MID-END-PORT-READINESS-CENSUS-1.md, section 12)?
#
#   tclsh9.0 audit/mid-end-port/readiness/tools/kernel-generic.tcl ?-functions 1500? ?-depth 8? ?-repeat 5?
#
# Prints one line per version and mode: lowering and link seconds, best
# run seconds (the whole executable), its value.
set here [file dirname [file normalize [info script]]]
set audit [file dirname [file dirname $here]]
set checkout [file dirname [file dirname $audit]]
set options [dict create -functions 1500 -depth 8 -repeat 5]
foreach {option value} $argv { dict set options $option $value }
source [file join $checkout surface surface.tcl]
source [file join $checkout compiler compiler.tcl]
source [file join $checkout native native.tcl]
set scratch [file tempdir mid-end-kernel-generic]
try {
    foreach variant {structs enums tables} {
        set channel [open [file join $audit kernel ranges-$variant.bot]]; set text [read $channel]; close $channel
        regsub {\nrun\(\d+, \d+\):} $text "\nrun([dict get $options -functions], [dict get $options -depth]):" text
        set copy [file join $scratch ranges-$variant.bot]
        set channel [open $copy w]; puts -nonewline $channel $text; close $channel
        set hir [surface::readProgramFile $copy -warnings off -cache ""]
        foreach specialize {1 0} {
            set exe [file join $scratch k-$variant-$specialize]
            set t0 [clock microseconds]
            set lines [native::Driver executable [native::nir $hir -specialize $specialize] $exe --startup worker]
            set build [expr {([clock microseconds] - $t0) / 1e6}]
            set exe [lindex [lindex $lines 0] 1]
            set best ""
            for {set i 0} {$i < [dict get $options -repeat]} {incr i} {
                set ::env(BOTLISH_NATIVE_RESULT) [file join $scratch result.txt]
                set t0 [clock microseconds]
                exec $exe
                set s [expr {([clock microseconds] - $t0) / 1e6}]
                unset ::env(BOTLISH_NATIVE_RESULT)
                if {$best eq "" || $s < $best} { set best $s }
            }
            set channel [open [file join $scratch result.txt]]; set value [lindex [lsearch -inline [split [read $channel] \n] {value *}] 1]; close $channel
            puts [format "%-8s specialize %d  lower+link %.2f s  best %.3f s  %s" $variant $specialize $build $best $value]
        }
    }
} finally {
    file delete -force $scratch
}
