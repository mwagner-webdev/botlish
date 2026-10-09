# mutate.tcl -- mutation testing of MutableArray[T] as a value (MUTABLE-ARRAY.md).
#
#   tclsh9.0 audit/mutable-array/tools/mutate.tcl ?-only NAME,...?
#                                                 ?-tests FILES?
#                                                 ?-fuzz-count N? ?-fuzz-seed N?
#                                                 ?-timeout SECONDS?
#
# Each mutant is a deliberate bug, written in mutants.txt (beside this
# script) as exact source replacements, each replaced text occurring exactly
# once. For each, a private copy of the compiler, library and native backend
# (a temporary directory) gets the replacements, and the detectors run
# against it:
#
#   * the test files FILES (default tests/mutable-array.test; each with a
#     private -tmpdir): killed if any test fails or a file does not complete;
#   * audit/mutable-array/tools/fuzz.tcl -n N -seed S (every backend, the
#     independent model): killed if it reports a disagreement or does not
#     complete;
#   * for a native mutant (one that edits native/src/ or the crate's
#     manifest), first a release build of the copy's native backend (a mutant
#     that does not build is reported NOT-BUILT, never counted as killed),
#     then also the Rust runtime tests of the array operations (`cargo test
#     --release --lib mutarray`).
#
# Mutants that edit only Tcl run first, against the copy's unmodified native
# build (native/lower.tcl is Tcl: every native test run reads the copy's);
# native mutants follow, each rebuilding the copy. A mutant every detector
# misses SURVIVES; the report lists each mutant, what killed it (failed test
# names, fuzz disagreements, Rust test failures) and the survivors. The real
# checkout, including its native/target, is never modified.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

set options [dict create -only "" -tests tests/mutable-array.test -fuzz-count 25 -fuzz-seed 11 -timeout 1800]
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
foreach {name description edits} [readMutants [file join [file dirname [file normalize [info script]]] mutants.txt]] {
    if {$only ne {} && $name ni $only} continue
    if {[isNative $edits]} {
        lappend nativeSelected $name $description $edits
    } else {
        lappend selected $name $description $edits
    }
}
set selected [concat $selected $nativeSelected]

# A private copy of the compiler sources, tests, library, the array audit
# tools and the native backend. Its native/target is a real copy when a
# native mutant is selected (it is rebuilt), else a link to this checkout's.
set tree [file tempdir botlish-ma-mutants]
foreach dir {compiler core hir surface lib tests examples audit/mutable-array .cargo} {
    if {![file exists [file join $root $dir]]} continue
    file mkdir [file dirname [file join $tree $dir]]
    file copy [file join $root $dir] [file join $tree $dir]
}
file mkdir [file join $tree native]
foreach entry [glob -directory [file join $root native] *] {
    if {[file tail $entry] ne "target"} {
        file copy $entry [file join $tree native]
    } elseif {$nativeSelected ne {}} {
        exec cp -a $entry [file join $tree native target]
    } else {
        file link -symbolic [file join $tree native target] $entry
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

proc lastLine {output} {
    return [string range [lindex [split [string trim $output] \n] end] 0 120]
}

set results {}
set manifest [file join $tree native Cargo.toml]
try {
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
            # The code the mutant edits changed: update mutants.txt.
            lappend results [list $name $description NOT-APPLIED "" "" ""]
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
                lappend results [list $name $description NOT-BUILT "" "" ""]
                puts "NOT-BUILT $name: [lastLine $output]"
                dict for {file text} $touched {
                    writeFile [file join $tree $file] $text
                }
                continue
            }
            lassign [run [dict get $options -timeout] cargo test --release --manifest-path $manifest --lib mutarray] status output
            cd $here
            if {$status != 0} {
                set failing [regexp -all -inline -line {^test (\S+) \.\.\. FAILED$} $output]
                set names [lmap {- n} $failing {set n}]
                set rust "killed ([expr {$names eq {} ? [lastLine $output] : [join $names {, }]}])"
            } else {
                set rust survived
            }
        }
        set failedTests {}
        set incomplete ""
        foreach testFile [dict get $options -tests] {
            set tmp [file tempdir botlish-ma-mutant-run]
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
        set scratch [file tempdir botlish-ma-mutant-fuzz]
        set here [pwd]
        cd $scratch
        lassign [run [dict get $options -timeout] tclsh9.0 [file join $tree audit mutable-array tools fuzz.tcl] \
            -n [dict get $options -fuzz-count] -seed [dict get $options -fuzz-seed]] status output
        cd $here
        file delete -force $scratch
        if {[regexp {programs \d+ disagreements (\d+)} [lindex [split [string trim $output] \n] end] -> n]} {
            set fuzz [expr {$n > 0 ? "killed ($n of [dict get $options -fuzz-count] programs disagree)" : "survived"}]
        } else {
            set fuzz "killed (did not complete: [lastLine $output])"
        }
        set verdict [expr {[string match killed* $tests] || [string match killed* $fuzz]
            || [string match killed* $rust] ? "KILLED" : "SURVIVED"}]
        lappend results [list $name $description $verdict $tests $fuzz $rust]
        puts "$verdict $name -- $description\n    tests: $tests\n    fuzz:  $fuzz"
        if {$native} {
            puts "    rust:  $rust"
        }
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
puts "[llength $results] mutants, $killed killed, [llength $survivors] survived[expr {$survivors eq {} ? "" : ": [join $survivors {, }]"}][expr {$unapplied eq {} ? "" : ", [llength $unapplied] not applied or not built: [join $unapplied {, }]"}]"
exit [expr {$survivors ne {} || $unapplied ne {}}]
