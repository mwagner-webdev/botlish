#!/usr/bin/env tclsh9.0
# codesize.tcl -- RAW-INT-ABI.md code-size impact: per program, whole-program
# machine-code bytes with the raw Int ABI off/on, and the bytes of exactly
# the functions that gain a raw signature (matched by name and instance key,
# before/after). Observation only.
#
#   tclsh9.0 audit/raw-int-abi/tools/codesize.tcl PROGRAM.bot...
set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
source [file join $root compiler compiler.tcl]
source [file join $root surface surface.tcl]
source [file join $root native native.tcl]
interp recursionlimit {} 20000
proc functionKeys {nir} {
    set keys {}
    foreach chunk [split [string map [list "\n\nfunc " "\n\u0001func "] $nir] \u0001] {
        set head [lindex [split $chunk \n] 0]
        if {![regexp {^func \d+ "([^"]*)" } $head -> name]} continue
        set inst ""
        regexp {instance="([^"]*)"} $head -> inst
        set mode [expr {[regexp {rawparams=|rawresult=1} $head] ? "raw" : "tagged"}]
        lappend keys [list "$name<$inst>" $mode]
    }
    return $keys
}
set grand0 0; set grand1 0; set g0 0; set g1 0
foreach path $argv {
    set hir [surface::readProgramFile $path]
    set nir0 [native::nir $hir -raw-int-abi-opt 0]
    set nir1 [native::nir $hir -raw-int-abi-opt 1]
    set s0 [native::codeSize $hir -raw-int-abi-opt 0]
    set s1 [native::codeSize $hir -raw-int-abi-opt 1]
    set k0 [functionKeys $nir0]
    set k1 [functionKeys $nir1]
    set b0 0; set b1 0; set n 0
    if {[llength $k0] == [llength $k1]} {
        foreach a $k0 b $k1 sz0 [lindex $s0 1] sz1 [lindex $s1 1] {
            if {[lindex $b 1] eq "raw" && [lindex $a 0] eq [lindex $b 0]} {
                incr b0 $sz0; incr b1 $sz1; incr n
            }
        }
    }
    puts [format "%-40s whole %6d -> %6d (%+d) | %2d functions with a raw signature %6d -> %6d (%+d)" $path [lindex $s0 0] [lindex $s1 0] [expr {[lindex $s1 0] - [lindex $s0 0]}] $n $b0 $b1 [expr {$b1 - $b0}]]
    incr grand0 [lindex $s0 0]; incr grand1 [lindex $s1 0]; incr g0 $b0; incr g1 $b1
}
puts [format "%-40s whole %6d -> %6d (%+d) | raw-signature functions %6d -> %6d (%+d)" TOTAL $grand0 $grand1 [expr {$grand1 - $grand0}] $g0 $g1 [expr {$g1 - $g0}]]
