#!/usr/bin/env tclsh9.0
# mutate.tcl -- mutation testing of restricted context injection
# (RESTRICTED-CONTEXT-INJECTION-MILESTONE-1.md, "Mutation testing").
#
#   tclsh9.0 audit/restricted-injection/tools/mutate.tcl ?-only NAME,...?
#                                                        ?-tests FILES?
#                                                        ?-timeout SECONDS?
#
# Each mutant is a deliberate bug in the restriction -- the injected set,
# the transitive requirement it is checked against, nesting, grants,
# context parameters, direct mediation, the coroutine provenance analysis,
# the syntax, HIR text -- written in mutants.txt (beside this script) as
# exact source replacements, each replaced text occurring exactly once, with
# a `!!` line naming the tests meant to detect it. For each, a private copy
# of the compiler, library and tests (a temporary directory) gets the
# replacements and the test files FILES run against it (default
# tests/restricted-injection.test, each with a private -tmpdir). A mutant is
# KILLED when one of its named detectors fails (or a file does not
# complete); a mutant only other tests catch is reported UNTARGETED, one no
# test catches SURVIVES. No mutant edits Rust, so the copy's native/target
# is a link to this checkout's. The real checkout is never modified.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

set options [dict create -only "" -tests tests/restricted-injection.test -timeout 1800]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

# The mutants of mutants.txt (its header has the format), as
# {NAME DESCRIPTION {FILE OLD NEW ...} DETECTORS ...}.
proc readMutants {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8 -translation lf
    set lines [split [read $f] \n]
    close $f
    set mutants {}
    set name ""
    set state outside
    foreach line $lines {
        switch -- $state {
            outside {
                if {[regexp {^@@ (\S+) (.*)$} $line -> n d]} {
                    if {$name ne ""} { lappend mutants $name $description $edits $detectors }
                    set name $n
                    set description $d
                    set edits {}
                    set detectors {}
                } elseif {[regexp {^!! (.*)$} $line -> names]} {
                    lappend detectors {*}$names
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
    if {$name ne ""} { lappend mutants $name $description $edits $detectors }
    return $mutants
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

proc isNative {edits} {
    foreach {file old new} $edits {
        if {[string match native/src/* $file] || [string match native/Cargo.* $file]} {
            return 1
        }
    }
    return 0
}

# Selected mutants, Tcl-only ones first.
set only [split [dict get $options -only] ,]
set selected {}
set nativeSelected {}
foreach {name description edits detectors} [readMutants [file join [file dirname [file normalize [info script]]] mutants.txt]] {
    if {$only ne {} && $name ni $only} continue
    if {$detectors eq {}} {
        error "mutant $name names no detector (a \"!! TEST ...\" line)"
    }
    if {[isNative $edits]} {
        error "mutant $name edits Rust: this harness never rebuilds the native backend"
    }
    lappend selected $name $description $edits $detectors
}
set selected [concat $selected $nativeSelected]

# A private copy of the compiler sources, tests, library, the context audit
# tools and the native backend. Its native/target is a real copy when a
# native mutant is selected (it is rebuilt), else a link to this checkout's.
set tree [file tempdir botlish-restricted-injection-mutants]
foreach dir {compiler core hir surface service lsp stdlib tests examples compilerpedia audit/static-decisions .cargo} {
    if {![file exists [file join $root $dir]]} continue
    file mkdir [file dirname [file join $tree $dir]]
    file copy [file join $root $dir] [file join $tree $dir]
}
file mkdir [file join $tree native]
foreach entry [glob -directory [file join $root native] *] {
    if {[file tail $entry] ne "target"} {
        file copy $entry [file join $tree native]
    } elseif {$nativeSelected ne {}} {
        # Copy the directory, following links: when native/target links to
        # another checkout's (AGENTS.md, "Running tests concurrently"), a
        # copied link would build every native mutant into that checkout.
        while {[file type $entry] eq "link"} {
            set entry [file join [file dirname $entry] [file readlink $entry]]
        }
        exec cp -a $entry [file join $tree native target]
    } else {
        file link -symbolic [file join $tree native target] $entry
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

proc lastLine {output} {
    return [string range [lindex [split [string trim $output] \n] end] 0 120]
}

# The unmutated copy must pass every test file: a mutant counts as killed
# only against a baseline that completes (a file that cannot even load in
# the copy would "kill" every mutant).
foreach testFile [dict get $options -tests] {
    set tmp [file tempdir botlish-restricted-injection-baseline]
    lassign [run [dict get $options -timeout] tclsh9.0 [file join $tree $testFile] -tmpdir $tmp] status output
    file delete -force $tmp
    if {![regexp {Total\s+\d+\s+Passed\s+\d+\s+Skipped\s+\d+\s+Failed\s+0} $output]} {
        file delete -force $tree
        puts "BASELINE FAILS: [file tail $testFile] does not pass unmutated in the copy: [lastLine $output]"
        exit 2
    }
}

set results {}
try {
    foreach {name description edits detectors} $selected {
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
                break
            }
            writeFile $path [string replace $text $first [expr {$first + [string length $old] - 1}] $new]
        }
        if {!$applied} {
            # The code the mutant edits changed: update mutants.txt.
            lappend results [list $name $description NOT-APPLIED ""]
            puts "NOT-APPLIED $name: the text to replace does not occur exactly once in $file"
            dict for {file text} $touched {
                writeFile [file join $tree $file] $text
            }
            continue
        }
        set failedTests {}
        set incomplete ""
        foreach testFile [dict get $options -tests] {
            set tmp [file tempdir botlish-restricted-injection-mutant-run]
            lassign [run [dict get $options -timeout] tclsh9.0 [file join $tree $testFile] -tmpdir $tmp] status output
            file delete -force $tmp
            lappend failedTests {*}[lmap {- n} [regexp -all -inline -line {^==== (\S+) .*FAILED$} $output] {set n}]
            if {$incomplete eq "" && ![regexp {Total\s+\d+\s+Passed\s+\d+\s+Skipped\s+\d+\s+Failed\s+(\d+)} $output]} {
                set incomplete "[file tail $testFile]: [lastLine $output]"
            }
        }
        set failedTests [lsort -unique $failedTests]
        set targeted [lmap t $failedTests {if {$t in $detectors} {set t} else {continue}}]
        if {$incomplete ne ""} {
            set verdict KILLED
            set tests "did not complete: $incomplete"
        } elseif {$targeted ne {}} {
            set verdict KILLED
            set tests "[llength $failedTests] failed, the named [join $targeted {, }] among them"
        } elseif {$failedTests ne {}} {
            set verdict UNTARGETED
            set tests "[llength $failedTests] failed ([join [lrange $failedTests 0 5] {, }]), none of the named [join $detectors {, }]"
        } else {
            set verdict SURVIVED
            set tests "no test failed"
        }
        lappend results [list $name $description $verdict $tests]
        puts "$verdict $name -- $description\n    tests: $tests"
        flush stdout
        dict for {file text} $touched {
            writeFile [file join $tree $file] $text
        }
    }
} finally {
    file delete -force $tree
}

set failed [lmap r $results {if {[lindex $r 2] eq "KILLED"} continue; lindex $r 0}]
set killed [llength [lsearch -all -index 2 $results KILLED]]
puts "[llength $results] mutants, $killed killed by a named detector[expr {$failed eq {} ? "" : ", not killed so: [join $failed {, }]"}]"
exit [expr {$failed ne {}}]
