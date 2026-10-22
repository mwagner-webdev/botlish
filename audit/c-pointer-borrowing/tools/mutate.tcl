# mutate.tcl -- mutation testing of temporary foreign byte exposure
# (C-POINTER-BORROWING.md).
#
#   tclsh9.0 audit/c-pointer-borrowing/tools/mutate.tcl ?-only NAME,...?
#                                    ?-tests FILES? ?-fuzz-count N?
#                                    ?-fuzz-seed N? ?-timeout SECONDS?
#
# Each mutant is a deliberate bug, written in mutants.txt (beside this
# script) as exact source replacements, each replaced text occurring exactly
# once. A mutant of code one host compiles differently (a `%% TARGET ...`
# line after its header: linux-x86_64, linux-aarch64, macos-aarch64) runs
# only on those hosts and is SKIPPED elsewhere, never counted as killed. For
# each, a private copy of the compiler, library and native backend (a
# temporary directory) gets the replacements, and the detectors run against
# it:
#
#   * the test files FILES (default tests/c-pointer-borrowing.test, the
#     borrow fixture's, tests/c-byte-borrowing.test, real C built by the
#     host's own compiler -- skipped where no C call links -- and
#     tests/c-ffi-error-capture.test, the error-capture window's detectors;
#     each with a private -tmpdir): killed if any test fails or a file does
#     not complete;
#   * audit/c-pointer-borrowing/tools/fuzz.tcl -n N -seed S (owners,
#     contracts and pointees against its own admission and byte model,
#     every backend): killed if it reports a disagreement or does not
#     complete;
#   * for a native mutant (one that edits native/src/), first a release
#     build of the copy's native backend (a mutant that does not build is
#     reported NOT-BUILT, never counted as killed).
#
# Mutants that edit only Tcl run first, against the copy's unmodified native
# build; native mutants follow, each rebuilding the copy. A mutant every
# detector misses SURVIVES; one whose text no longer occurs exactly once is
# NOT-APPLIED, one that does not build NOT-BUILT -- neither is killed, and
# either fails the run. The real checkout, including its native/target, is
# never modified. Every command runs under this script's own timeout (no
# timeout(1): macOS has none), so it runs on every host the detectors do.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

set options [dict create -only "" -tests {tests/c-pointer-borrowing.test tests/c-byte-borrowing.test tests/c-ffi-error-capture.test} -fuzz-count 15 -fuzz-seed 7 -timeout 1800]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

# This host's target, named as core::cabi names it (linux-x86_64,
# linux-aarch64, macos-aarch64).
set host [string cat [expr {$::tcl_platform(os) eq "Darwin" ? "macos" : [string tolower $::tcl_platform(os)]}] - \
    [expr {$::tcl_platform(machine) in {arm64 aarch64} ? "aarch64" : ($::tcl_platform(machine) in {amd64 x86_64} ? "x86_64" : $::tcl_platform(machine))}]]

# The mutants of mutants.txt (its header has the format), as
# {NAME DESCRIPTION HOSTS {FILE OLD NEW ...} ...}, HOSTS empty for every
# host.
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

proc isNative {edits} {
    foreach {file old new} $edits {
        if {[string match native/src/* $file] || [string match native/Cargo.* $file]} {
            return 1
        }
    }
    return 0
}

# Selected mutants, Tcl-only ones first.
set only [split [dict get $options -only] ,]
set selected {}
set nativeSelected {}
foreach {name description hosts edits} [readMutants [file join [file dirname [file normalize [info script]]] mutants.txt]] {
    if {$only ne {} && $name ni $only} continue
    if {[isNative $edits]} {
        lappend nativeSelected $name $description $hosts $edits
    } else {
        lappend selected $name $description $hosts $edits
    }
}
set selected [concat $selected $nativeSelected]

# A private copy of the compiler sources, tests, library, the audit tools and
# the native backend. Its native/target is a real copy when a native mutant
# is selected (it is rebuilt), else a link to this checkout's.
set tree [file tempdir botlish-borrow-mutants]
foreach dir {compiler core hir surface stdlib tests examples audit/c-pointer-borrowing .cargo} {
    if {![file exists [file join $root $dir]]} continue
    file mkdir [file dirname [file join $tree $dir]]
    file copy [file join $root $dir] [file join $tree $dir]
}
file mkdir [file join $tree native]
foreach entry [glob -directory [file join $root native] *] {
    if {[file tail $entry] ne "target"} {
        file copy $entry [file join $tree native]
    } elseif {$nativeSelected ne {}} {
        # Copy the directory, following links: when native/target links to
        # another checkout's (AGENTS.md, "Running tests concurrently"), a
        # copied link would build every native mutant into that checkout.
        while {[file type $entry] eq "link"} {
            set entry [file join [file dirname $entry] [file readlink $entry]]
        }
        exec cp -a $entry [file join $tree native target]
    } else {
        file link -symbolic [file join $tree native target] $entry
    }
}
foreach entry [glob -directory $root -types f *.tcl] {
    file copy $entry $tree
}

# {STATUS OUTPUT} of ARGS, its standard error merged into its output, run in
# the current directory; STATUS is "timeout" (the process killed) when it
# runs longer than TIMEOUT seconds (audit/c-ffi/tools/mutate.tcl's run).
proc run {timeout args} {
    set pipe [open |[concat $args [list 2>@1]] r]
    fconfigure $pipe -blocking 0 -translation lf -encoding utf-8
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
        catch {exec kill -9 {*}[pid $pipe]}
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

set results {}
set manifest [file join $tree native Cargo.toml]
try {
    foreach {name description hosts edits} $selected {
        if {$hosts ne {} && $host ni $hosts} {
            lappend results [list $name $description SKIPPED "" "" "" ""]
            puts "SKIPPED $name: not compiled differently for $host"
            continue
        }
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
            # The code the mutant edits changed: update mutants.txt.
            lappend results [list $name $description NOT-APPLIED "" "" "" ""]
            puts "NOT-APPLIED $name: the text to replace does not occur exactly once in $file"
            dict for {file text} $touched {
                writeFile [file join $tree $file] $text
            }
            continue
        }
        set native [isNative $edits]
        set rust ""
        if {$native} {
            # Cargo finds the copy's .cargo/config.toml (frame pointers: the
            # collector's stack walk needs them) from the working directory.
            set here [pwd]
            cd $tree
            lassign [run [dict get $options -timeout] cargo build --release --manifest-path $manifest] status output
            if {$status != 0} {
                cd $here
                lappend results [list $name $description NOT-BUILT "" "" "" ""]
                puts "NOT-BUILT $name: [lastLine $output]"
                dict for {file text} $touched {
                    writeFile [file join $tree $file] $text
                }
                continue
            }
            cd $here
            set rust built
        }
        set failedTests {}
        set incomplete ""
        foreach testFile [dict get $options -tests] {
            set tmp [file tempdir botlish-borrow-mutant-run]
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
        set golden ""
        set scratch [file tempdir botlish-borrow-mutant-fuzz]
        set here [pwd]
        cd $scratch
        lassign [run [dict get $options -timeout] tclsh9.0 [file join $tree audit c-pointer-borrowing tools fuzz.tcl] \
            -n [dict get $options -fuzz-count] -seed [dict get $options -fuzz-seed]] status output
        cd $here
        file delete -force $scratch
        if {[regexp {programs \d+ cases \d+ refused \d+ disagreements (\d+)} [lindex [split [string trim $output] \n] end] -> n]} {
            set fuzz [expr {$n > 0 ? "killed ($n disagreements in [dict get $options -fuzz-count] programs)" : "survived"}]
        } else {
            set fuzz "killed (did not complete: [lastLine $output])"
        }
        set verdict [expr {[string match killed* $tests] || [string match killed* $fuzz] ? "KILLED" : "SURVIVED"}]
        lappend results [list $name $description $verdict $tests $golden $fuzz $rust]
        puts "$verdict $name -- $description\n    tests:  $tests"
        puts "    fuzz:   $fuzz"
        flush stdout
        dict for {file text} $touched {
            writeFile [file join $tree $file] $text
        }
    }
} finally {
    file delete -force $tree
}

set survivors [lmap r $results {if {[lindex $r 2] ne "SURVIVED"} continue; lindex $r 0}]
set unapplied [lmap r $results {if {[lindex $r 2] ni {NOT-APPLIED NOT-BUILT}} continue; lindex $r 0}]
set killed [llength [lsearch -all -index 2 $results KILLED]]
set skipped [llength [lsearch -all -index 2 $results SKIPPED]]
puts "[llength $results] mutants, $killed killed, [llength $survivors] survived[expr {$survivors eq {} ? "" : ": [join $survivors {, }]"}], $skipped skipped (on $host)[expr {$unapplied eq {} ? "" : ", [llength $unapplied] not applied or not built: [join $unapplied {, }]"}]"
exit [expr {$survivors ne {} || $unapplied ne {}}]
