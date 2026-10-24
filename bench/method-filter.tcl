#!/usr/bin/env tclsh9.0
# method-filter.tcl -- what the kind proofs of the method-call decision save
# (METHOD-DECISION-FILTER.md, "Performance";
# METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md, "Economics").
#
#   tclsh9.0 bench/method-filter.tcl ?-reference 1? ?-audit 1? FILE.bot ...
#   tclsh9.0 bench/method-filter.tcl ... -suites ?SUITES?
#
# -suites alone is the golden suites that decide method calls; with a list
# (one argument: names separated by spaces or commas, `.bot` optional) those
# suites.
#
# Each program is compiled in a process of its own with the kind proofs (the
# default decision): its whole-program builds, the method trial builds among
# them, the single deviations among those, the final programs built again,
# the builds read from a record, and the front end's time. -reference 1
# compiles it again by the reference rule (hir::methodKindProofs 0: every
# candidate judged by its own build) and prints its builds, trials and time
# beside them. -audit 1 compiles it under hir::methodReferenceAudit, which
# decides by both rules and fails on any difference.
#
# The numbers in the documents were measured with this tool on the sandbox's
# four cores; the build counts are exact, the times are not.

set root [file dirname [file dirname [file normalize [info script]]]]

set suites {callable-contracts collection-iteration collections declared-errors
    destructuring diagnostics float64 framework-semantics imports
    method-equivalence-imported methods mutable-array mutable-map mutable-set
    mutable-vector numeric-text ownership place-parameters recursive-types
    refinements static-compile stdlib-namespaces structs-and-enums traits
    variadics}

set counters {builds methodTrials methodDeviations methodFinals methodReused}

proc one {file mode} {
    global root counters
    source [file join $root core core.tcl]
    source [file join $root surface surface.tcl]
    interp recursionlimit {} 100000
    set hir::methodKindProofs [expr {$mode ne "reference"}]
    set hir::methodReferenceAudit [expr {$mode eq "audit"}]
    set before [hir::BuildStats]
    set start [clock milliseconds]
    if {[catch {surface::readProgramFile $file -strict 0 -warnings off -cache ""} message]} {
        puts "RESULT error [string map {\n { }} [string range $message 0 160]]"
        return
    }
    set ms [expr {[clock milliseconds] - $start}]
    set after [hir::BuildStats]
    set fields {}
    foreach counter $counters {
        lappend fields $counter [expr {[dict get $after $counter] - [dict get $before $counter]}]
    }
    puts "RESULT ok $fields ms $ms audits $hir::methodReferenceAudits"
}

proc measure {file mode} {
    set output [exec [info nameofexecutable] [info script] -one $file $mode 2>@1]
    foreach line [split $output \n] {
        if {[string match "RESULT *" $line]} {
            return [lrange $line 1 end]
        }
    }
    return [list error $output]
}

set args $argv
if {[lindex $args 0] eq "-one"} {
    one [lindex $args 1] [lindex $args 2]
    exit
}
set reference 0
set audit 0
set files {}
while {$args ne ""} {
    set arg [lindex $args 0]
    switch -- $arg {
        -reference { set reference [lindex $args 1]; set args [lrange $args 2 end] }
        -audit { set audit [lindex $args 1]; set args [lrange $args 2 end] }
        -suites {
            set names $suites
            set next [lindex $args 1]
            set args [lrange $args 1 end]
            # (A list of suites, not a file: no leading "-", no "/".)
            if {[llength $args] > 0 && ![string match -* $next] && [string first / $next] < 0} {
                set names [lmap n [split [string map {, " "} $next]] {
                    if {$n eq ""} continue
                    file rootname $n
                }]
                set args [lrange $args 1 end]
            }
            foreach s $names { lappend files [file join $root tests golden $s.bot] }
        }
        default { lappend files $arg; set args [lrange $args 1 end] }
    }
}
if {$files eq ""} {
    puts stderr "usage: method-filter.tcl ?-reference 1? ?-audit 1? (-suites ?SUITES? | FILE.bot ...)"
    exit 2
}

puts [format "%-30s %7s %7s %5s %6s %6s %8s  %s" program builds trials devs finals reused ms \
    [if {$reference} {string cat "reference builds/trials/ms"} else {string cat ""}]]
set totals [dict create ms 0 refBuilds 0 refTrials 0 refMs 0]
foreach counter $counters { dict set totals $counter 0 }
set problems 0
foreach file $files {
    set kind [measure $file kind]
    if {[lindex $kind 0] ne "ok"} {
        puts [format "%-30s %s" [file tail $file] [lrange $kind 0 3]]
        incr problems
        continue
    }
    set k [dict create {*}[lrange $kind 1 end]]
    set note ""
    if {$reference} {
        set ref [measure $file reference]
        if {[lindex $ref 0] ne "ok"} {
            append note "reference: [lrange $ref 0 3]"
            incr problems
        } else {
            set r [dict create {*}[lrange $ref 1 end]]
            append note [format "%5d/%-5d %8d" [dict get $r builds] [dict get $r methodTrials] [dict get $r ms]]
            dict incr totals refBuilds [dict get $r builds]
            dict incr totals refTrials [dict get $r methodTrials]
            dict incr totals refMs [dict get $r ms]
        }
    }
    if {$audit} {
        set a [measure $file audit]
        if {[lindex $a 0] ne "ok"} {
            append note "  AUDIT FAILED: [lrange $a 1 end]"
            incr problems
        } else {
            append note "  audited [dict get [dict create {*}[lrange $a 1 end]] audits]"
        }
    }
    puts [format "%-30s %7d %7d %5d %6d %6d %8d  %s" [file tail $file] \
        [dict get $k builds] [dict get $k methodTrials] [dict get $k methodDeviations] \
        [dict get $k methodFinals] [dict get $k methodReused] [dict get $k ms] $note]
    foreach counter [concat $counters ms] {
        dict incr totals $counter [dict get $k $counter]
    }
}
puts [format "%-30s %7d %7d %5d %6d %6d %8d  %s" total \
    [dict get $totals builds] [dict get $totals methodTrials] [dict get $totals methodDeviations] \
    [dict get $totals methodFinals] [dict get $totals methodReused] [dict get $totals ms] \
    [if {$reference} {format "%5d/%-5d %8d" [dict get $totals refBuilds] [dict get $totals refTrials] [dict get $totals refMs]} else {string cat ""}]]
exit [expr {$problems > 0}]
