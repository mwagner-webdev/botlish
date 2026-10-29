#!/usr/bin/env tclsh9.0
# mutate.tcl -- can the checks of paths and the synchronous filesystem fail?
# (WINDOWS-X86-64-MILESTONE-7.md, "Mutation testing").
#
#   tclsh9.0 audit/filesystem/tools/mutate.tcl ?-only NAME,...? ?-fuzz-n N?
#       ?-timeout SECONDS?
#
# Each mutant of mutants.txt beside this script (the format is its header's)
# is applied to a private copy of the compiler, library and tests (a
# temporary directory; native/target a link to this checkout's: no mutant
# edits native/), and the detectors run against it in turn until one kills
# it:
#
#   * audit/filesystem/tools/fuzz.tcl -n N (default 60) over every part this
#     host runs: killed if it reports a disagreement or does not complete;
#   * tests/filesystem.test (a private -tmpdir): killed if a test fails or
#     the file does not complete.
#
# A mutant with a `%% TARGET ...` line runs only on those hosts
# (core::cabi::hostTarget) and is SKIPPED elsewhere. Output: one line per
# mutant -- killed by what, SURVIVED, SKIPPED or that its text does not apply
# exactly once. Exits 1 unless every mutant this host runs applies and is
# killed. The real checkout is never modified.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -only "" -fuzz-n 60 -timeout 3600]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}
source [file join $root core core.tcl]
set host [core::cabi::hostTarget]

# The mutants of PATH: {NAME DESCRIPTION HOSTS {FILE OLD NEW ...} ...}.
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

# {STATUS OUTPUT} of ARGS, its standard error merged into its output;
# STATUS is "timeout" (the process killed) when it runs longer than TIMEOUT
# seconds (audit/context-traits/tools/mutate.tcl's run: no `timeout`
# command, which on Windows is another program).
proc run {timeout args} {
    set pipe [open |[concat $args [list 2>@1]] r]
    fconfigure $pipe -blocking 0 -translation auto -encoding utf-8
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
        if {$::tcl_platform(platform) eq "windows"} {
            foreach p [pid $pipe] { catch {exec taskkill /F /T /PID $p} }
        } else {
            catch {exec kill -9 {*}[pid $pipe]}
        }
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

set only [split [dict get $options -only] ,]
set selected {}
foreach {name description hosts edits} [readMutants [file join [file dirname [file normalize [info script]]] mutants.txt]] {
    if {$only ne {} && $name ni $only} continue
    lappend selected $name $description $hosts $edits
}

set tree [file tempdir botlish-filesystem-mutants]
foreach dir {compiler core hir surface stdlib tests audit/filesystem .cargo} {
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
    foreach {name description hosts edits} $selected {
        if {$hosts ne {} && $host ni $hosts} {
            puts "[format %-36s $name] SKIPPED (a mutant of $hosts)"
            continue
        }
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
            puts "[format %-36s $name] does not apply exactly once"
            incr failures
        } else {
            set status SURVIVED
            lassign [run $timeout $tclsh [file join $tree audit filesystem tools fuzz.tcl] -n [dict get $options -fuzz-n]] code output
            set summary [lindex [split [string trim $output] \n] end]
            if {$code != 0 || ![regexp {disagreements 0$} $summary]} {
                set first [lindex [split [string trim $output] \n] 0]
                set status "killed by the fuzzer ([string range $first 0 100])"
            } else {
                set tmp [file join $tree tcltest]
                file delete -force $tmp
                file mkdir $tmp
                lassign [run $timeout $tclsh [file join $tree tests filesystem.test] -tmpdir $tmp] code output
                set names [lsort -unique [lmap {- t} [regexp -all -inline -line {^==== (\S+) FAILED$} $output] {set t}]]
                if {$code != 0 || $names ne {} || ![regexp {Total\t[0-9]+\tPassed} $output]} {
                    set status "killed by filesystem.test ([join [lrange $names 0 3] {, }][expr {[llength $names] > 4 ? ", ..." : ""}])"
                }
            }
            if {$status eq "SURVIVED"} {
                incr failures
            }
            puts "[format %-36s $name] $status"
        }
        dict for {path text} $saved {
            writeFile $path $text
        }
    }
} finally {
    if {$::tcl_platform(platform) eq "unix"} {
        exec rm -rf -- $tree
    } else {
        file delete -force $tree
    }
}
exit [expr {$failures > 0}]
