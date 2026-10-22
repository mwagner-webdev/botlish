#!/usr/bin/env tclsh9.0
# census.tcl -- every `hash` call of the repository's Botlish programs, by how
# the admission rule treats its argument (HASHABLE-AND-KEYED-HASH.md, "Public
# hash admission").
#
#   tclsh9.0 audit/hashable/tools/census.tcl ?FILE.bot ...?
#
# Without arguments: every .bot file under examples/, tests/golden/,
# bench/, audit/hash-table/ and audit/refactor/kickoff-corpus/ that calls
# `hash`. Each is compiled as a program (with its own directory as the
# application root); a file that is no program on its own (a module) is
# reported as such. Per file: the hash calls whose argument is Hashable
# (total: hashtotal), statically unknown (dynamic: the fallible hash) and
# statically not Hashable (rejected: TRAIT-NOT-SATISFIED, only in a file that
# no longer compiles), and the argument types of the dynamic ones.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set files $argv
set argv {}
source [file join $root tests helpers.tcl]
source [file join $root surface surface.tcl]

if {$files eq {}} {
    foreach dir {examples tests/golden bench audit/hash-table audit/refactor/kickoff-corpus} {
        foreach f [exec find [file join $root $dir] -name *.bot] {
            if {[regexp {(^|[^_a-zA-Z.:])hash\(} [core::ReadFile $f]]} {
                lappend files $f
            }
        }
    }
}

set totals [dict create total 0 dynamic 0 rejected 0 modules 0 files 0]
foreach f [lsort $files] {
    set rel [string range $f [string length $root/] end]
    if {[catch {surface::readProgramFile $f -warnings off -strict 0} hir]} {
        puts [format "%-60s not a program on its own (%s)" $rel [lindex [split $hir \n] 0]]
        dict incr totals modules
        continue
    }
    dict incr totals files
    set counts [dict create total 0 dynamic 0 rejected 0]
    set dynamicTypes {}
    foreach e [hirFind $hir call] {
        lassign [hir::get $hir $e target] kind target
        if {$kind ne "native" || [dict get [hir::symbol $hir $target] name] ne "hash"} continue
        set arg [lindex [hir::get $hir $e args] 0]
        set type [hir::typeOf $hir $arg]
        switch -- [lindex [hir::types::HashClass $type] 0] {
            total { dict incr counts total }
            unknown { dict incr counts dynamic; lappend dynamicTypes [hir::types::show $type] }
            none { dict incr counts rejected }
        }
    }
    dict for {k n} $counts {
        dict incr totals $k $n
    }
    puts [format "%-60s total %3d dynamic %3d rejected %d%s" $rel [dict get $counts total] \
        [dict get $counts dynamic] [dict get $counts rejected] \
        [expr {$dynamicTypes eq {} ? "" : "   dynamic: [join [lsort -unique $dynamicTypes] {, }]"}]]
}
puts "programs [dict get $totals files] (and [dict get $totals modules] files that are no program on their own): hash calls total [dict get $totals total], dynamic [dict get $totals dynamic], rejected [dict get $totals rejected]"
