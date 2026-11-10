# mutate.tcl -- mutation testing of the depth-safe front end
# (DEPTH-SAFE-NESTED-EXPRESSION-FRONTEND-MILESTONE-1.md).
#
#   tclsh9.0 audit/depth-safe-nesting/tools/mutate.tcl ?-only NAME,...?
#       ?-timeout SECONDS? ?-memory KB?
#
# Each mutant is a deliberate bug, written in mutants.txt (beside this
# script) as exact source replacements, each replaced text occurring exactly
# once, and a `!!` line naming its detectors: tests of
# tests/depth-safe-nesting.test (tcltest -match patterns), and `fuzz` for
# this audit's fuzzer (fuzz.tcl, a few deep programs). For each, a private
# copy of the compiler (a temporary directory; native/target linked, never
# rebuilt: every mutant is Tcl) gets the replacements, and its detectors run
# against it; it is killed if a named test fails, the fuzzer reports a
# failure, or either does not complete within the timeout or the memory cap
# (a ulimit of each detector's process). The detectors first run on the
# unmutated copy (the control): one that fails there would kill every
# mutant, so the run stops. A mutant its detectors miss SURVIVES. The real
# checkout is never modified.
#
# mutants.txt's format: `@@ NAME DESCRIPTION`, then `!! DETECTOR ...`, then
# for each edit `## FILE` and the text `<<<<` OLD `====` NEW `>>>>`.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

set options [dict create -only "" -timeout 1800 -memory 6000000]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

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
                    if {$name ne ""} { lappend mutants $name $description $detectors $edits }
                    set name $n
                    set description $d
                    set detectors {}
                    set edits {}
                } elseif {[regexp {^!! (.*)$} $line -> d]} {
                    lappend detectors {*}$d
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
    if {$name ne ""} { lappend mutants $name $description $detectors $edits }
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
foreach {name description detectors edits} [readMutants [file join [file dirname [file normalize [info script]]] mutants.txt]] {
    if {$only ne {} && $name ni $only} continue
    lappend selected $name $description $detectors $edits
}

# A private copy of the compiler sources, tests, library and this audit.
set tree [file tempdir botlish-depth-safe-mutants]
foreach dir {compiler core hir surface stdlib tests examples service lsp compilerpedia pm audit/depth-safe-nesting .cargo} {
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

# The verdict of DETECTORS on TREE: "survived" or "killed (...)".
proc detect {tree detectors} {
    global options
    set patterns [lsearch -all -inline -not -exact $detectors fuzz]
    set verdicts {}
    if {$patterns ne {}} {
        set tmp [file tempdir botlish-depth-safe-mutant-run]
        lassign [run [dict get $options -timeout] tclsh9.0 [file join $tree tests depth-safe-nesting.test] \
            -tmpdir $tmp -match $patterns] status output
        file delete -force $tmp
        set failed [lmap {- n} [regexp -all -inline -line {^==== (\S+) .*FAILED$} $output] {set n}]
        if {![regexp {Total\s+\d+\s+Passed\s+\d+\s+Skipped\s+\d+\s+Failed\s+(\d+)} $output]} {
            lappend verdicts "tests did not complete: [lastLine $output]"
        } elseif {$failed ne {}} {
            lappend verdicts "[llength $failed] failed: [join [lrange [lsort -unique $failed] 0 4] {, }]"
        }
    }
    if {"fuzz" in $detectors} {
        lassign [run [dict get $options -timeout] tclsh9.0 [file join $tree audit depth-safe-nesting tools fuzz.tcl] \
            -seed 3 -programs 4 -depth 1200 -backends interp] status output
        if {[regexp {, (\d+) failures$} [lindex [split [string trim $output] \n] end] -> n]} {
            if {$n > 0} {
                lappend verdicts "fuzz: $n failures"
            }
        } else {
            lappend verdicts "fuzz did not complete: [lastLine $output]"
        }
    }
    if {$verdicts eq {}} {
        return survived
    }
    return "killed ([join $verdicts {; }])"
}

set results {}
try {
    set all {}
    foreach {name description detectors edits} $selected {
        foreach d $detectors {
            if {$d ni $all} { lappend all $d }
        }
    }
    set start [clock seconds]
    set control [detect $tree $all]
    puts "CONTROL (no mutant, [expr {[clock seconds] - $start}] s): $control"
    flush stdout
    if {$control ne "survived"} {
        puts "the detectors do not pass on the unmutated copy: no mutant can be judged"
        file delete -force $tree
        exit 2
    }
    foreach {name description detectors edits} $selected {
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
            lappend results [list $name NOT-APPLIED]
            puts "NOT-APPLIED $name: the text to replace does not occur exactly once in $file"
        } else {
            set started [clock seconds]
            set verdict [detect $tree $detectors]
            set status [expr {[string match killed* $verdict] ? "KILLED" : "SURVIVED"}]
            lappend results [list $name $status]
            puts "$status $name ([expr {[clock seconds] - $started}] s) -- $description\n    $verdict"
        }
        flush stdout
        dict for {file text} $touched {
            writeFile [file join $tree $file] $text
        }
    }
} finally {
    file delete -force $tree
}

set survivors [lmap r $results {if {[lindex $r 1] ne "SURVIVED"} continue; lindex $r 0}]
set unapplied [lmap r $results {if {[lindex $r 1] ne "NOT-APPLIED"} continue; lindex $r 0}]
set killed [llength [lsearch -all -index 1 $results KILLED]]
puts "[llength $results] mutants, $killed killed, [llength $survivors] survived[expr {$survivors eq {} ? "" : ": [join $survivors {, }]"}][expr {$unapplied eq {} ? "" : ", [llength $unapplied] not applied: [join $unapplied {, }]"}]"
exit [expr {$survivors ne {} || $unapplied ne {}}]
