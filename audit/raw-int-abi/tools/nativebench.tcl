#!/usr/bin/env tclsh9.0
# nativebench.tcl -- RAW-INT-ABI.md native execution time of the emitted NIR
# with the raw Int ABI off (A), eligibility-only (B: -raw-demand-opt 0) and
# demand-filtered (C): `botlish-native bench RUNS file.nir`, best run of
# REPEAT invocations. Wall-clock, so only large differences mean anything on a
# shared machine; callgrind (profile-nir.sh) is the reliable per-instruction
# figure.
#
#   tclsh9.0 audit/raw-int-abi/tools/nativebench.tcl ?-runs N? ?-repeat M? PROGRAM.bot...
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set args $argv
set argv {}
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
set runs 200
set repeat 3
while {[lindex $args 0] in {-runs -repeat}} {
    if {[lindex $args 0] eq "-runs"} { set runs [lindex $args 1] } else { set repeat [lindex $args 1] }
    set args [lrange $args 2 end]
}
set bin [file join $root native target release botlish-native]
set tmp [file join [pwd] .nativebench-[pid].nir]
set configs {
    A {-raw-int-abi-opt 0}
    B {-raw-int-abi-opt 1 -raw-demand-opt 0}
    C {-raw-int-abi-opt 1 -raw-demand-opt 1}
}
foreach path $args {
    set hir [surface::readProgramFile $path]
    set line [file rootname [file tail $path]]
    foreach {name opts} $configs {
        set f [open $tmp w]
        fconfigure $f -encoding utf-8
        puts -nonewline $f [native::nir $hir {*}$opts]
        close $f
        set best ""
        for {set i 0} {$i < $repeat} {incr i} {
            set out [exec $bin bench $runs $tmp]
            # `times N1 N2 ...`: per-run nanoseconds.
            regexp {times ([^\n]*)} $out -> times
            set us [tcl::mathfunc::min {*}$times]
            if {$best eq "" || $us < $best} { set best $us }
        }
        append line [format "  %s %d ns" $name $best]
    }
    puts $line
}
file delete $tmp
