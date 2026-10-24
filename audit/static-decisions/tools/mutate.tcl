# mutate.tcl -- mutation testing of the static decision schedulers
# (STATIC-COMPILE.md, "Decision economics").
#
#   tclsh9.0 audit/static-decisions/tools/mutate.tcl ?-only NAME,...? ?-tests FILES?
#                                         ?-fuzz-count N? ?-fuzz-seed N?
#                                         ?-timeout SECONDS?
#
# Each mutant is a deliberate bug in the scheduler (hir/static.tcl), its
# dependency analysis (hir/staticdeps.tcl), the method-call decisions'
# reuse (hir/methods.tcl) or the demotion re-check's reuse of the check before
# it (hir::check, hir::signatures::infer), written in mutants.txt beside
# this script in the format of audit/static-compile/tools/mutants.txt. Two
# kinds:
#
#   semantic     the batched scheduler decides another program than the
#                sequential one (a dependency missed, a decision reused
#                stale, a message from the wrong build): killed by the
#                equality tests and the fuzzer's differential;
#   economic     the decisions stay right but the builds grow (a dependency
#                invented, a batch cut short, a reuse refused): killed by the
#                deterministic build-count tests and the fuzzer's bound --
#                the milestone's contract is economic, so these are bugs.
#
# For each, a private copy of the compiler, library and tests (a temporary
# directory; native/target a link to this checkout's) gets the replacements
# and the detectors run against it:
#
#   * the test files FILES (default tests/static-economics.test, with a
#     private -tmpdir): killed if any test fails or the file does not
#     complete;
#   * audit/static-decisions/tools/fuzz.tcl -n N -seed S -legacy 0: killed if
#     it reports a failure or does not complete.
#
# The real checkout is never modified.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

set options [dict create -only "" -tests {tests/static-economics.test} -fuzz-count 6 -fuzz-seed 5 -timeout 2400]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

# The mutants of mutants.txt (its header has the format), as
# {NAME DESCRIPTION {FILE OLD NEW ...} ...}.
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
                    if {$name ne ""} { lappend mutants $name $description $edits }
                    set name $n
                    set description $d
                    set edits {}
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
    if {$name ne ""} { lappend mutants $name $description $edits }
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


set only [split [dict get $options -only] ,]
set selected {}
foreach {name description edits} [readMutants [file join [file dirname [file normalize [info script]]] mutants.txt]] {
    if {$only ne {} && $name ni $only} continue
    lappend selected $name $description $edits
}

set tree [file tempdir botlish-static-decisions-mutants]
foreach dir {compiler core hir surface stdlib tests examples audit/static-decisions .cargo} {
    if {![file exists [file join $root $dir]]} continue
    file mkdir [file dirname [file join $tree $dir]]
    file copy [file join $root $dir] [file join $tree $dir]
}
file mkdir [file join $tree native]
foreach entry [glob -directory [file join $root native] *] {
    if {[file tail $entry] ne "target"} {
        file copy $entry [file join $tree native]
    } else {
        file link -symbolic [file join $tree native target] $entry
    }
}
foreach entry [glob -directory $root -types f *.tcl] {
    file copy $entry $tree
}

set results {}
try {
    foreach {name description edits} $selected {
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
            set tmp [file tempdir botlish-static-decisions-mutant-run]
            lassign [run [dict get $options -timeout] tclsh9.0 [file join $tree $testFile] -tmpdir $tmp] status output
            file delete -force $tmp
            lappend failedTests {*}[lmap {- n} [regexp -all -inline -line {^==== (\S+) .*FAILED$} $output] {set n}]
            if {$incomplete eq "" && ![regexp {Total\s+\d+\s+Passed\s+\d+\s+Skipped\s+\d+\s+Failed\s+(\d+)} $output]} {
                set incomplete "[file tail $testFile]: [lastLine $output]"
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
        set scratch [file tempdir botlish-static-decisions-mutant-fuzz]
        set here [pwd]
        cd $scratch
        lassign [run [dict get $options -timeout] tclsh9.0 [file join $tree audit static-decisions tools fuzz.tcl] \
            -n [dict get $options -fuzz-count] -seed [dict get $options -fuzz-seed] -legacy 0] status output
        cd $here
        file delete -force $scratch
        if {[regexp -line {^seed \d+: (\d+) programs, .* (\d+) failures$} $output -> programs n]} {
            set fuzz [expr {$n > 0 ? "killed ($n of $programs programs fail: [lastLine [lindex [regexp -all -inline -line {^    FAIL .*$} $output] 0]])" : "survived"}]
        } else {
            set fuzz "killed (did not complete: [lastLine $output])"
        }
        set verdict [expr {[string match killed* $tests] || [string match killed* $fuzz] ? "KILLED" : "SURVIVED"}]
        lappend results [list $name $description $verdict $tests $fuzz]
        puts "$verdict $name -- $description\n    tests: $tests\n    fuzz:  $fuzz"
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
puts "[llength $results] mutants, $killed killed, [llength $survivors] survived[expr {$survivors eq {} ? "" : ": [join $survivors {, }]"}][expr {$unapplied eq {} ? "" : ", [llength $unapplied] not applied: [join $unapplied {, }]"}]"
exit [expr {$survivors ne {} || $unapplied ne {}}]
