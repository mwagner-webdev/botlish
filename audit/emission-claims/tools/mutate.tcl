# mutate.tcl -- mutation testing of emission claims (EMISSION-CLAIMS-
# MILESTONE-1.md, "Mutation results"): the checker's own proof rules
# (hir/emission.tcl, hir/emitdfa.tcl), the recognizer outcome model
# (core/dfa.tcl), the value facts certificates rest on (hir/intset.tcl and
# the hir::range transfers it lifts, native result sets), and the trust
# boundary (re-verification of text, the in-process memo).
#
#   tclsh9.0 audit/emission-claims/tools/mutate.tcl ?-only NAME,...?
#       ?-timeout SECONDS? ?-check 1? ?-out FILE?
#
# Each mutant of mutants.txt (beside this script; its header has the
# format) is a deliberate bug written as exact replacements, each replaced
# text occurring exactly once. For each, a private copy of the compiler (a
# temporary directory; native/target a symlink to this checkout's: no
# mutant edits the native crate) gets the replacements, and the tests its
# `%% match` names run against it (tests/emission-claims.test and
# tests/interval-sets.test, each with a private -tmpdir); when they all
# pass, both files run whole. A mutant is killed when a test fails or a file
# does not complete; it SURVIVES otherwise. -check 1 only checks that every
# mutant still applies. The real checkout is never modified.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -only "" -timeout 1500 -check 0 -out ""]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

proc readFile {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8 -translation lf
    set text [read $f]
    close $f
    return $text
}

proc writeFile {path text} {
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
    foreach line [split [readFile $path] \n] {
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

set mutants [readMutants [file join [file dirname [file normalize [info script]]] mutants.txt]]

# A private copy of the compiler, its tests and what they read.
set tree [file tempdir botlish-emission-mutants]
foreach dir {compiler core hir surface stdlib tests service lsp compilerpedia} {
    file copy [file join $root $dir] [file join $tree $dir]
}
file mkdir [file join $tree examples dfa] [file join $tree audit]
file copy [file join $root examples dfa json] [file join $tree examples dfa json]
file copy [file join $root audit emission-claims] [file join $tree audit emission-claims]
file mkdir [file join $tree native]
foreach entry [glob -directory [file join $root native] *] {
    if {[file tail $entry] eq "target"} {
        file link -symbolic [file join $tree native target] $entry
    } else {
        file copy $entry [file join $tree native]
    }
}
foreach entry [glob -directory $root -types f *.tcl] {
    file copy $entry $tree
}

proc run {timeout args} {
    set status 0
    if {[catch {exec timeout $timeout {*}$args 2>@1} output options]} {
        set status [lindex [dict get $options -errorcode] end]
        if {![string is integer -strict $status]} { set status 1 }
        regsub {\n?child process exited abnormally$} $output "" output
    }
    return [list $status $output]
}

# {KILLED DETAIL} of running the test files against the tree, with MATCH
# (tcltest -match patterns, "" for every test).
proc Tests {match} {
    global tree options
    set failed {}
    set incomplete ""
    foreach file {emission-claims interval-sets} {
        set tmp [file tempdir botlish-emission-mutant-run]
        set args [list tclsh9.0 [file join $tree tests $file.test] -tmpdir $tmp]
        if {$match ne ""} {
            lappend args -match $match
        }
        lassign [run [dict get $options -timeout] {*}$args] status output
        file delete -force $tmp
        foreach {- n} [regexp -all -inline -line {^==== (\S+) .*FAILED$} $output] {
            lappend failed $n
        }
        if {![regexp {Total\s+\d+\s+Passed\s+\d+\s+Skipped\s+\d+\s+Failed\s+\d+} $output]} {
            set incomplete "$file.test did not complete: [string range [lindex [split [string trim $output] \n] end] 0 120]"
        }
    }
    set failed [lsort -unique $failed]
    if {$failed ne {}} {
        return [list 1 "failed: [join [lrange $failed 0 5] {, }][expr {[llength $failed] > 6 ? ", ..." : ""}]"]
    }
    if {$incomplete ne ""} {
        return [list 1 $incomplete]
    }
    return [list 0 ""]
}

set only [split [dict get $options -only] ,]
set results {}
try {
    foreach mutant $mutants {
        lassign $mutant name description match edits
        if {$only ne {} && $name ni $only} continue
        set touched [dict create]
        set applied 1
        foreach {file old new} $edits {
            set path [file join $tree $file]
            if {![dict exists $touched $file]} {
                dict set touched $file [readFile $path]
            }
            set text [readFile $path]
            set first [string first $old $text]
            if {$first < 0 || [string first $old $text [expr {$first + 1}]] >= 0} {
                set applied 0
                set missing $file
                break
            }
            writeFile $path [string replace $text $first [expr {$first + [string length $old] - 1}] $new]
        }
        if {!$applied} {
            lappend results [list $name $description NOT-APPLIED "the text to replace does not occur exactly once in $missing"]
            puts "NOT-APPLIED $name: the text to replace does not occur exactly once in $missing"
        } elseif {[dict get $options -check]} {
            lappend results [list $name $description APPLIES ""]
        } else {
            set t0 [clock seconds]
            lassign [Tests $match] killed detail
            set how "match"
            if {!$killed && $match ne ""} {
                lassign [Tests ""] killed detail
                set how "whole files"
            }
            set verdict [expr {$killed ? "KILLED" : "SURVIVED"}]
            set detail "$how, [expr {[clock seconds] - $t0}] s: $detail"
            lappend results [list $name $description $verdict $detail]
            puts "$verdict $name ($detail)"
            flush stdout
        }
        dict for {file text} $touched {
            writeFile [file join $tree $file] $text
        }
    }
} finally {
    file delete -force $tree
}

set survivors [lmap r $results {if {[lindex $r 2] ne "SURVIVED"} continue; lindex $r 0}]
set unapplied [lmap r $results {if {[lindex $r 2] ne "NOT-APPLIED"} continue; lindex $r 0}]
set killed [llength [lsearch -all -index 2 $results KILLED]]
set summary "[llength $results] mutants, $killed killed, [llength $survivors] survived[expr {$survivors eq {} ? "" : ": [join $survivors {, }]"}][expr {$unapplied eq {} ? "" : ", [llength $unapplied] not applied: [join $unapplied {, }]"}]"
puts $summary
if {[dict get $options -out] ne ""} {
    set lines [list "## Mutants" "" $summary "" "| mutant | rule | result |" "|---|---|---|"]
    foreach r $results {
        lassign $r name description verdict detail
        lappend lines "| `$name` | $description | [string tolower $verdict] ($detail) |"
    }
    writeFile [dict get $options -out] "[join $lines \n]\n"
}
exit [expr {$survivors ne {} || $unapplied ne {}}]
