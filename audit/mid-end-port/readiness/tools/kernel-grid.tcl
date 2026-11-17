# kernel-grid.tcl -- the mid-end-shaped kernel (audit/mid-end-port/kernel/,
# README.md section 2) over a grid of sizes, with what kernel.tcl does not
# record: the native versions' build time apart from their run, each
# version's peak resident size, and the native versions' allocation and
# collection summary (native::allocationReport, one JIT run of the same
# NIR). PORTABILITY-MID-END-PORT-READINESS-CENSUS-1.md, section 7.
#
#   tclsh9.0 audit/mid-end-port/readiness/tools/kernel-grid.tcl
#       ?-sizes "1500:8 ..."? ?-repeat 3? ?-versions "dict list tables structs enums tables-native"?
#
# Prints one line per size and version:
#   row F D VERSION {nodes N rounds R checksum C build S best S peakKb K
#       structAllocs N allocs N allocatedBytes B gcCycles N gcUs U maxPauseUs U}
# (build and the allocation fields only for native versions). Exits 1 if
# two versions of a size disagree on [nodes rounds checksum].

set here [file dirname [file normalize [info script]]]
set readiness [file dirname $here]
set audit [file dirname $readiness]
set checkout [file dirname [file dirname $audit]]
set options [dict create -sizes "1500:8" -repeat 3 -versions "dict list tables structs enums tables-native" -alloc 1]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "kernel-grid.tcl: unknown option $option" }
    dict set options $option $value
}
set tclsh [info nameofexecutable]
set peak [file join $here peak.py]
source [file join $checkout surface surface.tcl]
source [file join $checkout compiler compiler.tcl]
source [file join $checkout native native.tcl]

# Runs COMMAND under peak.py: {seconds peakKb output}.
proc measured {args} {
    set errFile [file join $::scratch peak.err]
    set output [exec python3 -I $::peak {*}$args 2> $errFile]
    set channel [open $errFile]; set err [read $channel]; close $channel
    if {![regexp {seconds ([0-9.]+) peakKb (\d+) status (\d+)} $err -> s kb status] || $status != 0} {
        error "measured: $args: $err"
    }
    return [list $s $kb $output]
}

set scratch [file tempdir mid-end-kernel-grid]
set failed 0
try {
    foreach size [dict get $options -sizes] {
        lassign [split $size :] functions depth
        set values {}
        foreach version [dict get $options -versions] {
            set row [dict create]
            if {$version in {dict list tables}} {
                set best ""; set bestKb ""
                for {set i 0} {$i < [dict get $options -repeat]} {incr i} {
                    lassign [measured $tclsh [file join $audit kernel ranges.tcl] $version $functions $depth] s kb output
                    lassign $output - nodes rounds check
                    if {$best eq "" || $s < $best} { set best $s }
                    if {$bestKb eq "" || $kb > $bestKb} { set bestKb $kb }
                }
                dict set row value [list $nodes $rounds $check]
            } else {
                set variant [expr {$version eq "tables-native" ? "tables" : $version}]
                set source [file join $audit kernel ranges-$variant.bot]
                set channel [open $source]; set text [read $channel]; close $channel
                if {![regsub {\nrun\(\d+, \d+\):} $text "\nrun($functions, $depth):" text]} {
                    error "kernel-grid.tcl: no run(...) line in $source"
                }
                set copy [file join $scratch ranges-$variant.bot]
                set channel [open $copy w]; puts -nonewline $channel $text; close $channel
                lassign [measured $tclsh [file join $checkout main.tcl] -warnings off -emit-native-executable $copy] build buildKb
                dict set row build $build
                dict set row buildPeakKb $buildKb
                set executable [file rootname $copy]
                set resultFile [file join $scratch result.txt]
                set best ""; set bestKb ""
                for {set i 0} {$i < [dict get $options -repeat]} {incr i} {
                    set ::env(BOTLISH_NATIVE_RESULT) $resultFile
                    lassign [measured $executable] s kb
                    unset ::env(BOTLISH_NATIVE_RESULT)
                    if {$best eq "" || $s < $best} { set best $s }
                    if {$bestKb eq "" || $kb > $bestKb} { set bestKb $kb }
                }
                set channel [open $resultFile]
                foreach line [split [read $channel] \n] {
                    if {[lindex $line 0] eq "value"} {
                        dict set row value [lmap item [lindex [lindex $line 1] 1] {lindex $item 1}]
                    }
                }
                close $channel
                if {[dict get $options -alloc]} {
                    set hir [surface::readProgramFile $copy -warnings off -cache ""]
                    set report [native::allocationReport $hir summary]
                    dict set row structAllocs [dict get $report byKind Struct allocations]
                    dict set row allocs [dict get $report total allocations]
                    dict set row allocatedBytes [dict get $report total allocatedBytes]
                    dict set row peakLiveBytes [dict get $report total peakLiveBytes]
                    dict set row gcCycles [dict get $report gc cycles]
                    dict set row gcUs [dict get $report gc totalTimeUs]
                    dict set row maxPauseUs [dict get $report gc maxPauseUs]
                }
            }
            dict set row best $best
            dict set row peakKb $bestKb
            lappend values [dict get $row value]
            puts [list row $functions $depth $version $row]
            flush stdout
        }
        if {[llength [lsort -unique $values]] != 1} {
            puts "DISAGREE at $functions:$depth: $values"
            set failed 1
        }
    }
} finally {
    file delete -force $scratch
}
exit $failed
