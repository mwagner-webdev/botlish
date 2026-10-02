#!/usr/bin/env tclsh9.0
# nativebench.tcl -- SHORT-STRING.md wall-clock of the emitted NIR with
# ShortString1 off and on: `botlish-native bench RUNS file.nir`, best of
# REPEAT invocations, ns per run. Wall-clock on a shared machine is placement
# sensitive for tiny kernels (RAW-INT-ABI.md's loop-count investigation): the
# deterministic figure is ir.tcl's instruction count.
#
#   tclsh9.0 audit/short-string/tools/nativebench.tcl ?-runs N? ?-repeat M? ?PROGRAM.bot...?
source [file join [file dirname [file normalize [info script]]] lib.tcl]
set runs 200
set repeat 5
set paths {}
set args $argv
while {$args ne ""} {
    set a [lindex $args 0]
    if {$a eq "-runs"} { set runs [lindex $args 1]; set args [lrange $args 2 end]
    } elseif {$a eq "-repeat"} { set repeat [lindex $args 1]; set args [lrange $args 2 end]
    } else { lappend paths $a; set args [lrange $args 1 end] }
}
if {$paths eq ""} { set paths [corpusPaths] }
set bin [file join $root native target release botlish-native]
set tmp [file join [pwd] .nativebench-short-[pid].nir]
foreach path $paths {
    set hir [surface::readProgramFile $path]
    set nir0 [native::nir $hir -short-string-opt 0]
    set nir1 [native::nir $hir -short-string-opt 1]
    if {$nir0 eq $nir1} {
        puts [format "%-16s identical NIR" [programName $path]]
        continue
    }
    set line [format "%-16s" [programName $path]]
    foreach {tag nir} [list off $nir0 on $nir1] {
        set f [open $tmp w]
        fconfigure $f -encoding utf-8
        puts -nonewline $f $nir
        close $f
        set best ""
        for {set i 0} {$i < $repeat} {incr i} {
            set out [exec $bin bench $runs $tmp]
            regexp {times ([^\n]*)} $out -> times
            set us [tcl::mathfunc::min {*}$times]
            if {$best eq "" || $us < $best} { set best $us }
        }
        append line [format "  %s %d ns" $tag $best]
        set ns($tag) $best
    }
    append line [format "  (%+.1f%%)" [expr {100.0 * ($ns(on) - $ns(off)) / $ns(off)}]]
    puts $line
}
file delete $tmp
