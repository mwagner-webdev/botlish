#!/usr/bin/env tclsh9.0
# compare.tcl -- RANGE-FIXPOINT-SCALING.md: compares two dump directories
# written by dump.tcl, one subdirectory per suite.
#
#   tclsh9.0 audit/range-fixpoint-scaling/tools/compare.tcl DUMP-A DUMP-B ?SUITE ...?
#
# SUITE defaults to all cov corpus bot. Per suite, the comparison is of the
# multiset of {KIND OUTPUT-KEY} records: every range analysis result and
# every NIR text the run produced, with multiplicities. Input keys are not
# compared: a call's arguments embed the compiler tree's path (an imported
# module's source location), so two trees never share them. Process logs are
# not paired either: concurrent runs reuse process ids, and two processes
# with one id append to one log. Prints IDENTICAL when every suite's
# multisets are equal.
lassign $argv a b
set suites [lrange $argv 2 end]
if {$suites eq ""} {
    set suites {all cov corpus bot}
}

# {RECORDS MULTISET}: the record count and {KIND OUTPUT-KEY} -> count.
proc load {dir} {
    set multiset [dict create]
    set records 0
    foreach path [glob -nocomplain -directory $dir *.log] {
        set channel [open $path r]
        foreach line [split [read $channel] \n] {
            if {$line eq ""} continue
            lassign $line kind in out
            dict incr multiset [list $kind $out]
            incr records
        }
        close $channel
    }
    return [list $records $multiset]
}

# The records of multiset A missing from multiset B (counted with
# multiplicity), printing the first few.
proc missing {suite label a b} {
    set count 0
    dict for {record n} $a {
        set m [expr {[dict exists $b $record] ? [dict get $b $record] : 0}]
        if {$n > $m} {
            incr count [expr {$n - $m}]
            if {$count <= 5} {
                puts "  $suite: only in $label: $record ($n vs $m)"
            }
        }
    }
    return $count
}

set same 1
foreach suite $suites {
    lassign [load [file join $a $suite]] ra ma
    lassign [load [file join $b $suite]] rb mb
    set kinds [dict create]
    dict for {record n} $ma {
        dict incr kinds [lindex $record 0] $n
    }
    set onlyA [missing $suite A $ma $mb]
    set onlyB [missing $suite B $mb $ma]
    puts [format "%-7s records %6d / %6d (%s)  distinct outputs %5d / %5d  only in A %d  only in B %d" \
        $suite $ra $rb $kinds [dict size $ma] [dict size $mb] $onlyA $onlyB]
    if {$onlyA || $onlyB || $ra == 0} {
        set same 0
    }
}
puts [expr {$same ? "IDENTICAL" : "MISMATCH"}]
