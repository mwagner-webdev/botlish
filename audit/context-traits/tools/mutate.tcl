# mutate.tcl -- mutation testing of context traits, validator proofs, the
# Linux and Darwin I/O and path libraries and the portable io library
# (CONTEXT-TRAITS.md, MACOS-AARCH64-MILESTONE-8.md).
#
#   tclsh9.0 audit/context-traits/tools/mutate.tcl ?-only PATTERN,...?
#        ?-tests FILES? ?-fuzz-count N? ?-fuzz-seed N? ?-timeout SECONDS?
#
# Each mutant is a deliberate bug, written in mutants.txt (beside this
# script) as exact source replacements, each replaced text occurring exactly
# once. A mutant whose killing tests run only on some hosts (a `%% TARGET
# ...` line after its header: linux-x86_64, linux-aarch64, macos-aarch64 --
# Darwin I/O runs on macos-aarch64 only) is SKIPPED elsewhere, never counted
# as killed. -only selects mutants by name or glob pattern (`darwin-*`). For
# each, a private copy of the compiler and library (a temporary directory;
# native/target is a symlink to this checkout's, so the native backend is
# the built one) gets the replacements, and two detectors run against it:
#
#   * the test files FILES (default tests/context-traits.test,
#     tests/portable-io.test, tests/linux-path.test and
#     tests/darwin-io.test; each with a private -tmpdir): killed if any test
#     fails or a file does not complete;
#   * audit/context-traits/tools/fuzz.tcl -n N -seed S: killed if it reports
#     a disagreement or does not complete.
#
# A mutant both detectors miss SURVIVES; one whose text no longer occurs
# exactly once is NOT-APPLIED (never killed; it fails the run). The report
# lists each mutant, what killed it (failed test names, fuzz failures) and
# the survivors. Every command runs under this script's own timeout (no
# timeout(1): macOS has none). The real checkout is never modified.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

set options [dict create -only "" -tests {context-traits.test portable-io.test linux-path.test darwin-io.test} \
    -fuzz-count 25 -fuzz-seed 11 -timeout 1800]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

# This host's target, named as core::cabi names it (linux-x86_64,
# linux-aarch64, macos-aarch64).
set host [string cat [expr {$::tcl_platform(os) eq "Darwin" ? "macos" : [string tolower $::tcl_platform(os)]}] - \
    [expr {$::tcl_platform(machine) in {arm64 aarch64} ? "aarch64" : ($::tcl_platform(machine) in {amd64 x86_64} ? "x86_64" : $::tcl_platform(machine))}]]

# The mutants of mutants.txt (its header has the format), as
# {NAME DESCRIPTION HOSTS {FILE OLD NEW ...} ...}, HOSTS empty for every
# host.
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
                    if {$name ne ""} { lappend mutants $name $description $hosts $edits }
                    set name $n
                    set description $d
                    set hosts {}
                    set edits {}
                } elseif {[regexp {^%% (.*)$} $line -> h]} {
                    set hosts $h
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
    if {$name ne ""} { lappend mutants $name $description $hosts $edits }
    return $mutants
}
set mutants [readMutants [file join [file dirname [file normalize [info script]]] mutants.txt]]

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

# A private copy of the compiler sources, tests, library and the fuzzer.
set tree [file tempdir botlish-context-trait-mutants]
foreach dir {compiler core hir surface lib tests examples audit/context-traits} {
    file mkdir [file dirname [file join $tree $dir]]
    file copy [file join $root $dir] [file join $tree $dir]
}
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

# {STATUS OUTPUT} of ARGS, its standard error merged into its output;
# STATUS is "timeout" (the process killed) when it runs longer than TIMEOUT
# seconds (audit/c-ffi/tools/mutate.tcl's run).
proc run {timeout args} {
    set pipe [open |[concat $args [list 2>@1]] r]
    fconfigure $pipe -blocking 0 -translation lf -encoding utf-8
    set ::runOutput ""
    set ::runDone 0
    fileevent $pipe readable [list apply {{pipe} {
        append ::runOutput [read $pipe]
        if {[eof $pipe]} { set ::runDone 1 }
    }} $pipe]
    set timer [after [expr {$timeout * 1000}] {set ::runDone timeout}]
    vwait ::runDone
    after cancel $timer
    if {$::runDone eq "timeout"} {
        catch {exec kill -9 {*}[pid $pipe]}
        catch {close $pipe}
        return [list timeout $::runOutput]
    }
    fconfigure $pipe -blocking 1
    set status 0
    if {[catch {close $pipe} message options]} {
        set status [lindex [dict get $options -errorcode] end]
        if {![string is integer -strict $status]} { set status 1 }
    }
    return [list $status $::runOutput]
}

# 1 if mutant NAME is one -only selects (every one when -only is empty).
proc selected {name} {
    set only [split [dict get $::options -only] ,]
    if {$only eq {}} {
        return 1
    }
    foreach pattern $only {
        if {[string match $pattern $name]} {
            return 1
        }
    }
    return 0
}

set results {}
try {
    foreach {name description hosts edits} $mutants {
        if {![selected $name]} continue
        if {$hosts ne {} && $host ni $hosts} {
            lappend results [list $name $description SKIPPED "" ""]
            puts "SKIPPED $name: its killing tests do not run on $host"
            continue
        }
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
            lappend results [list $name $description NOT-APPLIED "" ""]
            puts "NOT-APPLIED $name: the text to replace does not occur exactly once in $file"
            dict for {file text} $touched {
                writeFile [file join $tree $file] $text
            }
            continue
        }
        set failedTests {}
        set incomplete ""
        foreach testFile [dict get $options -tests] {
            set tmp [file tempdir botlish-context-trait-mutant-run]
            lassign [run [dict get $options -timeout] tclsh9.0 [file join $tree tests $testFile] -tmpdir $tmp] status output
            file delete -force $tmp
            foreach {- n} [regexp -all -inline -line {^==== (\S+) .*FAILED$} $output] {
                lappend failedTests $n
            }
            if {![regexp {Total\s+\d+\s+Passed\s+\d+\s+Skipped\s+\d+\s+Failed\s+(\d+)} $output]} {
                append incomplete "$testFile: [string range [lindex [split [string trim $output] \n] end] 0 120]; "
            }
        }
        set failedTests [lsort -unique $failedTests]
        if {$incomplete ne ""} {
            set tests "killed (did not complete: $incomplete)"
        } elseif {$failedTests ne {}} {
            set tests "killed ([llength $failedTests] failed: [join [lrange $failedTests 0 5] {, }][expr {[llength $failedTests] > 6 ? ", ..." : ""}])"
        } else {
            set tests survived
        }
        lassign [run [dict get $options -timeout] tclsh9.0 [file join $tree audit context-traits tools fuzz.tcl] \
            -n [dict get $options -fuzz-count] -seed [dict get $options -fuzz-seed]] status output
        if {[regexp {programs \d+ disagreements (\d+)} [lindex [split [string trim $output] \n] end] -> n]} {
            set fuzz [expr {$n > 0 ? "killed ($n of [dict get $options -fuzz-count] programs disagree)" : "survived"}]
        } else {
            set fuzz "killed (did not complete: [string range [lindex [split [string trim $output] \n] end] 0 120])"
        }
        set verdict [expr {[string match killed* $tests] || [string match killed* $fuzz] ? "KILLED" : "SURVIVED"}]
        lappend results [list $name $description $verdict $tests $fuzz]
        puts "$verdict $name\n    tests: $tests\n    fuzz:  $fuzz"
        flush stdout
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
set skipped [llength [lsearch -all -index 2 $results SKIPPED]]
puts "[llength $results] mutants, $killed killed, [llength $survivors] survived[expr {$survivors eq {} ? "" : ": [join $survivors {, }]"}], $skipped skipped (on $host)[expr {$unapplied eq {} ? "" : ", [llength $unapplied] not applied: [join $unapplied {, }]"}]"
exit [expr {$survivors ne {} || $unapplied ne {}}]
