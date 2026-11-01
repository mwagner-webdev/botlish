#!/usr/bin/env tclsh9.0
# utf16-mutate.tcl -- can the checks of UTF-16LE on byte storage fail?
# (UTF16-BYTE-STORAGE-MILESTONE-1.md, "Mutation testing").
#
#   tclsh9.0 audit/abi-bytes/tools/utf16-mutate.tcl ?-only NAME,...?
#       ?-fuzz-n N? ?-timeout SECONDS?
#
# Each mutant of utf16-mutants.txt beside this script (the format is its
# header's) is a deliberate break of the codec's contract, written as exact
# source replacements. For each, a private copy of the compiler, library,
# tests, this directory's tools and the native backend (a temporary
# directory; never this checkout) gets the replacements, and the detectors
# run against it:
#
#   * tests/utf16-bytes.test (a private -tmpdir): the names of the tests
#     that fail;
#   * utf16-fuzz.tcl -n N (default 40; every backend, the independent oracle
#     utf16-oracle.py): `fuzz` when it reports a disagreement or does not
#     complete;
#   * for a native mutant (one that edits native/), first a release build of
#     the copy (a mutant that does not build is NOT-BUILT, never killed),
#     then the Rust tests of the codec (`cargo test --release --lib
#     utf16le`): `rust:NAME` for each that fails.
#
# A mutant is KILLED when one of the detectors its `!!` line names is among
# those that fail -- the test that checks the contract the mutant breaks --
# KILLED-ELSEWHERE (a failure of this harness) when only other detectors
# fail, SURVIVED when none does. Tcl mutants run first against the copy's
# unmodified native build; native mutants follow, each rebuilding the copy
# (its native/target a real copy of this checkout's, so only the runtime
# crate recompiles). Exits 1 unless every mutant applies, builds and is
# KILLED.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -only "" -fuzz-n 40 -timeout 3600]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

# The mutants of PATH: {NAME DESCRIPTION DETECTORS {FILE OLD NEW ...} ...}.
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
                    set detectors $d
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

proc isNative {edits} {
    foreach {file old new} $edits {
        if {[string match native/* $file]} {
            return 1
        }
    }
    return 0
}

# {STATUS OUTPUT} of ARGS, its standard error merged into its output;
# STATUS is "timeout" (the process killed) when it runs longer than TIMEOUT
# seconds (audit/filesystem/tools/mutate.tcl's run: no `timeout` command,
# which on Windows is another program).
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

proc lastLine {output} {
    return [string range [lindex [split [string trim $output] \n] end] 0 120]
}

set only [split [dict get $options -only] ,]
set selected {}
set nativeSelected {}
foreach {name description detectors edits} [readMutants [file join [file dirname [file normalize [info script]]] utf16-mutants.txt]] {
    if {$only ne {} && $name ni $only} continue
    if {$detectors eq {}} {
        error "mutant $name names no detector (a `!!` line)"
    }
    if {[isNative $edits]} {
        lappend nativeSelected $name $description $detectors $edits
    } else {
        lappend selected $name $description $detectors $edits
    }
}
set selected [concat $selected $nativeSelected]

set tree [file tempdir botlish-utf16-mutants]
foreach dir {compiler core hir surface stdlib tests audit/abi-bytes .cargo} {
    if {![file exists [file join $root $dir]]} continue
    file mkdir [file dirname [file join $tree $dir]]
    file copy [file join $root $dir] [file join $tree $dir]
}
file mkdir [file join $tree native]
foreach entry [glob -directory [file join $root native] *] {
    if {[file tail $entry] ne "target"} {
        file copy $entry [file join $tree native]
    } elseif {$nativeSelected ne {}} {
        # Copy the directory, following links: a copied link would build
        # every native mutant into the linked checkout (AGENTS.md, "Running
        # tests concurrently").
        while {[file type $entry] eq "link"} {
            set entry [file join [file dirname $entry] [file readlink $entry]]
        }
        if {$::tcl_platform(platform) eq "unix"} {
            exec cp -a $entry [file join $tree native target]
        } else {
            file copy $entry [file join $tree native target]
        }
    } else {
        file link -symbolic [file join $tree native target] $entry
    }
}
foreach entry [glob -directory $root -types f *.tcl] {
    file copy $entry $tree
}

set results {}
set manifest [file join $tree native Cargo.toml]
set timeout [dict get $options -timeout]
set tclsh [info nameofexecutable]
try {
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
        set restore {
            dict for {file text} $touched {
                writeFile [file join $tree $file] $text
            }
        }
        if {!$applied} {
            lappend results [list $name NOT-APPLIED]
            puts "NOT-APPLIED $name: a text to replace does not occur exactly once in $file"
            eval $restore
            continue
        }
        set killers {}
        set native [isNative $edits]
        if {$native} {
            set here [pwd]
            cd $tree
            lassign [run $timeout cargo build --release --manifest-path $manifest] status output
            if {$status != 0} {
                cd $here
                lappend results [list $name NOT-BUILT]
                puts "NOT-BUILT $name: [lastLine $output]"
                eval $restore
                continue
            }
            lassign [run $timeout cargo test --release --manifest-path $manifest --lib utf16le] status output
            cd $here
            foreach {- test} [regexp -all -inline -line {^test \S*::(\S+) \.\.\. FAILED$} $output] {
                lappend killers rust:$test
            }
            if {$status != 0 && ![string match *rust:* $killers]} {
                lappend killers rust:did-not-complete
            }
        }
        set tmp [file tempdir botlish-utf16-mutant-run]
        lassign [run $timeout $tclsh [file join $tree tests utf16-bytes.test] -tmpdir $tmp] status output
        file delete -force $tmp
        if {![regexp {Total\s+\d+\s+Passed\s+\d+\s+Skipped\s+\d+\s+Failed\s+\d+} $output]} {
            lappend killers tests:did-not-complete
        }
        foreach {- test} [regexp -all -inline -line {^==== (\S+) .*FAILED$} $output] {
            if {$test ni $killers} {
                lappend killers $test
            }
        }
        lassign [run $timeout $tclsh [file join $tree audit abi-bytes tools utf16-fuzz.tcl] \
            -n [dict get $options -fuzz-n]] status output
        if {![regexp {cases \d+ disagreements 0$} [string trim $output]]} {
            lappend killers fuzz
        }
        set named [lmap k $killers {if {$k in $detectors} {set k} else continue}]
        if {$named ne {}} {
            set verdict KILLED
        } elseif {$killers ne {}} {
            set verdict KILLED-ELSEWHERE
        } else {
            set verdict SURVIVED
        }
        lappend results [list $name $verdict]
        puts "$verdict $name -- $description\n    named: $detectors\n    failed: [expr {$killers eq {} ? "nothing" : [join $killers {, }]}]"
        flush stdout
        eval $restore
    }
} finally {
    file delete -force $tree
}

set bad [lmap r $results {if {[lindex $r 1] eq "KILLED"} continue; lindex $r 0}]
puts "mutants [llength $results] killed [expr {[llength $results] - [llength $bad]}] not killed by their detector [llength $bad][expr {$bad eq {} ? "" : " ($bad)"}]"
exit [expr {$bad ne {}}]
