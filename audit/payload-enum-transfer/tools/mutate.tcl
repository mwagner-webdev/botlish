#!/usr/bin/env tclsh9.0
# mutate.tcl -- mutation testing of payload-bearing enum transfer
# (PORTABILITY-PAYLOAD-ENUM-TRANSFER-MILESTONE-1.md, "Mutation testing"),
# adapted from audit/value-transfer/tools/mutate.tcl.
#
#   tclsh9.0 audit/payload-enum-transfer/tools/mutate.tcl ?-only NAME,...?
#                                                  ?-timeout SECONDS?
#                                                  ?-backend interp|compile|all?
#
# Each mutant is a deliberate bug in one rule -- the static judgement
# (hir/types.tcl's SendClass), the schema (hir/transfer.tcl), the Tcl codec
# (core/transfer.tcl), the native plan (native/lower.tcl's TransferPlan) or
# the native codec (native/src/runtime/transfer.rs) -- written in
# mutants.txt (beside this script) as exact source replacements, each
# replaced text occurring exactly once, with `!!` lines naming its
# detectors: tests of tests/payload-enum-transfer.test,
# tests/value-transfer.test or tests/sendability.test (tcltest -match
# patterns), `rust:FILTER` for `cargo test --release --lib FILTER` of the
# native crate, or `fuzz:SEEDS` for this audit's differential fuzzer
# (fuzz.tcl -seeds SEEDS, every backend, against the independent oracle).
# For each mutant a private copy of the compiler, library, tests, tools and
# native backend (a temporary directory) gets the replacements; a mutant
# that edits Rust rebuilds the copy's native backend first (one that does
# not build is NOT-BUILT, never counted as killed). Only the named
# detectors run, so a mutant is KILLED when one of them fails -- a test
# reported FAILED, a Rust test or the fuzzer failing -- and SURVIVED when
# all pass. A test file that does not complete is INCOMPLETE, not a kill:
# a harness failure is no evidence (the brief's section 17). The baseline
# -- every detector unmutated, in the copy -- must pass first. The real
# checkout is never modified.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]

set options [dict create -only "" -timeout 3600 -backend interp]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

set testFiles {tests/payload-enum-transfer.test tests/value-transfer.test tests/sendability.test}

# The mutants of mutants.txt, as {NAME DESCRIPTION {FILE OLD NEW ...}
# DETECTORS ...}.
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
        if {[string match native/src/* $file]} {
            return 1
        }
    }
    return 0
}

set only [split [dict get $options -only] ,]
set selected {}
set anyNative 0
foreach {name description edits detectors} [readMutants [file join [file dirname [file normalize [info script]]] mutants.txt]] {
    if {$only ne {} && $name ni $only} continue
    if {$detectors eq {}} {
        error "mutant $name names no detector (a \"!! TEST ...\" line)"
    }
    if {[isNative $edits]} {
        set anyNative 1
    }
    lappend selected $name $description $edits $detectors
}

# A private copy. Its native/target is a real copy when a Rust mutant is
# selected (it is rebuilt), else a link to this checkout's.
set tree [file tempdir botlish-pet-mutants]
foreach dir {compiler core hir surface service lsp stdlib tests examples compilerpedia tools packages pm audit/payload-enum-transfer .cargo} {
    if {![file exists [file join $root $dir]]} continue
    file mkdir [file dirname [file join $tree $dir]]
    file copy [file join $root $dir] [file join $tree $dir]
}
file mkdir [file join $tree native]
foreach entry [glob -directory [file join $root native] *] {
    if {[file tail $entry] ne "target"} {
        file copy $entry [file join $tree native]
    } elseif {$anyNative} {
        # Copy the directory, following links (AGENTS.md, "Running tests
        # concurrently"): a copied link would build every mutant into
        # another checkout's native/target.
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
set manifest [file join $tree native Cargo.toml]

if {[dict get $options -backend] eq "all"} {
    unset -nocomplain env(CORE_BACKEND)
} else {
    set env(CORE_BACKEND) [dict get $options -backend]
}
set env(LANG) C.utf8
set env(LC_ALL) C.utf8

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

# {FAILED INCOMPLETE}: the Tcl DETECTORS (tcltest -match patterns: a loop's
# generated names may be globbed) run in the copy; INCOMPLETE says why a
# file did not complete, or that no detector ran at all.
proc runDetectors {tree detectors} {
    global options testFiles
    set match [lmap d $detectors {if {[string match rust:* $d] || [string match fuzz:* $d]} continue; set d}]
    if {$match eq {}} {
        return {{} {}}
    }
    set failed {}
    set incomplete ""
    set ran 0
    foreach testFile $testFiles {
        set tmp [file tempdir botlish-pet-mutant-run]
        lassign [run [dict get $options -timeout] tclsh9.0 [file join $tree $testFile] -tmpdir $tmp -match $match] status output
        file delete -force $tmp
        lappend failed {*}[lmap {- n} [regexp -all -inline -line {^==== (\S+) .*FAILED$} $output] {set n}]
        if {[regexp {Total\s+(\d+)\s+Passed\s+(\d+)\s+Skipped\s+(\d+)\s+Failed\s+(\d+)} $output -> total passed skipped fails]} {
            incr ran [expr {$passed + $fails}]
        } elseif {$incomplete eq ""} {
            set incomplete "[file tail $testFile]: [lastLine $output]"
        }
    }
    if {$incomplete eq "" && $ran == 0} {
        set incomplete "no detector ran ($match)"
    }
    return [list [lsort -unique $failed] $incomplete]
}

# The fuzz detectors of DETECTORS, run in the copy: the failures, each
# "fuzz:SEEDS (WHY)".
proc runFuzz {tree detectors} {
    global options
    set failed {}
    foreach d $detectors {
        if {![string match fuzz:* $d]} continue
        set seeds [string range $d 5 end]
        lassign [run [dict get $options -timeout] tclsh9.0 [file join $tree audit payload-enum-transfer tools fuzz.tcl] -seeds $seeds -cases 6 -mutations 8] status output
        if {$status != 0} {
            set why [lindex [regexp -inline -line {^DISAGREE .*$} $output] 0]
            if {$why eq ""} {
                set why [lastLine $output]
            }
            lappend failed "$d ([string range $why 0 160])"
        }
    }
    return $failed
}

# The baseline: every detector passes unmutated in the copy.
set all {}
foreach {name description edits detectors} $selected {
    lappend all {*}$detectors
}
set all [lsort -unique $all]
lassign [runDetectors $tree $all] failed incomplete
lappend failed {*}[runFuzz $tree $all]
if {$failed ne {} || $incomplete ne ""} {
    file delete -force $tree
    puts "BASELINE FAILS: [join $failed {, }] $incomplete"
    exit 2
}
set rustFilters [lsort -unique [lmap d $all {if {[string match rust:* $d]} {string range $d 5 end} else continue}]]
if {$rustFilters ne {}} {
    set here [pwd]
    cd $tree
    foreach filter $rustFilters {
        lassign [run [dict get $options -timeout] cargo test --release --manifest-path $manifest --lib $filter] status output
        if {$status != 0} {
            cd $here
            file delete -force $tree
            puts "BASELINE FAILS: cargo test --lib $filter: [lastLine $output]"
            exit 2
        }
    }
    cd $here
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
        if {!$applied} {
            lappend results [list $name $description NOT-APPLIED ""]
            puts "NOT-APPLIED $name: the text to replace does not occur exactly once in $file"
            dict for {file text} $touched {
                writeFile [file join $tree $file] $text
            }
            continue
        }
        set native [isNative $edits]
        set rustKilled {}
        if {$native} {
            set here [pwd]
            cd $tree
            lassign [run [dict get $options -timeout] cargo build --release --manifest-path $manifest] status output
            if {$status != 0} {
                cd $here
                lappend results [list $name $description NOT-BUILT [lastLine $output]]
                puts "NOT-BUILT $name: [lastLine $output]"
                dict for {file text} $touched {
                    writeFile [file join $tree $file] $text
                }
                continue
            }
            foreach d $detectors {
                if {![string match rust:* $d]} continue
                lassign [run [dict get $options -timeout] cargo test --release --manifest-path $manifest --lib [string range $d 5 end]] status output
                if {$status != 0} {
                    set failing [lmap {- n} [regexp -all -inline -line {^test (\S+) \.\.\. FAILED$} $output] {set n}]
                    lappend rustKilled "$d ([expr {$failing eq {} ? [lastLine $output] : [join $failing {, }]}])"
                }
            }
            cd $here
        }
        lassign [runDetectors $tree $detectors] failed incomplete
        set fuzzKilled [runFuzz $tree $detectors]
        if {$failed ne {} || $rustKilled ne {} || $fuzzKilled ne {}} {
            set verdict KILLED
            set tests [join [concat $failed $rustKilled $fuzzKilled] {, }]
            if {$incomplete ne ""} {
                append tests " (and did not complete: $incomplete)"
            }
        } elseif {$incomplete ne ""} {
            set verdict INCOMPLETE
            set tests "did not complete: $incomplete"
        } else {
            set verdict SURVIVED
            set tests "no detector failed"
        }
        lappend results [list $name $description $verdict $tests]
        puts "$verdict $name -- $description\n    detectors: $tests"
        flush stdout
        dict for {file text} $touched {
            writeFile [file join $tree $file] $text
        }
        if {$native} {
            # The unmutated backend again, for the next mutant.
            set here [pwd]
            cd $tree
            run [dict get $options -timeout] cargo build --release --manifest-path $manifest
            cd $here
        }
    }
} finally {
    file delete -force $tree
}

set failed [lmap r $results {if {[lindex $r 2] eq "KILLED"} continue; lindex $r 0}]
set killed [llength [lsearch -all -index 2 $results KILLED]]
puts "[llength $results] mutants, $killed killed by a named detector[expr {$failed eq {} ? "" : ", not killed so: [join $failed {, }]"}]"
exit [expr {$failed ne {}}]
