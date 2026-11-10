# mutate.tcl -- can the tests of
# TEXT-AND-COLLECTION-DOCUMENTATION-AND-DIAGNOSTICS-MILESTONE-1.md fail, and
# for the reason they state?
#
#   tclsh9.0 audit/text-collection-docs/tools/mutate.tcl ?-only NAME,...? ?-timeout SECONDS?
#
# Each mutant of mutants.txt beside this script (the format is its header's)
# is applied to a private copy of the compiler, library, tests and main.tcl (a
# temporary directory; native/target a link to this checkout's), and each
# test file its `%%` line names (default
# tests/text-collection-docs-diagnostics.test)
# runs against it, with a private -tmpdir and -match the patterns of its `!!`
# line. A mutant is killed only when a test its `!!` line names fails: a
# mutant that breaks a file, or only other tests, is reported as not killed
# for its reason. The real checkout is never modified.
#
# Output: one line per mutant -- the expected tests that killed it, or
# SURVIVED, NOT FOR ITS REASON (the tests that did fail), or that its text
# does not apply exactly once. Exits 1 unless every mutant applies and is
# killed by an expected test.

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set options [dict create -only "" -timeout 1800]
foreach {option value} $argv {
    if {![dict exists $options $option]} { error "unknown option $option" }
    dict set options $option $value
}

# The mutants of PATH: {NAME DESCRIPTION EXPECTED FILES {FILE OLD NEW ...} ...}.
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
                    if {$name ne ""} { lappend mutants $name $description $expected $files $edits }
                    set name $n
                    set description $d
                    set expected {}
                    set files {tests/text-collection-docs-diagnostics.test}
                    set edits {}
                } elseif {[regexp {^!! (.*)$} $line -> tests]} {
                    set expected $tests
                } elseif {[regexp {^%% (.*)$} $line -> testFiles]} {
                    set files $testFiles
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
    if {$name ne ""} { lappend mutants $name $description $expected $files $edits }
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

# 1 if test NAME matches one of PATTERNS.
proc expectedTest {name patterns} {
    foreach p $patterns {
        if {[string match $p $name]} {
            return 1
        }
    }
    return 0
}

set only [split [dict get $options -only] ,]
set selected {}
foreach {name description expected files edits} [readMutants [file join [file dirname [file normalize [info script]]] mutants.txt]] {
    if {$only ne {} && $name ni $only} continue
    if {$expected eq {}} {
        error "mutant $name names no test that must kill it (!!)"
    }
    lappend selected $name $description $expected $files $edits
}

set tree [file tempdir botlish-text-collection-docs-mutants]
foreach dir {compiler core hir surface stdlib service lsp compilerpedia tests docs audit/static-decisions audit/text-collection-docs .cargo} {
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
set env(LANG) C.utf8
set env(LC_ALL) C.utf8
try {
    foreach {name description expected files edits} $selected {
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
            puts "[format %-32s $name] does not apply exactly once"
            incr failures
        } else {
            set failed {}
            set broken {}
            foreach testFile $files {
                set tmp [file join $tree tcltest-tmp]
                file delete -force $tmp
                file mkdir $tmp
                lassign [run $timeout $tclsh [file join $tree $testFile] -tmpdir $tmp -match $expected] code output
                lappend failed {*}[lmap {- t} [regexp -all -inline -line {^==== (\S+) FAILED$} $output] {set t}]
                if {$code != 0 || ![regexp {Total\t[0-9]+\tPassed} $output]} {
                    lappend broken "[file tail $testFile] exit $code"
                }
            }
            set failed [lsort -unique $failed]
            set killers [lmap t $failed {if {![expectedTest $t $expected]} continue; set t}]
            if {$killers ne {}} {
                set status "killed by [join $killers {, }]"
            } elseif {$failed ne {} || $broken ne {}} {
                set status "NOT FOR ITS REASON (failed: [join $failed {, }]; [join $broken {, }])"
                incr failures
            } else {
                set status SURVIVED
                incr failures
            }
            puts "[format %-32s $name] $status"
        }
        dict for {path text} $saved {
            writeFile $path $text
        }
    }
} finally {
    file delete -force $tree
}
exit [expr {$failures > 0}]
