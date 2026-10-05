#!/usr/bin/env tclsh9.0
# compare.tcl -- RANGE-FIXPOINT-SCALING.md: compares two dump directories
# written by dump.tcl, one subdirectory per suite (all cov corpus bot).
#
#   tclsh9.0 audit/range-fixpoint-scaling/tools/compare.tcl DUMP-A DUMP-B
#
# Per suite: the records of each run, the distinct inputs (by KIND), how
# many inputs map to different outputs, the inputs only one run saw, and the
# inputs one run lowered to more than one output (a nondeterminism check).
# Prints IDENTICAL when no input differs and both runs saw the same inputs.
lassign $argv a b
proc load {dir} {
    set map [dict create]   ;# kind,inKey -> sorted unique outKeys
    set count 0
    foreach f [glob -nocomplain -directory $dir *.log] {
        set c [open $f r]
        foreach line [split [read $c] \n] {
            if {$line eq ""} continue
            lassign $line kind in out
            dict lappend map "$kind $in" $out
            incr count
        }
        close $c
    }
    dict for {k v} $map { dict set map $k [lsort -unique $v] }
    return [list $count $map]
}
set bad 0
foreach suite {all cov corpus bot} {
    lassign [load [file join $a $suite]] ca ma
    lassign [load [file join $b $suite]] cb mb
    set diff 0; set onlyA 0; set onlyB 0; set multi 0
    set kinds [dict create]
    dict for {k v} $ma {
        dict incr kinds [lindex $k 0]
        if {[llength $v] > 1} { incr multi }
        if {![dict exists $mb $k]} { incr onlyA; continue }
        if {[dict get $mb $k] ne $v} {
            incr diff
            if {$diff <= 5} { puts "  DIFF $suite $k: $v vs [dict get $mb $k]" }
        }
    }
    dict for {k v} $mb { if {![dict exists $ma $k]} { incr onlyB } }
    puts [format "%-7s records %6d/%6d  distinct inputs %5d (%s)  differing %d  only-in-A %d  only-in-B %d  multi-output-inputs %d" \
        $suite $ca $cb [dict size $ma] $kinds $diff $onlyA $onlyB $multi]
    if {$diff || $onlyA || $onlyB} { set bad 1 }
}
puts [expr {$bad ? "MISMATCH" : "IDENTICAL"}]
