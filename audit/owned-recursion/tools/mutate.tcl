# mutate.tcl -- mutation testing of the recursive-ownership analysis
# (OWNED-RECURSION-DECLARATION-SUMMARY-MILESTONE-1.md).
#
#   tclsh9.0 audit/owned-recursion/tools/mutate.tcl ?-only NAME,...?
#       ?-tests FILES? ?-fuzz-programs N? ?-fuzz-queries N? ?-fuzz-seed N?
#       ?-fuzz-runtime N? ?-timeout SECONDS? ?-memory KB?
#
# Each mutant is a deliberate bug, written in mutants.txt (beside this
# script) as exact source replacements, each replaced text occurring exactly
# once. For each, a private copy of the compiler and library (a temporary
# directory; native/target linked, never rebuilt: every mutant is Tcl) gets
# the replacements, and the detectors run against it:
#
#   * the test files FILES (default below; each with a private -tmpdir):
#     killed if any test fails or a file does not complete within the
#     timeout or the memory cap (-memory KB, a ulimit of each detector's
#     process: a mutant that brings back an unfolding never ends, and one
#     whose applications double exhausts memory -- never the machine's);
#   * audit/owned-recursion/tools/fuzz.tcl -programs N -queries Q -seed S
#     -runtime R: the compiler against the independent model (oracle.py),
#     the old walk's differences classified (reference.tcl), written types
#     and runtime releases: killed if it reports a failure or does not
#     complete.
#
# The detectors first run on the unmutated copy (the control): a detector
# that fails or does not complete there would kill every mutant, so the run
# stops.
# A mutant every detector misses SURVIVES; the report lists each mutant,
# what killed it and the survivors. The real checkout is never modified.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

set options [dict create -only "" -tests {tests/owned-recursion.test tests/affine-applications.test tests/written-affine-applications.test} -fuzz-programs 16 -fuzz-queries 8 -fuzz-seed 5 -fuzz-runtime 8 -timeout 900 -memory 3000000]
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

set only [split [dict get $options -only] ,]
set selected {}
foreach {name description edits} [readMutants [file join [file dirname [file normalize [info script]]] mutants.txt]] {
    if {$only ne {} && $name ni $only} continue
    lappend selected $name $description $edits
}

# A private copy of the compiler sources, tests, library and this audit.
set tree [file tempdir botlish-owned-recursion-mutants]
foreach dir {compiler core hir surface stdlib tests examples service lsp compilerpedia audit/owned-recursion .cargo} {
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

proc run {timeout args} {
    set status 0
    if {[catch {exec sh -c {ulimit -v "$0"; exec "$@"} [dict get $::options -memory] timeout $timeout {*}$args 2>@1} output caught]} {
        set status [lindex [dict get $caught -errorcode] end]
        if {![string is integer -strict $status]} { set status 1 }
        regsub {\n?child process exited abnormally$} $output "" output
    }
    return [list $status $output]
}

proc lastLine {output} {
    return [string range [lindex [split [string trim $output] \n] end] 0 120]
}

proc detect {tree {verbose 0}} {
    global options
    set failedTests {}
    set incomplete ""
    foreach testFile [dict get $options -tests] {
        set tmp [file tempdir botlish-owned-recursion-mutant-run]
        # (The fuzzer smoke test is the fuzzer detector's work here.)
        lassign [run [dict get $options -timeout] tclsh9.0 [file join $tree $testFile] -tmpdir $tmp -skip or-fuzz-smoke] status output
        file delete -force $tmp
        if {$verbose && [regexp -line {^==== (\S+) .*FAILED$} $output]} {
            puts $output
        }
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
    lassign [run [dict get $options -timeout] tclsh9.0 [file join $tree audit owned-recursion tools fuzz.tcl] \
        -programs [dict get $options -fuzz-programs] -queries [dict get $options -fuzz-queries] \
        -seed [dict get $options -fuzz-seed] -runtime [dict get $options -fuzz-runtime] -native 0] status output
    if {[regexp {, (\d+) failures$} [lindex [split [string trim $output] \n] end] -> n]} {
        set fuzz [expr {$n > 0 ? "killed ($n failures)" : "survived"}]
    } else {
        set fuzz "killed (did not complete: [lastLine $output])"
    }
    return [list $tests $fuzz]
}

set results {}
try {
    set start [clock seconds]
    lassign [detect $tree 1] tests fuzz
    puts "CONTROL (no mutant, [expr {[clock seconds] - $start}] s) -- tests: $tests; fuzz: $fuzz"
    flush stdout
    if {$tests ne "survived" || $fuzz ne "survived"} {
        puts "the detectors do not pass on the unmutated copy: no mutant can be judged"
        file delete -force $tree
        exit 2
    }
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
        lassign [detect $tree] tests fuzz
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
