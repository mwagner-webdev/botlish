#!/usr/bin/env tclsh9.0
# mutate.tcl -- mutation testing of explicit external tools, target support
# packages and the artifact manifest
# (EXTERNAL-COMPILER-TOOLS-AND-TARGET-PACKAGES-MILESTONE-1.md, "Mutation
# testing").
#
#   tclsh9.0 audit/external-tools/tools/mutate.tcl ?-only NAME,...? ?-timeout SECONDS?
#
# Each mutant is a deliberate bug -- a tool run without being named, an
# ambiguity resolved by order, words joined into a shell command, a protocol
# or an exit status ignored, a target support package read for the host or
# accepted for another OS ABI or runtime ABI, a missing one replaced, a lock
# weakened, a tool package's dependencies resolved apart, a manifest without
# ownership or accepted for another build, an installation a tool changed,
# a generated caller that depends on its generator's tree or guesses a
# signature -- written in mutants.txt (beside this script) as exact source
# replacements, each replaced text occurring exactly once, with a `!!` line
# naming the tests of tests/external-tools.test meant to detect it. For each,
# a private copy of the compiler, the package manager, the experiment's
# sources and the tests (a temporary directory) gets the replacements, and
# the mutant's named tests run against it (tcltest -match, a private
# -tmpdir). A mutant is KILLED when one of them fails (or the file does not
# complete) and SURVIVES otherwise. No mutant edits Rust, so the copy's
# native/target is a link to this checkout's. The real checkout is never
# modified.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set testFile tests/external-tools.test

set options [dict create -only "" -timeout 1800]
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

# The mutants of mutants.txt (its header has the format), as
# {NAME DESCRIPTION {FILE OLD NEW ...} DETECTORS ...}.
proc readMutants {path} {
    set lines [split [readFile $path] \n]
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

set only [split [dict get $options -only] ,]
set selected {}
set allDetectors {}
foreach {name description edits detectors} [readMutants [file join [file dirname [file normalize [info script]]] mutants.txt]] {
    if {$only ne {} && $name ni $only} continue
    if {$detectors eq {}} {
        error "mutant $name names no detector (a \"!! TEST ...\" line)"
    }
    foreach {file old new} $edits {
        if {[string match native/src/* $file] || [string match native/Cargo.* $file]} {
            error "mutant $name edits Rust: this harness never rebuilds the native backend"
        }
    }
    lappend selected $name $description $edits $detectors
    lappend allDetectors {*}$detectors
}
set allDetectors [lsort -unique $allDetectors]

# The private copy.
set tree [file tempdir botlish-external-tools-mutants]
foreach dir {compiler core hir surface service lsp pm stdlib tests examples compilerpedia audit/external-tools} {
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
foreach entry [concat [glob -directory $root -types f *.tcl] [list [file join $root LICENSE]]] {
    file copy $entry $tree
}

proc run {timeout args} {
    set status 0
    if {[catch {exec timeout $timeout {*}$args 2>@1} output options]} {
        set status [lindex [dict get $options -errorcode] end]
        if {![string is integer -strict $status]} { set status 1 }
    }
    return [list $status $output]
}

# The named tests that failed in OUTPUT, and whether the file completed.
proc outcome {output detectors} {
    set failed {}
    foreach name $detectors {
        if {[regexp "==== $name \[^\\n\]*FAILED" $output] || [regexp "==== $name FAILED" $output]} {
            lappend failed $name
        }
    }
    set completed [regexp {Total\s+\d+\s+Passed\s+\d+\s+Skipped\s+\d+\s+Failed\s+\d+} $output]
    return [list $failed $completed]
}

# The unmutated copy must pass every detector: a mutant counts as killed
# only against a baseline that passes.
# (-verbose p lists each passed test: a detector its constraints skip on
# this host cannot kill anything here, and is named.)
set tmp [file tempdir botlish-external-tools-baseline]
lassign [run [dict get $options -timeout] tclsh9.0 [file join $tree $testFile] -tmpdir $tmp -match $allDetectors -verbose p] status output
file delete -force $tmp
lassign [outcome $output $allDetectors] failed completed
if {!$completed || $failed ne "" || ![regexp {Failed\s+0} $output]} {
    file delete -force $tree
    puts "BASELINE FAILS: the detectors do not pass unmutated in the copy ($failed):\n[string range $output end-2000 end]"
    exit 2
}
set skipped [lmap name $allDetectors {
    if {[regexp "\\+\\+\\+\\+ $name PASSED" $output]} continue
    set name
}]
if {$skipped ne ""} {
    puts "note: detectors skipped on this host (their constraints): [join $skipped {, }]: a mutant only they detect cannot be killed here"
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
        if {$applied} {
            set tmp [file tempdir botlish-external-tools-mutant]
            lassign [run [dict get $options -timeout] tclsh9.0 [file join $tree $testFile] -tmpdir $tmp -match $detectors] status output
            file delete -force $tmp
            lassign [outcome $output $detectors] failed completed
            if {!$completed} {
                set verdict KILLED
                set by "(the test file did not complete)"
            } elseif {$failed ne ""} {
                set verdict KILLED
                set by [join $failed ", "]
            } else {
                set verdict SURVIVES
                set by ""
            }
        } else {
            set verdict NOT-APPLIED
            set by "the text to replace does not occur exactly once in $file"
        }
        dict for {file text} $touched {
            writeFile [file join $tree $file] $text
        }
        lappend results [list $name $verdict $by]
        puts [format "%-26s %-11s %s" $name $verdict $by]
        flush stdout
    }
} finally {
    file delete -force $tree
}

set killed [llength [lsearch -all -index 1 $results KILLED]]
puts "$killed/[llength $results] killed"
exit [expr {$killed == [llength $results] ? 0 : 1}]
