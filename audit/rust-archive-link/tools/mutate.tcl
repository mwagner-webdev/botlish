# mutate.tcl -- can the tests of HTTP-MACOS-RUST-ARCHIVE-LINK-FEASIBILITY-
# MILESTONE-1.md fail, and for the reason they state?
#
#   tclsh9.0 audit/rust-archive-link/tools/mutate.tcl ?-only NAME,...? ?-timeout SECONDS?
#
# Each mutant of mutants.txt beside this script (the format is its header's)
# that applies to this host is applied to a private copy of the compiler,
# the package manager, the tools, the fixture, the tests and main.tcl (a
# temporary directory; native/target a link to this checkout's), and the
# test files its `%%` line names (tests/rust-archive-link.test by default)
# run against it, each with a private -tmpdir; the fixture's cargo builds go
# to a private cache shared by the run's mutants (no mutant edits the unit's
# Rust). A mutant is killed only when one of the tests its `!!` line names
# fails: a mutant that breaks the file, or only other tests, is reported as
# not killed for its reason. The real checkout is never modified.
#
# Output: one line per mutant -- the expected tests that killed it,
# SURVIVED, NOT FOR ITS REASON (the tests that did fail), not for this host,
# or that its text does not apply exactly once. Exits 1 unless every mutant
# for this host applies and is killed by an expected test.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -only "" -timeout 1800]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

# The mutants of PATH: {NAME DESCRIPTION EXPECTED FILES HOST {FILE OLD NEW ...} ...}.
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
                    if {$name ne ""} { lappend mutants $name $description $expected $files $host $edits }
                    set name $n
                    set description $d
                    set expected {}
                    set files {tests/rust-archive-link.test}
                    set host *
                    set edits {}
                } elseif {[regexp {^!! (.*)$} $line -> tests]} {
                    set expected $tests
                } elseif {[regexp {^%% (.*)$} $line -> testFiles]} {
                    set files $testFiles
                } elseif {[regexp {^\?\? (\S+)$} $line -> h]} {
                    set host $h
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
    if {$name ne ""} { lappend mutants $name $description $expected $files $host $edits }
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
    set prefix [expr {[auto_execok timeout] ne "" ? [list timeout $timeout] : {}}]
    if {[catch {exec {*}$prefix {*}$args 2>@1} output options]} {
        set status [lindex [dict get $options -errorcode] end]
        if {![string is integer -strict $status]} { set status 1 }
    }
    return [list $status $output]
}

proc hostTarget {} {
    set arch [expr {$::tcl_platform(machine) in {arm64 aarch64} ? "aarch64" : "x86_64"}]
    return [expr {$::tcl_platform(os) eq "Darwin" ? "macos-$arch" : "linux-$arch"}]
}

set only [split [dict get $options -only] ,]
set selected {}
foreach {name description expected files host edits} [readMutants [file join [file dirname [file normalize [info script]]] mutants.txt]] {
    if {$only ne {} && $name ni $only} continue
    if {$expected eq {}} {
        error "mutant $name names no test that must kill it (!!)"
    }
    lappend selected $name $description $expected $files $host $edits
}

set tree [file tempdir botlish-rust-archive-link-mutants]
foreach dir {compiler core hir surface stdlib service lsp compilerpedia ccompile pm tools tests
        audit/rust-archive-link packages/http/native/src .cargo} {
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
set ::env(BOTLISH_CACHE_DIR) [file join $tree cache]

set failures 0
set timeout [dict get $options -timeout]
set tclsh [info nameofexecutable]
set target [hostTarget]
try {
    foreach {name description expected files host edits} $selected {
        if {![string match $host $target]} {
            # Still applied, so that its text is checked on every host.
            set note " (not for this host, $target: its edit applies)"
        } else {
            set note ""
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
            puts "[format %-22s $name] does not apply exactly once"
            incr failures
        } elseif {$note ne ""} {
            puts "[format %-22s $name] not run$note"
        } else {
            set failed {}
            set broken {}
            foreach testFile $files {
                set tmp [file join $tree tcltest-tmp]
                file delete -force $tmp
                file mkdir $tmp
                lassign [run $timeout $tclsh [file join $tree $testFile] -tmpdir $tmp] code output
                lappend failed {*}[lmap {- t} [regexp -all -inline -line {^==== (\S+) FAILED$} $output] {set t}]
                if {$code != 0 || ![regexp {Total\t[0-9]+\tPassed} $output]} {
                    lappend broken "$testFile exit $code"
                }
            }
            set failed [lsort -unique $failed]
            set killers [lmap t $failed {if {$t ni $expected} continue; set t}]
            if {$killers ne {}} {
                set status "killed by [join $killers {, }]"
            } elseif {$failed ne {} || $broken ne {}} {
                set status "NOT FOR ITS REASON (failed: [join $failed {, }]; [join $broken {, }])"
                incr failures
            } else {
                set status SURVIVED
                incr failures
            }
            puts "[format %-22s $name] $status"
        }
        dict for {path text} $saved {
            writeFile $path $text
        }
    }
} finally {
    file delete -force $tree
}
exit [expr {$failures > 0}]
