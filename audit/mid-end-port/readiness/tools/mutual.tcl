# mutual.tcl -- times programs/mutual.bot's three forms of one mutually
# recursive walk natively (PORTABILITY-MID-END-PORT-READINESS-CENSUS-1.md,
# section 5): merged (one function over a request enum), passed (function
# values and a closure per block expression), flat (no recursion through
# the cycle).
#
#   tclsh9.0 audit/mid-end-port/readiness/tools/mutual.tcl ?-trees 3000? ?-depth 10? ?-repeat 3?
#
# Each form is its own executable (main(TREES, DEPTH, VARIANT)): prints one
# line per form with its value, best time, peak resident size and the
# native allocation summary. Exits 1 unless the three values agree.

set here [file dirname [file normalize [info script]]]
set readiness [file dirname $here]
set checkout [file dirname [file dirname [file dirname $readiness]]]
set options [dict create -trees 3000 -depth 10 -repeat 3]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "mutual.tcl: unknown option $option" }
    dict set options $option $value
}
set peak [file join $here peak.py]
source [file join $checkout surface surface.tcl]
source [file join $checkout compiler compiler.tcl]
source [file join $checkout native native.tcl]
set channel [open [file join $readiness programs mutual.bot]]; set text [read $channel]; close $channel
set scratch [file tempdir mid-end-mutual]
set values {}
try {
    foreach {variant name} {0 merged 1 passed 2 flat} {
        set program $text
        if {![regsub {\nall\(\d+, \d+\):} $program "\nmain([dict get $options -trees], [dict get $options -depth], $variant):" program]} {
            error "mutual.tcl: no all(...) line"
        }
        set copy [file join $scratch mutual-$name.bot]
        set channel [open $copy w]; puts -nonewline $channel $program; close $channel
        set hir [surface::readProgramFile $copy -warnings off -cache ""]
        set exe [file join $scratch mutual-$name]
        set lines [native::Driver executable [native::nir $hir] $exe --startup worker]
        set exe [lindex [lindex $lines 0] 1]
        set resultFile [file join $scratch result.txt]
        set best ""; set bestKb 0
        for {set i 0} {$i < [dict get $options -repeat]} {incr i} {
            set ::env(BOTLISH_NATIVE_RESULT) $resultFile
            exec python3 -I $peak $exe 2> [file join $scratch err]
            unset ::env(BOTLISH_NATIVE_RESULT)
            set channel [open [file join $scratch err]]; set err [read $channel]; close $channel
            regexp {seconds ([0-9.]+) peakKb (\d+)} $err -> s kb
            if {$best eq "" || $s < $best} { set best $s }
            if {$kb > $bestKb} { set bestKb $kb }
        }
        set channel [open $resultFile]
        set value ""
        foreach line [split [read $channel] \n] {
            if {[lindex $line 0] eq "value"} { set value [lmap item [lindex [lindex $line 1] 1] {lindex $item 1}] }
        }
        close $channel
        lappend values $value
        set report [native::allocationReport $hir summary]
        puts [list form $name value $value seconds $best peakKb $bestKb \
            allocs [dict get $report total allocations] structs [dict get $report byKind Struct allocations] \
            blocks [dict get $report byKind Block allocations] lists [dict get $report byKind List allocations] \
            gcCycles [dict get $report gc cycles]]
        flush stdout
    }
} finally {
    file delete -force $scratch
}
exit [expr {[llength [lsort -unique $values]] != 1}]
