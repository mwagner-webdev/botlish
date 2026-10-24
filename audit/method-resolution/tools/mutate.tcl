# mutate.tcl -- can the checks of the method-call decision fail?
# (METHOD-RESOLUTION-CORRECTNESS-MILESTONE-1.md, "Mutation testing").
#
#   tclsh9.0 audit/method-resolution/tools/mutate.tcl ?-only NAME,...?
#       ?-oracle-seeds N? ?-timeout SECONDS?
#
# Each mutant of mutants.txt beside this script (the format is its header's)
# is applied to a private copy of the compiler, library and tests (a
# temporary directory; native/target a link to this checkout's), and the
# detectors run against it in turn until one kills it:
#
#   * tests/method-resolution.test and tests/method-filter.test (each with a
#     private -tmpdir): killed if a test fails or a file does not complete;
#   * audit/method-resolution/tools/oracle.tcl over N seeds (default 40):
#     killed if it reports a disagreement or does not complete.
#
# Output: one line per mutant, killed by what, or SURVIVED, or that its text
# does not apply exactly once. Exits 1 unless every mutant applies and is
# killed. The real checkout is never modified.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

set options [dict create -only "" -oracle-seeds 40 -timeout 3600]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

# The mutants of PATH: {NAME DESCRIPTION {FILE OLD NEW ...} ...}.
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
    }
    return [list $status $output]
}

set only [split [dict get $options -only] ,]
set selected {}
foreach {name description edits} [readMutants [file join [file dirname [file normalize [info script]]] mutants.txt]] {
    if {$only ne {} && $name ni $only} continue
    lappend selected $name $description $edits
}

set tree [file tempdir botlish-method-resolution-mutants]
foreach dir {compiler core hir surface stdlib tests audit/method-resolution audit/method-filter .cargo} {
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

set failures 0
set timeout [dict get $options -timeout]
set tclsh [info nameofexecutable]
try {
    foreach {name description edits} $selected {
        set saved [dict create]
        set applied 1
        foreach {file old new} $edits {
            set path [file join $tree $file]
            if {![dict exists $saved $path]} {
                dict set saved $path [readFile $path]
            }
            set text [readFile $path]
            set at [string first $old $text]
            if {$at < 0 || [string first $old $text [expr {$at + 1}]] >= 0} {
                set applied 0
                break
            }
            writeFile $path [string replace $text $at [expr {$at + [string length $old] - 1}] $new]
        }
        if {!$applied} {
            puts "[format %-34s $name] does not apply exactly once"
            incr failures
        } else {
            set status "SURVIVED"
            foreach test {method-resolution method-filter} {
                set tmp [file join $tree tcltest-$test]
                file delete -force $tmp
                file mkdir $tmp
                lassign [run $timeout $tclsh [file join $tree tests $test.test] -tmpdir $tmp] code output
                set failed [regexp -all -line {^==== (\S+) FAILED$} $output]
                if {$code != 0 || $failed > 0 || ![regexp {Total\t[0-9]+\tPassed} $output]} {
                    set names [lsort -unique [lmap {- t} [regexp -all -inline -line {^==== (\S+) FAILED$} $output] {set t}]]
                    set status "killed by $test.test ([join [lrange $names 0 3] {, }][expr {[llength $names] > 4 ? ", ..." : ""}])"
                    break
                }
            }
            if {$status eq "SURVIVED"} {
                lassign [run $timeout $tclsh [file join $tree audit method-resolution tools oracle.tcl] [dict get $options -oracle-seeds] 1] code output
                set summary [lindex [split [string trim $output] \n] end]
                if {$code != 0 || ![regexp {disagreements 0$} $summary]} {
                    set status "killed by the oracle ([string range $summary 0 120])"
                }
            }
            if {$status eq "SURVIVED"} {
                incr failures
            }
            puts "[format %-34s $name] $status"
        }
        dict for {path text} $saved {
            writeFile $path $text
        }
    }
} finally {
    file delete -force $tree
}
exit [expr {$failures > 0}]
