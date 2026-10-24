#!/usr/bin/env tclsh9.0
# mutate.tcl -- mutation test of module privacy and CONTEXT-RESOURCE-ESCAPE
# (MODULE-PRIVACY-AND-CONTEXT-ESCAPE-MILESTONE-1.md).
#
#   tclsh9.0 audit/module-privacy/tools/mutate.tcl ?-only NAME,...?
#       ?-fuzz-count N? ?-fuzz-seed S? ?-timeout SECONDS?
#
# Each mutant of mutants.txt (beside this file; its header has the format)
# breaks one rule of the implementation in a private copy of the tree, never
# this checkout. A mutant is KILLED when tests/module-privacy.test or
# tests/context-resource-escape.test (on interp) has a failing test or the
# fuzzer (audit/module-privacy/tools/fuzz.tcl, an independent model of both
# rules) a disagreement; a mutant all three miss SURVIVES, and so does one
# whose text no longer applies (NOT-APPLIED: update its text when the code
# it mutates changes, keeping it a mutant of the same rule). The unmutated
# copy must pass first. The exit status is 1 if anything survived. No mutant
# edits native/: the copy links this checkout's native/target (nothing
# rebuilds it).

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

set options [dict create -only "" -fuzz-count 40 -fuzz-seed 1 -timeout 1800]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

# The mutants of PATH as {NAME DESCRIPTION {FILE OLD NEW ...} ...}.
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

# A private copy of the compiler sources, the library, the tests and this
# audit's tools; native/target is a link to this checkout's (never rebuilt).
set tree [file tempdir botlish-privacy-mutants]
foreach dir {compiler core hir surface service compilerpedia stdlib tests examples audit/module-privacy audit/icy-tower/context-refactor/repro} {
    file mkdir [file dirname [file join $tree $dir]]
    file copy [file join $root $dir] [file join $tree $dir]
}
file mkdir [file join $tree native]
foreach entry [glob -directory [file join $root native] *] {
    if {[file tail $entry] eq "target"} {
        file link -symbolic [file join $tree native target] $entry
    } elseif {[file isfile $entry]} {
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
    }
    return [list $status $output]
}

# What the detectors say of the copy: a list of reasons, empty when all pass.
proc detect {} {
    global tree options
    set reasons {}
    foreach {file prefix} {module-privacy.test mp context-resource-escape.test ce} {
        set tmp [file join $tree tcltest-[clock clicks]]
        file mkdir $tmp
        lassign [run [dict get $options -timeout] env LANG=C.utf8 LC_ALL=C.utf8 CORE_BACKEND=interp \
            tclsh9.0 [file join $tree tests $file] -tmpdir $tmp] status output
        file delete -force $tmp
        if {![regexp {Total\t(\d+)\tPassed\t(\d+)\tSkipped\t(\d+)\tFailed\t(\d+)} $output -> total passed skipped failed]} {
            lappend reasons "$file did not finish"
        } elseif {$failed > 0} {
            lappend reasons "$file ([join [lsort -unique [regexp -all -inline "$prefix-\[a-z0-9-\]+(?= FAILED)" $output]] {, }])"
        }
    }
    lassign [run [dict get $options -timeout] env LANG=C.utf8 LC_ALL=C.utf8 tclsh9.0 \
        [file join $tree audit module-privacy tools fuzz.tcl] -n [dict get $options -fuzz-count] \
        -seed [dict get $options -fuzz-seed]] status output
    if {$status != 0} {
        regsub {\n?child process exited abnormally$} $output "" output
        set last [lindex [split [string trim $output] \n] end]
        lappend reasons "fuzzer ($last)"
    }
    return $reasons
}

set results {}
try {
    set baseline [detect]
    puts "baseline: [expr {$baseline eq {} ? "clean" : [join $baseline {; }]}]"
    if {$baseline ne {}} {
        puts "the unmutated copy does not pass: fix that first"
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
            puts "NOT-APPLIED $name: the text to replace does not occur exactly once in $file"
            lappend results [list $name NOT-APPLIED {}]
        } else {
            set reasons [detect]
            if {$reasons eq {}} {
                puts "SURVIVED  $name -- $description"
                lappend results [list $name SURVIVED {}]
            } else {
                puts "killed    $name  by [join $reasons {; }]"
                lappend results [list $name KILLED $reasons]
            }
        }
        dict for {file text} $touched {
            writeFile [file join $tree $file] $text
        }
    }
} finally {
    file delete -force $tree
}
set killed [llength [lsearch -all -index 1 $results KILLED]]
set bad [lmap r $results {expr {[lindex $r 1] eq "KILLED" ? [continue] : [lindex $r 0]}}]
puts "module-privacy-mutation mutants [llength $results] killed $killed survivors [llength $bad]"
if {$bad ne {}} {
    puts "survivors: [join $bad {, }]"
    exit 1
}
