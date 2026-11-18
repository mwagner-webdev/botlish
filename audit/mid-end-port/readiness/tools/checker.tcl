# checker.tcl -- runs the compiler-shaped probe (programs/checker.bot) and
# its Tcl reference (programs/checker.tcl) and compares them
# (PORTABILITY-MID-END-PORT-READINESS-CENSUS-1.md, section 8):
#
#   tclsh9.0 audit/mid-end-port/readiness/tools/checker.tcl
#       ?-agree "300:6"? ?-backends "compile cranelift-generic cranelift"?
#       ?-sizes "2000:8 8000:8"? ?-repeat 3?
#
# * agreement: at each -agree size, the probe on every -backends backend
#   through main.tcl, and the Tcl reference, must print the same
#   [nodes, rechecks, diagnostics, summary checksum, diagnostic checksum].
#   (interp is a backend too, but takes minutes at 300:6.)
# * cost: at each -sizes size, the Tcl reference (best of -repeat, peak
#   resident size) against the probe as a native executable (its build
#   apart, then best of -repeat and peak resident size), the generic
#   (unspecialized) native executable likewise, and the native allocation
#   summary (native::allocationReport, one JIT run).
#
# Prints `agree ...` and `cost ...` lines; exits 1 on a disagreement.

set here [file dirname [file normalize [info script]]]
set readiness [file dirname $here]
set checkout [file dirname [file dirname [file dirname $readiness]]]
set options [dict create -agree "300:6" -backends "compile cranelift-generic cranelift" -sizes "2000:8" -repeat 3]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "checker.tcl: unknown option $option" }
    dict set options $option $value
}
set tclsh [info nameofexecutable]
set peak [file join $here peak.py]
set probe [file join $readiness programs checker.bot]
set reference [file join $readiness programs checker.tcl]
source [file join $checkout surface surface.tcl]
source [file join $checkout compiler compiler.tcl]
source [file join $checkout native native.tcl]

proc measured {args} {
    set errFile [file join $::scratch peak.err]
    set output [exec python3 -I $::peak {*}$args 2> $errFile]
    set channel [open $errFile]; set err [read $channel]; close $channel
    if {![regexp {seconds ([0-9.]+) peakKb (\d+) status (\d+)} $err -> s kb status] || $status != 0} {
        error "measured: $args: $err"
    }
    return [list $s $kb $output]
}
proc sized {functions depth} {
    set channel [open $::probe]; set text [read $channel]; close $channel
    if {![regsub {\nmain\(\d+, \d+\):} $text "\nmain($functions, $depth):" text]} {
        error "checker.tcl: no main(...) line in $::probe"
    }
    set copy [file join $::scratch checker-$functions-$depth.bot]
    set channel [open $copy w]; puts -nonewline $channel $text; close $channel
    return $copy
}
proc referenceValue {functions depth} {
    set line [exec $::tclsh $::reference $functions $depth]
    return [list [lrange $line 1 5] [string trimright [lindex $line 6] s]]
}
proc executableValue {resultFile} {
    set channel [open $resultFile]
    set value ""
    foreach line [split [read $channel] \n] {
        if {[lindex $line 0] eq "value"} {
            set value [lmap item [lindex [lindex $line 1] 1] {lindex $item 1}]
        }
    }
    close $channel
    return $value
}

set scratch [file tempdir mid-end-checker]
set failed 0
try {
    foreach size [dict get $options -agree] {
        lassign [split $size :] functions depth
        set copy [sized $functions $depth]
        lassign [referenceValue $functions $depth] expected
        puts [list agree $functions $depth tcl $expected]
        foreach backend [dict get $options -backends] {
            set output [exec $tclsh [file join $checkout main.tcl] -warnings off -backend $backend $copy]
            if {![regexp {value: \[([^]]*)\]} $output -> value]} {
                set value [list failed [string range $output 0 300]]
            } else {
                set value [string map {, ""} $value]
            }
            puts [list agree $functions $depth $backend $value]
            if {$value ne $expected} { set failed 1; puts "DISAGREE: $backend" }
        }
        flush stdout
    }
    foreach size [dict get $options -sizes] {
        lassign [split $size :] functions depth
        set copy [sized $functions $depth]
        set row [dict create]
        set best ""; set bestKb 0
        for {set i 0} {$i < [dict get $options -repeat]} {incr i} {
            lassign [measured $tclsh $reference $functions $depth] s kb output
            set inner [string trimright [lindex $output 6] s]
            if {$best eq "" || $inner < $best} { set best $inner }
            if {$kb > $bestKb} { set bestKb $kb }
            set expected [lrange $output 1 5]
        }
        dict set row tcl [list value $expected seconds $best peakKb $bestKb]
        foreach {name specialize} {native 1 generic 0} {
            set exe [file join $scratch checker-$name]
            set hir [surface::readProgramFile $copy -warnings off -cache ""]
            set t0 [clock microseconds]
            set lines [native::Driver executable [native::nir $hir -specialize $specialize] $exe --startup worker]
            set build [expr {([clock microseconds] - $t0) / 1e6}]
            set exe [lindex [lindex $lines 0] 1]
            set best ""; set bestKb 0
            set resultFile [file join $scratch result.txt]
            for {set i 0} {$i < [dict get $options -repeat]} {incr i} {
                set ::env(BOTLISH_NATIVE_RESULT) $resultFile
                lassign [measured $exe] s kb
                unset ::env(BOTLISH_NATIVE_RESULT)
                if {$best eq "" || $s < $best} { set best $s }
                if {$kb > $bestKb} { set bestKb $kb }
            }
            set value [executableValue $resultFile]
            if {$value ne $expected} { set failed 1; puts "DISAGREE: $name at $size: $value" }
            dict set row $name [list value $value lowerAndLink [format %.2f $build] seconds $best peakKb $bestKb]
        }
        set report [native::allocationReport $hir summary 1 -specialize 1]
        dict set row alloc [list allocs [dict get $report total allocations] \
            bytes [dict get $report total allocatedBytes] \
            structs [dict get $report byKind Struct allocations] \
            strings [dict get $report strings objects] \
            lists [dict get $report byKind List allocations] \
            gcCycles [dict get $report gc cycles] gcUs [dict get $report gc totalTimeUs] \
            vectorDetaches [dict get $report mutableVector detaches] \
            vectorDetachElements [dict get $report mutableVector detachElements] \
            arrayDetaches [dict get $report mutableArray detaches]]
        puts [list cost $functions $depth $row]
        flush stdout
    }
} finally {
    file delete -force $scratch
}
exit $failed
