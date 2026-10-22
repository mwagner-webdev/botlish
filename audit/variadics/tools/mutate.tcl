# mutate.tcl -- mutation testing of Botlish variadic parameters
# (VARIADICS-VERTICAL-SLICE-1.md, "Mutation testing").
#
#   tclsh9.0 audit/variadics/tools/mutate.tcl ?-only NAME,...? ?-fuzz-count N?
#                                             ?-fuzz-seed S? ?-timeout SECONDS?
#
# Each mutant is a deliberate bug, written in mutants.txt (beside this
# script) as exact source replacements, each replaced text occurring exactly
# once. For each, a private copy of the tree (the native build shared
# through a link: no mutant edits native/) gets the replacements, and the
# detectors run against it:
#
#   * tests/variadics.test (a private -tmpdir): killed if any test fails or
#     the file does not complete;
#   * for a mutant the tests miss, audit/variadics/tools/fuzz.tcl -n N
#     -seed S: killed if it reports a disagreement or does not complete.
#
# One line per mutant (KILLED, SURVIVED or a mutation that does not apply);
# the exit status is 1 unless every mutant applies and is killed. The real
# checkout is never modified.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -only "" -fuzz-count 8 -fuzz-seed 5 -timeout 1800]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

proc readText {path} {
    set channel [open $path]
    fconfigure $channel -encoding utf-8 -translation lf
    set text [read $channel]
    close $channel
    return $text
}

proc writeText {path text} {
    set channel [open $path w]
    fconfigure $channel -encoding utf-8 -translation lf
    puts -nonewline $channel $text
    close $channel
}

# The mutants of PATH as {NAME DESCRIPTION {FILE OLD NEW ...}} triples.
proc readMutants {path} {
    set mutants {}
    set name ""
    set state outside
    foreach line [split [readText $path] \n] {
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

# Runs COMMAND (a list) with a wall-clock limit; {STATUS OUTPUT}, STATUS 0
# for a clean exit, 1 for a failing one, timeout when it was stopped.
proc run {command} {
    set limit [dict get $::options -timeout]
    set status [catch {exec timeout $limit {*}$command 2>@1} output options]
    if {$status && [lindex [dict get $options -errorcode] 0] eq "CHILDSTATUS" && [lindex [dict get $options -errorcode] 2] == 124} {
        return [list timeout $output]
    }
    return [list $status $output]
}

set only [split [dict get $options -only] ,]
set scratch [file tempdir botlish-variadics-mutants-]
set results {}
set failures 0
foreach {name description edits} [readMutants [file join $root audit variadics tools mutants.txt]] {
    if {$only ne {} && $name ni $only} continue
    set tree [file join $scratch $name]
    file mkdir $tree
    exec tar -C $root --exclude=./native/target --exclude=./.git -cf - . | tar -C $tree -xf -
    file link -symbolic [file join $tree native target] [file join $root native target]
    set applies 1
    foreach {file old new} $edits {
        set path [file join $tree $file]
        set text [readText $path]
        set at [string first $old $text]
        if {$at < 0 || [string first $old $text [expr {$at + 1}]] >= 0} {
            puts "NOT-APPLIED $name -- the text to replace does not occur exactly once in $file"
            set applies 0
            break
        }
        writeText $path [string replace $text $at [expr {$at + [string length $old] - 1}] $new]
    }
    if {!$applies} {
        incr failures
        file delete -force $tree
        continue
    }
    set tmp [file join $tree tcltest-tmp]
    file mkdir $tmp
    lassign [run [list [info nameofexecutable] [file join $tree tests variadics.test] -tmpdir $tmp]] status output
    set failed [lsort -unique [lmap {- t} [regexp -all -inline -line {^==== (\S+) FAILED$} $output] {set t}]]
    if {$status eq "timeout"} {
        set verdict "KILLED $name -- $description\n    tests: did not complete (timeout)"
    } elseif {$failed ne {}} {
        set verdict "KILLED $name -- $description\n    tests: [llength $failed] failed: [join $failed {, }]"
    } elseif {![regexp {Total\t[0-9]+\tPassed\t[0-9]+\tSkipped\t[0-9]+\tFailed\t0} $output]} {
        set verdict "KILLED $name -- $description\n    tests: the file did not complete: [string range [string trim $output] end-300 end]"
    } else {
        lassign [run [list [info nameofexecutable] [file join $tree audit variadics tools fuzz.tcl] \
            -n [dict get $options -fuzz-count] -seed [dict get $options -fuzz-seed]]] status output
        set summary [lindex [split [string trim $output] \n] end]
        if {[regexp {disagreements ([0-9]+)$} $summary -> n] && $n == 0 && $status == 0} {
            set verdict "SURVIVED $name -- $description\n    tests: passed\n    fuzz: $summary"
            incr failures
        } else {
            set verdict "KILLED $name -- $description\n    tests: passed\n    fuzz: killed ($summary)"
        }
    }
    puts $verdict
    flush stdout
    lappend results $verdict
    file delete -force $tree
}
file delete -force $scratch
set killed [llength [lsearch -all $results KILLED*]]
puts "[llength $results] mutants, $killed killed, [expr {[llength $results] - $killed}] survived"
exit [expr {$failures > 0}]
