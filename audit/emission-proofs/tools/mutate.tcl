# mutate.tcl -- mutation testing of the modular emission checker
# (MODULAR-EMISSION-PROOFS-MILESTONE-1.md, section 15).
#
#   tclsh9.0 audit/emission-proofs/tools/mutate.tcl ?-only NAME,...? ?-out FILE?
#
# Each mutant of mutants.txt (beside this script) is a deliberate bug in a
# proof rule, written as exact replacements in the checker's sources. For
# each, a private copy of audit/emission-proofs/tools gets the
# replacements, and audit/emission-proofs/tests/emission-proofs.test runs
# against it (EMISSION_PROOFS_TOOLS), first the tests the mutant's `match`
# names, then -- when they all pass -- the whole file. A mutant is killed
# when a test fails or the file does not complete; it SURVIVES otherwise.
# The real tools are never modified.

set here [file dirname [file normalize [info script]]]
set root [file dirname [file dirname [file dirname $here]]]
set options [dict create -only "" -out ""]
foreach {option value} $argv {
    dict set options $option $value
}

proc readText {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8 -translation lf
    set t [read $f]
    close $f
    return $t
}

proc writeText {path text} {
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}

# {NAME DESCRIPTION MATCH {FILE OLD NEW ...}}...
proc readMutants {path} {
    set mutants {}
    set name ""
    set state outside
    foreach line [split [readText $path] \n] {
        switch -- $state {
            outside {
                if {[regexp {^@@ (\S+) (.*)$} $line -> n d]} {
                    if {$name ne ""} { lappend mutants [list $name $description $match $edits] }
                    set name $n
                    set description $d
                    set match ""
                    set edits {}
                } elseif {[regexp {^%% match (.*)$} $line -> m]} {
                    set match $m
                } elseif {[regexp {^## (\S+)$} $line -> file]} {
                    set current $file
                } elseif {$line eq "<<<<"} {
                    set state old
                    set old {}
                }
            }
            old {
                if {$line eq "===="} {
                    set state new
                    set new {}
                } else {
                    lappend old $line
                }
            }
            new {
                if {$line eq ">>>>"} {
                    lappend edits $current [join $old \n] [join $new \n]
                    set state outside
                } else {
                    lappend new $line
                }
            }
        }
    }
    if {$name ne ""} { lappend mutants [list $name $description $match $edits] }
    return $mutants
}

# Runs the test file against tools directory DIR: {PASSED FAILED NAMES}.
proc runTests {dir match} {
    set args [list [info nameofexecutable] [file join $::root audit emission-proofs tests emission-proofs.test]]
    if {$match ne ""} {
        lappend args -match $match
    }
    set ::env(EMISSION_PROOFS_TOOLS) $dir
    set ::env(EMISSION_PROOFS_ROOT) $::root
    set code [catch {exec env LANG=C.utf8 LC_ALL=C.utf8 {*}$args 2>@1} out]
    unset ::env(EMISSION_PROOFS_TOOLS)
    unset ::env(EMISSION_PROOFS_ROOT)
    if {![regexp {Total\s+(\d+)\s+Passed\s+(\d+)\s+Skipped\s+(\d+)\s+Failed\s+(\d+)} $out -> total passed skipped failed]} {
        set lines [split [string trim $out] \n]
        return [list 0 -1 [list "did not complete: [string range [lindex $lines 0] 0 160]"]]
    }
    set names [regexp -all -inline {==== (\S+) FAILED} $out]
    set names [lsort -unique [lmap {- n} $names {set n}]]
    return [list $passed $failed $names]
}

# The control: the unmutated tools, copied the same way, must pass the
# tests a mutant is first held to; otherwise every mutant would read as
# killed.
set control [file tempdir]
foreach f [glob -directory $here *.tcl] {
    file copy $f $control
}
lassign [runTests $control "ep-declared-domain ep-negation-holes ep-boundary-adjacent ep-store-reuse"] passed failed names
file delete -force $control
if {$failed != 0 || $passed != 4} {
    puts stderr "mutate.tcl: the unmutated copy does not pass ($passed passed, $failed failed: $names)"
    exit 2
}

set mutants [readMutants [file join $here mutants.txt]]
set only [split [dict get $options -only] ,]
set rows {}
set survivors {}
set killed 0
set total 0
foreach m $mutants {
    lassign $m name description match edits
    if {$only ne {} && $name ni $only} continue
    incr total
    set dir [file tempdir]
    foreach f [glob -directory $here *.tcl] {
        file copy $f $dir
    }
    file copy [file join $here mutants.txt] $dir
    set applies 1
    foreach {file old new} $edits {
        set path [file join $dir $file]
        set text [readText $path]
        set at [string first $old $text]
        if {$at < 0 || [string first $old $text [expr {$at + 1}]] >= 0} {
            set applies 0
            break
        }
        writeText $path [string replace $text $at [expr {$at + [string length $old] - 1}] $new]
    }
    if {!$applies} {
        lappend rows "| `$name` | $description | DOES NOT APPLY |"
        lappend survivors $name
        file delete -force $dir
        continue
    }
    set t0 [clock seconds]
    lassign [runTests $dir $match] passed failed names
    set how "match"
    if {$failed == 0} {
        lassign [runTests $dir ""] passed failed names
        set how "whole file"
    }
    set secs [expr {[clock seconds] - $t0}]
    if {$failed != 0} {
        incr killed
        lappend rows "| `$name` | $description | killed ($how, ${secs} s): [join $names {, }] |"
    } else {
        lappend survivors $name
        lappend rows "| `$name` | $description | **SURVIVES** |"
    }
    puts "$name: [lindex $rows end]"
    file delete -force $dir
}
set report [list "## Mutants of the modular checker" "" "$killed of $total killed" "" \
    "| mutant | rule | result |" "|---|---|---|" {*}$rows]
if {$survivors ne {}} {
    lappend report "" "Surviving: [join $survivors {, }]"
}
set text [join $report \n]
if {[dict get $options -out] ne ""} {
    writeText [dict get $options -out] "$text\n"
}
puts $text
exit [expr {$survivors ne {}}]
