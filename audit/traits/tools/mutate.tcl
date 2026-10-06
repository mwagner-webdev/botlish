# mutate.tcl -- mutation testing of eager structural traits (TRAITS.md).
#
#   tclsh9.0 audit/traits/tools/mutate.tcl ?-only NAME,...? ?-fuzz-count N? ?-fuzz-seed N? ?-timeout SECONDS?
#
# Each mutant is a deliberate bug in the trait implementation, written in
# mutants.txt (beside this script) as exact source replacements, each
# replaced text occurring exactly once. For each, a private copy of the compiler (a temporary directory;
# native/target is a symlink to this checkout's, so the native backend is the
# built one) gets the replacements, and two detectors run against it:
#
#   * tests/traits.test (with a private -tmpdir): killed if any test fails or
#     the file does not complete;
#   * audit/traits/tools/fuzz.tcl -count N -seed S: killed if it reports a
#     failure or does not complete.
#
# A mutant both detectors miss SURVIVES; the report lists each mutant, what
# killed it (failed test names, fuzz failures) and the survivors. The real
# checkout is never modified.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

set options [dict create -only "" -fuzz-count 40 -fuzz-seed 11 -timeout 900]
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

# A private copy of the compiler sources, tests and the trait fuzzer.
set tree [file tempdir botlish-trait-mutants]
foreach dir {compiler core hir surface lib tests audit/traits} {
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

proc run {timeout args} {
    set status 0
    if {[catch {exec timeout $timeout {*}$args 2>@1} output options]} {
        set status [lindex [dict get $options -errorcode] end]
        if {![string is integer -strict $status]} { set status 1 }
        regsub {\n?child process exited abnormally$} $output "" output
    }
    return [list $status $output]
}

set only [split [dict get $options -only] ,]
set results {}
try {
    foreach {name description edits} $mutants {
        if {$only ne {} && $name ni $only} continue
        set touched [dict create]
        foreach {file old new} $edits {
            set path [file join $tree $file]
            if {![dict exists $touched $file]} {
                dict set touched $file [readFile $path]
            }
            set text [readFile $path]
            set first [string first $old $text]
            if {$first < 0 || [string first $old $text [expr {$first + 1}]] >= 0} {
                error "mutant $name: the text to replace does not occur exactly once in $file"
            }
            writeFile $path [string replace $text $first [expr {$first + [string length $old] - 1}] $new]
        }
        set tmp [file tempdir botlish-trait-mutant-run]
        lassign [run [dict get $options -timeout] tclsh9.0 [file join $tree tests traits.test] -tmpdir $tmp] status output
        file delete -force $tmp
        set failed [regexp -all -inline -line {^==== (trait-\S+) } $output]
        set failed [lsort -unique [lmap {- n} $failed {set n}]]
        if {[regexp {Total\s+\d+\s+Passed\s+\d+\s+Skipped\s+\d+\s+Failed\s+(\d+)} $output -> n]} {
            set tests [expr {$n > 0 ? "killed ($n failed: [join [lrange $failed 0 5] {, }][expr {[llength $failed] > 6 ? ", ..." : ""}])" : "survived"}]
        } else {
            set tests "killed (did not complete: [string range [lindex [split [string trim $output] \n] end] 0 120])"
        }
        lassign [run [dict get $options -timeout] tclsh9.0 [file join $tree audit traits tools fuzz.tcl] \
            -count [dict get $options -fuzz-count] -seed [dict get $options -fuzz-seed]] status output
        if {[regexp {(\d+) failures} [lindex [split [string trim $output] \n] end] -> n]} {
            set fuzz [expr {$n > 0 ? "killed ($n of [dict get $options -fuzz-count] programs fail)" : "survived"}]
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
puts "[llength $results] mutants, [expr {[llength $results] - [llength $survivors]}] killed, [llength $survivors] survived[expr {$survivors eq {} ? "" : ": [join $survivors {, }]"}]"
